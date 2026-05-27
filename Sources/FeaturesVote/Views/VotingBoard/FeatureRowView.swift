import SwiftUI

/// Feature row view for the voting board list
public struct FeatureRowView: View {
    let feature: Feature
    let theme: Theme
    let config: Configuration
    let availableTags: [Tag]
    let upvoteIcon: Image
    let onVote: () -> Void

    public init(
        feature: Feature,
        theme: Theme = .default,
        config: Configuration = .default,
        availableTags: [Tag] = [],
        upvoteIcon: Image = Image(systemName: "chevron.up"),
        onVote: @escaping () -> Void
    ) {
        self.feature = feature
        self.theme = theme
        self.config = config
        self.availableTags = availableTags
        self.upvoteIcon = upvoteIcon
        self.onVote = onVote
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Main Content
            VStack(alignment: .leading, spacing: 14) {
                // Title
                Text(feature.title)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(theme.textPrimaryColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                // Description
                HTMLText(feature.description)
                    .lineLimit(config.ui.maxDescriptionLines)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                // Tags
                if config.ui.showTags, let tags = feature.tags, !tags.isEmpty {
                    TagsView(tags: tags, availableTags: availableTags)
                        .padding(.top, 2)
                }

                // Footer (Avatar, comment count, status badge)
                HStack(spacing: 10) {
                    // User avatar + name
                    if config.ui.showAvatars {
                        UserDisplayView(
                            userId: feature.userId,
                            size: 24,
                            showName: true,
                            theme: theme
                        )
                    }

                    Spacer()

                    // Comment count
                    if config.ui.showCommentCount && feature.commentCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 11))
                            Text("\(feature.commentCount)")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                    }

                    // Status badge
                    if config.ui.showStatusBadge {
                        StatusBadgeView(status: feature.status, theme: theme)
                    }
                }
                .padding(.top, 6)
            }

            // Vote Button (right-aligned)
            VoteButtonView(
                voteCount: feature.totalVotes,
                hasVoted: feature.hasVoted,
                theme: theme,
                upvoteIcon: upvoteIcon,
                onTap: onVote
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(theme.surfaceColor)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), Color.gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
}

#if DEBUG
struct FeatureRowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(hex: "#F3F4F6").edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                FeatureRowView(
                    feature: .mock(),
                    onVote: {}
                )
                .padding(.horizontal)
            }
        }
    }
}
#endif
