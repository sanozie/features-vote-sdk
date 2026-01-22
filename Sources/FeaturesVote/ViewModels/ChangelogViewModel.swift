import Foundation
import SwiftUI

/// ViewModel for the changelog view
@MainActor
public final class ChangelogViewModel: ObservableObject {
    // MARK: - Published State

    @Published private(set) var releases: [Release] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: APIError?
    @Published private(set) var releaseFeatures: [String: [Feature]] = [:] // releaseId: features
    @Published private(set) var loadingFeatureIds: Set<String> = [] // Track which releases are loading features

    // MARK: - Dependencies

    private let slug: String
    private let releaseService: ReleaseServiceProtocol

    // MARK: - Computed Properties

    /// Sorted releases (newest first)
    public var sortedReleases: [Release] {
        releases.sorted { $0.releasedAt > $1.releasedAt }
    }

    // MARK: - Initialization

    public init(
        slug: String,
        releaseService: ReleaseServiceProtocol
    ) {
        self.slug = slug
        self.releaseService = releaseService
    }

    // MARK: - Actions

    /// Load all releases
    public func loadReleases() async {
        isLoading = true
        error = nil

        do {
            releases = try await releaseService.fetchReleases(slug: slug)
            FVLog.debug("Loaded \(releases.count) releases", category: .data)
        } catch let apiError as APIError {
            error = apiError
            FVLog.error(apiError, message: "Failed to load releases", category: .network)
        } catch {
            self.error = .unknown(error.localizedDescription)
            FVLog.error(error, message: "Unknown error loading releases", category: .general)
        }

        isLoading = false
    }

    /// Load features for a specific release
    public func loadFeaturesForRelease(_ releaseId: String) async {
        // Skip if already loading or already loaded
        guard !loadingFeatureIds.contains(releaseId),
              releaseFeatures[releaseId] == nil else {
            return
        }

        loadingFeatureIds.insert(releaseId)

        do {
            let features = try await releaseService.fetchFeaturesByRelease(releaseId: releaseId)
            releaseFeatures[releaseId] = features
            FVLog.debug("Loaded \(features.count) features for release \(releaseId)", category: .data)
        } catch let apiError as APIError {
            error = apiError
            FVLog.error(apiError, message: "Failed to load features for release \(releaseId)", category: .network)
        } catch {
            self.error = .unknown(error.localizedDescription)
            FVLog.error(error, message: "Failed to load features for release \(releaseId)", category: .general)
        }

        loadingFeatureIds.remove(releaseId)
    }

    /// Check if features are loading for a release
    public func isLoadingFeatures(for release: Release) -> Bool {
        loadingFeatureIds.contains(release.id)
    }

    /// Get features for a release
    public func features(for release: Release) -> [Feature] {
        releaseFeatures[release.id] ?? []
    }

    /// Refresh releases
    public func refresh() async {
        await loadReleases()
    }
}
