import SwiftUI

/// Comments list view
public struct CommentsListView: View {
    @StateObject private var viewModel: CommentsViewModel

    private let theme: Theme
    private let config: Configuration
    private let localization: Localization
    private let projectLogoUrl: String?

    public init(
        featureId: String,
        slug: String,
        theme: Theme = .default,
        config: Configuration = .default,
        localization: Localization = .default,
        projectLogoUrl: String? = nil,
        projectCustomization: Customization? = nil,
        userService: UserService? = nil
    ) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(
            featureId: featureId,
            slug: slug,
            commentService: CommentService(),
            userService: userService ?? UserService(),
            configuration: config,
            projectCustomization: projectCustomization
        ))
        self.theme = theme
        self.config = config
        self.localization = localization
        self.projectLogoUrl = projectLogoUrl
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("\(localization.Comments) (\(viewModel.comments.count))")
                .font(.headline)
                .foregroundColor(theme.textPrimaryColor)
                .padding(.horizontal)

            // Permission error alert (tapping Send while blocked)
            .alert("Sign In Required", isPresented: Binding(
                get: { viewModel.permissionError != nil },
                set: { if !$0 { viewModel.clearPermissionError() } }
            )) {
                Button("OK", role: .cancel) { viewModel.clearPermissionError() }
            } message: {
                Text(viewModel.permissionError ?? "")
            }

            // Comment input — shown only when anonymous commenting is allowed
            if viewModel.isAnonymousCommentingBlocked {
                Text(viewModel.anonBlockedMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.06))
                    .cornerRadius(8)
                    .padding(.horizontal)
            } else {
                CommentInputView(
                    commentText: $viewModel.commentText,
                    selectedImage: $viewModel.selectedImage,
                    isSubmitting: viewModel.isSubmitting,
                    theme: theme,
                    localization: localization,
                    onSubmit: {
                        Task { _ = await viewModel.submitComment() }
                    }
                )
            }

            // Comments list
            if viewModel.isLoading {
                LoadingView()
                    .frame(height: 200)
            } else if viewModel.comments.isEmpty {
                EmptyStateView(
                    message: "No comments yet. Be the first to comment!",
                    icon: "bubble.left"
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.comments) { comment in
                        CommentRowView(
                            comment: comment,
                            theme: theme,
                            projectLogoUrl: projectLogoUrl,
                            onReactionTap: { emoji in
                                Task {
                                    if comment.userReactions.contains(emoji) {
                                        await viewModel.removeReaction(from: comment, emoji: emoji)
                                    } else {
                                        await viewModel.addReaction(to: comment, emoji: emoji)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .task {
            await viewModel.loadComments()
        }
    }
}
