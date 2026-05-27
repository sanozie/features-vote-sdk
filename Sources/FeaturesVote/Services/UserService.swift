import Foundation

/// Service for managing user state and authentication
public final class UserService {
    private var currentUser: User

    /// Tracks whether the developer has explicitly identified this user via email, customID, or token.
    /// A UUID-only user (auto-generated at init) is still considered anonymous until the developer
    /// provides a real identifier. This fixes the bug where allowAnonymousVoting had no effect.
    private var isExplicitlyIdentified: Bool = false

    public init() {
        self.currentUser = User()

        // Set anonymous UUID if no user configured (for API tracking only — does not affect isAnonymous)
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

    /// Update user email (marks user as explicitly identified)
    public func setEmail(_ email: String) {
        currentUser.email = email
        isExplicitlyIdentified = true
    }

    /// Update user custom ID (marks user as explicitly identified)
    public func setCustomID(_ customID: String) {
        currentUser.appUserId = customID
        isExplicitlyIdentified = true
    }

    /// Update user image URL
    public func setImageUrl(_ imageUrl: String) {
        currentUser.imgUrl = imageUrl
    }

    /// Update user spend amount
    public func setSpend(_ spend: Double) {
        currentUser.userSpend = spend
    }

    /// Set JWT token (marks user as explicitly identified)
    public func setToken(_ token: String) {
        currentUser.token = token
        isExplicitlyIdentified = true
    }

    /// Set Google auth flag
    public func setGoogleAuth(_ isGoogleAuth: Bool) {
        currentUser.isGoogleAuth = isGoogleAuth
    }

    /// Update entire user object
    public func setUser(_ user: User) {
        currentUser = user

        // Ensure we have an ID for API tracking
        if currentUser.appUserId == nil && !currentUser.isAuthenticated {
            currentUser.appUserId = UUIDManager.getUUID()
        }

        // Mark as explicitly identified if real credentials are present
        if user.email != nil || user.token != nil {
            isExplicitlyIdentified = true
        }
    }

    /// Clear user data and revert to anonymous (UUID-only) state
    public func clearUser() {
        currentUser = User(appUserId: UUIDManager.getUUID())
        isExplicitlyIdentified = false
    }

    /// Whether the current user is anonymous.
    ///
    /// A user is anonymous when no explicit identification (email, customID, or token) has been
    /// provided by the developer via `FeaturesVote.updateUser(...)` or `FeaturesVote.setToken(...)`.
    /// An auto-generated UUID assigned at init does NOT count as identification.
    public var isAnonymous: Bool {
        !isExplicitlyIdentified
    }

    /// Whether the current user is authenticated (has been explicitly identified)
    public var isAuthenticated: Bool {
        isExplicitlyIdentified
    }
}
