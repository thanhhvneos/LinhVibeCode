import Foundation

// MARK: - Skill

struct Skill: Identifiable, Hashable, Codable, Equatable {
    let id: UUID
    let name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }

    static func == (lhs: Skill, rhs: Skill) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Level

enum Level: String, Codable, CaseIterable {
    case junior = "Junior"
    case senior = "Senior"
}

// MARK: - Member

struct Member: Identifiable, Codable {
    let id: UUID
    let name: String
    let skills: [Skill]
    let level: Level
    let cost: Double            // hourly rate (USD)
    let preference: [Skill]
    var currentAllocation: Double // 0.0 → 1.0 (fraction currently used)

    var availability: Double {
        max(0, 1 - currentAllocation)
    }

    var seniorityScore: Double {
        switch level {
        case .junior: return 0.5
        case .senior: return 1.0
        }
    }

    // Custom init retains `availability` label for source compatibility with existing callers.
    // The value is intentionally ignored; availability is derived from currentAllocation.
    init(id: UUID = UUID(), name: String, skills: [Skill], level: Level, cost: Double,
         availability: Double = 0, preference: [Skill], currentAllocation: Double) {
        self.id = id
        self.name = name
        self.skills = skills
        self.level = level
        self.cost = cost
        self.preference = preference
        self.currentAllocation = currentAllocation
    }
}

// MARK: - Project

struct Project: Identifiable, Codable {
    let id: UUID
    let name: String
    let timeline: String
    let estimateEffort: Double   // person-days
    let requiredRoles: [RequiredRole]
}

// MARK: - RequiredRole

struct RequiredRole: Identifiable, Codable {
    let id: UUID
    let skill: Skill
    let quantity: Int

    init(id: UUID = UUID(), skill: Skill, quantity: Int) {
        self.id = id
        self.skill = skill
        self.quantity = quantity
    }
}

// MARK: - AssignedMember

struct AssignedMember: Identifiable, Codable {
    let id: UUID
    let member: Member
    let role: Skill
    let allocation: Double  // 0.0 → 1.0
    let score: Double       // matching score
    let reason: String      // human-readable explanation of why this member was selected

    init(id: UUID = UUID(), member: Member, role: Skill, allocation: Double, score: Double, reason: String = "") {
        self.id = id
        self.member = member
        self.role = role
        self.allocation = allocation
        self.score = score
        self.reason = reason
    }
}

// MARK: - AllocationResult

struct AllocationResult: Identifiable, Codable {
    let id: UUID
    let project: Project
    let assignedMembers: [AssignedMember]
    let score: Double
    let risks: [Risk]

    init(id: UUID = UUID(), project: Project, assignedMembers: [AssignedMember], score: Double, risks: [Risk]) {
        self.id = id
        self.project = project
        self.assignedMembers = assignedMembers
        self.score = score
        self.risks = risks
    }

    var status: ProjectStatus {
        let hasCritical = risks.contains { $0.severity == .critical }
        let hasHigh = risks.contains { $0.severity == .high }
        if hasCritical { return .critical }
        if hasHigh { return .risk }
        return .ok
    }
}

// MARK: - Risk

enum Risk: Identifiable, Codable {
    var id: String { description }

    case missingSkill(String)
    case overload(String)
    case skillGap(String)
    case keyDependency(String)

    var description: String {
        switch self {
        case .missingSkill(let s):  return "Missing skill: \(s)"
        case .overload(let s):      return "Overload: \(s)"
        case .skillGap(let s):      return "Skill gap: \(s)"
        case .keyDependency(let s): return "Key dependency: \(s)"
        }
    }

    var icon: String {
        switch self {
        case .missingSkill:  return "person.fill.xmark"
        case .overload:      return "exclamationmark.circle.fill"
        case .skillGap:      return "chart.bar.xaxis"
        case .keyDependency: return "link"
        }
    }

    var severity: RiskSeverity {
        switch self {
        case .missingSkill:  return .critical
        case .overload:      return .high
        case .skillGap:      return .medium
        case .keyDependency: return .medium
        }
    }

    // MARK: Codable
    private enum CodingKeys: String, CodingKey { case type, value }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type  = try c.decode(String.self, forKey: .type)
        let value = try c.decode(String.self, forKey: .value)
        switch type {
        case "missingSkill":  self = .missingSkill(value)
        case "overload":      self = .overload(value)
        case "skillGap":      self = .skillGap(value)
        case "keyDependency": self = .keyDependency(value)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: c,
                debugDescription: "Unknown Risk type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .missingSkill(let s):  try c.encode("missingSkill",  forKey: .type); try c.encode(s, forKey: .value)
        case .overload(let s):      try c.encode("overload",      forKey: .type); try c.encode(s, forKey: .value)
        case .skillGap(let s):      try c.encode("skillGap",      forKey: .type); try c.encode(s, forKey: .value)
        case .keyDependency(let s): try c.encode("keyDependency", forKey: .type); try c.encode(s, forKey: .value)
        }
    }
}

// MARK: - RiskSeverity

enum RiskSeverity: String, Comparable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    private var sortOrder: Int {
        switch self {
        case .critical: return 3
        case .high:     return 2
        case .medium:   return 1
        case .low:      return 0
        }
    }

    static func < (lhs: RiskSeverity, rhs: RiskSeverity) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - ProjectStatus

enum ProjectStatus {
    case ok
    case risk
    case critical

    var label: String {
        switch self {
        case .ok:       return "OK"
        case .risk:     return "Risk"
        case .critical: return "Critical"
        }
    }

    var colorName: String {
        switch self {
        case .ok:       return "statusGreen"
        case .risk:     return "statusOrange"
        case .critical: return "statusRed"
        }
    }

    var systemIcon: String {
        switch self {
        case .ok:       return "checkmark.circle.fill"
        case .risk:     return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }
}
