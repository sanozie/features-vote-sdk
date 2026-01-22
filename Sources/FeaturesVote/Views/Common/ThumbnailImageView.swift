import SwiftUI

/// A thumbnail image view that expands to full-screen when tapped
public struct ThumbnailImageView: View {
    let imageURL: URL?
    let maxThumbnailHeight: CGFloat
    let cornerRadius: CGFloat
    let theme: Theme

    @State private var isShowingViewer = false
    @State private var imageLoadFailed = false

    public init(
        imageURL: URL?,
        maxThumbnailHeight: CGFloat = 150,
        cornerRadius: CGFloat = 8,
        theme: Theme = .default
    ) {
        self.imageURL = imageURL
        self.maxThumbnailHeight = maxThumbnailHeight
        self.cornerRadius = cornerRadius
        self.theme = theme
    }

    public var body: some View {
        if let url = imageURL {
            Button(action: {
                if !imageLoadFailed {
                    isShowingViewer = true
                }
            }) {
                thumbnailContent(url: url)
            }
            .buttonStyle(ThumbnailButtonStyle())
            #if os(iOS)
            .fullScreenCover(isPresented: $isShowingViewer) {
                ImageViewerOverlay(imageURL: url) {
                    isShowingViewer = false
                }
            }
            #else
            .sheet(isPresented: $isShowingViewer) {
                ImageViewerOverlay(imageURL: url) {
                    isShowingViewer = false
                }
                .frame(minWidth: 600, minHeight: 500)
            }
            #endif
        }
    }

    @ViewBuilder
    private func thumbnailContent(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                thumbnailPlaceholder
            case .success(let image):
                ZStack(alignment: .bottomTrailing) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: maxThumbnailHeight)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(cornerRadius)

                    // Expand icon overlay
                    expandIndicator
                }
                .onAppear {
                    imageLoadFailed = false
                }
            case .failure:
                failedThumbnail
                    .onAppear {
                        imageLoadFailed = true
                    }
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxHeight: maxThumbnailHeight)
    }

    private var thumbnailPlaceholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(theme.surfaceColor.opacity(0.5))
            .frame(height: maxThumbnailHeight * 0.6)
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            )
    }

    private var failedThumbnail: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(theme.surfaceColor.opacity(0.3))
            .frame(height: maxThumbnailHeight * 0.5)
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                    Text("Image unavailable")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            )
    }

    private var expandIndicator: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(6)
            .background(Color.black.opacity(0.5))
            .cornerRadius(4)
            .padding(8)
    }
}

/// Custom button style for thumbnails that provides subtle feedback
struct ThumbnailButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(Animation.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#if DEBUG
struct ThumbnailImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ThumbnailImageView(
                imageURL: URL(string: "https://picsum.photos/400/300"),
                maxThumbnailHeight: 150,
                theme: .default
            )

            ThumbnailImageView(
                imageURL: URL(string: "https://invalid-url-test.com/image.jpg"),
                maxThumbnailHeight: 150,
                theme: .default
            )
        }
        .padding()
    }
}
#endif
