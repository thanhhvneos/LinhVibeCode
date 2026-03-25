import SwiftUI

struct ProjectCardView: View {
    let result: AllocationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // ── Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.project.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(result.project.timeline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                StatusBadgeView(status: result.status)
            }

            Divider()

            // ── Stats row
            HStack(spacing: 0) {
                statItem(
                    icon: "person.2.fill",
                    value: "\(result.assignedMembers.count)",
                    label: "Assigned"
                )
                Spacer()
                statItem(
                    icon: "chart.bar.fill",
                    value: String(format: "%.0f%%", result.score * 100),
                    label: "Score"
                )
                Spacer()
                statItem(
                    icon: "exclamationmark.triangle.fill",
                    value: "\(result.risks.count)",
                    label: "Risks"
                )
                Spacer()
                statItem(
                    icon: "clock.fill",
                    value: "\(Int(result.project.estimateEffort))d",
                    label: "Effort"
                )
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    let store = AppDataStore()
    if let result = store.results.first {
        ProjectCardView(result: result)
            .padding()
    }
}
