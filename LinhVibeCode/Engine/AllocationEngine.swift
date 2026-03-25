import Foundation

final class AllocationEngine {

    // MARK: - Scoring
    // Weights: skill match 40%, availability 30%, cost efficiency 20%, preference 10%
    // costScore is normalized against the most expensive member so the factor is effective.

    func calculateScore(member: Member, role: RequiredRole, allMembers: [Member], usedMembers: Set<UUID>) -> Double {
        let skillMatch  = member.skills.contains(role.skill) ? 1.0 : 0.0
        let availability = member.availability
        let maxCost     = allMembers.map { $0.cost }.max() ?? 1
        let costScore   = 1.0 - (member.cost / maxCost)   // 0 = most expensive, 1 = cheapest
        let preference  = member.preference.contains(role.skill) ? 1.0 : 0.5
        let reusePenalty = usedMembers.contains(member.id) ? 0.5 : 1.0

        let base = (0.4 * skillMatch)
                 + (0.3 * availability)
                 + (0.2 * costScore)
                 + (0.1 * preference)

        return base * reusePenalty
    }

    // MARK: - Allocation

    func allocate(project: Project, members: [Member]) -> AllocationResult {
        var assigned: [AssignedMember] = []
        var risks: [Risk] = []
        var riskSet: Set<String> = []           // deduplicate risks
        var pendingAllocation: [UUID: Double] = [:]
        var usedMembers: Set<UUID> = []

        func addRisk(_ risk: Risk) {
            if riskSet.insert(risk.id).inserted {
                risks.append(risk)
            }
        }

        for role in project.requiredRoles {
            let slot = 1.0 / Double(role.quantity)

            // ── Prefer members who actually have the required skill
            let available = members.filter { $0.availability > 0 }
            let primary   = available.filter {  $0.skills.contains(role.skill) }
            let fallback  = available.filter { !$0.skills.contains(role.skill) }
            let pool      = primary.isEmpty ? fallback : primary

            let candidates = pool
                .map { ($0, calculateScore(member: $0, role: role, allMembers: members, usedMembers: usedMembers)) }
                .sorted { $0.1 > $1.1 }

            let selected = candidates.prefix(role.quantity)

            // ── Risk: not enough available members
            if selected.count < role.quantity {
                addRisk(.missingSkill(role.skill.name))
            }

            for (member, score) in selected {
                let skillMatch = member.skills.contains(role.skill)

                // ── Explainable reason string
                let reason = "Skill match: \(skillMatch ? "Yes" : "No"), Availability: \(Int(member.availability * 100))%, Cost: $\(Int(member.cost))/hr"

                assigned.append(AssignedMember(
                    member: member,
                    role: role.skill,
                    allocation: slot,
                    score: score,
                    reason: reason
                ))

                // ── Risk: fallback selection — member lacks the required skill
                if !skillMatch {
                    addRisk(.skillGap("\(member.name) → \(role.skill.name)"))
                }

                // ── Risk: cumulative allocation exceeds 100%
                let pending = pendingAllocation[member.id, default: 0]
                if member.currentAllocation + pending + slot > 1.0 {
                    addRisk(.overload(member.name))
                }

                pendingAllocation[member.id, default: 0] += slot
                usedMembers.insert(member.id)
            }
        }

        // ── Risk: key dependency — same member covers multiple roles
        let grouped = Dictionary(grouping: assigned, by: { $0.member.id })
        for (_, slots) in grouped where slots.count > 1 {
            addRisk(.keyDependency(slots[0].member.name))
        }

        let avgScore = assigned.isEmpty ? 0 : assigned.map { $0.score }.reduce(0, +) / Double(assigned.count)

        return AllocationResult(
            project: project,
            assignedMembers: assigned,
            score: avgScore,
            risks: risks
        )
    }
}

