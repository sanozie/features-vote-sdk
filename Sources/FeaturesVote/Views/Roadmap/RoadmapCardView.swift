import SwiftUI

/// Compact feature card for roadmap Kanban columns
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

    private var statusColor: Color {
        theme.color(for: feature.status)
    }

    // Strip HTML tags so the compact card shows clean plain text
    private var plainDescription: String {
        feature.description
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Left status accent stripe — clipped to card's rounded corners by clipShape below
            Rectangle()
                .fill(statusColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 10) {
                // Title
                Text(feature.title)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(theme.textPrimaryColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Description (HTML stripped for compact display)
                if !plainDescription.isEmpty {
                    Text(plainDescription)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(theme.textSecondaryColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Tags
                if config.ui.showTags, let tags = feature.tags, !tags.isEmpty {
                    TagsView(tags: tags, availableTags: availableTags)
                }

                // Footer: compact vote pill + comment count
                HStack(alignment: .center) {
                    // Vote button — standalone Button so it doesn't conflict with card tap
                    Button(action: onVote) {
                        HStack(spacing: 4) {
                            Image(systemName: feature.hasVoted ? "chevron.up.circle.fill" : "chevron.up.circle")
                                .font(.system(size: 13, weight: .semibold))
                            Text("\(feature.totalVotes)")
                                .font(.system(size: 12, weight: .bold))
                                .monospacedDigit()
                        }
                        .foregroundColor(feature.hasVoted ? theme.primaryColor : .secondary)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 9)
                        .background(
                            Capsule()
                                .fill(feature.hasVoted
                                    ? theme.primaryColor.opacity(0.12)
                                    : Color.gray.opacity(0.08))
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    if config.ui.showCommentCount && feature.commentCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 11))
                            Text("\(feature.commentCount)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), Color.gray.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        // Use onTapGesture instead of wrapping in Button to avoid nested-button gesture conflicts.
        // The vote Button above captures its own hit area; this fires for the rest of the card.
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

#if DEBUG
struct RoadmapCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            RoadmapCardView(
                feature: .mock(status: .inProgress, hasVoted: true),
                onVote: {},
                onTap: {}
            )
            RoadmapCardView(
                feature: .mock(status: .approved, commentCount: 3, hasVoted: false),
                onVote: {},
                onTap: {}
            )
            RoadmapCardView(
                feature: .mock(
                    title: "Dark mode support across all screens",
                    description: "<p>Users have been asking for <strong>dark mode</strong> for months.</p>",
                    status: .pending,
                    commentCount: 0,
                    hasVoted: false
                ),
                onVote: {},
                onTap: {}
            )
        }
        .padding()
        .frame(width: 280)
        .background(Color(hex: "#F3F4F6"))
    }
}
#endif
