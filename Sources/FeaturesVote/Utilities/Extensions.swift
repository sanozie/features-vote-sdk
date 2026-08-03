import Foundation
import SwiftUI

// MARK: - Color Extensions

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "#FF0000" or "FF0000")
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Convert Color to hex string (includes alpha as #RRGGBBAA when opacity < 1)
    public var hexString: String? {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components else { return nil }
        #elseif canImport(AppKit)
        guard let components = NSColor(self).cgColor.components else { return nil }
        #endif

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = Float(components.count >= 4 ? components[3] : 1.0)

        if a < 1.0 {
            return String(format: "#%02lX%02lX%02lX%02lX",
                         lroundf(r * 255),
                         lroundf(g * 255),
                         lroundf(b * 255),
                         lroundf(a * 255))
        }
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }

    /// Calculate luminance of color
    private var luminance: Double {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else { return 0 }
        #elseif canImport(AppKit)
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else { return 0 }
        #endif

        let r = components[0]
        let g = components[1]
        let b = components[2]

        // Calculate relative luminance
        let adjustedR = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4)
        let adjustedG = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4)
        let adjustedB = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4)

        return 0.2126 * adjustedR + 0.7152 * adjustedG + 0.0722 * adjustedB
    }

    /// Get contrasting text color (white or black) based on background luminance
    public var contrastingTextColor: Color {
        // WCAG recommends white text for luminance < 0.5, black for >= 0.5
        return luminance > 0.5 ? .black : .white
    }

    /// Check if this color is light (returns true if light, false if dark)
    public var isLight: Bool {
        return luminance > 0.5
    }
}

// MARK: - Date Extensions

extension Date {
    /// Format date as relative time string (e.g., "2 hours ago")
    public func relativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Format date as short string (e.g., "Jan 5, 2024")
    public func shortDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Format date as date and time (e.g., "Jan 5, 2024 at 3:45 PM")
    public func dateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions

extension String {
    /// Truncate string to specified length with ellipsis
    public func truncated(to length: Int, addEllipsis: Bool = true) -> String {
        if self.count <= length {
            return self
        }
        let endIndex = self.index(self.startIndex, offsetBy: length)
        let truncated = String(self[..<endIndex])
        return addEllipsis ? truncated + "..." : truncated
    }

    /// Check if string is a valid email
    public var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply conditional modifier
    @ViewBuilder
    public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply conditional modifier with else clause
    @ViewBuilder
    public func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}
