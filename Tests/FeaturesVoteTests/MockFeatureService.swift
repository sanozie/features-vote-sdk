import XCTest
import FeaturesVote

/// A test double for `FeatureServiceProtocol` that returns pre-configured results
/// and tracks call counts for assertion in unit tests.
final class MockFeatureService: FeatureServiceProtocol, @unchecked Sendable {

    // MARK: - Configurable Responses

    var fetchProjectResult: Result<Project, Error> = .success(Project.fixture())
    var fetchFeaturesResult: Result<[Feature], Error> = .success([])
    var createFeatureResult: Result<String, Error> = .success("new-id")

    // MARK: - Call Tracking

    var fetchProjectCallCount = 0
    var fetchFeaturesCallCount = 0
    var createFeatureCallCount = 0

    var lastFetchProjectSlug: String?
    var lastFetchFeaturesSlug: String?
    var lastCreateFeatureTitle: String?
    var lastCreateFeatureDescription: String?

    // MARK: - FeatureServiceProtocol

    func fetchProject(slug: String) async throws -> Project {
        fetchProjectCallCount += 1
        lastFetchProjectSlug = slug
        return try fetchProjectResult.get()
    }

    func fetchFeatures(slug: String, user: User?) async throws -> [Feature] {
        fetchFeaturesCallCount += 1
        lastFetchFeaturesSlug = slug
        return try fetchFeaturesResult.get()
    }

    func createFeature(
        slug: String,
        title: String,
        description: String,
        tags: [String]?,
        user: User?,
        imageData: Data?,
        fileName: String?
    ) async throws -> String {
        createFeatureCallCount += 1
        lastCreateFeatureTitle = title
        lastCreateFeatureDescription = description
        return try createFeatureResult.get()
    }
}
