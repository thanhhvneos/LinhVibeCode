import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject var store: AppDataStore
    let project: Project

    private var result: AllocationResult? { store.result(for: project) }

    var body: some View {
        List {
            // ── 1. Overview
            overviewSection

            // ── 2. Required roles
            Section("Required Roles") {
                ForEach(project.requiredRoles) { role in
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .foregroundStyle(.blue)
                        Text(role.skill.name)
                        Spacer()
                        Text("×\(role.quantity)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // ── 3. Assigned team
            if let result, !result.assignedMembers.isEmpty {
                let bestID = result.assignedMembers.max(by: { $0.score < $1.score })?.id
                Section("Assigned Team") {
                    ForEach(result.assignedMembers) { assigned in
                        AssignedMemberRowView(assigned: assigned, isBest: assigned.id == bestID)
                    }
                }
            }

            // ── 4. Score
            if let result {
                Section("Score") {
                    ScoreGaugeView(score: result.score)
                }
            }

            // ── 5. Risks
            if let result, !result.risks.isEmpty {
                Section("Risks") {
                    ForEach(result.risks) { risk in
                        RiskRowView(risk: risk)
                    }
                }
            }

            // ── 6. AI Explain section
            if let result, !result.assignedMembers.isEmpty {
                Section("Why These Members?") {
                    ForEach(result.assignedMembers) { assigned in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(assigned.member.name)
                                .font(.subheadline.weight(.semibold))
                            Text(assigned.reason.isEmpty ? "No explanation available." : assigned.reason)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SimulationView(project: project)
                } label: {
                    Label("Simulate", systemImage: "slider.horizontal.3")
                }
            }
        }
    }

    // MARK: - Overview section

    private var overviewSection: some View {
        Section {
            LabeledContent("Timeline", value: project.timeline)
            LabeledContent("Effort", value: "\(Int(project.estimateEffort)) person-days")
            if let result {
                HStack {
                    Text("Status")
                    Spacer()
                    StatusBadgeView(status: result.status)
                }
            }
        }
    }
}

// MARK: - AssignedMemberRowView

private struct AssignedMemberRowView: View {
    let assigned: AssignedMember
    let isBest: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Avatar circle — gold ring + crown for best member
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(isBest ? Color.yellow.opacity(0.2) : Color.accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .strokeBorder(isBest ? Color.yellow : Color.clear, lineWidth: 2)
                    )
                Text(String(assigned.member.name.prefix(1)))
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(isBest ? .orange : .accentColor)
                    .frame(width: 36, height: 36)
                if isBest {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.yellow)
                        .offset(x: 4, y: -4)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(assigned.member.name)
                    .font(.subheadline.weight(.medium))
                Text("\(assigned.role.name)  •  \(assigned.member.level.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f%%", assigned.score * 100))
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                Text(String(format: "Alloc %.0f%%", assigned.allocation * 100))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - ScoreGaugeView

private struct ScoreGaugeView: View {
    let score: Double  // 0…1
    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Match Score")
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.0f / 100", animatedScore * 100))
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(scoreColor)
                    .contentTransition(.numericText())
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.15))
                        .frame(height: 8)
                    Capsule().fill(scoreColor)
                        .frame(width: geo.size.width * min(animatedScore, 1), height: 8)
                        .animation(.easeOut(duration: 0.8), value: animatedScore)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedScore = score
            }
        }
    }

    private var scoreColor: Color {
        switch score {
        case ..<0.4: return .red
        case ..<0.7: return .orange
        default:     return .green
        }
    }
}

// MARK: - RiskRowView

private struct RiskRowView: View {
    let risk: Risk

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: risk.icon)
                .foregroundStyle(risk.severity.color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(risk.description)
                    .font(.subheadline)
                Text(risk.severity.rawValue)
                    .font(.caption2)
                    .foregroundStyle(risk.severity.color)
            }
        }
        .padding(.vertical, 2)
    }
}

extension RiskSeverity {
    var color: Color {
        switch self {
        case .critical: return .red
        case .high:     return .orange
        case .medium:   return .yellow
        case .low:      return .green
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: Project.mockProjects[0])
            .environmentObject(AppDataStore())
    }
}
