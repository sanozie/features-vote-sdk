import Foundation

/// User information for feature authors and commenters
public struct FeatureUser: Codable, Identifiable, Hashable {
    public let id: String  // For Identifiable protocol
    public let name: String
    public let imgUrl: String?

    enum CodingKeys: String, CodingKey {
        case name
        case imgUrl = "img_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.imgUrl = try container.decodeIfPresent(String.self, forKey: .imgUrl)
        // Use name as ID since API doesn't return user_id in the response
        self.id = self.name
    }

    public init(
        name: String,
        imgUrl: String? = nil
    ) {
        self.id = name
        self.name = name
        self.imgUrl = imgUrl
    }

    /// Generate a random color for avatar background based on name
    public var avatarColor: String {
        // Use the name to generate a consistent color
        let hash = abs(name.hashValue)
        let colors = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8",
            "#F7B731", "#5F27CD", "#00D2D3", "#FF9FF3", "#54A0FF",
            "#48DBFB", "#0ABDE3", "#10AC84", "#EE5A6F", "#C44569"
        ]
        return colors[hash % colors.count]
    }

    /// Get initials from name (first letter or first two letters of first two words)
    public var initials: String {
        let components = name.components(separatedBy: .whitespaces)
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: FeatureUser, rhs: FeatureUser) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data

extension FeatureUser {
    /// Create a mock feature user for previews and testing
    public static func mock(
        name: String = "John Doe",
        imgUrl: String? = nil
    ) -> FeatureUser {
        FeatureUser(name: name, imgUrl: imgUrl)
    }
}
