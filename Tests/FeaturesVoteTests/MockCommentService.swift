import XCTest
import FeaturesVote

/// A test double for `CommentServiceProtocol` that returns pre-configured results
/// and tracks call counts and arguments for assertion in unit tests.
final class MockCommentService: CommentServiceProtocol, @unchecked Sendable {

    // MARK: - Configurable Responses

    var fetchCommentsResult: Result<[Comment], Error> = .success([])
    var addCommentResult: Result<String, Error> = .success("new-comment-id")
    var addReactionResult: Result<Void, Error> = .success(())
    var removeReactionResult: Result<Void, Error> = .success(())

    // MARK: - Call Tracking

    var fetchCommentsCallCount = 0
    var addCommentCallCount = 0
    var addReactionCallCount = 0
    var removeReactionCallCount = 0

    var lastFetchCommentsFeatureId: String?
    var lastAddCommentFeatureId: String?
    var lastAddCommentText: String?
    var lastAddReactionCommentId: String?
    var lastAddReactionEmoji: String?
    var lastRemoveReactionCommentId: String?
    var lastRemoveReactionEmoji: String?

    // MARK: - CommentServiceProtocol

    func fetchComments(featureId: String, user: User?) async throws -> [Comment] {
        fetchCommentsCallCount += 1
        lastFetchCommentsFeatureId = featureId
        return try fetchCommentsResult.get()
    }

    func addComment(
        featureId: String,
        slug: String,
        comment: String,
        user: User?,
        imageData: Data?,
        fileName: String?
    ) async throws -> String {
        addCommentCallCount += 1
        lastAddCommentFeatureId = featureId
        lastAddCommentText = comment
        return try addCommentResult.get()
    }

    func addReaction(commentId: String, emoji: String, user: User?) async throws {
        addReactionCallCount += 1
        lastAddReactionCommentId = commentId
        lastAddReactionEmoji = emoji
        return try addReactionResult.get()
    }

    func removeReaction(commentId: String, emoji: String, user: User?) async throws {
        removeReactionCallCount += 1
        lastRemoveReactionCommentId = commentId
        lastRemoveReactionEmoji = emoji
        return try removeReactionResult.get()
    }
}
