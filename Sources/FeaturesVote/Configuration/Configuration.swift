import SwiftUI

/// Configuration for Features.Vote widgets
public struct Configuration {
    /// UI-related configuration
    public var ui: UI

    /// Behavior-related configuration
    public var behavior: Behavior

    /// Button configuration
    public var buttons: Buttons

    public init(
        ui: UI = .default,
        behavior: Behavior = .default,
        buttons: Buttons = .default
    ) {
        self.ui = ui
        self.behavior = behavior
        self.buttons = buttons
    }

    /// Default configuration
    public static let `default` = Configuration()
}

// MARK: - UI Configuration

extension Configuration {
    /// UI display settings
    public struct UI {
        /// Show status badge on feature cards
        public var showStatusBadge: Bool

        /// Show comment count on feature cards
        public var showCommentCount: Bool

        /// Show tags on feature cards
        public var showTags: Bool

        /// Show "Powered by Features.Vote" watermark
        public var showWatermark: Bool

        /// Enable pull-to-refresh gesture
        public var enablePullToRefresh: Bool

        /// Maximum number of description lines before truncation
        public var maxDescriptionLines: Int

        /// Show user avatars
        public var showAvatars: Bool

        public init(
            showStatusBadge: Bool = true,
            showCommentCount: Bool = true,
            showTags: Bool = true,
            showWatermark: Bool = true,
            enablePullToRefresh: Bool = true,
            maxDescriptionLines: Int = 3,
            showAvatars: Bool = true
        ) {
            self.showStatusBadge = showStatusBadge
            self.showCommentCount = showCommentCount
            self.showTags = showTags
            self.showWatermark = showWatermark
            self.enablePullToRefresh = enablePullToRefresh
            self.maxDescriptionLines = maxDescriptionLines
            self.showAvatars = showAvatars
        }

        public static let `default` = UI()
    }
}

// MARK: - Behavior Configuration

extension Configuration {
    /// Behavior and feature settings
    public struct Behavior {
        /// Allow anonymous users to vote
        public var allowAnonymousVoting: Bool

        /// Allow anonymous users to comment
        public var allowAnonymousComments: Bool

        /// Require email when creating features
        public var requireEmailForCreate: Bool

        /// Enable optimistic UI updates (update immediately, revert on error)
        public var enableOptimisticUpdates: Bool

        /// Show confirmation dialog before voting
        public var confirmVoting: Bool

        /// Show confirmation dialog before unsubscribing
        public var confirmUnsubscribe: Bool

        public init(
            allowAnonymousVoting: Bool = true,
            allowAnonymousComments: Bool = true,
            requireEmailForCreate: Bool = false,
            enableOptimisticUpdates: Bool = true,
            confirmVoting: Bool = false,
            confirmUnsubscribe: Bool = true
        ) {
            self.allowAnonymousVoting = allowAnonymousVoting
            self.allowAnonymousComments = allowAnonymousComments
            self.requireEmailForCreate = requireEmailForCreate
            self.enableOptimisticUpdates = enableOptimisticUpdates
            self.confirmVoting = confirmVoting
            self.confirmUnsubscribe = confirmUnsubscribe
        }

        public static let `default` = Behavior()
    }
}

// MARK: - Button Configuration

extension Configuration {
    /// Button icons and styling
    public struct Buttons {
        /// Icon for upvote button
        public var upvoteIcon: Image

        /// Icon for subscribe button (not subscribed)
        public var subscribeIcon: Image

        /// Icon for subscribed state
        public var subscribedIcon: Image

        public init(
            upvoteIcon: Image = Image(systemName: "arrow.up"),
            subscribeIcon: Image = Image(systemName: "bell"),
            subscribedIcon: Image = Image(systemName: "bell.fill")
        ) {
            self.upvoteIcon = upvoteIcon
            self.subscribeIcon = subscribeIcon
            self.subscribedIcon = subscribedIcon
        }

        public static let `default` = Buttons()
    }
}
