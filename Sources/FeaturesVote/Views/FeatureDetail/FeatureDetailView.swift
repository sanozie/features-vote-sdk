import SwiftUI

/// Feature detail view with comments
public struct FeatureDetailView: View {
    @StateObject private var viewModel: FeatureDetailViewModel

    private let slug: String
    private let theme: Theme
    private let config: Configuration
    private let localization: Localization
    private let projectLogoUrl: String?
    private let projectCustomization: Customization?
    private let onFeatureUpdated: ((Feature) -> Void)?

    public init(
        feature: Feature,
        slug: String,
        theme: Theme = .default,
        config: Configuration = .default,
        localization: Localization = .default,
        projectLogoUrl: String? = nil,
        projectCustomization: Customization? = nil,
        userService: UserService? = nil,
        onFeatureUpdated: ((Feature) -> Void)? = nil
    ) {
        self.slug = slug
        self.projectLogoUrl = projectLogoUrl
        self.projectCustomization = projectCustomization
        _viewModel = StateObject(wrappedValue: FeatureDetailViewModel(
            feature: feature,
            slug: slug,
            voteService: VoteService(),
            commentService: CommentService(),
            subscriptionService: SubscriptionService(),
            userService: userService ?? UserService(),
            configuration: config,
            projectCustomization: projectCustomization
        ))
        self.theme = theme
        self.config = config
        self.localization = localization
        self.onFeatureUpdated = onFeatureUpdated
    }

    public var body: some View {
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    subscriptionBanners
                    featureHeader
                    Divider()
                    descriptionSection
                    tagsSection
                    Divider()
                    createdBySection
                    Divider()
                    commentsSection
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onChange(of: viewModel.feature.hasSubscribed) { _ in onFeatureUpdated?(viewModel.feature) }
        .onChange(of: viewModel.feature.hasVoted)      { _ in onFeatureUpdated?(viewModel.feature) }
        .onChange(of: viewModel.feature.totalVotes)    { _ in onFeatureUpdated?(viewModel.feature) }
        .alert("Confirm Vote", isPresented: $viewModel.showVoteConfirmation) {
            Button("Vote") { Task { await viewModel.confirmPendingVote() } }
            Button("Cancel", role: .cancel) { viewModel.cancelPendingVote() }
        } message: {
            Text("Are you sure you want to cast your vote for this feature?")
        }
        .alert("Unsubscribe", isPresented: $viewModel.showUnsubscribeConfirmation) {
            Button("Unsubscribe", role: .destructive) { Task { await viewModel.confirmUnsubscribe() } }
            Button("Cancel", role: .cancel) { viewModel.cancelUnsubscribe() }
        } message: {
            Text("Are you sure you want to unsubscribe from notifications for this post?")
        }
        .alert("Sign In Required", isPresented: $viewModel.showPermissionAlert) {
            Button("OK", role: .cancel) { viewModel.clearPermissionError() }
        } message: {
            Text(viewModel.permissionError ?? "")
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var subscriptionBanners: some View {
        if let message = viewModel.subscriptionMessage {
            infoBanner(text: message, color: .green, icon: "checkmark.circle.fill") {
                viewModel.dismissSubscriptionMessage()
            }
        }
        if let error = viewModel.subscriptionError {
            infoBanner(text: error, color: .red, icon: "exclamationmark.triangle.fill") {
                viewModel.dismissSubscriptionMessage()
            }
        }
    }

    private var featureHeader: some View {
        FeatureHeaderView(
            feature: viewModel.feature,
            theme: theme,
            config: config,
            onVote: { viewModel.requestVote() },
            onSubscribe: { viewModel.requestSubscriptionToggle() },
            isSubscribing: viewModel.isSubscribing,
            shouldShowSubscribeButton: viewModel.shouldShowSubscribeButton
        )
        .padding()
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(theme.textPrimaryColor)
            HTMLText(viewModel.feature.description, fontSize: 16)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var tagsSection: some View {
        if let tags = viewModel.feature.tags, !tags.isEmpty {
            TagsView(tags: tags)
                .padding(.horizontal)
        }
    }

    private var createdBySection: some View {
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
    }

    private var commentsSection: some View {
        CommentsListView(
            featureId: viewModel.feature.id,
            slug: slug,
            theme: theme,
            config: config,
            localization: localization,
            projectLogoUrl: projectLogoUrl,
            projectCustomization: projectCustomization,
            userService: viewModel.userService
        )
    }

    // MARK: - Helper

    @ViewBuilder
    private func infoBanner(
        text: String,
        color: Color,
        icon: String,
        onDismiss: @escaping () -> Void
    ) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(color)
            Text(text).font(.system(size: 14)).foregroundColor(.primary)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark").font(.system(size: 12)).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#if DEBUG
struct FeatureDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeatureDetailView(feature: .mock(), slug: "demo")
        }
    }
}
#endif
