import Foundation

// MARK: - Skill

struct Skill: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
}

// MARK: - Member

struct Member: Identifiable {
    let id: UUID
    let name: String
    let skills: [Skill]
    let level: Level
    let cost: Double
    var availability: Double // 0 → 1
    let preference: [Skill]
    var currentAllocation: Double // 0 → 1
}

enum Level: String {
    case junior
    case senior
}

// MARK: - Project

struct Project: Identifiable {
    let id: UUID
    let name: String
    let timeline: String
    let estimate: Double
    let requiredRoles: [RequiredRole]
}

// MARK: - Required Role

struct RequiredRole: Identifiable {
    let id: UUID = UUID()
    let skill: Skill
    let quantity: Int
}

// MARK: - Allocation Result

struct AllocationResult {
    let project: Project
    let assignedMembers: [AssignedMember]
    let score: Double
    let risks: [Risk]
}

// MARK: - Assigned Member

struct AssignedMember: Identifiable {
    let id: UUID = UUID()
    let member: Member
    let role: Skill
    let allocation: Double
    let score: Double
}

// MARK: - Risk

enum Risk: Identifiable {
    var id: String { description }

    case missingSkill(String)
    case overload(String)
    case skillGap(String)
    case dependency(String)

    var description: String {
        switch self {
        case .missingSkill(let s): return "Missing skill: \(s)"
        case .overload(let s): return "Overload: \(s)"
        case .skillGap(let s): return "Skill gap: \(s)"
        case .dependency(let s): return "Dependency: \(s)"
        }
    }
}