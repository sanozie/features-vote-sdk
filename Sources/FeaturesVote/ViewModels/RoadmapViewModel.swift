import Foundation
import SwiftUI

/// ViewModel for the roadmap (Kanban board) view
@MainActor
public final class RoadmapViewModel: ObservableObject {
    // MARK: - Published State

    @Published private(set) var features: [Feature] = []
    @Published private(set) var project: Project?
    @Published private(set) var isLoading = false
    @Published private(set) var error: APIError?
    @Published var sortOrder: RoadmapSortOrder = .votes

    // MARK: - Dependencies

    private let slug: String
    private let featureService: FeatureServiceProtocol
    private let voteService: VoteServiceProtocol
    internal let userService: UserService

    // MARK: - Computed Properties

    /// Features grouped by status for Kanban columns
    public var featuresByStatus: [FeatureStatus: [Feature]] {
        let grouped = Dictionary(grouping: features) { $0.status }
        return grouped.mapValues { features in
            features.sorted { a, b in
                switch sortOrder {
                case .votes:
                    return a.totalVotes > b.totalVotes
                case .releaseDate:
                    // Sort by release date for done features
                    if a.status == .done, b.status == .done {
                        if let dateA = a.releaseDate, let dateB = b.releaseDate {
                            return dateA > dateB
                        }
                        return a.releaseDate != nil
                    }
                    return a.totalVotes > b.totalVotes
                }
            }
        }
    }

    /// All status columns for the Kanban board
    public let statusColumns: [FeatureStatus] = [
        .pending,
        .approved,
        .inProgress,
        .done,
        .rejected
    ]

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

    /// Refresh features
    public func refresh() async {
        await loadFeatures()
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

/// Sort order for roadmap
public enum RoadmapSortOrder: String, CaseIterable {
    case votes = "Votes"
    case releaseDate = "Release Date"
}
