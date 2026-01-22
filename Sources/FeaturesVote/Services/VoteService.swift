import Foundation

/// Request body for voting
struct VoteRequest: Encodable {
    let featureId: String
    let name: String?
    let email: String?
    let appUserId: String?
    let imgUrl: String?
    let userSpend: Double?
    let token: String?

    enum CodingKeys: String, CodingKey {
        case featureId = "feature_id"
        case name
        case email
        case appUserId = "app_user_id"
        case imgUrl = "img_url"
        case userSpend = "user_spend"
        case token
    }
}

/// Protocol for vote service to allow for mocking
public protocol VoteServiceProtocol {
    func upvote(featureId: String, user: User?) async throws
    func downvote(featureId: String, user: User?) async throws
}

/// Service for managing feature votes
public final class VoteService: VoteServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Upvote a feature
    public func upvote(featureId: String, user: User? = nil) async throws {
        FVLog.info("Upvoting feature: \(featureId)", category: .network)
        FVLog.debug("User info - email: \(user?.email ?? "nil"), appUserId: \(user?.appUserId ?? "nil"), token: \(user?.token != nil ? "[present]" : "nil")", category: .network)

        let request = VoteRequest(
            featureId: featureId,
            name: user?.name,
            email: user?.email,
            appUserId: user?.appUserId,
            imgUrl: user?.imgUrl,
            userSpend: user?.userSpend,
            token: user?.token
        )

        do {
            let _: String = try await apiClient.requestString(.upvote, body: request)
            FVLog.info("Upvote successful for feature: \(featureId)", category: .network)
        } catch {
            FVLog.error(error, message: "Upvote failed for feature: \(featureId)", category: .network)
            throw error
        }
    }

    /// Remove vote (downvote) from a feature
    public func downvote(featureId: String, user: User? = nil) async throws {
        FVLog.info("Downvoting feature: \(featureId)", category: .network)
        FVLog.debug("User info - email: \(user?.email ?? "nil"), appUserId: \(user?.appUserId ?? "nil"), token: \(user?.token != nil ? "[present]" : "nil")", category: .network)

        let request = VoteRequest(
            featureId: featureId,
            name: user?.name,
            email: user?.email,
            appUserId: user?.appUserId,
            imgUrl: user?.imgUrl,
            userSpend: user?.userSpend,
            token: user?.token
        )

        do {
            let _: String = try await apiClient.requestString(.downvote, body: request)
            FVLog.info("Downvote successful for feature: \(featureId)", category: .network)
        } catch {
            FVLog.error(error, message: "Downvote failed for feature: \(featureId)", category: .network)
            throw error
        }
    }
}
