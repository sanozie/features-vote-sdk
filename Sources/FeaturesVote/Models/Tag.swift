import Foundation

/// A tag that can be applied to feature requests
public struct Tag: Codable, Identifiable, Hashable {
    public let label: String
    public let theme: String // Hex color

    public var id: String { label }

    public init(label: String, theme: String) {
        self.label = label
        self.theme = theme
    }
}
