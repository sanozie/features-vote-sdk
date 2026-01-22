import Foundation
import SwiftUI

/// ViewModel for comments section
@MainActor
public final class CommentsViewModel: ObservableObject {
    // MARK: - Published State

    @Published public var commentText = ""
    @Published public var selectedImage: Data? = nil
    @Published private(set) var comments: [Comment] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var error: APIError?

    // MARK: - Dependencies

    private let featureId: String
    private let slug: String
    private let commentService: CommentServiceProtocol
    private let userService: UserService

    // MARK: - Computed Properties

    /// Whether the comment form is valid
    public var isValid: Bool {
        !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var isAnonymous: Bool {
        userService.isAnonymous
    }

    // MARK: - Initialization

    public init(
        featureId: String,
        slug: String,
        commentService: CommentServiceProtocol,
        userService: UserService
    ) {
        self.featureId = featureId
        self.slug = slug
        self.commentService = commentService
        self.userService = userService
    }

    // MARK: - Actions

    /// Load comments
    public func loadComments() async {
        isLoading = true
        error = nil

        do {
            let user = userService.getUser()
            FVLog.debug("Loading comments for feature: \(featureId)", category: .data)

            let fetchedComments = try await commentService.fetchComments(featureId: featureId, user: user)

            // Sort comments by created_at ascending (oldest first), matching JS widget
            comments = fetchedComments.sorted { $0.createdAt < $1.createdAt }

            FVLog.debug("Loaded \(comments.count) comments", category: .data)
        } catch let apiError as APIError {
            FVLog.error(apiError, message: "Failed to load comments", category: .network)
            error = apiError
        } catch {
            FVLog.error(error, message: "Unknown error loading comments", category: .general)
            self.error = .unknown(error.localizedDescription)
        }

        isLoading = false
    }

    /// Submit a new comment
    public func submitComment() async -> Bool {
        guard isValid else {
            return false
        }

        isSubmitting = true
        error = nil

        do {
            let user = userService.getUser()

            _ = try await commentService.addComment(
                featureId: featureId,
                slug: slug,
                comment: commentText.trimmingCharacters(in: .whitespacesAndNewlines),
                user: user,
                imageData: selectedImage,
                fileName: "image.jpg"
            )

            // Reset form
            commentText = ""
            selectedImage = nil

            // Reload comments
            await loadComments()

            isSubmitting = false
            return true
        } catch let apiError as APIError {
            error = apiError
            isSubmitting = false
            return false
        } catch {
            self.error = .unknown(error.localizedDescription)
            isSubmitting = false
            return false
        }
    }

    /// Add a reaction to a comment
    public func addReaction(to comment: Comment, emoji: String) async {
        do {
            let user = userService.getUser()
            try await commentService.addReaction(commentId: comment.id, emoji: emoji, user: user)

            // Optimistically update local state
            if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                var updatedComment = comments[index]
                var reactions = updatedComment.reactions
                reactions[emoji, default: 0] += 1
                var userReactions = updatedComment.userReactions
                if !userReactions.contains(emoji) {
                    userReactions.append(emoji)
                }

                comments[index] = Comment(
                    id: updatedComment.id,
                    userId: updatedComment.userId,
                    userName: updatedComment.userName,
                    userImgUrl: updatedComment.userImgUrl,
                    featureId: updatedComment.featureId,
                    comment: updatedComment.comment,
                    createdAt: updatedComment.createdAt,
                    reactions: reactions,
                    userReactions: userReactions,
                    isAdmin: updatedComment.isAdmin,
                    fileUrl: updatedComment.fileUrl
                )
            }
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    /// Remove a reaction from a comment
    public func removeReaction(from comment: Comment, emoji: String) async {
        do {
            let user = userService.getUser()
            try await commentService.removeReaction(commentId: comment.id, emoji: emoji, user: user)

            // Optimistically update local state
            if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                var updatedComment = comments[index]
                var reactions = updatedComment.reactions
                if let count = reactions[emoji], count > 0 {
                    reactions[emoji] = count - 1
                    if reactions[emoji] == 0 {
                        reactions.removeValue(forKey: emoji)
                    }
                }
                var userReactions = updatedComment.userReactions
                userReactions.removeAll { $0 == emoji }
                comments[index] = Comment(
                    id: updatedComment.id,
                    userId: updatedComment.userId,
                    userName: updatedComment.userName,
                    userImgUrl: updatedComment.userImgUrl,
                    featureId: updatedComment.featureId,
                    comment: updatedComment.comment,
                    createdAt: updatedComment.createdAt,
                    reactions: reactions,
                    userReactions: userReactions,
                    isAdmin: updatedComment.isAdmin,
                    fileUrl: updatedComment.fileUrl
                )
            }
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    #if canImport(UIKit)
    /// Set selected image from UIImage
    public func setImage(_ image: UIImage?) {
        selectedImage = image?.jpegData(compressionQuality: 0.8)
    }
    #elseif canImport(AppKit)
    /// Set selected image from NSImage
    public func setImage(_ image: NSImage?) {
        if let image = image,
           let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData) {
            selectedImage = bitmapImage.representation(
                using: .jpeg,
                properties: [.compressionFactor: 0.8]
            )
        } else {
            selectedImage = nil
        }
    }
    #endif
}
