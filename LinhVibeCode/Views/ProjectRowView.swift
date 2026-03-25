import SwiftUI

struct ProjectRowView: View {
    @EnvironmentObject var store: AppDataStore
    let project: Project

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.headline)
                Text(project.timeline)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadgeView(status: store.status(for: project))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List(Project.mockProjects) { project in
        ProjectRowView(project: project)
    }
    .environmentObject(AppDataStore())
}
