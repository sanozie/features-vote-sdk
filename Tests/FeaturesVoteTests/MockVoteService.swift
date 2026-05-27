import XCTest
import FeaturesVote

/// A test double for `VoteServiceProtocol` that returns pre-configured results
/// and tracks call counts and arguments for assertion in unit tests.
final class MockVoteService: VoteServiceProtocol, @unchecked Sendable {

    // MARK: - Configurable Responses

    var upvoteResult: Result<Void, Error> = .success(())
    var downvoteResult: Result<Void, Error> = .success(())

    // MARK: - Call Tracking

    var upvoteCallCount = 0
    var downvoteCallCount = 0

    var lastUpvotedFeatureId: String?
    var lastDownvotedFeatureId: String?

    // MARK: - VoteServiceProtocol

    func upvote(featureId: String, user: User?) async throws {
        upvoteCallCount += 1
        lastUpvotedFeatureId = featureId
        return try upvoteResult.get()
    }

    func downvote(featureId: String, user: User?) async throws {
        downvoteCallCount += 1
        lastDownvotedFeatureId = featureId
        return try downvoteResult.get()
    }
}
