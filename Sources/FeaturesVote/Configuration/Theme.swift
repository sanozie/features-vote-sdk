import SwiftUI

/// Theme configuration for customizing the appearance of Features.Vote widgets
public struct Theme {
    // MARK: - Colors

    /// Primary color for buttons, accents, and interactive elements
    public var primaryColor: Color

    /// Secondary color for supporting UI elements
    public var secondaryColor: Color

    /// Background color for main views
    public var backgroundColor: Color

    /// Surface color for cards and elevated elements
    public var surfaceColor: Color

    /// Primary text color
    public var textPrimaryColor: Color

    /// Secondary text color for less important text
    public var textSecondaryColor: Color

    /// Error color for error messages and destructive actions
    public var errorColor: Color

    /// Success color for success messages
    public var successColor: Color

    // MARK: - Status Colors

    /// Color for pending status
    public var pendingColor: Color

    /// Color for approved status
    public var approvedColor: Color

    /// Color for in progress status
    public var inProgressColor: Color

    /// Color for done/completed status
    public var doneColor: Color

    /// Color for rejected status
    public var rejectedColor: Color

    // MARK: - Typography

    /// Font for titles and headers
    public var titleFont: Font

    /// Font for body text
    public var bodyFont: Font

    /// Font for captions and small text
    public var captionFont: Font

    // MARK: - Layout

    /// Corner radius for rounded elements
    public var cornerRadius: CGFloat

    // MARK: - Initialization

    public init(
        primaryColor: Color = Color(hex: "#7C3AED"),
        secondaryColor: Color = .purple,
        backgroundColor: Color = Color(hex: "#F3F4F6"),
        surfaceColor: Color = .white,
        textPrimaryColor: Color = Color.primary,
        textSecondaryColor: Color = Color.secondary,
        errorColor: Color = .red,
        successColor: Color = .green,
        pendingColor: Color = Color(hex: "#718096"), // gray - matching JS widget
        approvedColor: Color = Color(hex: "#06B6D4"), // cyan - matching JS widget
        inProgressColor: Color = Color(hex: "#F97316"), // orange - matching JS widget
        doneColor: Color = Color(hex: "#10B981"), // green - matching JS widget
        rejectedColor: Color = Color(hex: "#EF4444"), // red - matching JS widget
        titleFont: Font = .system(size: 17, weight: .semibold, design: .default),
        bodyFont: Font = .system(size: 15, weight: .regular, design: .default),
        captionFont: Font = .system(size: 13, weight: .medium, design: .default),
        cornerRadius: CGFloat = 16
    ) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundColor = backgroundColor
        self.surfaceColor = surfaceColor
        self.textPrimaryColor = textPrimaryColor
        self.textSecondaryColor = textSecondaryColor
        self.errorColor = errorColor
        self.successColor = successColor
        self.pendingColor = pendingColor
        self.approvedColor = approvedColor
        self.inProgressColor = inProgressColor
        self.doneColor = doneColor
        self.rejectedColor = rejectedColor
        self.titleFont = titleFont
        self.bodyFont = bodyFont
        self.captionFont = captionFont
        self.cornerRadius = cornerRadius
    }

    /// Default theme
    public static let `default` = Theme()

    /// Create theme from project configuration
    /// - Parameters:
    ///   - project: The project configuration
    ///   - colorScheme: The current color scheme (light/dark)
    /// - Returns: A theme matching the project's branding
    public static func from(project: Project, colorScheme: ColorScheme = .light) -> Theme {
        let primaryHex = colorScheme == .light ? project.primaryLight : project.primaryDark
        let primaryColor = Color(hex: primaryHex)

        return Theme(
            primaryColor: primaryColor,
            secondaryColor: primaryColor.opacity(0.7),
            backgroundColor: colorScheme == .light ? Color(hex: "#F3F4F6") : Color(hex: "#1F2937"),
            surfaceColor: colorScheme == .light ? .white : Color(hex: "#374151"),
            textPrimaryColor: colorScheme == .light ? .black : .white,
            textSecondaryColor: .secondary,
            errorColor: .red,
            successColor: .green,
            pendingColor: Color(hex: "#718096"), // gray - matching JS widget
            approvedColor: Color(hex: "#06B6D4"), // cyan - matching JS widget
            inProgressColor: Color(hex: "#F97316"), // orange - matching JS widget
            doneColor: Color(hex: "#10B981"), // green - matching JS widget
            rejectedColor: Color(hex: "#EF4444") // red - matching JS widget
        )
    }

    /// Get color for a specific feature status
    public func color(for status: FeatureStatus) -> Color {
        switch status {
        case .pending:
            return pendingColor
        case .approved:
            return approvedColor
        case .inProgress:
            return inProgressColor
        case .done:
            return doneColor
        case .rejected:
            return rejectedColor
        }
    }
}
