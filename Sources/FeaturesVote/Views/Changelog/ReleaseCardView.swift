import SwiftUI

/// Release card view for changelog with glassmorphism READ MORE button
public struct ReleaseCardView: View {
    let release: Release
    let theme: Theme
    let hideDescriptionPreview: Bool

    @Environment(\.colorScheme) var colorScheme

    public init(
        release: Release,
        theme: Theme = .default,
        hideDescriptionPreview: Bool = true
    ) {
        self.release = release
        self.theme = theme
        self.hideDescriptionPreview = hideDescriptionPreview
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card content
            VStack(alignment: .leading, spacing: 16) {
                // Header: Date at top, then Title, then Version tag
                VStack(alignment: .leading, spacing: 8) {
                    // Release date (at top)
                    Text("Released on \(formattedDate)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    // Title (header text)
                    Text(release.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme.textPrimaryColor)
                        .lineLimit(2)

                    // Version tag (smaller badge)
                    HStack(spacing: 4) {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text(release.version)
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(theme.primaryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.primaryColor.opacity(0.1))
                    .cornerRadius(5)
                }

                if !hideDescriptionPreview {
                    // Short description preview (if available)
                    if !release.shortDescription.isEmpty {
                        Text(release.shortDescription)
                            .font(.system(size: 15))
                            .foregroundColor(theme.textPrimaryColor)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Long description preview with gradient overlay
                    ZStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 0) {
                            MarkdownView(markdown: release.longDescription, theme: theme)
                                .font(.system(size: 14))
                                .lineSpacing(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .frame(height: 120)
                        .clipped()

                        // Gradient overlay at bottom (fading to background color for smoother transition)
                        LinearGradient(
                            colors: [
                                (colorScheme == .dark ? Color.black : Color.white).opacity(0),
                                (colorScheme == .dark ? Color.black : Color.white).opacity(0.7),
                                (colorScheme == .dark ? Color.black : Color.white)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        .allowsHitTesting(false)
                    }
                }
            }
            .padding(20)

            // Glassmorphism READ MORE button (full width)
            GlassmorphismReadMoreButton(theme: theme)
        }
        .background(theme.surfaceColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: release.releasedAt)
    }
}

/// Minimal, right-aligned "Read more" affordance
struct GlassmorphismReadMoreButton: View {
    let theme: Theme

    var body: some View {
        HStack(spacing: 3) {
            Spacer()

            Text("Read more")
                .font(.system(size: 12, weight: .medium))

            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundColor(theme.primaryColor.opacity(0.85))
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

/// Helper to apply corner radius to specific corners
#if canImport(UIKit)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
#else
extension View {
    func cornerRadius(_ radius: CGFloat, corners: Any) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius))
    }
}
#endif

#if DEBUG
struct ReleaseCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Default: description hidden
            ReleaseCardView(release: Release.mock())
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color(hex: "#F3F4F6"))

            // With description preview shown
            ReleaseCardView(release: Release.mock(), hideDescriptionPreview: false)
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color(hex: "#F3F4F6"))

            // Dark mode (default: description hidden)
            ReleaseCardView(release: Release.mock())
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.black)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
