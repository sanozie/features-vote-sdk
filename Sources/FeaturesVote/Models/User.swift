import Foundation

/// User information for authentication and attribution
public struct User: Codable, Equatable {
    public var name: String?
    public var email: String?
    public var appUserId: String?
    public var imgUrl: String?
    public var userSpend: Double?
    public var token: String?
    public var isGoogleAuth: Bool?

    /// Contextual metadata about the post creator (app version, current page, etc.),
    /// stored pre-serialized as a JSON string and sent on feature creation as `post_metadata`.
    /// Deliberately omitted from `CodingKeys` so decoding a server `User` never collides with
    /// the object-vs-string shape of the wire format.
    public var postMetadataJSON: String? = nil

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case appUserId = "app_user_id"
        case imgUrl = "img_url"
        case userSpend = "user_spend"
        case token
        case isGoogleAuth = "is_google_auth"
    }

    public init(
        name: String? = nil,
        email: String? = nil,
        appUserId: String? = nil,
        imgUrl: String? = nil,
        userSpend: Double? = nil,
        token: String? = nil,
        isGoogleAuth: Bool? = nil,
        postMetadataJSON: String? = nil
    ) {
        self.name = name
        self.email = email
        self.appUserId = appUserId
        self.imgUrl = imgUrl
        self.userSpend = userSpend
        self.token = token
        self.isGoogleAuth = isGoogleAuth
        self.postMetadataJSON = postMetadataJSON
    }

    /// Whether this represents an authenticated user
    public var isAuthenticated: Bool {
        email != nil || appUserId != nil || token != nil
    }

    /// Whether this is an anonymous user
    public var isAnonymous: Bool {
        !isAuthenticated
    }
}
