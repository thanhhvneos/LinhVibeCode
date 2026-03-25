import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var appeared = false

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
            }
            .navigationTitle("Projects")
            .onAppear {
                if !appeared {
                    appeared = true
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppDataStore())
}
