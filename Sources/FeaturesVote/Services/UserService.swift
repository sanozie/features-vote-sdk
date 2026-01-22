import Foundation

/// Service for managing user state and authentication
public final class UserService {
    private var currentUser: User

    public init() {
        self.currentUser = User()

        // Set anonymous UUID if no user configured
        if !currentUser.isAuthenticated {
            currentUser.appUserId = UUIDManager.getUUID()
        }
    }

    /// Get the current user
    public func getUser() -> User {
        currentUser
    }

    /// Update user name
    public func setName(_ name: String) {
        currentUser.name = name
    }

    /// Update user email
    public func setEmail(_ email: String) {
        currentUser.email = email
    }

    /// Update user custom ID
    public func setCustomID(_ customID: String) {
        currentUser.appUserId = customID
    }

    /// Update user image URL
    public func setImageUrl(_ imageUrl: String) {
        currentUser.imgUrl = imageUrl
    }

    /// Update user spend amount
    public func setSpend(_ spend: Double) {
        currentUser.userSpend = spend
    }

    /// Set JWT token
    public func setToken(_ token: String) {
        currentUser.token = token
    }

    /// Set Google auth flag
    public func setGoogleAuth(_ isGoogleAuth: Bool) {
        currentUser.isGoogleAuth = isGoogleAuth
    }

    /// Update entire user object
    public func setUser(_ user: User) {
        currentUser = user

        // Ensure we have an ID
        if currentUser.appUserId == nil && !currentUser.isAuthenticated {
            currentUser.appUserId = UUIDManager.getUUID()
        }
    }

    /// Clear user data and revert to anonymous
    public func clearUser() {
        currentUser = User(appUserId: UUIDManager.getUUID())
    }

    /// Whether the current user is anonymous
    public var isAnonymous: Bool {
        currentUser.isAnonymous
    }

    /// Whether the current user is authenticated
    public var isAuthenticated: Bool {
        currentUser.isAuthenticated
    }
}
