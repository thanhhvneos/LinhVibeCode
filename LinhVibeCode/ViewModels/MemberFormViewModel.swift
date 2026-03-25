import Foundation

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
    let availableSkills: [Skill]

    var title: String {
        if case .add = mode { return "Add Member" }
        return "Edit Member"
    }

    // MARK: - Init

    init(mode: Mode, availableSkills: [Skill] = Skill.all) {
        self.mode = mode
        self.availableSkills = availableSkills
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

    // MARK: - Build

    /// Validates all fields (setting per-field errors), then returns a Member on success.
    /// Preserves the original UUID when editing.
    func build() -> Member? {
        let trimmed = FormParsers.nonEmpty(name)
        nameError = trimmed == nil ? "Name is required." : nil

        let cost = FormParsers.positiveDouble(costText)
        costError = cost == nil ? "Enter a positive number." : nil

        let alloc = FormParsers.fraction(allocationText)
        allocationError = alloc == nil ? "Must be between 0.0 and 1.0." : nil

        guard let trimmed, let cost, let alloc else { return nil }

        let skills = availableSkills.filter { selectedSkillIDs.contains($0.id) }
        let prefs  = availableSkills.filter { preferenceSkillIDs.contains($0.id) }
        let id: UUID = { if case .edit(let o) = mode { return o.id }; return UUID() }()

        return Member(id: id, name: trimmed, skills: skills, level: level,
                      cost: cost, preference: prefs, currentAllocation: alloc)
    }
}
