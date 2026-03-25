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
}
