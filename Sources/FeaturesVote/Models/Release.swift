import Foundation

/// A product release with associated features (for v1.1 Changelog widget)
public struct Release: Codable, Identifiable, Hashable {
    public let id: String
    public let version: String
    public let title: String
    public let shortDescription: String
    public let longDescription: String
    public let releasedAt: Date
    public let createdAt: Date
    public let projectId: String

    enum CodingKeys: String, CodingKey {
        case id
        case version
        case title
        case shortDescription = "short_description"
        case longDescription = "long_description"
        case releasedAt = "released_at"
        case createdAt = "created_at"
        case projectId = "project_id"
    }

    public init(
        id: String,
        version: String,
        title: String,
        shortDescription: String,
        longDescription: String,
        releasedAt: Date,
        createdAt: Date,
        projectId: String
    ) {
        self.id = id
        self.version = version
        self.title = title
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.releasedAt = releasedAt
        self.createdAt = createdAt
        self.projectId = projectId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        version = try container.decode(String.self, forKey: .version)
        title = try container.decode(String.self, forKey: .title)
        shortDescription = (try? container.decode(String.self, forKey: .shortDescription)) ?? ""
        longDescription = (try? container.decode(String.self, forKey: .longDescription)) ?? ""
        projectId = try container.decode(String.self, forKey: .projectId)

        // Handle flexible date formats
        // released_at can be just a date string "2025-08-16" or full ISO8601
        let releasedAtString = try container.decode(String.self, forKey: .releasedAt)
        if let date = Self.parseDate(releasedAtString) {
            releasedAt = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .releasedAt,
                in: container,
                debugDescription: "Could not parse date: \(releasedAtString)"
            )
        }

        // created_at is typically full ISO8601 format
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let date = Self.parseDate(createdAtString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Could not parse date: \(createdAtString)"
            )
        }
    }

    private static func parseDate(_ dateString: String) -> Date? {
        // Try ISO8601 with fractional seconds and timezone first
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }

        // Try ISO8601 without fractional seconds
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }

        // Try simple date format "YYYY-MM-DD"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: dateString) {
            return date
        }

        return nil
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Release, rhs: Release) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data

extension Release {
    /// Create a mock release for previews and testing
    public static func mock(
        id: String = UUID().uuidString,
        version: String = "1.0.0",
        title: String = "Initial Release",
        shortDescription: String = "Our first major release with exciting features!",
        longDescription: String = """
        # What's New

        This release includes many new features and improvements to enhance your experience.

        ## Key Features

        - **Dark Mode Support**: Beautiful dark theme across all screens
        - **Performance Improvements**: 2x faster loading times
        - **Bug Fixes**: Resolved issues with authentication

        ## Technical Details

        We've optimized the core rendering engine and improved memory management.

        ```swift
        func example() {
            print("Hello, World!")
        }
        ```

        Thank you for using our product!
        """
    ) -> Release {
        Release(
            id: id,
            version: version,
            title: title,
            shortDescription: shortDescription,
            longDescription: longDescription,
            releasedAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            createdAt: Date().addingTimeInterval(-86400 * 35), // 35 days ago
            projectId: "project123"
        )
    }
}
