import SwiftUI

/// Compact feature card for roadmap view
public struct RoadmapCardView: View {
    let feature: Feature
    let theme: Theme
    let config: Configuration
    let availableTags: [Tag]
    let onVote: () -> Void
    let onTap: () -> Void

    public init(
        feature: Feature,
        theme: Theme = .default,
        config: Configuration = .default,
        availableTags: [Tag] = [],
        onVote: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) {
        self.feature = feature
        self.theme = theme
        self.config = config
        self.availableTags = availableTags
        self.onVote = onVote
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(feature.title)
                    .font(theme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimaryColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Description (truncated)
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(theme.textSecondaryColor)
                    .lineLimit(2)

                // Tags
                if config.ui.showTags, let tags = feature.tags, !tags.isEmpty {
                    TagsView(tags: tags, availableTags: availableTags)
                }

                Divider()

                // Footer
                HStack {
                    // Vote button
                    Button(action: onVote) {
                        HStack(spacing: 4) {
                            Image(systemName: feature.hasVoted ? "arrow.up.circle.fill" : "arrow.up.circle")
                            Text("\(feature.totalVotes)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(feature.hasVoted ? theme.primaryColor : .secondary)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Comment count
                    if config.ui.showCommentCount && feature.commentCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                            Text("\(feature.commentCount)")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.surfaceColor)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct RoadmapCardView_Previews: PreviewProvider {
    static var previews: some View {
        RoadmapCardView(
            feature: .mock(),
            onVote: {},
            onTap: {}
        )
        .padding()
        .frame(width: 250)
    }
}
#endif
