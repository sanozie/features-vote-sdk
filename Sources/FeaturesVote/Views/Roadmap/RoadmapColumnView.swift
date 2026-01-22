import SwiftUI

/// Kanban column for a specific status
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

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: status.iconName)
                        .font(.caption)

                    Text(status.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(theme.color(for: status))

                Spacer()

                // Count badge
                Text("\(features.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.color(for: status))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.color(for: status).opacity(0.1))
            .cornerRadius(8)

            // Features
            if features.isEmpty {
                Text("No features")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
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
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#if DEBUG
struct RoadmapColumnView_Previews: PreviewProvider {
    static var previews: some View {
        RoadmapColumnView(
            status: .inProgress,
            features: [.mock(), .mock()],
            onVote: { _ in },
            onFeatureTap: { _ in }
        )
        .frame(width: 300)
        .padding()
    }
}
#endif
