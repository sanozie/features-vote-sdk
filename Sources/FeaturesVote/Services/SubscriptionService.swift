import Foundation

/// Request body for subscribing to a feature
struct SubscribeRequest: Encodable {
    let postId: String
    let slug: String
    let token: String?
    let isGoogleAuth: Bool?
    let googleEmail: String?
    let subscriberEmail: String?

    enum CodingKeys: String, CodingKey {
        case postId
        case slug
        case token
        case isGoogleAuth
        case googleEmail
        case subscriberEmail
    }
}

/// Request body for unsubscribing from a feature
struct UnsubscribeRequest: Encodable {
    let postId: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case postId
        case email
    }
}

/// Protocol for subscription service to allow for mocking
public protocol SubscriptionServiceProtocol {
    func subscribe(featureId: String, slug: String, user: User?) async throws
    func unsubscribe(featureId: String, email: String) async throws
}

/// Service for managing feature subscriptions
public final class SubscriptionService: SubscriptionServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Subscribe to updates for a feature
    public func subscribe(featureId: String, slug: String, user: User? = nil) async throws {
        FVLog.info("Subscribing to feature: \(featureId), slug: \(slug)", category: .network)
        FVLog.debug("User info - email: \(user?.email ?? "nil"), token: \(user?.token != nil ? "[present]" : "nil"), isGoogleAuth: \(user?.isGoogleAuth ?? false)", category: .network)

        let request = SubscribeRequest(
            postId: featureId,
            slug: slug,
            token: user?.token,
            isGoogleAuth: user?.isGoogleAuth,
            googleEmail: user?.isGoogleAuth == true ? user?.email : nil,
            subscriberEmail: user?.email
        )

        do {
            let _: String = try await apiClient.requestString(.subscribePost, body: request)
            FVLog.info("Subscribe successful for feature: \(featureId)", category: .network)
        } catch {
            FVLog.error(error, message: "Subscribe failed for feature: \(featureId)", category: .network)
            throw error
        }
    }

    /// Unsubscribe from updates for a feature
    public func unsubscribe(featureId: String, email: String) async throws {
        FVLog.info("Unsubscribing from feature: \(featureId), email: \(email)", category: .network)

        let request = UnsubscribeRequest(
            postId: featureId,
            email: email
        )

        do {
            let _: String = try await apiClient.requestString(.unsubscribePost, body: request)
            FVLog.info("Unsubscribe successful for feature: \(featureId)", category: .network)
        } catch {
            FVLog.error(error, message: "Unsubscribe failed for feature: \(featureId)", category: .network)
            throw error
        }
    }
}
