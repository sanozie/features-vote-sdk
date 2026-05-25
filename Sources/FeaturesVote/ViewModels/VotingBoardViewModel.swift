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

    // MARK: - Dependencies

    public let slug: String
    private let featureService: FeatureServiceProtocol
    private let voteService: VoteServiceProtocol
    internal let userService: UserService

    // MARK: - Computed Properties

    /// Filtered and sorted features based on current tab and sort order
    public var filteredFeatures: [Feature] {
        let filtered = features.filter { feature in
            // Tab filter
            let matchesTab: Bool
            switch selectedTab {
            case .open: matchesTab = feature.status.isOpen
            case .done: matchesTab = feature.status == .done
            }

            // Search filter
            let matchesSearch = searchText.isEmpty ||
                feature.title.localizedCaseInsensitiveContains(searchText) ||
                feature.description.localizedCaseInsensitiveContains(searchText)

            return matchesTab && matchesSearch
        }

        return filtered.sorted { a, b in
            // Always prioritize in-progress status first
            if a.status == .inProgress && b.status != .inProgress {
                return true
            } else if a.status != .inProgress && b.status == .inProgress {
                return false
            }

            // Then sort by the selected sort order
            switch sortOrder {
            case .votes:
                return a.totalVotes > b.totalVotes
            case .recent:
                return a.createdAt > b.createdAt
            }
        }
    }

    /// Whether user is anonymous
    public var isAnonymous: Bool {
        userService.isAnonymous
    }

    // MARK: - Initialization

    public init(
        slug: String,
        featureService: FeatureServiceProtocol,
        voteService: VoteServiceProtocol,
        userService: UserService
    ) {
        self.slug = slug
        self.featureService = featureService
        self.voteService = voteService
        self.userService = userService
    }

    // MARK: - Actions

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

    /// Toggle vote on a feature
    public func toggleVote(for feature: Feature) async {
        let originalFeature = feature
        let isVoting = !feature.hasVoted

        // Optimistic update
        updateFeatureVote(feature, isVoting: isVoting)

        do {
            let user = userService.getUser()

            if isVoting {
                try await voteService.upvote(featureId: feature.id, user: user)
            } else {
                try await voteService.downvote(featureId: feature.id, user: user)
            }
        } catch {
            // Revert on failure
            updateFeatureVote(originalFeature, isVoting: !isVoting)

            if let apiError = error as? APIError {
                self.error = apiError
            } else {
                self.error = .unknown(error.localizedDescription)
            }
        }
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

    /// Update a feature in the list (used when returning from detail view)
    public func updateFeature(_ feature: Feature) {
        if let index = features.firstIndex(where: { $0.id == feature.id }) {
            features[index] = feature
        }
    }

    // MARK: - Private Methods

    private func updateFeatureVote(_ feature: Feature, isVoting: Bool) {
        if let index = features.firstIndex(where: { $0.id == feature.id }) {
            features[index].hasVoted = isVoting
            features[index] = Feature(
                id: features[index].id,
                title: features[index].title,
                description: features[index].description,
                totalVotes: isVoting ? features[index].totalVotes + 1 : max(0, features[index].totalVotes - 1),
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
