import Foundation

/// Protocol for release service to allow for mocking
public protocol ReleaseServiceProtocol {
    func fetchReleases(slug: String) async throws -> [Release]
    func fetchFeaturesByRelease(releaseId: String) async throws -> [Feature]
}

/// Service for managing releases and changelog
public final class ReleaseService: ReleaseServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Fetch all releases for a project
    public func fetchReleases(slug: String) async throws -> [Release] {
        let endpoint = APIEndpoint.releases(slug: slug)
        FVLog.debug("Fetching releases for slug: \(slug)", category: .network)

        do {
            let releases: [Release] = try await apiClient.request(endpoint)
            FVLog.debug("Loaded \(releases.count) releases", category: .data)
            return releases
        } catch {
            FVLog.error(error, message: "Failed to fetch releases", category: .network)
            throw error
        }
    }

    /// Fetch all features for a specific release
    public func fetchFeaturesByRelease(releaseId: String) async throws -> [Feature] {
        let endpoint = APIEndpoint.postsByRelease(releaseId: releaseId)
        return try await apiClient.request(endpoint)
    }
}
