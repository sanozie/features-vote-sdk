import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Main entry point for the FeaturesVote SDK
public struct FeaturesVote {
    // MARK: - Thread-Safe Shared State

    private static let lock = NSLock()
    private static var _shared: FeaturesVoteInstance?

    internal static var shared: FeaturesVoteInstance {
        lock.lock()
        defer { lock.unlock() }
        guard let instance = _shared else {
            fatalError("FeaturesVote not configured. Call FeaturesVote.configure(with:) first.")
        }
        return instance
    }

    // MARK: - Public Configuration

    /// Configure the SDK with a project slug
    public static func configure(with slug: String) {
        lock.lock()
        defer { lock.unlock() }
        _shared = FeaturesVoteInstance(slug: slug)
    }

    /// Global theme configuration
    public static var theme: Theme {
        get { shared.theme }
        set {
            lock.lock()
            defer { lock.unlock() }
            _shared?.theme = newValue
        }
    }

    /// Global configuration
    public static var config: Configuration {
        get { shared.config }
        set {
            lock.lock()
            defer { lock.unlock() }
            _shared?.config = newValue
        }
    }

    /// Global localization strings
    public static var localization: Localization {
        get { shared.localization }
        set {
            lock.lock()
            defer { lock.unlock() }
            _shared?.localization = newValue
        }
    }

    // MARK: - User Management

    /// Update user custom ID
    public static func updateUser(customID: String) {
        shared.userService.setCustomID(customID)
    }

    /// Update user email
    public static func updateUser(email: String) {
        shared.userService.setEmail(email)
    }

    /// Update user name
    public static func updateUser(name: String) {
        shared.userService.setName(name)
    }

    /// Update user image URL
    public static func updateUser(imageUrl: String) {
        shared.userService.setImageUrl(imageUrl)
    }

    /// Update user spend amount
    public static func updateUser(spend: Double) {
        shared.userService.setSpend(spend)
    }

    /// Attach contextual metadata to posts created by this user.
    ///
    /// Use this to tell the app owner what context a feature request was created in —
    /// e.g. app version, the current screen, device model, or plan tier. The values are
    /// sent with new posts as `post_metadata` and surface in the admin dashboard.
    ///
    ///     FeaturesVote.updateMetadata([
    ///         "app_version": "1.2.3",
    ///         "page": "settings",
    ///         "plan": "pro"
    ///     ])
    public static func updateMetadata(_ metadata: [String: Any]) {
        shared.userService.setMetadata(metadata)
    }

    /// Set JWT token
    public static func setToken(_ token: String) {
        shared.userService.setToken(token)
    }

    /// Clear user data
    public static func clearUser() {
        shared.userService.clearUser()
    }

    // MARK: - SwiftUI Views

    /// Voting board view (SwiftUI)
    public struct VotingBoardView: View {
        public init() {}

        public var body: some View {
            let instance = FeaturesVote.shared
            return InternalVotingBoardView(
                viewModel: VotingBoardViewModel(
                    slug: instance.slug,
                    featureService: instance.featureService,
                    voteService: instance.voteService,
                    userService: instance.userService,
                    configuration: instance.config
                ),
                theme: instance.theme,
                config: instance.config,
                localization: instance.localization
            )
        }
    }

    /// Feature detail view (SwiftUI)
    public struct FeatureDetailView: View {
        let feature: Feature

        public init(feature: Feature) {
            self.feature = feature
        }

        public var body: some View {
            let instance = FeaturesVote.shared
            return InternalFeatureDetailView(
                feature: feature,
                slug: instance.slug,
                theme: instance.theme,
                config: instance.config,
                localization: instance.localization,
                userService: instance.userService
            )
        }
    }

    /// Create feature view (SwiftUI)
    public struct CreateFeatureView: View {
        let onSuccess: (() -> Void)?

        public init(onSuccess: (() -> Void)? = nil) {
            self.onSuccess = onSuccess
        }

        public var body: some View {
            let instance = FeaturesVote.shared
            return InternalCreateFeatureView(
                slug: instance.slug,
                availableTags: [], // Will be fetched from project
                theme: instance.theme,
                config: instance.config,
                localization: instance.localization,
                onSuccess: onSuccess,
                userService: instance.userService
            )
        }
    }

    /// Changelog view (SwiftUI)
    public struct ChangelogView: View {
        public init() {}

        public var body: some View {
            let instance = FeaturesVote.shared
            return InternalChangelogView(
                slug: instance.slug,
                theme: instance.theme,
                config: instance.config,
                availableTags: [] // Will be fetched from project
            )
        }
    }

    /// Roadmap view (SwiftUI)
    public struct RoadmapView: View {
        public init() {}

        public var body: some View {
            let instance = FeaturesVote.shared
            return InternalRoadmapView(
                viewModel: RoadmapViewModel(
                    slug: instance.slug,
                    featureService: instance.featureService,
                    voteService: instance.voteService,
                    userService: instance.userService,
                    configuration: instance.config
                ),
                theme: instance.theme,
                config: instance.config,
                localization: instance.localization
            )
        }
    }

    #if canImport(UIKit)
    // MARK: - UIKit Bridges

    /// Get a UIViewController for the voting board
    public static var votingBoardViewController: UIViewController {
        let view = VotingBoardView()
        return UIHostingController(rootView: view)
    }

    /// Get a UIViewController for feature detail
    public static func featureDetailViewController(for feature: Feature) -> UIViewController {
        let view = FeatureDetailView(feature: feature)
        return UIHostingController(rootView: view)
    }

    /// Get a UIViewController for creating a feature
    public static func createFeatureViewController(onSuccess: (() -> Void)? = nil) -> UIViewController {
        let view = CreateFeatureView(onSuccess: onSuccess)
        return UIHostingController(rootView: view)
    }

    /// Get a UIViewController for the changelog
    public static var changelogViewController: UIViewController {
        let view = ChangelogView()
        return UIHostingController(rootView: view)
    }

    /// Get a UIViewController for the roadmap
    public static var roadmapViewController: UIViewController {
        let view = RoadmapView()
        return UIHostingController(rootView: view)
    }
    #endif
}

// MARK: - Internal Instance

internal final class FeaturesVoteInstance {
    let slug: String
    var theme: Theme
    var config: Configuration
    var localization: Localization

    // Services
    let apiClient: APIClient
    let featureService: FeatureService
    let voteService: VoteService
    let commentService: CommentService
    let subscriptionService: SubscriptionService
    let userService: UserService

    init(slug: String) {
        self.slug = slug
        self.theme = .default
        self.config = .default
        self.localization = .default

        // Initialize services
        self.apiClient = APIClient()
        self.featureService = FeatureService(apiClient: apiClient)
        self.voteService = VoteService(apiClient: apiClient)
        self.commentService = CommentService(apiClient: apiClient)
        self.subscriptionService = SubscriptionService(apiClient: apiClient)
        self.userService = UserService()
    }
}

// MARK: - Internal Namespace

// Use unique internal type names to avoid conflicts
internal typealias InternalVotingBoardView = VotingBoardView
internal typealias InternalFeatureDetailView = FeatureDetailView
internal typealias InternalCreateFeatureView = CreateFeatureView
internal typealias InternalChangelogView = ChangelogView
internal typealias InternalRoadmapView = RoadmapView
