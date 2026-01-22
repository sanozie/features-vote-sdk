import Foundation
import SwiftUI

/// ViewModel for feature detail view
@MainActor
public final class FeatureDetailViewModel: ObservableObject {
    // MARK: - Published State

    @Published public var feature: Feature
    @Published private(set) var comments: [Comment] = []
    @Published private(set) var isLoadingComments = false
    @Published private(set) var isSubscribing = false
    @Published private(set) var error: APIError?
    @Published public var subscriptionMessage: String?
    @Published public var subscriptionError: String?

    // MARK: - Dependencies

    private let slug: String
    private let voteService: VoteServiceProtocol
    private let commentService: CommentServiceProtocol
    private let subscriptionService: SubscriptionServiceProtocol
    internal let userService: UserService

    // MARK: - Computed Properties

    public var isAnonymous: Bool {
        userService.isAnonymous
    }

    /// Whether the subscribe button should be shown (only when email is supplied)
    public var shouldShowSubscribeButton: Bool {
        let user = userService.getUser()
        return user.email != nil
    }

    // MARK: - Initialization

    public init(
        feature: Feature,
        slug: String,
        voteService: VoteServiceProtocol,
        commentService: CommentServiceProtocol,
        subscriptionService: SubscriptionServiceProtocol,
        userService: UserService
    ) {
        self.feature = feature
        self.slug = slug
        self.voteService = voteService
        self.commentService = commentService
        self.subscriptionService = subscriptionService
        self.userService = userService
    }

    // MARK: - Actions

    /// Load comments for the feature
    public func loadComments() async {
        isLoadingComments = true
        error = nil

        do {
            let user = userService.getUser()
            comments = try await commentService.fetchComments(featureId: feature.id, user: user)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }

        isLoadingComments = false
    }

    /// Toggle vote on the feature
    public func toggleVote() async {
        let originalVoteState = feature.hasVoted
        let originalVoteCount = feature.totalVotes

        // Optimistic update
        feature.hasVoted.toggle()
        feature = Feature(
            id: feature.id,
            title: feature.title,
            description: feature.description,
            totalVotes: feature.hasVoted ? feature.totalVotes + 1 : max(0, feature.totalVotes - 1),
            status: feature.status,
            createdAt: feature.createdAt,
            updatedAt: feature.updatedAt,
            commentCount: feature.commentCount,
            hasVoted: feature.hasVoted,
            hasSubscribed: feature.hasSubscribed,
            userId: feature.userId,
            releaseDate: feature.releaseDate,
            tags: feature.tags,
            fileUrl: feature.fileUrl,
            releaseId: feature.releaseId
        )

        do {
            let user = userService.getUser()

            if feature.hasVoted {
                try await voteService.upvote(featureId: feature.id, user: user)
            } else {
                try await voteService.downvote(featureId: feature.id, user: user)
            }
        } catch {
            // Revert on failure
            feature = Feature(
                id: feature.id,
                title: feature.title,
                description: feature.description,
                totalVotes: originalVoteCount,
                status: feature.status,
                createdAt: feature.createdAt,
                updatedAt: feature.updatedAt,
                commentCount: feature.commentCount,
                hasVoted: originalVoteState,
                hasSubscribed: feature.hasSubscribed,
                userId: feature.userId,
                releaseDate: feature.releaseDate,
                tags: feature.tags,
                fileUrl: feature.fileUrl,
                releaseId: feature.releaseId
            )

            if let apiError = error as? APIError {
                self.error = apiError
            } else {
                self.error = .unknown(error.localizedDescription)
            }
        }
    }

    /// Toggle subscription to the feature (matching JS widget behavior)
    public func toggleSubscription() async {
        // Clear previous messages
        subscriptionMessage = nil
        subscriptionError = nil

        // Start loading
        isSubscribing = true

        let originalState = feature.hasSubscribed
        let user = userService.getUser()

        // Optimistic update
        feature.hasSubscribed.toggle()

        do {
            if feature.hasSubscribed {
                // Subscribe
                try await subscriptionService.subscribe(
                    featureId: feature.id,
                    slug: slug,
                    user: user
                )
                subscriptionMessage = "Successfully subscribed to email notifications for this post."
            } else {
                // Unsubscribe
                guard let email = user.email else {
                    throw APIError.unauthorized
                }
                try await subscriptionService.unsubscribe(
                    featureId: feature.id,
                    email: email
                )
                subscriptionMessage = "Successfully unsubscribed from email notifications for this post."
            }

            // Success - keep the optimistic update
            isSubscribing = false
        } catch {
            // Revert on failure
            feature.hasSubscribed = originalState
            isSubscribing = false

            subscriptionError = "Something went wrong with \(originalState ? "unsubscribing from" : "subscribing to") this post. Please try again or contact support."

            if let apiError = error as? APIError {
                self.error = apiError
            } else {
                self.error = .unknown(error.localizedDescription)
            }
        }
    }

    /// Dismiss subscription message
    public func dismissSubscriptionMessage() {
        subscriptionMessage = nil
        subscriptionError = nil
    }

    /// Add a reaction to a comment
    public func addReaction(to comment: Comment, emoji: String) async {
        do {
            let user = userService.getUser()
            try await commentService.addReaction(commentId: comment.id, emoji: emoji, user: user)

            // Optimistically update local state
            if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                var updatedComment = comments[index]
                var reactions = updatedComment.reactions
                reactions[emoji, default: 0] += 1
                var userReactions = updatedComment.userReactions
                if !userReactions.contains(emoji) {
                    userReactions.append(emoji)
                }

                comments[index] = Comment(
                    id: updatedComment.id,
                    userId: updatedComment.userId,
                    featureId: updatedComment.featureId,
                    comment: updatedComment.comment,
                    createdAt: updatedComment.createdAt,
                    reactions: reactions,
                    userReactions: userReactions,
                    isAdmin: updatedComment.isAdmin,
                    fileUrl: updatedComment.fileUrl
                )
            }
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    /// Remove a reaction from a comment
    public func removeReaction(from comment: Comment, emoji: String) async {
        do {
            let user = userService.getUser()
            try await commentService.removeReaction(commentId: comment.id, emoji: emoji, user: user)

            // Optimistically update local state
            if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                var updatedComment = comments[index]
                var reactions = updatedComment.reactions
                if let count = reactions[emoji], count > 0 {
                    reactions[emoji] = count - 1
                    if reactions[emoji] == 0 {
                        reactions.removeValue(forKey: emoji)
                    }
                }
                var userReactions = updatedComment.userReactions
                userReactions.removeAll { $0 == emoji }

                comments[index] = Comment(
                    id: updatedComment.id,
                    userId: updatedComment.userId,
                    featureId: updatedComment.featureId,
                    comment: updatedComment.comment,
                    createdAt: updatedComment.createdAt,
                    reactions: reactions,
                    userReactions: userReactions,
                    isAdmin: updatedComment.isAdmin,
                    fileUrl: updatedComment.fileUrl
                )
            }
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }
}
