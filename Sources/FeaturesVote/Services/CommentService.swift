import Foundation

/// Protocol for comment service to allow for mocking
public protocol CommentServiceProtocol {
    func fetchComments(featureId: String, user: User?) async throws -> [Comment]
    func addComment(featureId: String, slug: String, comment: String, user: User?, imageData: Data?, fileName: String?) async throws -> String
    func addReaction(commentId: String, emoji: String, user: User?) async throws
    func removeReaction(commentId: String, emoji: String, user: User?) async throws
}

/// Service for managing comments and reactions
public final class CommentService: CommentServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Fetch all comments for a feature
    public func fetchComments(featureId: String, user: User? = nil) async throws -> [Comment] {
        let endpoint = APIEndpoint.comments(
            featureId: featureId,
            email: user?.email,
            appUserId: user?.appUserId,
            token: user?.token
        )

        FVLog.debug("Fetching comments for feature: \(featureId)", category: .network)

        let comments: [Comment] = try await apiClient.request(endpoint)
        FVLog.debug("Received \(comments.count) comments", category: .data)

        return comments
    }

    /// Add a comment to a feature
    public func addComment(
        featureId: String,
        slug: String,
        comment: String,
        user: User? = nil,
        imageData: Data? = nil,
        fileName: String? = nil
    ) async throws -> String {
        let formData = MultipartFormData()

        // Add form fields
        formData.append(user?.appUserId ?? "", forKey: "app_user_id")
        formData.append(user?.email ?? "", forKey: "email")
        formData.append(user?.name ?? "", forKey: "user_name")
        formData.append(comment, forKey: "comment")
        formData.append(user?.token ?? "", forKey: "token")
        formData.append(String(user?.userSpend ?? 0), forKey: "user_spend")

        // Add image if provided
        if let imageData = imageData {
            let filename = fileName ?? "image.jpg"
            formData.append(
                imageData,
                withName: "file",
                fileName: filename,
                mimeType: "image/jpeg"
            )
        }

        return try await apiClient.uploadString(
            .createComment(slug: slug, featureId: featureId),
            formData: formData
        )
    }

    /// Add an emoji reaction to a comment
    public func addReaction(commentId: String, emoji: String, user: User? = nil) async throws {
        let request = CommentReactionRequest(
            commentId: commentId,
            emoji: emoji,
            name: user?.name,
            email: user?.email,
            appUserId: user?.appUserId,
            imgUrl: user?.imgUrl,
            userSpend: user?.userSpend,
            token: user?.token
        )

        let _: String = try await apiClient.requestString(.addReaction, body: request)
    }

    /// Remove an emoji reaction from a comment
    public func removeReaction(commentId: String, emoji: String, user: User? = nil) async throws {
        let request = CommentReactionRequest(
            commentId: commentId,
            emoji: emoji,
            name: user?.name,
            email: user?.email,
            appUserId: user?.appUserId,
            imgUrl: user?.imgUrl,
            userSpend: user?.userSpend,
            token: user?.token
        )

        let _: String = try await apiClient.requestString(.removeReaction, body: request)
    }
}
