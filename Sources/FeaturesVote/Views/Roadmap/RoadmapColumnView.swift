import SwiftUI

/// Kanban column for a specific feature status
public struct RoadmapColumnView: View {
    let status: FeatureStatus
    let features: [Feature]
    let theme: Theme
    let config: Configuration
    let availableTags: [Tag]
    let onVote: (Feature) -> Void
    let onFeatureTap: (Feature) -> Void

    public init(
        status: FeatureStatus,
        features: [Feature],
        theme: Theme = .default,
        config: Configuration = .default,
        availableTags: [Tag] = [],
        onVote: @escaping (Feature) -> Void,
        onFeatureTap: @escaping (Feature) -> Void
    ) {
        self.status = status
        self.features = features
        self.theme = theme
        self.config = config
        self.availableTags = availableTags
        self.onVote = onVote
        self.onFeatureTap = onFeatureTap
    }

    private var statusColor: Color {
        theme.color(for: status)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            columnHeader

            if features.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(features) { feature in
                            RoadmapCardView(
                                feature: feature,
                                theme: theme,
                                config: config,
                                availableTags: availableTags,
                                onVote: { onVote(feature) },
                                onTap: { onFeatureTap(feature) }
                            )
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
        )
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Sub-views

    private var columnHeader: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: status.iconName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(statusColor)
            }

            Text(status.displayName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(statusColor)

            Spacer()

            Text("\(features.count)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(statusColor))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "tray")
                .font(.system(size: 22))
                .foregroundColor(statusColor.opacity(0.3))
            Text("No features")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}

#if DEBUG
struct RoadmapColumnView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(alignment: .top, spacing: 16) {
            RoadmapColumnView(
                status: .inProgress,
                features: [.mock(status: .inProgress, hasVoted: true), .mock(status: .inProgress)],
                onVote: { _ in },
                onFeatureTap: { _ in }
            )
            .frame(width: 280)

            RoadmapColumnView(
                status: .approved,
                features: [],
                onVote: { _ in },
                onFeatureTap: { _ in }
            )
            .frame(width: 280)
        }
        .padding()
        .background(Color(hex: "#F3F4F6"))
    }
}
#endif
