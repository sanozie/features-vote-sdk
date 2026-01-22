import SwiftUI

/// Feature detail view with comments
public struct FeatureDetailView: View {
    @StateObject private var viewModel: FeatureDetailViewModel

    private let slug: String
    private let theme: Theme
    private let config: Configuration
    private let localization: Localization
    private let projectLogoUrl: String?
    private let onFeatureUpdated: ((Feature) -> Void)?

    public init(
        feature: Feature,
        slug: String,
        theme: Theme = .default,
        config: Configuration = .default,
        localization: Localization = .default,
        projectLogoUrl: String? = nil,
        userService: UserService? = nil,
        onFeatureUpdated: ((Feature) -> Void)? = nil
    ) {
        self.slug = slug
        _viewModel = StateObject(wrappedValue: FeatureDetailViewModel(
            feature: feature,
            slug: slug,
            voteService: VoteService(),
            commentService: CommentService(),
            subscriptionService: SubscriptionService(),
            userService: userService ?? UserService()
        ))
        self.theme = theme
        self.config = config
        self.localization = localization
        self.projectLogoUrl = projectLogoUrl
        self.onFeatureUpdated = onFeatureUpdated
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Success/Error alerts (matching JS widget)
                if let message = viewModel.subscriptionMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            viewModel.dismissSubscriptionMessage()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                if let error = viewModel.subscriptionError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            viewModel.dismissSubscriptionMessage()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                // Header
                FeatureHeaderView(
                    feature: viewModel.feature,
                    theme: theme,
                    onVote: {
                        Task { await viewModel.toggleVote() }
                    },
                    onSubscribe: {
                        Task { await viewModel.toggleSubscription() }
                    },
                    isSubscribing: viewModel.isSubscribing,
                    shouldShowSubscribeButton: viewModel.shouldShowSubscribeButton
                )
                .padding()

                Divider()

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(theme.textPrimaryColor)

                    HTMLText(viewModel.feature.description, fontSize: 16)
                }
                .padding(.horizontal)

                // Tags
                if let tags = viewModel.feature.tags, !tags.isEmpty {
                    TagsView(tags: tags)
                        .padding(.horizontal)
                }

                Divider()

                // Created by section
                HStack(spacing: 8) {
                    Text("Created by")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    UserDisplayView(
                        userId: viewModel.feature.userId,
                        size: 20,
                        showName: true,
                        theme: theme
                    )
                }
                .padding(.horizontal)

                Divider()

                // Comments section
                CommentsListView(
                    featureId: viewModel.feature.id,
                    slug: slug,
                    theme: theme,
                    config: config,
                    localization: localization,
                    projectLogoUrl: projectLogoUrl,
                    userService: viewModel.userService
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.feature.hasSubscribed) { _ in
            onFeatureUpdated?(viewModel.feature)
        }
        .onChange(of: viewModel.feature.hasVoted) { _ in
            onFeatureUpdated?(viewModel.feature)
        }
        .onChange(of: viewModel.feature.totalVotes) { _ in
            onFeatureUpdated?(viewModel.feature)
        }
    }
}

#if DEBUG
struct FeatureDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeatureDetailView(
                feature: .mock(),
                slug: "demo"
            )
        }
    }
}
#endif
