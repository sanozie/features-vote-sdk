import SwiftUI

/// Full release detail view with markdown and features
public struct ReleaseDetailView: View {
    let release: Release
    let theme: Theme
    let availableTags: [Tag]
    let features: [Feature]
    let isLoadingFeatures: Bool
    let onLoadFeatures: () -> Void

    @Environment(\.colorScheme) var colorScheme

    public init(
        release: Release,
        theme: Theme = .default,
        availableTags: [Tag] = [],
        features: [Feature] = [],
        isLoadingFeatures: Bool = false,
        onLoadFeatures: @escaping () -> Void = {}
    ) {
        self.release = release
        self.theme = theme
        self.availableTags = availableTags
        self.features = features
        self.isLoadingFeatures = isLoadingFeatures
        self.onLoadFeatures = onLoadFeatures
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 16) {
                    // Version tag
                    HStack(spacing: 6) {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text(release.version)
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(theme.primaryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(theme.primaryColor.opacity(0.1))
                    .cornerRadius(8)

                    // Title
                    Text(release.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(theme.textPrimaryColor)
                        .fixedSize(horizontal: false, vertical: true)

                    // Release date
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text("Released on \(formattedDate)")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Short description
                if !release.shortDescription.isEmpty {
                    Text(release.shortDescription)
                        .font(.system(size: 17))
                        .foregroundColor(theme.textPrimaryColor.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                }

                Divider()
                    .padding(.horizontal, 20)

                // Long description (markdown)
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's New")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(theme.textPrimaryColor)

                    MarkdownView(markdown: release.longDescription, theme: theme)
                        .font(.system(size: 16))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)

                // Features section
                if !features.isEmpty || isLoadingFeatures {
                    Divider()
                        .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features in this Release")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(theme.textPrimaryColor)

                        if isLoadingFeatures {
                            // Loading skeletons
                            VStack(spacing: 12) {
                                ForEach(0..<3, id: \.self) { _ in
                                    FeatureSkeletonView()
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                ForEach(features, id: \.id) { feature in
                                    FeatureItemView(
                                        feature: feature,
                                        theme: theme,
                                        availableTags: availableTags
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Bottom spacing
                Color.clear.frame(height: 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(
            (colorScheme == .dark ? Color.black : Color(hex: "#F9FAFB"))
                .ignoresSafeArea()
        )
        .onAppear {
            if features.isEmpty && !isLoadingFeatures {
                onLoadFeatures()
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: release.releasedAt)
    }
}

/// Individual feature item in release
struct FeatureItemView: View {
    let feature: Feature
    let theme: Theme
    let availableTags: [Tag]

    var body: some View {
        HStack(spacing: 12) {
            // Tags
            if let tags = feature.tags, !tags.isEmpty {
                ForEach(tags.prefix(2), id: \.self) { tag in
                    let tagData = availableTags.first(where: { $0.label == tag })
                    let colors = chakraColors(for: tagData?.theme ?? "gray")

                    Text(tag)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(colors.text)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(colors.background)
                        )
                }
            }

            // Vote count (heart emoji + count)
            HStack(spacing: 4) {
                Text("❤️")
                    .font(.system(size: 11))
                Text("\(feature.totalVotes)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(6)

            // Feature title
            Text(feature.title)
                .font(.system(size: 15))
                .foregroundColor(theme.textPrimaryColor)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    /// Map Chakra UI colorScheme to actual colors (subtle variant)
    private func chakraColors(for theme: String) -> (background: Color, text: Color) {
        switch theme.lowercased() {
        case "gray":
            return (Color(hex: "#EDF2F7"), Color(hex: "#4A5568"))
        case "red":
            return (Color(hex: "#FED7D7"), Color(hex: "#C53030"))
        case "orange":
            return (Color(hex: "#FEEBC8"), Color(hex: "#C05621"))
        case "yellow":
            return (Color(hex: "#FEFCBF"), Color(hex: "#B7791F"))
        case "green":
            return (Color(hex: "#C6F6D5"), Color(hex: "#2F855A"))
        case "teal":
            return (Color(hex: "#B2F5EA"), Color(hex: "#285E61"))
        case "blue":
            return (Color(hex: "#BEE3F8"), Color(hex: "#2C5282"))
        case "cyan":
            return (Color(hex: "#C4F1F9"), Color(hex: "#00A3C4"))
        case "purple":
            return (Color(hex: "#E9D8FD"), Color(hex: "#6B46C1"))
        case "pink":
            return (Color(hex: "#FED7E2"), Color(hex: "#B83280"))
        default:
            return (Color(hex: "#EDF2F7"), Color(hex: "#4A5568"))
        }
    }
}

/// Skeleton loading view for features
struct FeatureSkeletonView: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 24)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 24)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(maxWidth: .infinity)
                .frame(height: 18)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

#if DEBUG
struct ReleaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReleaseDetailView(
                release: Release.mock(),
                features: [.mock(), .mock(), .mock()]
            )
        }
    }
}
#endif
