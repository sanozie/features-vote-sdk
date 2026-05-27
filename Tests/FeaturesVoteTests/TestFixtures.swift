import XCTest
import FeaturesVote

// MARK: - Feature Fixtures

extension Feature {
    /// Create a deterministic Feature for use in tests.
    static func fixture(
        id: String = "fixture-feature-id",
        title: String = "Test Feature",
        totalVotes: Int = 10,
        hasVoted: Bool = false,
        hasSubscribed: Bool = false,
        status: FeatureStatus = .pending,
        commentCount: Int = 3,
        userId: String? = "fixture-user-id"
    ) -> Feature {
        Feature(
            id: id,
            title: title,
            description: "A fixture feature description for testing purposes.",
            totalVotes: totalVotes,
            status: status,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            updatedAt: Date(timeIntervalSinceReferenceDate: 3600),
            commentCount: commentCount,
            hasVoted: hasVoted,
            hasSubscribed: hasSubscribed,
            userId: userId,
            releaseDate: nil,
            tags: ["test"],
            fileUrl: nil,
            releaseId: nil
        )
    }
}

// MARK: - Project & Customization Fixtures

extension Customization {
    /// Create a deterministic Customization for use in tests.
    static func fixture(
        isAnonDisabled: Bool? = nil,
        disabledAnonMessage: String? = nil,
        isInProgressOnTop: Bool? = nil,
        hideWatermark: Bool? = nil,
        suggestPopupHeaderText: String? = nil,
        suggestPopupSuccessMsg: String? = nil
    ) -> Customization {
        Customization(
            tags: [Tag(label: "bug", theme: "#FF0000"), Tag(label: "feature", theme: "#00FF00")],
            hideWatermark: hideWatermark,
            votingBoardTitle: "Feature Requests",
            isAnonDisabled: isAnonDisabled,
            isPrivateBoard: nil,
            isTokenOnly: nil,
            suggestPopupSuccessMsg: suggestPopupSuccessMsg,
            suggestPopupHeaderText: suggestPopupHeaderText,
            isInProgressOnTop: isInProgressOnTop,
            viewAllRequestsLink: nil,
            postLabel: nil,
            hideViewAllRedirect: nil,
            disabledAnonMessage: disabledAnonMessage,
            whitelistUrls: nil,
            defaultLanguage: "en",
            showTranslations: nil
        )
    }
}

extension Project {
    /// Create a deterministic Project for use in tests.
    static func fixture(
        slug: String = "test-project",
        isAnonDisabled: Bool? = nil,
        disabledAnonMessage: String? = nil,
        isInProgressOnTop: Bool? = nil,
        hideWatermark: Bool? = nil,
        suggestPopupHeaderText: String? = nil,
        suggestPopupSuccessMsg: String? = nil
    ) -> Project {
        Project(
            name: "Test Project",
            slug: slug,
            primaryLight: "#6366F1",
            primaryDark: "#818CF8",
            logoUrl: "https://features.vote/logo.png",
            websiteUrl: "https://features.vote",
            colorMode: nil,
            customization: .fixture(
                isAnonDisabled: isAnonDisabled,
                disabledAnonMessage: disabledAnonMessage,
                isInProgressOnTop: isInProgressOnTop,
                hideWatermark: hideWatermark,
                suggestPopupHeaderText: suggestPopupHeaderText,
                suggestPopupSuccessMsg: suggestPopupSuccessMsg
            )
        )
    }
}

// MARK: - Comment Fixtures

extension Comment {
    /// Create a deterministic Comment for use in tests.
    static func fixture(
        id: String = "fixture-comment-id",
        featureId: String = "fixture-feature-id",
        content: String = "This is a test comment.",
        userReactions: [String] = []
    ) -> Comment {
        Comment(
            id: id,
            userId: "fixture-user-id",
            userName: "Test User",
            userImgUrl: nil,
            featureId: featureId,
            comment: content,
            createdAt: Date(timeIntervalSinceReferenceDate: 0),
            reactions: ["👍": 2],
            userReactions: userReactions,
            isAdmin: false,
            fileUrl: nil
        )
    }
}

// MARK: - Configuration Fixtures

extension Configuration {
    /// Create a Configuration for use in tests, overriding individual bool settings.
    /// Starts from `Configuration.default` and applies the provided overrides.
    static func fixture(
        allowAnonymousVoting: Bool = true,
        allowAnonymousComments: Bool = true,
        requireEmailForCreate: Bool = false,
        enableOptimisticUpdates: Bool = true,
        confirmVoting: Bool = false,
        confirmUnsubscribe: Bool = true,
        showWatermark: Bool = true,
        showAvatars: Bool = true,
        showCommentCount: Bool = true,
        enablePullToRefresh: Bool = true
    ) -> Configuration {
        Configuration(
            ui: Configuration.UI(
                showStatusBadge: true,
                showCommentCount: showCommentCount,
                showTags: true,
                showWatermark: showWatermark,
                enablePullToRefresh: enablePullToRefresh,
                maxDescriptionLines: 3,
                showAvatars: showAvatars
            ),
            behavior: Configuration.Behavior(
                allowAnonymousVoting: allowAnonymousVoting,
                allowAnonymousComments: allowAnonymousComments,
                requireEmailForCreate: requireEmailForCreate,
                enableOptimisticUpdates: enableOptimisticUpdates,
                cacheTimeout: 300,
                confirmVoting: confirmVoting,
                confirmUnsubscribe: confirmUnsubscribe
            ),
            buttons: .default
        )
    }
}

// MARK: - UserService Factories

extension UserService {
    /// Returns a fresh, anonymous UserService (no email/customID/token set).
    static func anonymous() -> UserService {
        UserService()
    }

    /// Returns a UserService with an email set, making it explicitly identified.
    static func identified(email: String = "test@example.com") -> UserService {
        let service = UserService()
        service.setEmail(email)
        return service
    }
}
