import Foundation

// MARK: - Skill Constants

extension Skill {
    static let iOS         = Skill(id: UUID(uuidString: "A1000000-0000-0000-0000-000000000001")!, name: "iOS Development")
    static let android     = Skill(id: UUID(uuidString: "A1000000-0000-0000-0000-000000000002")!, name: "Android Development")
    static let backend     = Skill(id: UUID(uuidString: "A1000000-0000-0000-0000-000000000003")!, name: "Backend Development")
    static let frontend    = Skill(id: UUID(uuidString: "A1000000-0000-0000-0000-000000000004")!, name: "Frontend Development")
    static let uiux        = Skill(id: UUID(uuidString: "A1000000-0000-0000-0000-000000000005")!, name: "UI/UX Design")
    static let qa          = Skill(id: UUID(uuidString: "A1000000-0000-0000-0000-000000000006")!, name: "QA Testing")
    static let devops      = Skill(id: UUID(uuidString: "A1000000-0000-0000-0000-000000000007")!, name: "DevOps")
    static let pm          = Skill(id: UUID(uuidString: "A1000000-0000-0000-0000-000000000008")!, name: "Product Management")

    static let all: [Skill] = [.iOS, .android, .backend, .frontend, .uiux, .qa, .devops, .pm]
}

// MARK: - Mock Members

extension Member {
    static let mockMembers: [Member] = [
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000001")!,
            name: "Linh Nguyễn",
            skills: [.iOS, .uiux],
            level: .senior,
            cost: 45,
            availability: 0.8,
            preference: [.iOS],
            currentAllocation: 0.2
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000002")!,
            name: "Minh Trần",
            skills: [.backend, .devops],
            level: .senior,
            cost: 50,
            availability: 0.6,
            preference: [.backend],
            currentAllocation: 0.4
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000003")!,
            name: "Hoa Lê",
            skills: [.iOS],
            level: .junior,
            cost: 20,
            availability: 1.0,
            preference: [.iOS],
            currentAllocation: 0.0
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000004")!,
            name: "Tuấn Phạm",
            skills: [.frontend, .uiux],
            level: .senior,
            cost: 40,
            availability: 0.7,
            preference: [.frontend],
            currentAllocation: 0.3
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000005")!,
            name: "Nam Vũ",
            skills: [.backend],
            level: .junior,
            cost: 18,
            availability: 1.0,
            preference: [.backend],
            currentAllocation: 0.0
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000006")!,
            name: "Mai Đinh",
            skills: [.qa],
            level: .senior,
            cost: 35,
            availability: 0.9,
            preference: [.qa],
            currentAllocation: 0.1
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000007")!,
            name: "Đức Hoàng",
            skills: [.android, .backend],
            level: .senior,
            cost: 42,
            availability: 0.5,
            preference: [.android],
            currentAllocation: 0.5
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000008")!,
            name: "Thu Bùi",
            skills: [.frontend, .qa],
            level: .junior,
            cost: 16,
            availability: 1.0,
            preference: [.qa],
            currentAllocation: 0.0
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000009")!,
            name: "Long Đặng",
            skills: [.devops, .backend],
            level: .senior,
            cost: 48,
            availability: 0.4,
            preference: [.devops],
            currentAllocation: 0.6
        ),
        Member(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000010")!,
            name: "Phương Ngô",
            skills: [.qa],
            level: .junior,
            cost: 15,
            availability: 1.0,
            preference: [.qa],
            currentAllocation: 0.0
        )
    ]
}

// MARK: - Mock Projects

extension Project {
    static let mockProjects: [Project] = [
        Project(
            id: UUID(uuidString: "C1000000-0000-0000-0000-000000000001")!,
            name: "SuperApp – E-commerce & Delivery",
            timeline: "3 months (Apr – Jun 2026)",
            estimateEffort: 180,
            requiredRoles: [
                RequiredRole(skill: .iOS,      quantity: 2),
                RequiredRole(skill: .backend,  quantity: 2),
                RequiredRole(skill: .uiux,     quantity: 1),
                RequiredRole(skill: .qa,       quantity: 1)
            ]
        ),
        Project(
            id: UUID(uuidString: "C1000000-0000-0000-0000-000000000002")!,
            name: "Analytics Dashboard",
            timeline: "2 months (Apr – May 2026)",
            estimateEffort: 90,
            requiredRoles: [
                RequiredRole(skill: .frontend, quantity: 2),
                RequiredRole(skill: .backend,  quantity: 1),
                RequiredRole(skill: .qa,       quantity: 1)
            ]
        ),
        Project(
            id: UUID(uuidString: "C1000000-0000-0000-0000-000000000003")!,
            name: "Payment Gateway Integration",
            timeline: "4 months (Apr – Jul 2026)",
            estimateEffort: 240,
            requiredRoles: [
                RequiredRole(skill: .backend,  quantity: 2),
                RequiredRole(skill: .iOS,      quantity: 1),
                RequiredRole(skill: .android,  quantity: 1),
                RequiredRole(skill: .devops,   quantity: 1),
                RequiredRole(skill: .qa,       quantity: 2)
            ]
        )
    ]
}
