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
        userService: UserService? = nil
    ) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(
            featureId: featureId,
            slug: slug,
            commentService: CommentService(),
            userService: userService ?? UserService()
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

            // Comment input
            CommentInputView(
                commentText: $viewModel.commentText,
                selectedImage: $viewModel.selectedImage,
                isSubmitting: viewModel.isSubmitting,
                theme: theme,
                localization: localization,
                onSubmit: {
                    Task {
                        _ = await viewModel.submitComment()
                    }
                }
            )

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
