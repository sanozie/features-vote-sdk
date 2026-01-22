import SwiftUI

/// Feature header with title, vote button, and subscribe (matching list card layout)
public struct FeatureHeaderView: View {
    let feature: Feature
    let theme: Theme
    let onVote: () -> Void
    let onSubscribe: () -> Void
    let isSubscribing: Bool
    let shouldShowSubscribeButton: Bool

    public init(
        feature: Feature,
        theme: Theme,
        onVote: @escaping () -> Void,
        onSubscribe: @escaping () -> Void,
        isSubscribing: Bool = false,
        shouldShowSubscribeButton: Bool = true
    ) {
        self.feature = feature
        self.theme = theme
        self.onVote = onVote
        self.onSubscribe = onSubscribe
        self.isSubscribing = isSubscribing
        // TODO: Remove this once the API is updated
        // self.shouldShowSubscribeButton = shouldShowSubscribeButton
        self.shouldShowSubscribeButton = true
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left side: Title, status, and subscribe button
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(feature.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimaryColor)
                    .fixedSize(horizontal: false, vertical: true)

                // Status badge below title (matching list card)
                HStack(spacing: 12) {
                    StatusBadgeView(status: feature.status, theme: theme)

                    // Subscribe button (matching JS widget's ghost variant)
                    if shouldShowSubscribeButton {
                        Button(action: onSubscribe) {
                            HStack(spacing: 6) {
                                if isSubscribing {
                                    ProgressView()
                                        .frame(width: 14, height: 14)
                                } else {
                                    Image(systemName: feature.hasSubscribed ? "bell.fill" : "plus")
                                        .font(.system(size: 14))
                                }
                                Text(feature.hasSubscribed ? "Subscribed" : "Subscribe")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.clear)
                        }
                        .disabled(isSubscribing)
                        .opacity(isSubscribing ? 0.6 : 1.0)
                    }
                }
            }

            Spacer()

            // Right side: Vote button (matching list card)
            VoteButtonView(
                voteCount: feature.totalVotes,
                hasVoted: feature.hasVoted,
                theme: theme,
                onTap: onVote
            )
        }
    }
}
