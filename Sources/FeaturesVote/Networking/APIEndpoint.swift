import Foundation

/// HTTP methods
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// API endpoints for Features.Vote
public enum APIEndpoint {
    // Project
    case project(slug: String)

    // Features
    case features(slug: String, appUserId: String?, email: String?, token: String?)
    case createFeature(slug: String)
    case feature(featureId: String)

    // Voting
    case upvote
    case downvote

    // Comments
    case comments(featureId: String, email: String?, appUserId: String?, token: String?)
    case createComment(slug: String, featureId: String)
    case addReaction
    case removeReaction

    // Subscriptions
    case subscribePost
    case unsubscribePost

    // Releases (v1.1)
    case releases(slug: String)
    case postsByRelease(releaseId: String)

    // User
    case user(userId: String)
    case userToken

    /// Base URL for the API
    static let baseURL = "https://features.vote/api"

    /// Path for the endpoint
    var path: String {
        switch self {
        case .project(let slug):
            return "/public/project?slug=\(slug)"

        case .features(let slug, let appUserId, let email, let token):
            // Always include all params (matching JS widget behavior)
            let encodedEmail = email?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "/public/features?slug=\(slug)&app_user_id=\(appUserId ?? "")&email=\(encodedEmail)&token=\(token ?? "")"

        case .createFeature(let slug):
            return "/public/features/create?slug=\(slug)"

        case .feature(let featureId):
            return "/public/feature?featureId=\(featureId)"

        case .upvote:
            return "/public/upvote"

        case .downvote:
            return "/public/downvote"

        case .comments(let featureId, let email, let appUserId, let token):
            var path = "/public/comments?featureId=\(featureId)"
            if let email = email, !email.isEmpty {
                path += "&email=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? email)"
            }
            if let appUserId = appUserId, !appUserId.isEmpty {
                path += "&app_user_id=\(appUserId)"
            }
            if let token = token, !token.isEmpty {
                path += "&token=\(token)"
            }
            return path

        case .createComment(let slug, let featureId):
            return "/public/comments/create?slug=\(slug)&featureId=\(featureId)"

        case .addReaction:
            return "/public/comments/add-reaction"

        case .removeReaction:
            return "/public/comments/remove-reaction"

        case .subscribePost:
            return "/public/subscribe-post"

        case .unsubscribePost:
            return "/public/unsubscribe-post"

        case .releases(let slug):
            return "/public/releases?slug=\(slug)"

        case .postsByRelease(let releaseId):
            return "/public/posts-by-release?releaseId=\(releaseId)"

        case .user(let userId):
            return "/public/user?userId=\(userId)"

        case .userToken:
            return "/public/user-token"
        }
    }

    /// HTTP method for the endpoint
    var method: HTTPMethod {
        switch self {
        case .project,
             .features,
             .feature,
             .comments,
             .releases,
             .postsByRelease,
             .user:
            return .get

        case .createFeature,
             .upvote,
             .downvote,
             .createComment,
             .addReaction,
             .removeReaction,
             .subscribePost,
             .unsubscribePost,
             .userToken:
            return .post
        }
    }

    /// Full URL for the endpoint
    var url: URL? {
        URL(string: Self.baseURL + path)
    }
}
