import SwiftUI

/// Feature header with title, vote button, and subscribe button
public struct FeatureHeaderView: View {
    let feature: Feature
    let theme: Theme
    let config: Configuration
    let onVote: () -> Void
    let onSubscribe: () -> Void
    let isSubscribing: Bool
    let shouldShowSubscribeButton: Bool

    public init(
        feature: Feature,
        theme: Theme,
        config: Configuration = .default,
        onVote: @escaping () -> Void,
        onSubscribe: @escaping () -> Void,
        isSubscribing: Bool = false,
        shouldShowSubscribeButton: Bool = true
    ) {
        self.feature = feature
        self.theme = theme
        self.config = config
        self.onVote = onVote
        self.onSubscribe = onSubscribe
        self.isSubscribing = isSubscribing
        self.shouldShowSubscribeButton = shouldShowSubscribeButton
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left: Title, status badge, subscribe
            VStack(alignment: .leading, spacing: 12) {
                Text(feature.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimaryColor)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    StatusBadgeView(status: feature.status, theme: theme)

                    if shouldShowSubscribeButton {
                        Button(action: onSubscribe) {
                            HStack(spacing: 6) {
                                if isSubscribing {
                                    ProgressView()
                                        .frame(width: 14, height: 14)
                                        .tint(theme.primaryColor)
                                } else {
                                    // Use configurable subscribe/subscribed icons
                                    (feature.hasSubscribed
                                        ? config.buttons.subscribedIcon
                                        : config.buttons.subscribeIcon)
                                        .font(.system(size: 13))
                                }
                                Text(feature.hasSubscribed ? "Subscribed" : "Subscribe")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(
                                feature.hasSubscribed
                                    ? theme.primaryColor
                                    : theme.primaryColor.opacity(0.75)
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(theme.primaryColor.opacity(0.08))
                            .cornerRadius(8)
                        }
                        .disabled(isSubscribing)
                        .opacity(isSubscribing ? 0.6 : 1.0)
                    }
                }
            }

            Spacer()

            // Right: Vote button (uses configurable upvote icon)
            VoteButtonView(
                voteCount: feature.totalVotes,
                hasVoted: feature.hasVoted,
                theme: theme,
                upvoteIcon: config.buttons.upvoteIcon,
                onTap: onVote
            )
        }
    }
}
