import SwiftUI

/// Shared inline error label used below form fields.
struct FieldErrorLabel: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
    }
}
