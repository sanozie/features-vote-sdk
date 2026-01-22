import SwiftUI

/// Single comment row view
public struct CommentRowView: View {
    let comment: Comment
    let theme: Theme
    let projectLogoUrl: String?
    let onReactionTap: (String) -> Void

    private static let storageBaseURL = "https://gsvxtxhayvayudcjyhbw.supabase.co/storage/v1/object/public/images"

    /// Resolves a file URL - if it's already a full URL, use it as-is; otherwise prepend the storage base URL
    private static func resolveFileURL(_ urlString: String) -> URL? {
        // If it's already a full URL, use it directly
        if let url = URL(string: urlString), url.scheme?.hasPrefix("http") == true {
            return url
        }

        // Otherwise, treat it as a file path and prepend the storage base URL
        let fullURLString = "\(storageBaseURL)/\(urlString)"
        return URL(string: fullURLString)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                // Check isAdmin first (matching React widget pattern)
                if comment.isAdmin {
                    // Admin comment - show project logo and ADMIN badge
                    HStack(spacing: 8) {
                        AvatarView(imageUrl: projectLogoUrl, name: "Admin", size: 32)
                        Text("ADMIN")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.primaryColor.opacity(0.2))
                            .foregroundColor(theme.primaryColor)
                            .cornerRadius(4)
                    }
                } else if let userId = comment.userId {
                    // Fetch and display user by ID
                    UserDisplayView(
                        userId: userId,
                        size: 32,
                        showName: true,
                        theme: theme,
                        isAdmin: false
                    )
                } else {
                    // Anonymous user
                    HStack(spacing: 8) {
                        AvatarView(imageUrl: nil, name: "Anonymous", size: 32)
                        Text("Anonymous")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(theme.textPrimaryColor)
                    }
                }

                Spacer()

                Text(comment.createdAt.relativeTimeString())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Comment text
            HTMLText(comment.comment)

            // Attached image thumbnail - tap to view full size
            if let fileUrl = comment.fileUrl, !fileUrl.isEmpty {
                ThumbnailImageView(
                    imageURL: Self.resolveFileURL(fileUrl),
                    maxThumbnailHeight: 150,
                    cornerRadius: theme.cornerRadius,
                    theme: theme
                )
            }

            // Reactions
            if !comment.reactions.isEmpty {
                HStack(spacing: 8) {
                    ForEach(Array(comment.reactions.keys.sorted()), id: \.self) { emoji in
                        Button {
                            onReactionTap(emoji)
                        } label: {
                            HStack(spacing: 4) {
                                Text(emoji)
                                    .font(.caption)
                                Text("\(comment.reactions[emoji] ?? 0)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(comment.userReactions.contains(emoji) ? theme.primaryColor.opacity(0.2) : Color.secondary.opacity(0.1))
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(theme.surfaceColor)
        .cornerRadius(theme.cornerRadius)
    }
}
