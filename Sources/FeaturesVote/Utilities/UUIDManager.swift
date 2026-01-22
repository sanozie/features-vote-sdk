import Foundation

/// Manages anonymous user identification via persistent UUID
public final class UUIDManager {
    private static let userUUIDKey = "com.featuresvote.user-uuid"
    private static let userDefaults = UserDefaults.standard

    /// Get or create a UUID for the current user
    /// Returns a UUID prefixed with "anon_" for anonymous users
    public static func getUUID() -> String {
        if let existingUUID = userDefaults.string(forKey: userUUIDKey) {
            return existingUUID
        }

        let newUUID = "anon_\(UUID().uuidString)"
        userDefaults.set(newUUID, forKey: userUUIDKey)
        return newUUID
    }

    /// Store a custom UUID
    public static func setUUID(_ uuid: String) {
        userDefaults.set(uuid, forKey: userUUIDKey)
    }

    /// Delete the stored UUID
    public static func deleteUUID() {
        userDefaults.removeObject(forKey: userUUIDKey)
    }

    /// Check if current user has an anonymous UUID
    public static var isAnonymous: Bool {
        guard let uuid = userDefaults.string(forKey: userUUIDKey) else {
            return true
        }
        return uuid.hasPrefix("anon_")
    }
}
