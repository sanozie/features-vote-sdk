import Foundation

/// A feature request with voting, comments, and status tracking
public struct Feature: Codable, Identifiable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let totalVotes: Int
    public let status: FeatureStatus
    public let createdAt: Date
    public let updatedAt: Date // Always has a value (falls back to createdAt if API returns null)
    public let commentCount: Int
    public var hasVoted: Bool
    public var hasSubscribed: Bool
    public let userId: String?
    public let releaseDate: Date?
    public let tags: [String]?
    public let fileUrl: String?
    public let releaseId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case totalVotes = "total_votes"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case commentCount = "comment_count"
        case hasVoted = "has_voted"
        case hasSubscribed = "has_subscribed"
        case userId = "user_id"
        case releaseDate = "release_date"
        case tags
        case fileUrl = "file_url"
        case releaseId = "release_id"
    }

    public init(
        id: String,
        title: String,
        description: String,
        totalVotes: Int,
        status: FeatureStatus,
        createdAt: Date,
        updatedAt: Date,
        commentCount: Int,
        hasVoted: Bool,
        hasSubscribed: Bool,
        userId: String? = nil,
        releaseDate: Date? = nil,
        tags: [String]? = nil,
        fileUrl: String? = nil,
        releaseId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.totalVotes = totalVotes
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.commentCount = commentCount
        self.hasVoted = hasVoted
        self.hasSubscribed = hasSubscribed
        self.userId = userId
        self.releaseDate = releaseDate
        self.tags = tags
        self.fileUrl = fileUrl
        self.releaseId = releaseId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Feature, rhs: Feature) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Custom Decoding

extension Feature {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        totalVotes = try container.decode(Int.self, forKey: .totalVotes)

        // Handle status with potential API typo
        let statusString = try container.decode(String.self, forKey: .status)
        if let parsedStatus = FeatureStatus(apiValue: statusString) {
            status = parsedStatus
        } else {
            status = .pending // Default fallback
        }

        createdAt = try container.decode(Date.self, forKey: .createdAt)
        // updatedAt can be null from API, fallback to createdAt if not present
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
        // commentCount may be missing from API response, default to 0
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0
        // hasVoted and hasSubscribed may be missing from API response (e.g., in changelog), default to false
        hasVoted = try container.decodeIfPresent(Bool.self, forKey: .hasVoted) ?? false
        hasSubscribed = try container.decodeIfPresent(Bool.self, forKey: .hasSubscribed) ?? false
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        releaseDate = try container.decodeIfPresent(Date.self, forKey: .releaseDate)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        fileUrl = try container.decodeIfPresent(String.self, forKey: .fileUrl)
        releaseId = try container.decodeIfPresent(String.self, forKey: .releaseId)
    }
}

// MARK: - Mock Data

extension Feature {
    /// Create a mock feature for previews and testing
    public static func mock(
        id: String = UUID().uuidString,
        title: String = "Sample Feature Request",
        description: String = "This is a sample description for a feature request.",
        totalVotes: Int = 42,
        status: FeatureStatus = .pending,
        commentCount: Int = 5,
        hasVoted: Bool = false,
        hasSubscribed: Bool = false,
        tags: [String]? = ["enhancement", "ui"]
    ) -> Feature {
        Feature(
            id: id,
            title: title,
            description: description,
            totalVotes: totalVotes,
            status: status,
            createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
            updatedAt: Date().addingTimeInterval(-3600), // 1 hour ago
            commentCount: commentCount,
            hasVoted: hasVoted,
            hasSubscribed: hasSubscribed,
            userId: "user123",
            tags: tags
        )
    }
}
