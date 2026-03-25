import Foundation

final class ProjectFormViewModel: ObservableObject {

    enum Mode {
        case add
        case edit(Project)
    }

    struct RoleDraft: Identifiable {
        var id: UUID = UUID()
        var skill: Skill
        var quantity: Int = 1
    }

    // MARK: - Draft fields

    @Published var name: String = ""
    @Published var timeline: String = ""
    @Published var effortText: String = ""
    @Published var roles: [RoleDraft] = []

    // MARK: - Field-level validation errors

    @Published var nameError: String? = nil
    @Published var timelineError: String? = nil
    @Published var effortError: String? = nil

    let mode: Mode
    let availableSkills: [Skill]

    var title: String {
        if case .add = mode { return "Add Project" }
        return "Edit Project"
    }

    // MARK: - Init

    init(mode: Mode, availableSkills: [Skill] = Skill.all) {
        self.mode = mode
        self.availableSkills = availableSkills
        if case .edit(let p) = mode {
            name       = p.name
            timeline   = p.timeline
            effortText = String(Int(p.estimateEffort))
            roles      = p.requiredRoles.map { RoleDraft(id: $0.id, skill: $0.skill, quantity: $0.quantity) }
        }
    }

    // MARK: - Role helpers

    func addRole() {
        guard let first = availableSkills.first else { return }
        roles.append(RoleDraft(skill: first))
    }

    func removeRoles(at offsets: IndexSet) {
        roles.remove(atOffsets: offsets)
    }

    // MARK: - Build

    /// Validates all fields (setting per-field errors), then returns a Project on success.
    /// Preserves the original UUID when editing.
    func build() -> Project? {
        let trimmedName = FormParsers.nonEmpty(name)
        nameError = trimmedName == nil ? "Project name is required." : nil

        let trimmedTimeline = FormParsers.nonEmpty(timeline)
        timelineError = trimmedTimeline == nil ? "Timeline is required." : nil

        let effort = FormParsers.positiveDouble(effortText)
        effortError = effort == nil ? "Enter a positive number." : nil

        guard let trimmedName, let trimmedTimeline, let effort else { return nil }

        let requiredRoles = roles.map {
            RequiredRole(id: $0.id, skill: $0.skill, quantity: max(1, $0.quantity))
        }
        let id: UUID = { if case .edit(let o) = mode { return o.id }; return UUID() }()

        return Project(id: id, name: trimmedName, timeline: trimmedTimeline,
                       estimateEffort: effort, requiredRoles: requiredRoles)
    }
}
