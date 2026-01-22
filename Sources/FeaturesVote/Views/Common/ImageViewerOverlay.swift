import SwiftUI
#if os(macOS)
import AppKit
#endif

/// Full-screen image viewer overlay with zoom, pan, and close functionality
public struct ImageViewerOverlay: View {
    let imageURL: URL
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageSize: CGSize = .zero

    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 4.0

    public init(imageURL: URL, onDismiss: @escaping () -> Void) {
        self.imageURL = imageURL
        self.onDismiss = onDismiss
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dimmed background
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }

                // Image with zoom and pan
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newScale = lastScale * value
                                        scale = min(max(newScale, minScale), maxScale)
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        // Reset offset if zoomed out
                                        if scale <= 1.0 {
                                            withAnimation(.spring(response: 0.3)) {
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        }
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        if scale > 1.0 {
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                        // Constrain offset to reasonable bounds
                                        constrainOffset(in: geometry.size)
                                    }
                            )
                            .onTapGesture(count: 2) {
                                // Double tap to zoom in/out
                                withAnimation(.spring(response: 0.3)) {
                                    if scale > 1.0 {
                                        scale = 1.0
                                        lastScale = 1.0
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        scale = 2.5
                                        lastScale = 2.5
                                    }
                                }
                            }
                    case .failure:
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Failed to load image")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Close button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    }
                    Spacer()
                }

                // Zoom indicator (shows briefly when zooming)
                VStack {
                    Spacer()
                    if scale != 1.0 {
                        Text("\(Int(scale * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(16)
                            .padding(.bottom, 24)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: scale)
            }
        }
    }

    private func constrainOffset(in size: CGSize) {
        // Calculate the maximum allowed offset based on scale
        let maxOffsetX = max(0, (size.width * (scale - 1)) / 2)
        let maxOffsetY = max(0, (size.height * (scale - 1)) / 2)

        withAnimation(.spring(response: 0.3)) {
            offset = CGSize(
                width: min(max(offset.width, -maxOffsetX), maxOffsetX),
                height: min(max(offset.height, -maxOffsetY), maxOffsetY)
            )
            lastOffset = offset
        }
    }
}

/// View modifier to present the image viewer as a full-screen cover
struct ImageViewerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let imageURL: URL?

    func body(content: Content) -> some View {
        content
            #if os(iOS)
            .fullScreenCover(isPresented: $isPresented) {
                if let url = imageURL {
                    ImageViewerOverlay(imageURL: url) {
                        isPresented = false
                    }
                    .background(ClearBackgroundView())
                }
            }
            #else
            .sheet(isPresented: $isPresented) {
                if let url = imageURL {
                    ImageViewerOverlay(imageURL: url) {
                        isPresented = false
                    }
                    .frame(minWidth: 600, minHeight: 500)
                }
            }
            #endif
    }
}

/// Helper to make full screen cover background transparent
#if os(iOS)
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#elseif os(macOS)
struct ClearBackgroundView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif

extension View {
    /// Present an image viewer overlay
    func imageViewer(isPresented: Binding<Bool>, imageURL: URL?) -> some View {
        self.modifier(ImageViewerModifier(isPresented: isPresented, imageURL: imageURL))
    }
}

#if DEBUG
struct ImageViewerOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewerOverlay(
            imageURL: URL(string: "https://picsum.photos/800/600")!,
            onDismiss: {}
        )
    }
}
#endif
