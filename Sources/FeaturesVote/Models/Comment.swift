import Foundation

/// A comment on a feature request with emoji reactions
public struct Comment: Codable, Identifiable, Hashable {
    public let id: String
    public let userId: String?
    public let userName: String?
    public let userImgUrl: String?
    public let featureId: String
    public let comment: String
    public let createdAt: Date
    public let reactions: [String: Int] // emoji: count
    public let userReactions: [String] // emojis current user has reacted with
    public let isAdmin: Bool
    public let fileUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userName = "user_name"
        case userImgUrl = "user_img_url"
        case featureId = "feature_id"
        case comment
        case createdAt = "created_at"
        case reactions
        case userReactions = "user_reactions"
        case isAdmin = "is_admin"
        case fileUrl = "file_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // ID can be either a number or string from the API
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }

        // userId can be number, string, or null
        if let userIdInt = try? container.decode(Int.self, forKey: .userId) {
            userId = String(userIdInt)
        } else if let userIdString = try? container.decode(String.self, forKey: .userId) {
            userId = userIdString
        } else {
            userId = nil
        }

        // userName and userImgUrl are not in the API response, will be nil
        userName = try? container.decode(String.self, forKey: .userName)
        userImgUrl = try? container.decode(String.self, forKey: .userImgUrl)

        // featureId should be UUID string, but handle both just in case
        if let featureIdInt = try? container.decode(Int.self, forKey: .featureId) {
            featureId = String(featureIdInt)
        } else {
            featureId = try container.decode(String.self, forKey: .featureId)
        }

        comment = try container.decode(String.self, forKey: .comment)
        createdAt = try container.decode(Date.self, forKey: .createdAt)

        // Reactions: handle both Int and String values, or empty dict
        if let reactionsDict = try? container.decode([String: Int].self, forKey: .reactions) {
            reactions = reactionsDict
        } else if let reactionsStringDict = try? container.decode([String: String].self, forKey: .reactions) {
            reactions = reactionsStringDict.compactMapValues { Int($0) }
        } else {
            reactions = [:]
        }

        userReactions = (try? container.decode([String].self, forKey: .userReactions)) ?? []
        isAdmin = (try? container.decode(Bool.self, forKey: .isAdmin)) ?? false
        fileUrl = try? container.decode(String.self, forKey: .fileUrl)
    }

    public init(
        id: String,
        userId: String? = nil,
        userName: String? = nil,
        userImgUrl: String? = nil,
        featureId: String,
        comment: String,
        createdAt: Date,
        reactions: [String: Int] = [:],
        userReactions: [String] = [],
        isAdmin: Bool = false,
        fileUrl: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userImgUrl = userImgUrl
        self.featureId = featureId
        self.comment = comment
        self.createdAt = createdAt
        self.reactions = reactions
        self.userReactions = userReactions
        self.isAdmin = isAdmin
        self.fileUrl = fileUrl
    }

    /// Total reaction count across all emojis
    public var totalReactionCount: Int {
        reactions.values.reduce(0, +)
    }

    /// Whether the current user has reacted with a specific emoji
    public func hasReacted(with emoji: String) -> Bool {
        userReactions.contains(emoji)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Request Models

/// Request body for creating a comment
public struct CreateCommentRequest: Encodable {
    public let appUserId: String?
    public let email: String?
    public let userName: String?
    public let userImgUrl: String?
    public let comment: String
    public let isAdmin: Bool
    public let userSpend: Double?
    public let token: String?

    enum CodingKeys: String, CodingKey {
        case appUserId = "app_user_id"
        case email
        case userName = "user_name"
        case userImgUrl = "user_img_url"
        case comment
        case isAdmin = "is_admin"
        case userSpend = "user_spend"
        case token
    }

    public init(
        appUserId: String? = nil,
        email: String? = nil,
        userName: String? = nil,
        userImgUrl: String? = nil,
        comment: String,
        isAdmin: Bool = false,
        userSpend: Double? = nil,
        token: String? = nil
    ) {
        self.appUserId = appUserId
        self.email = email
        self.userName = userName
        self.userImgUrl = userImgUrl
        self.comment = comment
        self.isAdmin = isAdmin
        self.userSpend = userSpend
        self.token = token
    }
}

/// Request body for adding/removing a reaction
public struct CommentReactionRequest: Encodable {
    public let commentId: String
    public let emoji: String
    public let name: String?
    public let email: String?
    public let appUserId: String?
    public let imgUrl: String?
    public let userSpend: Double?
    public let token: String?

    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case emoji
        case name
        case email
        case appUserId = "app_user_id"
        case imgUrl = "img_url"
        case userSpend = "user_spend"
        case token
    }

    public init(
        commentId: String,
        emoji: String,
        name: String? = nil,
        email: String? = nil,
        appUserId: String? = nil,
        imgUrl: String? = nil,
        userSpend: Double? = nil,
        token: String? = nil
    ) {
        self.commentId = commentId
        self.emoji = emoji
        self.name = name
        self.email = email
        self.appUserId = appUserId
        self.imgUrl = imgUrl
        self.userSpend = userSpend
        self.token = token
    }
}

// MARK: - Mock Data

extension Comment {
    /// Create a mock comment for previews and testing
    public static func mock(
        id: String = UUID().uuidString,
        userId: String? = "user123",
        userName: String? = "John Doe",
        userImgUrl: String? = nil,
        featureId: String = "feature123",
        comment: String = "This is a sample comment.",
        reactions: [String: Int] = ["👍": 3, "❤️": 1],
        userReactions: [String] = ["👍"],
        isAdmin: Bool = false
    ) -> Comment {
        Comment(
            id: id,
            userId: userId,
            userName: userName,
            userImgUrl: userImgUrl,
            featureId: featureId,
            comment: comment,
            createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
            reactions: reactions,
            userReactions: userReactions,
            isAdmin: isAdmin
        )
    }

    /// Get avatar color for this comment's user
    public var avatarColor: String {
        guard let name = userName, !name.isEmpty else {
            return "#9CA3AF"
        }
        let hash = abs(name.hashValue)
        let colors = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8",
            "#F7B731", "#5F27CD", "#00D2D3", "#FF9FF3", "#54A0FF",
            "#48DBFB", "#0ABDE3", "#10AC84", "#EE5A6F", "#C44569"
        ]
        return colors[hash % colors.count]
    }

    /// Get initials from username
    public var initials: String {
        guard let name = userName, !name.isEmpty else {
            return "?"
        }
        let components = name.components(separatedBy: .whitespaces)
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}
