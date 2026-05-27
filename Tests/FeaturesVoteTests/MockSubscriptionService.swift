import XCTest
import FeaturesVote

/// A test double for `SubscriptionServiceProtocol` that returns pre-configured results
/// and tracks call counts and arguments for assertion in unit tests.
final class MockSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {

    // MARK: - Configurable Responses

    var subscribeResult: Result<Void, Error> = .success(())
    var unsubscribeResult: Result<Void, Error> = .success(())

    // MARK: - Call Tracking

    var subscribeCallCount = 0
    var unsubscribeCallCount = 0

    var lastSubscribeFeatureId: String?
    var lastUnsubscribeFeatureId: String?

    // MARK: - SubscriptionServiceProtocol

    func subscribe(featureId: String, slug: String, user: User?) async throws {
        subscribeCallCount += 1
        lastSubscribeFeatureId = featureId
        return try subscribeResult.get()
    }

    func unsubscribe(featureId: String, email: String) async throws {
        unsubscribeCallCount += 1
        lastUnsubscribeFeatureId = featureId
        return try unsubscribeResult.get()
    }
}

// MARK: - Generic test error type

enum TestError: Error {
    case network
    case server
}
