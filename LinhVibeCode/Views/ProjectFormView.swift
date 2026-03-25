import SwiftUI

struct ProjectFormView: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    typealias Mode = ProjectFormViewModel.Mode

    @StateObject private var vm: ProjectFormViewModel

    init(mode: Mode) {
        _vm = StateObject(wrappedValue: ProjectFormViewModel(mode: mode))
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                rolesSection
            }
            .navigationTitle(vm.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Sections

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Project name", text: $vm.name)
            if let error = vm.nameError {
                FieldErrorLabel(message: error)
            }

            TextField("Timeline (e.g. Q3 2025)", text: $vm.timeline)
            if let error = vm.timelineError {
                FieldErrorLabel(message: error)
            }

            HStack {
                Text("Effort (person-days)")
                Spacer()
                TextField("e.g. 30", text: $vm.effortText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            if let error = vm.effortError {
                FieldErrorLabel(message: error)
            }
        }
    }

    private var rolesSection: some View {
        Section {
            ForEach($vm.roles) { $role in
                HStack {
                    Picker("", selection: $role.skill) {
                        ForEach(vm.availableSkills) { skill in
                            Text(skill.name).tag(skill)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()

                    Spacer()

                    Stepper(value: $role.quantity, in: 1...10) {
                        Text("×\(role.quantity)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                vm.removeRoles(at: offsets)
            }

            Button {
                withAnimation { vm.addRole() }
            } label: {
                Label("Add Role", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Required Roles")
        } footer: {
            if vm.roles.isEmpty {
                Text("Add at least one required role.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Action

    private func save() {
        guard let project = vm.build() else { return }
        switch vm.mode {
        case .add:  store.addProject(project)
        case .edit: store.updateProject(project)
        }
        dismiss()
    }
}

#Preview {
    ProjectFormView(mode: .add)
        .environmentObject(AppDataStore())
}
