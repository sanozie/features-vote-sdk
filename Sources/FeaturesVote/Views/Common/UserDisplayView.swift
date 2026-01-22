import SwiftUI

/// View that displays user information, fetching it if needed
public struct UserDisplayView: View {
    let userId: String?
    let size: CGFloat
    let showName: Bool
    let theme: Theme
    let isAdmin: Bool

    @State private var user: FeatureUser?
    @State private var isLoading = false

    private let userService = FeatureUserService()

    public init(
        userId: String?,
        size: CGFloat = 24,
        showName: Bool = true,
        theme: Theme = .default,
        isAdmin: Bool = false
    ) {
        self.userId = userId
        self.size = size
        self.showName = showName
        self.theme = theme
        self.isAdmin = isAdmin
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let userId = userId {
                if isLoading {
                    // Loading state
                    ProgressView()
                        .frame(width: size, height: size)
                    if showName {
                        Text("...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.textSecondaryColor)
                    }
                } else if let user = user {
                    // User loaded
                    AvatarView(
                        imageUrl: user.imgUrl,
                        name: user.name,
                        size: size
                    )
                    if showName {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(user.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(theme.textPrimaryColor)

                                if isAdmin {
                                    Text("ADMIN")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(theme.primaryColor.opacity(0.2))
                                        .foregroundColor(theme.primaryColor)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                } else {
                    // Fallback to userId (GUID)
                    AvatarView(
                        imageUrl: nil,
                        name: "User",
                        size: size
                    )
                    if showName {
                        Text("User")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(theme.textSecondaryColor)
                    }
                }
            } else {
                // Anonymous user
                AvatarView(
                    imageUrl: nil,
                    name: "Anonymous",
                    size: size
                )
                if showName {
                    Text("Anonymous")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.textSecondaryColor)
                }
            }
        }
        .task(id: userId) {
            guard let userId = userId, user == nil, !isLoading else { return }
            await loadUser(userId: userId)
        }
    }

    private func loadUser(userId: String) async {
        isLoading = true
        do {
            user = try await userService.fetchUser(userId: userId)
        } catch {
            // Silently fail and show fallback
            FVLog.debug("Failed to load user \(userId): \(error.localizedDescription)", category: .data)
        }
        isLoading = false
    }
}

#if DEBUG
struct UserDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            UserDisplayView(userId: "test123", size: 32, showName: true)
            UserDisplayView(userId: nil, size: 24, showName: true)
        }
        .padding()
    }
}
#endif
