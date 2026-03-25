import Foundation

final class AllocationEngine {

    func allocate(project: Project, members: [Member]) -> AllocationResult {
        // TODO: implement in Phase 2
        return AllocationResult(
            project: project,
            assignedMembers: [],
            score: 0,
            risks: []
        )
    }
}
