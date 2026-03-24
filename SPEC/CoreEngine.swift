func calculateScore(member: Member, role: RequiredRole) -> Double {
    let skillMatch = member.skills.contains(role.skill) ? 1.0 : 0.0
    let availability = member.availability
    let costScore = 1.0 / member.cost
    let preference = member.preference.contains(role.skill) ? 1.0 : 0.5

    return (0.4 * skillMatch)
         + (0.3 * availability)
         + (0.2 * costScore)
         + (0.1 * preference)
}

func allocate(project: Project, members: [Member]) -> AllocationResult {
    var assigned: [AssignedMember] = []
    var risks: [Risk] = []

    for role in project.requiredRoles {
        let candidates = members
            .map { ($0, calculateScore(member: $0, role: role)) }
            .sorted { $0.1 > $1.1 }

        let selected = candidates.prefix(role.quantity)

        if selected.count < role.quantity {
            risks.append(.missingSkill(role.skill.name))
        }

        for (member, score) in selected {
            assigned.append(
                AssignedMember(
                    member: member,
                    role: role.skill,
                    allocation: 0.5,
                    score: score
                )
            )

            if member.currentAllocation + 0.5 > 1.0 {
                risks.append(.overload(member.name))
            }
        }
    }

    return AllocationResult(
        project: project,
        assignedMembers: assigned,
        score: assigned.map { $0.score }.reduce(0, +),
        risks: risks
    )
}