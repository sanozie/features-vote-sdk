import SwiftUI

/// Main voting board view
public struct VotingBoardView: View {
    @StateObject private var viewModel: VotingBoardViewModel
    @State private var showCreateSheet = false
    @State private var isSearchExpanded = false
    @FocusState private var isSearchFocused: Bool

    private let theme: Theme
    private let config: Configuration
    private let localization: Localization

    public init(
        viewModel: VotingBoardViewModel,
        theme: Theme = .default,
        config: Configuration = .default,
        localization: Localization = .default
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme
        self.config = config
        self.localization = localization
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()

                content
            }
            .tint(theme.primaryColor)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.project?.customization.votingBoardTitle ?? localization.votingBoardTitle)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(theme.textPrimaryColor)
                }
            }
            #if os(iOS)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            // Confirmation dialog for voting
            .alert("Confirm Vote", isPresented: $viewModel.showVoteConfirmation) {
                Button("Vote") {
                    Task { await viewModel.confirmPendingVote() }
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelPendingVote()
                }
            } message: {
                Text("Are you sure you want to cast your vote for this feature?")
            }
            // Permission error (anonymous user blocked)
            .alert(
                "Sign In Required",
                isPresented: $viewModel.showPermissionAlert,
                actions: { Button("OK", role: .cancel) { viewModel.clearPermissionError() } },
                message: { Text(viewModel.permissionError ?? "") }
            )
            .sheet(isPresented: $showCreateSheet, onDismiss: {
                Task { await viewModel.refresh() }
            }) {
                CreateFeatureSheet(
                    slug: viewModel.slug,
                    availableTags: viewModel.project?.customization.tags ?? [],
                    projectCustomization: viewModel.project?.customization,
                    theme: theme,
                    config: config,
                    localization: localization,
                    userService: viewModel.userService
                )
            }
        }
        .task {
            await viewModel.loadProject()
            await viewModel.loadFeatures()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.features.isEmpty {
            LoadingView()
        } else if let error = viewModel.error, viewModel.features.isEmpty {
            ErrorView(error: error) {
                Task { await viewModel.loadFeatures() }
            }
        } else {
            VStack(spacing: 0) {
                headerView

                if viewModel.filteredFeatures.isEmpty {
                    emptyState
                } else {
                    featureList
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                if !isSearchExpanded {
                    FilterTabsView(selectedTab: $viewModel.selectedTab, theme: theme)
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                }

                if isSearchExpanded {
                    expandedSearchView
                        .frame(maxWidth: .infinity)
                } else {
                    collapsedSearchButton
                }

                if !isSearchExpanded {
                    createButton
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSearchExpanded)
        }
        .background(
            theme.backgroundColor
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Search Components

    private var collapsedSearchButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isSearchExpanded = true
                isSearchFocused = true
            }
        } label: {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(theme.primaryColor.opacity(0.8))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var expandedSearchView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(theme.primaryColor.opacity(0.7))

            TextField(localization.searchPlaceholder, text: $viewModel.searchText)
                .font(.system(size: 15))
                .textFieldStyle(.plain)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    isSearchFocused = false
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.4))
                }
                .buttonStyle(.plain)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 0.8))
                ))
            }

            // Close button — clears search text too
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.searchText = ""
                    isSearchExpanded = false
                    isSearchFocused = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1.5)
        )
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .leading)),
            removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .leading))
        ))
    }

    private var createButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showCreateSheet = true
            }
        } label: {
            Text(localization.createFeatureButton)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 40)
                .background(
                    LinearGradient(
                        colors: [theme.primaryColor, theme.primaryColor.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)
                .shadow(color: theme.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Empty / List

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(message: localization.noFeaturesMessage)
            Spacer()
        }
    }

    private var featureList: some View {
        featureScrollView
            .navigationDestination(for: Feature.self) { feature in
                // Always resolve the freshest copy from the viewModel to capture any
                // vote changes made from the list before navigating.
                let latestFeature = viewModel.features.first(where: { $0.id == feature.id }) ?? feature
                FeatureDetailView(
                    feature: latestFeature,
                    slug: viewModel.slug,
                    theme: theme,
                    config: config,
                    localization: localization,
                    projectLogoUrl: viewModel.project?.logoUrl,
                    projectCustomization: viewModel.project?.customization,
                    userService: viewModel.userService,
                    onFeatureUpdated: { updatedFeature in
                        viewModel.updateFeature(updatedFeature)
                    }
                )
                .onDisappear {
                    Task { await viewModel.refresh() }
                }
            }
    }

    /// The scroll view, conditionally wrapped with `.refreshable` based on config.
    @ViewBuilder
    private var featureScrollView: some View {
        if config.ui.enablePullToRefresh {
            ScrollView {
                featureListContent
            }
            .refreshable {
                await viewModel.refresh()
            }
        } else {
            ScrollView {
                featureListContent
            }
        }
    }

    private var featureListContent: some View {
        LazyVStack(spacing: 20) {
            ForEach(viewModel.filteredFeatures) { feature in
                NavigationLink(value: feature) {
                    FeatureRowView(
                        feature: feature,
                        theme: theme,
                        config: config,
                        availableTags: viewModel.project?.customization.tags ?? [],
                        upvoteIcon: config.buttons.upvoteIcon,
                        onVote: {
                            viewModel.requestVote(for: feature)
                        }
                    )
                }
                .buttonStyle(.plain)
            }

            footerView
                .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - Footer

    private var footerView: some View {
        VStack(spacing: 16) {
            Divider()

            HStack {
                HStack(spacing: 8) {
                    let user = viewModel.userService.getUser()
                    AvatarView(
                        imageUrl: user.imgUrl,
                        name: user.name ?? user.email ?? "User",
                        size: 28
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        if let name = user.name {
                            Text(name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(theme.textPrimaryColor)
                        }
                        if let email = user.email {
                            Text(email)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        } else if user.name == nil {
                            Text(viewModel.isAnonymous ? "Anonymous" : "User")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(theme.textPrimaryColor)
                        }
                    }
                }

                Spacer()

                // Watermark: respect both local config and server override
                if viewModel.shouldShowWatermark {
                    Link(destination: URL(string: "https://features.vote")!) {
                        HStack(spacing: 4) {
                            Text("Powered by")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Text("Features.Vote")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(theme.primaryColor)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Helper Views

struct CreateFeatureSheet: View {
    let slug: String
    let availableTags: [Tag]
    let projectCustomization: Customization?
    let theme: Theme
    let config: Configuration
    let localization: Localization
    var userService: UserService? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CreateFeatureView(
            slug: slug,
            availableTags: availableTags,
            theme: theme,
            config: config,
            localization: localization,
            projectCustomization: projectCustomization,
            onSuccess: {
                dismiss()
            },
            userService: userService
        )
    }
}

#if DEBUG
struct VotingBoardView_Previews: PreviewProvider {
    static var previews: some View {
        VotingBoardView(
            viewModel: VotingBoardViewModel(
                slug: "demo",
                featureService: FeatureService(),
                voteService: VoteService(),
                userService: UserService()
            )
        )
    }
}
#endif
