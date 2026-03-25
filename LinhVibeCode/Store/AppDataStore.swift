import Foundation
import Combine

final class AppDataStore: ObservableObject {
    @Published var members: [Member] = Member.mockMembers
    @Published var projects: [Project] = Project.mockProjects

    private let engine = AllocationEngine()

    /// Pre-computed allocation results for all projects.
    private(set) var results: [AllocationResult] = []

    init() {
        results = projects.map { engine.allocate(project: $0, members: members) }
    }

    func result(for project: Project) -> AllocationResult? {
        results.first { $0.project.id == project.id }
    }

    func status(for project: Project) -> ProjectStatus {
        result(for: project)?.status ?? .ok
    }

    /// Run a what-if simulation without touching stored results.
    /// - Parameters:
    ///   - project: The project to simulate.
    ///   - excludedMemberIDs: Members toggled off by the user.
    ///   - roleOverrides: quantity overrides keyed by RequiredRole.id.
    func simulate(
        project: Project,
        excludedMemberIDs: Set<UUID>,
        roleOverrides: [UUID: Int]
    ) -> AllocationResult {
        let filteredMembers = members.filter { !excludedMemberIDs.contains($0.id) }
        let adjustedRoles = project.requiredRoles.map { role in
            RequiredRole(
                id: role.id,
                skill: role.skill,
                quantity: roleOverrides[role.id] ?? role.quantity
            )
        }
        let simulatedProject = Project(
            id: project.id,
            name: project.name,
            timeline: project.timeline,
            estimateEffort: project.estimateEffort,
            requiredRoles: adjustedRoles
        )
        return engine.allocate(project: simulatedProject, members: filteredMembers)
    }
}
