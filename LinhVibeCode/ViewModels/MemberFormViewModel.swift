import Foundation

/// Owns all non-UI logic for the Add / Edit member form.
/// The View binds to @Published properties and calls actions — zero business logic in the View.
final class MemberFormViewModel: ObservableObject {

    enum Mode {
        case add
        case edit(Member)
    }

    // MARK: - Draft fields

    @Published var name: String = ""
    @Published var level: Level = .junior
    @Published var costText: String = ""
    @Published var allocationText: String = ""
    @Published var selectedSkillIDs: Set<UUID> = []
    @Published var preferenceSkillIDs: Set<UUID> = []

    // MARK: - Field-level validation errors

    @Published var nameError: String? = nil
    @Published var costError: String? = nil
    @Published var allocationError: String? = nil

    let mode: Mode

    var title: String {
        if case .add = mode { return "Add Member" }
        return "Edit Member"
    }

    // MARK: - Init

    init(mode: Mode) {
        self.mode = mode
        if case .edit(let m) = mode {
            name               = m.name
            level              = m.level
            costText           = String(m.cost)
            allocationText     = String(m.currentAllocation)
            selectedSkillIDs   = Set(m.skills.map(\.id))
            preferenceSkillIDs = Set(m.preference.map(\.id))
        }
    }

    // MARK: - Skill helpers

    func toggleSkill(_ id: UUID, on: Bool) {
        if on { selectedSkillIDs.insert(id) }
        else  { selectedSkillIDs.remove(id); preferenceSkillIDs.remove(id) }
    }

    func togglePreference(_ id: UUID, on: Bool) {
        if on { preferenceSkillIDs.insert(id) }
        else  { preferenceSkillIDs.remove(id) }
    }

    // MARK: - Validation

    private func validateName() {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty
            ? "Name is required." : nil
    }

    private func validateCost() {
        if let v = Double(costText), v > 0 { costError = nil }
        else { costError = "Enter a positive number." }
    }

    private func validateAllocation() {
        if let v = Double(allocationText), v >= 0, v <= 1 { allocationError = nil }
        else { allocationError = "Must be between 0.0 and 1.0." }
    }

    /// Validates all fields, sets per-field error messages, returns true when all pass.
    func validateAll() -> Bool {
        validateName()
        validateCost()
        validateAllocation()
        return nameError == nil && costError == nil && allocationError == nil
    }

    // MARK: - Build & Save

    /// Parses draft state into a Member model. Preserves original UUID on edit.
    private func buildMember() -> Member? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              let cost  = Double(costText),  cost >= 0,
              let alloc = Double(allocationText), alloc >= 0, alloc <= 1
        else { return nil }

        let skills = Skill.all.filter { selectedSkillIDs.contains($0.id) }
        let prefs  = Skill.all.filter { preferenceSkillIDs.contains($0.id) }

        // Preserve UUID identity on update — never generate a new one here
        let id: UUID = { if case .edit(let o) = mode { return o.id }; return UUID() }()

        return Member(
            id: id,
            name: trimmed,
            skills: skills,
            level: level,
            cost: cost,
            preference: prefs,
            currentAllocation: alloc
        )
    }

    /// Validates, builds the member, and commits to the store. Returns true on success.
    @discardableResult
    func save(to store: AppDataStore) -> Bool {
        guard validateAll(), let member = buildMember() else { return false }
        switch mode {
        case .add:        store.addMember(member)
        case .edit:       store.updateMember(member)
        }
        return true
    }
}
