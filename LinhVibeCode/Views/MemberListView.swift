import SwiftUI

struct MemberListView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var showAddSheet = false
    @State private var editingMember: Member? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.members) { member in
                    MemberRowView(member: member)
                        .contentShape(Rectangle())
                        .onTapGesture { editingMember = member }
                }
                .onDelete { offsets in
                    withAnimation { store.deleteMembersAtOffsets(offsets) }
                }
            }
            .navigationTitle("Members")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                MemberFormView(mode: .add)
                    .environmentObject(store)
            }
            // Edit sheet — key'd by member ID so SwiftUI remakes the form correctly
            // when a different member is tapped (avoids stale state bug)
            .sheet(item: $editingMember) { member in
                MemberFormView(mode: .edit(member))
                    .environmentObject(store)
            }
        }
    }
}

// MARK: - MemberRowView

private struct MemberRowView: View {
    let member: Member

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(String(member.name.prefix(1)))
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(member.name)
                        .font(.headline)
                    Text(member.level.rawValue)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(member.level == .senior ? .orange : .blue)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            (member.level == .senior ? Color.orange : Color.blue).opacity(0.12),
                            in: Capsule()
                        )
                }
                Text(member.skills.map(\.name).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(Int(member.cost))/hr")
                    .font(.subheadline.monospacedDigit())
                Text(String(format: "Avail %.0f%%", member.availability * 100))
                    .font(.caption2)
                    .foregroundStyle(member.availability > 0.5 ? .green : .orange)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    MemberListView()
        .environmentObject(AppDataStore())
}
