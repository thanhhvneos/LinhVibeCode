import SwiftUI

struct StatusBadgeView: View {
    let status: ProjectStatus

    var body: some View {
        Label(status.label, systemImage: status.systemIcon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.12), in: Capsule())
    }
}

extension ProjectStatus {
    var color: Color {
        switch self {
        case .ok:       return .green
        case .risk:     return .orange
        case .critical: return .red
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        StatusBadgeView(status: .ok)
        StatusBadgeView(status: .risk)
        StatusBadgeView(status: .critical)
    }
    .padding()
}
