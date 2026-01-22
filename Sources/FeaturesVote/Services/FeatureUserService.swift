import Foundation

/// Protocol for feature user service to allow for mocking
public protocol FeatureUserServiceProtocol {
    func fetchUser(userId: String) async throws -> FeatureUser
}

/// Service for fetching user information
public final class FeatureUserService: FeatureUserServiceProtocol {
    private let apiClient: APIClientProtocol

    // Cache to avoid repeated API calls for the same user
    private actor UserCache {
        private var cache: [String: FeatureUser] = [:]

        func get(_ userId: String) -> FeatureUser? {
            cache[userId]
        }

        func set(_ userId: String, user: FeatureUser) {
            cache[userId] = user
        }
    }

    private let cache = UserCache()

    public init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Fetch user by ID
    public func fetchUser(userId: String) async throws -> FeatureUser {
        // Check cache first
        if let cachedUser = await cache.get(userId) {
            return cachedUser
        }

        // Fetch from API
        let endpoint = APIEndpoint.user(userId: userId)
        let user: FeatureUser = try await apiClient.request(endpoint)

        // Cache the result
        await cache.set(userId, user: user)

        return user
    }
}
