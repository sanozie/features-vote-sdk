import SwiftUI

/// Changelog view showing product releases and updates (matching JS widget)
public struct ChangelogView: View {
    @StateObject private var viewModel: ChangelogViewModel

    private let slug: String
    private let theme: Theme
    private let config: Configuration
    private let availableTags: [Tag]

    public init(
        slug: String,
        theme: Theme = .default,
        config: Configuration = .default,
        availableTags: [Tag] = []
    ) {
        self.slug = slug
        self.theme = theme
        self.config = config
        self.availableTags = availableTags
        _viewModel = StateObject(wrappedValue: ChangelogViewModel(
            slug: slug,
            releaseService: ReleaseService()
        ))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    // Loading skeletons (matching compact card structure)
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(0..<2, id: \.self) { _ in
                                ReleaseSkeletonView()
                            }
                        }
                        .padding()
                    }
                } else if let error = viewModel.error {
                    // Error state
                    ErrorView(error: error) {
                        Task {
                            await viewModel.loadReleases()
                        }
                    }
                } else if viewModel.sortedReleases.isEmpty {
                    // Empty state
                    EmptyStateView(
                        message: "No releases yet",
                        icon: "shippingbox"
                    )
                } else {
                    // Releases list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.sortedReleases, id: \.id) { release in
                                NavigationLink(value: release) {
                                    ReleaseCardView(
                                        release: release,
                                        theme: theme
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                    .navigationDestination(for: Release.self) { release in
                        ReleaseDetailView(
                            release: release,
                            theme: theme,
                            availableTags: availableTags,
                            features: viewModel.features(for: release),
                            isLoadingFeatures: viewModel.isLoadingFeatures(for: release),
                            onLoadFeatures: {
                                Task {
                                    await viewModel.loadFeaturesForRelease(release.id)
                                }
                            }
                        )
                    }
                }
            }
            .navigationTitle("Changelog")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .task {
                await viewModel.loadReleases()
            }
        }
    }
}

/// Skeleton loading view for releases (matches compact card structure)
struct ReleaseSkeletonView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card content
            VStack(alignment: .leading, spacing: 8) {
                // Date skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 140, height: 13)

                // Title skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 220, height: 17)

                // Version tag skeleton
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 70, height: 24)
            }
            .padding(20)

            // READ MORE button skeleton
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 14)
                Spacer()
            }
            .padding(.vertical, 16)
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#if DEBUG
struct ChangelogView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogView(slug: "demo")
    }
}
#endif
