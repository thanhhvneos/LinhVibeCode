import SwiftUI

struct SimulationView: View {
    @EnvironmentObject var store: AppDataStore
    let project: Project

    // ── Local simulation state
    @State private var excludedMemberIDs: Set<UUID> = []
    @State private var roleOverrides: [UUID: Int] = [:]
    @State private var simResult: AllocationResult? = nil

    private var baseline: AllocationResult? { store.result(for: project) }

    var body: some View {
        List {
            membersSection
            rolesSection
            recalculateButton

            if let sim = simResult, let base = baseline {
                diffSection(sim: sim, base: base)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle("Simulation")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Toggle Members

    private var membersSection: some View {
        Section("Toggle Members") {
            ForEach(store.members) { member in
                let excluded = excludedMemberIDs.contains(member.id)
                Button {
                    if excluded {
                        excludedMemberIDs.remove(member.id)
                    } else {
                        excludedMemberIDs.insert(member.id)
                    }
                    simResult = nil
                } label: {
                    HStack {
                        Image(systemName: excluded ? "person.fill.xmark" : "person.fill.checkmark")
                            .foregroundColor(excluded ? .red : .green)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(member.name)
                                .font(.subheadline)
                                .foregroundColor(excluded ? .secondary : .primary)
                            Text("\(member.level.rawValue)  •  \(member.skills.map(\.name).joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if excluded {
                            Text("OFF")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.red)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Adjust Role Quantities

    private var rolesSection: some View {
        Section("Adjust Requirements") {
            ForEach(project.requiredRoles) { role in
                let current = roleOverrides[role.id] ?? role.quantity
                HStack {
                    Text(role.skill.name)
                        .font(.subheadline)
                    Spacer()
                    // Stepper: min 1, max 10
                    HStack(spacing: 4) {
                        Button {
                            let newVal = max(1, current - 1)
                            roleOverrides[role.id] = newVal
                            simResult = nil
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(current <= 1 ? .secondary : .accentColor)
                        .disabled(current <= 1)

                        Text("×\(current)")
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                            .frame(minWidth: 28)

                        Button {
                            let newVal = min(10, current + 1)
                            roleOverrides[role.id] = newVal
                            simResult = nil
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }

    // MARK: - Recalculate Button

    private var recalculateButton: some View {
        Section {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    simResult = store.simulate(
                        project: project,
                        excludedMemberIDs: excludedMemberIDs,
                        roleOverrides: roleOverrides
                    )
                }
            } label: {
                HStack {
                    Spacer()
                    Label("Recalculate", systemImage: "arrow.clockwise.circle.fill")
                        .font(.headline)
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .listRowBackground(Color.accentColor)
        }
    }

    // MARK: - Diff Result

    private func diffSection(sim: AllocationResult, base: AllocationResult) -> some View {
        let scoreDelta = sim.score - base.score
        let assignedDelta = sim.assignedMembers.count - base.assignedMembers.count
        let riskDelta = sim.risks.count - base.risks.count

        return Group {
            Section("Simulation Result") {
                diffRow(
                    label: "Score",
                    before: String(format: "%.0f%%", base.score * 100),
                    after: String(format: "%.0f%%", sim.score * 100),
                    delta: scoreDelta,
                    higherIsBetter: true
                )
                diffRow(
                    label: "Assigned",
                    before: "\(base.assignedMembers.count)",
                    after: "\(sim.assignedMembers.count)",
                    delta: Double(assignedDelta),
                    higherIsBetter: true
                )
                diffRow(
                    label: "Risks",
                    before: "\(base.risks.count)",
                    after: "\(sim.risks.count)",
                    delta: Double(riskDelta),
                    higherIsBetter: false
                )
                HStack {
                    Text("Status")
                    Spacer()
                    StatusBadgeView(status: sim.status)
                }
            }

            if !sim.assignedMembers.isEmpty {
                Section("New Team") {
                    ForEach(sim.assignedMembers) { assigned in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.blue)
                            Text(assigned.member.name)
                                .font(.subheadline)
                            Spacer()
                            Text(assigned.role.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f%%", assigned.score * 100))
                                .font(.caption.monospacedDigit().weight(.semibold))
                        }
                    }
                }
            }

            if !sim.risks.isEmpty {
                Section("New Risks") {
                    ForEach(sim.risks) { risk in
                        HStack(spacing: 8) {
                            Image(systemName: risk.icon)
                                .foregroundColor(risk.severity.color)
                            Text(risk.description)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }

    private func diffRow(label: String, before: String, after: String, delta: Double, higherIsBetter: Bool) -> some View {
        let improved = higherIsBetter ? delta > 0 : delta < 0
        let worsened = higherIsBetter ? delta < 0 : delta > 0
        let arrowColor: Color = improved ? .green : worsened ? .red : .secondary
        let arrow: String = delta > 0 ? "arrow.up" : delta < 0 ? "arrow.down" : "minus"

        return HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(before)
                .font(.subheadline.monospacedDigit())
                .foregroundColor(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(after)
                .font(.subheadline.monospacedDigit().weight(.semibold))
            Image(systemName: arrow)
                .font(.caption.weight(.bold))
                .foregroundColor(arrowColor)
        }
    }
}

#Preview {
    NavigationStack {
        SimulationView(project: Project.mockProjects[0])
            .environmentObject(AppDataStore())
    }
}
