import SwiftUI

/// Phase 4 will fill this screen in full.
struct ProjectDetailView: View {
    @EnvironmentObject var store: AppDataStore
    let project: Project

    var body: some View {
        Text("Detail coming in Phase 4")
            .foregroundStyle(.secondary)
            .navigationTitle(project.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: Project.mockProjects[0])
            .environmentObject(AppDataStore())
    }
}
