import Foundation

/// Centralized parsing helpers for form text fields.
/// Using these avoids repeating inline `Double(text)` guard patterns across ViewModels.
enum FormParsers {
    /// Trims whitespace; returns nil if the result is empty.
    static func nonEmpty(_ text: String) -> String? {
        let t = text.trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? nil : t
    }

    /// Parses a Double that must be strictly positive (> 0).
    static func positiveDouble(_ text: String) -> Double? {
        guard let v = Double(text), v > 0 else { return nil }
        return v
    }

    /// Parses a Double that must be in the closed range [0, 1].
    static func fraction(_ text: String) -> Double? {
        guard let v = Double(text), v >= 0, v <= 1 else { return nil }
        return v
    }
}
