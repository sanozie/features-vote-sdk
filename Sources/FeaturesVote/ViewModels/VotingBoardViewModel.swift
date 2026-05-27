import Foundation
import SwiftUI

/// Tab selection for filtering features
public enum FeatureTab: String, CaseIterable {
    case open = "Open"
    case done = "Done"
}

/// Sort order for features
public enum SortOrder: String, CaseIterable {
    case votes = "Votes"
    case recent = "Recent"
}

/// ViewModel for the voting board view
@MainActor
public final class VotingBoardViewModel: ObservableObject {
    // MARK: - Published State

    @Published private(set) var features: [Feature] = []
    @Published private(set) var project: Project?
    @Published private(set) var isLoading = false
    @Published private(set) var error: APIError?
    @Published var selectedTab: FeatureTab = .open
    @Published var sortOrder: SortOrder = .votes
    @Published var searchText = ""

    // Permission / confirmation alerts
    @Published public var permissionError: String?
    @Published public var showPermissionAlert = false
    @Published public var showVoteConfirmation = false

    // MARK: - Dependencies

    public let slug: String
    private let featureService: FeatureServiceProtocol
    private let voteService: VoteServiceProtocol
    internal let userService: UserService
    private let config: Configuration

    // Pending vote held while awaiting confirmation
    private var pendingVoteFeature: Feature?

    // MARK: - Computed Properties

    /// Project-level customization (loaded after fetchProject)
    private var projectCustomization: Customization? {
        project?.customization
    }

    /// Whether the project or local config has disabled anonymous actions
    private var isAnonDisabled: Bool {
        projectCustomization?.isAnonDisabled ?? false
    }

    /// Message to show when an anonymous action is blocked
    private var anonBlockedMessage: String {
        projectCustomization?.disabledAnonMessage
            ?? "Please sign in to perform this action."
    }

    /// Filtered and sorted features based on current tab, search, and sort order
    public var filteredFeatures: [Feature] {
        let filtered = features.filter { feature in
            let matchesTab: Bool
            switch selectedTab {
            case .open: matchesTab = feature.status.isOpen
            case .done: matchesTab = feature.status == .done
            }

            let matchesSearch = searchText.isEmpty ||
                feature.title.localizedCaseInsensitiveContains(searchText) ||
                feature.description.localizedCaseInsensitiveContains(searchText)

            return matchesTab && matchesSearch
        }

        // Respect server's isInProgressOnTop setting (defaults to true when not set)
        let pinInProgress = projectCustomization?.isInProgressOnTop ?? true

        return filtered.sorted { a, b in
            if pinInProgress {
                if a.status == .inProgress && b.status != .inProgress { return true }
                if a.status != .inProgress && b.status == .inProgress { return false }
            }

            switch sortOrder {
            case .votes:  return a.totalVotes > b.totalVotes
            case .recent: return a.createdAt > b.createdAt
            }
        }
    }

    /// Whether user is anonymous
    public var isAnonymous: Bool {
        userService.isAnonymous
    }

    /// Whether to show the "Powered by" watermark (respects both local config and server override)
    public var shouldShowWatermark: Bool {
        config.ui.showWatermark && !(projectCustomization?.hideWatermark ?? false)
    }

    // MARK: - Initialization

    public init(
        slug: String,
        featureService: FeatureServiceProtocol,
        voteService: VoteServiceProtocol,
        userService: UserService,
        configuration: Configuration = .default
    ) {
        self.slug = slug
        self.featureService = featureService
        self.voteService = voteService
        self.userService = userService
        self.config = configuration
    }

    // MARK: - Load Actions

    /// Load project configuration
    public func loadProject() async {
        do {
            project = try await featureService.fetchProject(slug: slug)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    /// Load features from API
    public func loadFeatures() async {
        isLoading = true
        error = nil

        do {
            let user = userService.getUser()
            features = try await featureService.fetchFeatures(slug: slug, user: user)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }

        isLoading = false
    }

    /// Refresh features silently (for pull-to-refresh — does not set isLoading)
    public func refresh() async {
        do {
            let user = userService.getUser()
            features = try await featureService.fetchFeatures(slug: slug, user: user)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    // MARK: - Vote Actions

    /// Entry point for a vote tap. Shows a confirmation dialog when `confirmVoting` is on,
    /// otherwise fires the vote immediately.
    public func requestVote(for feature: Feature) {
        // Check anonymous permission first
        if (isAnonymous && !config.behavior.allowAnonymousVoting) || (isAnonymous && isAnonDisabled) {
            permissionError = anonBlockedMessage
            showPermissionAlert = true
            return
        }

        if config.behavior.confirmVoting {
            pendingVoteFeature = feature
            showVoteConfirmation = true
        } else {
            Task { await toggleVote(for: feature) }
        }
    }

    /// Called when user confirms the vote dialog.
    public func confirmPendingVote() async {
        guard let feature = pendingVoteFeature else { return }
        pendingVoteFeature = nil
        showVoteConfirmation = false
        await toggleVote(for: feature)
    }

    /// Called when user cancels the vote dialog.
    public func cancelPendingVote() {
        pendingVoteFeature = nil
        showVoteConfirmation = false
    }

    /// Clears the current permission error.
    public func clearPermissionError() {
        permissionError = nil
        showPermissionAlert = false
    }

    /// Toggle vote on a feature (internal — use `requestVote(for:)` from the UI layer).
    public func toggleVote(for feature: Feature) async {
        let originalFeature = feature
        let isVoting = !feature.hasVoted

        // Optimistic update (only when configured)
        if config.behavior.enableOptimisticUpdates {
            updateFeatureVote(feature, isVoting: isVoting)
        }

        do {
            let user = userService.getUser()

            if isVoting {
                try await voteService.upvote(featureId: feature.id, user: user)
            } else {
                try await voteService.downvote(featureId: feature.id, user: user)
            }

            // Non-optimistic: apply update after confirmed API success
            if !config.behavior.enableOptimisticUpdates {
                updateFeatureVote(feature, isVoting: isVoting)
            }
        } catch {
            // Revert only if we applied the optimistic update
            if config.behavior.enableOptimisticUpdates {
                updateFeatureVote(originalFeature, isVoting: !isVoting)
            }

            if let apiError = error as? APIError {
                self.error = apiError
            } else {
                self.error = .unknown(error.localizedDescription)
            }
        }
    }

    // MARK: - Feature List Mutation

    /// Update a feature in the list (used when returning from detail view)
    public func updateFeature(_ feature: Feature) {
        if let index = features.firstIndex(where: { $0.id == feature.id }) {
            features[index] = feature
        }
    }

    // MARK: - Private Helpers

    private func updateFeatureVote(_ feature: Feature, isVoting: Bool) {
        if let index = features.firstIndex(where: { $0.id == feature.id }) {
            features[index] = Feature(
                id: features[index].id,
                title: features[index].title,
                description: features[index].description,
                totalVotes: isVoting
                    ? features[index].totalVotes + 1
                    : max(0, features[index].totalVotes - 1),
                status: features[index].status,
                createdAt: features[index].createdAt,
                updatedAt: features[index].updatedAt,
                commentCount: features[index].commentCount,
                hasVoted: isVoting,
                hasSubscribed: features[index].hasSubscribed,
                userId: features[index].userId,
                releaseDate: features[index].releaseDate,
                tags: features[index].tags,
                fileUrl: features[index].fileUrl,
                releaseId: features[index].releaseId
            )
        }
    }
}
