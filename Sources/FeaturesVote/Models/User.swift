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
        isGoogleAuth: Bool? = nil
    ) {
        self.name = name
        self.email = email
        self.appUserId = appUserId
        self.imgUrl = imgUrl
        self.userSpend = userSpend
        self.token = token
        self.isGoogleAuth = isGoogleAuth
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
