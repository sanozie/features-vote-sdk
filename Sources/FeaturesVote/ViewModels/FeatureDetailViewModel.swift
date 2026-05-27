import Foundation
import SwiftUI

/// ViewModel for feature detail view
@MainActor
public final class FeatureDetailViewModel: ObservableObject {
    // MARK: - Published State

    @Published public var feature: Feature
    @Published private(set) var isLoadingComments = false
    @Published private(set) var isSubscribing = false
    @Published private(set) var error: APIError?
    @Published public var subscriptionMessage: String?
    @Published public var subscriptionError: String?

    // Permission / confirmation alerts
    @Published public var permissionError: String?
    @Published public var showPermissionAlert = false
    @Published public var showVoteConfirmation = false
    @Published public var showUnsubscribeConfirmation = false

    // MARK: - Dependencies

    private let slug: String
    private let voteService: VoteServiceProtocol
    private let commentService: CommentServiceProtocol
    private let subscriptionService: SubscriptionServiceProtocol
    internal let userService: UserService
    private let config: Configuration
    private let projectCustomization: Customization?

    // MARK: - Computed Properties

    public var isAnonymous: Bool {
        userService.isAnonymous
    }

    /// Whether the subscribe button should be shown (only when email is supplied)
    public var shouldShowSubscribeButton: Bool {
        let user = userService.getUser()
        return user.email != nil
    }

    /// Whether the project or local config has disabled anonymous actions
    private var isAnonDisabled: Bool {
        projectCustomization?.isAnonDisabled ?? false
    }

    private var anonBlockedMessage: String {
        projectCustomization?.disabledAnonMessage
            ?? "Please sign in to perform this action."
    }

    // MARK: - Initialization

    public init(
        feature: Feature,
        slug: String,
        voteService: VoteServiceProtocol,
        commentService: CommentServiceProtocol,
        subscriptionService: SubscriptionServiceProtocol,
        userService: UserService,
        configuration: Configuration = .default,
        projectCustomization: Customization? = nil
    ) {
        self.feature = feature
        self.slug = slug
        self.voteService = voteService
        self.commentService = commentService
        self.subscriptionService = subscriptionService
        self.userService = userService
        self.config = configuration
        self.projectCustomization = projectCustomization
    }

    // MARK: - Vote Actions

    /// Entry point for a vote tap. Shows confirmation when `confirmVoting` is on.
    public func requestVote() {
        // Check anonymous permission
        if (isAnonymous && !config.behavior.allowAnonymousVoting) || (isAnonymous && isAnonDisabled) {
            permissionError = anonBlockedMessage
            showPermissionAlert = true
            return
        }

        if config.behavior.confirmVoting {
            showVoteConfirmation = true
        } else {
            Task { await toggleVote() }
        }
    }

    /// Called when user confirms the vote dialog.
    public func confirmPendingVote() async {
        showVoteConfirmation = false
        await toggleVote()
    }

    /// Called when user cancels the vote dialog.
    public func cancelPendingVote() {
        showVoteConfirmation = false
    }

    /// Toggle vote on the feature (internal — use `requestVote()` from the UI layer).
    public func toggleVote() async {
        let originalVoteState = feature.hasVoted
        let originalVoteCount = feature.totalVotes
        let isVoting = !feature.hasVoted

        // Optimistic update
        if config.behavior.enableOptimisticUpdates {
            applyVote(isVoting: isVoting)
        }

        do {
            let user = userService.getUser()

            if isVoting {
                try await voteService.upvote(featureId: feature.id, user: user)
            } else {
                try await voteService.downvote(featureId: feature.id, user: user)
            }

            // Non-optimistic: apply after confirmed success
            if !config.behavior.enableOptimisticUpdates {
                applyVote(isVoting: isVoting)
            }
        } catch {
            // Revert only if we applied an optimistic update
            if config.behavior.enableOptimisticUpdates {
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
            }

            if let apiError = error as? APIError {
                self.error = apiError
            } else {
                self.error = .unknown(error.localizedDescription)
            }
        }
    }

    // MARK: - Subscription Actions

    /// Entry point for subscribe/unsubscribe. Shows confirmation before unsubscribing when configured.
    public func requestSubscriptionToggle() {
        if feature.hasSubscribed && config.behavior.confirmUnsubscribe {
            showUnsubscribeConfirmation = true
        } else {
            Task { await toggleSubscription() }
        }
    }

    /// Called when the user confirms the unsubscribe dialog.
    public func confirmUnsubscribe() async {
        showUnsubscribeConfirmation = false
        await toggleSubscription()
    }

    /// Cancel the unsubscribe confirmation.
    public func cancelUnsubscribe() {
        showUnsubscribeConfirmation = false
    }

    /// Toggle subscription to the feature (matching JS widget behavior)
    public func toggleSubscription() async {
        subscriptionMessage = nil
        subscriptionError = nil
        isSubscribing = true

        let originalState = feature.hasSubscribed
        let user = userService.getUser()

        feature.hasSubscribed.toggle()

        do {
            if feature.hasSubscribed {
                try await subscriptionService.subscribe(
                    featureId: feature.id,
                    slug: slug,
                    user: user
                )
                subscriptionMessage = "Successfully subscribed to email notifications for this post."
            } else {
                guard let email = user.email else {
                    throw APIError.unauthorized
                }
                try await subscriptionService.unsubscribe(
                    featureId: feature.id,
                    email: email
                )
                subscriptionMessage = "Successfully unsubscribed from email notifications for this post."
            }

            isSubscribing = false
        } catch {
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

    // MARK: - Comments

    /// Add a reaction to a comment
    public func addReaction(to comment: Comment, emoji: String) async {
        do {
            let user = userService.getUser()
            try await commentService.addReaction(commentId: comment.id, emoji: emoji, user: user)
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
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    // MARK: - Misc

    /// Dismiss subscription message
    public func dismissSubscriptionMessage() {
        subscriptionMessage = nil
        subscriptionError = nil
    }

    /// Clears the current permission error.
    public func clearPermissionError() {
        permissionError = nil
        showPermissionAlert = false
    }

    // MARK: - Private Helpers

    private func applyVote(isVoting: Bool) {
        feature = Feature(
            id: feature.id,
            title: feature.title,
            description: feature.description,
            totalVotes: isVoting
                ? feature.totalVotes + 1
                : max(0, feature.totalVotes - 1),
            status: feature.status,
            createdAt: feature.createdAt,
            updatedAt: feature.updatedAt,
            commentCount: feature.commentCount,
            hasVoted: isVoting,
            hasSubscribed: feature.hasSubscribed,
            userId: feature.userId,
            releaseDate: feature.releaseDate,
            tags: feature.tags,
            fileUrl: feature.fileUrl,
            releaseId: feature.releaseId
        )
    }
}
