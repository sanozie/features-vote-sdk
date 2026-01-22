import SwiftUI

/// User avatar view with fallback
public struct AvatarView: View {
    let imageUrl: String?
    let name: String?
    let size: CGFloat

    public init(imageUrl: String?, name: String?, size: CGFloat = 32) {
        self.imageUrl = imageUrl
        self.name = name
        self.size = size
    }

    public var body: some View {
        Group {
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        fallbackView
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                fallbackView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var fallbackView: some View {
        ZStack {
            Circle()
                .fill(Color(hex: avatarColor))

            Text(initials)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(.white)
        }
    }

    private var initials: String {
        guard let name = name, !name.isEmpty else {
            return "?"
        }

        let components = name.components(separatedBy: .whitespaces)
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }

    /// Generate a consistent color based on the name
    private var avatarColor: String {
        guard let name = name, !name.isEmpty else {
            return "#9CA3AF"
        }
        let hash = abs(name.hashValue)
        let colors = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8",
            "#F7B731", "#5F27CD", "#00D2D3", "#FF9FF3", "#54A0FF",
            "#48DBFB", "#0ABDE3", "#10AC84", "#EE5A6F", "#C44569"
        ]
        return colors[hash % colors.count]
    }
}

#if DEBUG
struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AvatarView(imageUrl: nil, name: "John Doe", size: 40)
            AvatarView(imageUrl: nil, name: "Jane Smith", size: 32)
            AvatarView(imageUrl: nil, name: nil, size: 24)
        }
        .padding()
    }
}
#endif
