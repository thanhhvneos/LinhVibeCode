import Foundation
import Combine

final class AppDataStore: ObservableObject {
    @Published var members: [Member] = Member.mockMembers {
        didSet { recomputeResults() }
    }
    @Published var projects: [Project] = Project.mockProjects {
        didSet { recomputeResults() }
    }

    private let engine = AllocationEngine()

    /// Pre-computed allocation results for all projects.
    @Published private(set) var results: [AllocationResult] = []

    init() {
        recomputeResults()
    }

    // MARK: - Results

    private func recomputeResults() {
        results = projects.map { engine.allocate(project: $0, members: members) }
    }

    func result(for project: Project) -> AllocationResult? {
        results.first { $0.project.id == project.id }
    }

    func status(for project: Project) -> ProjectStatus {
        result(for: project)?.status ?? .ok
    }

    // MARK: - Member CRUD

    func addMember(_ member: Member) {
        members.append(member)
    }

    func updateMember(_ updated: Member) {
        guard let idx = members.firstIndex(where: { $0.id == updated.id }) else { return }
        members[idx] = updated
    }

    func deleteMember(id: UUID) {
        members.removeAll { $0.id == id }
    }

    func deleteMembersAtOffsets(_ offsets: IndexSet) {
        members.remove(atOffsets: offsets)
    }

    // MARK: - Project CRUD

    func addProject(_ project: Project) {
        projects.append(project)
    }

    func updateProject(_ updated: Project) {
        guard let idx = projects.firstIndex(where: { $0.id == updated.id }) else { return }
        projects[idx] = updated
    }

    func deleteProjectsAtOffsets(_ offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
    }

    // MARK: - Simulation

    /// Run a what-if simulation without touching stored results.
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
