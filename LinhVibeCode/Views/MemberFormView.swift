import SwiftUI

struct MemberFormView: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    typealias Mode = MemberFormViewModel.Mode

    @StateObject private var vm: MemberFormViewModel

    init(mode: Mode) {
        _vm = StateObject(wrappedValue: MemberFormViewModel(mode: mode))
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                skillsSection
                preferredSkillsSection
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

    // MARK: - Form sections

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Full name", text: $vm.name)
            if let error = vm.nameError {
                fieldError(error)
            }

            Picker("Level", selection: $vm.level) {
                ForEach(Level.allCases, id: \.self) { l in
                    Text(l.rawValue).tag(l)
                }
            }

            HStack {
                Text("Cost ($/hr)")
                Spacer()
                TextField("e.g. 45", text: $vm.costText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            if let error = vm.costError {
                fieldError(error)
            }

            HStack {
                Text("Current Allocation")
                Spacer()
                TextField("0.0 – 1.0", text: $vm.allocationText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            if let error = vm.allocationError {
                fieldError(error)
            }
        }
    }

    private var skillsSection: some View {
        Section("Skills") {
            ForEach(Skill.all) { skill in
                Toggle(skill.name, isOn: Binding(
                    get: { vm.selectedSkillIDs.contains(skill.id) },
                    set: { vm.toggleSkill(skill.id, on: $0) }
                ))
            }
        }
    }

    @ViewBuilder
    private var preferredSkillsSection: some View {
        if !vm.selectedSkillIDs.isEmpty {
            Section("Preferred Skills") {
                ForEach(Skill.all.filter { vm.selectedSkillIDs.contains($0.id) }) { skill in
                    Toggle(skill.name, isOn: Binding(
                        get: { vm.preferenceSkillIDs.contains(skill.id) },
                        set: { vm.togglePreference(skill.id, on: $0) }
                    ))
                }
            }
        }
    }

    private func fieldError(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.red)
    }

    // MARK: - Action

    private func save() {
        if vm.save(to: store) {
            dismiss()
        }
    }
}

#Preview {
    MemberFormView(mode: .add)
        .environmentObject(AppDataStore())
}
