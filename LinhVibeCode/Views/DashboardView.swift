import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: AppDataStore

    var body: some View {
        NavigationStack {
            List(store.projects) { project in
                NavigationLink {
                    ProjectDetailView(project: project)
                } label: {
                    ProjectRowView(project: project)
                }
            }
            .navigationTitle("Projects")
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppDataStore())
}
