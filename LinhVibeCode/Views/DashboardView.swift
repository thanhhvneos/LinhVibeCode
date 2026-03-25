import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var appeared = false
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(store.projects.enumerated()), id: \.element.id) { index, project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        ProjectRowView(project: project)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(
                        .easeOut(duration: 0.35).delay(Double(index) * 0.07),
                        value: appeared
                    )
                }
                .onDelete { offsets in
                    withAnimation { store.deleteProjectsAtOffsets(offsets) }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                if !appeared { appeared = true }
            }
            .sheet(isPresented: $showAddSheet) {
                ProjectFormView(mode: .add)
                    .environmentObject(store)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppDataStore())
}
