import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Protocol for feature service to allow for mocking
public protocol FeatureServiceProtocol {
    func fetchProject(slug: String) async throws -> Project
    func fetchFeatures(slug: String, user: User?) async throws -> [Feature]
    func createFeature(
        slug: String,
        title: String,
        description: String,
        tags: [String]?,
        user: User?,
        imageData: Data?,
        fileName: String?
    ) async throws -> String
}

/// Service for managing feature requests
public final class FeatureService: FeatureServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Fetch project configuration
    public func fetchProject(slug: String) async throws -> Project {
        try await apiClient.request(.project(slug: slug))
    }

    /// Fetch all features for a project
    public func fetchFeatures(slug: String, user: User? = nil) async throws -> [Feature] {
        let endpoint = APIEndpoint.features(
            slug: slug,
            appUserId: user?.appUserId,
            email: user?.email,
            token: user?.token
        )

        FVLog.info("Fetching features - URL: \(endpoint.url?.absoluteString ?? "nil")", category: .network)
        FVLog.debug("User info - email: \(user?.email ?? "nil"), appUserId: \(user?.appUserId ?? "nil"), token: \(user?.token != nil ? "[present]" : "nil")", category: .network)

        let features: [Feature] = try await apiClient.request(endpoint)

        FVLog.debug("Fetched \(features.count) features", category: .network)
        for feature in features {
            if feature.hasSubscribed {
                FVLog.debug("Feature '\(feature.title)' hasSubscribed=true", category: .network)
            }
        }

        return features
    }

    /// Create a new feature request
    public func createFeature(
        slug: String,
        title: String,
        description: String,
        tags: [String]? = nil,
        user: User? = nil,
        imageData: Data? = nil,
        fileName: String? = nil
    ) async throws -> String {
        let formData = MultipartFormData()

        // Add form fields
        formData.append(slug, forKey: "slug")
        formData.append(title, forKey: "title")
        formData.append(description, forKey: "description")

        // Add tags as JSON array
        if let tags = tags, !tags.isEmpty {
            if let tagsJSON = try? JSONEncoder().encode(tags),
               let tagsString = String(data: tagsJSON, encoding: .utf8) {
                formData.append(tagsString, forKey: "tags")
            }
        } else {
            formData.append("[]", forKey: "tags")
        }

        // Add user fields
        formData.append(user?.name ?? "", forKey: "name")
        formData.append(user?.email ?? "", forKey: "email")
        formData.append(user?.appUserId ?? "", forKey: "app_user_id")
        formData.append(user?.token ?? "", forKey: "token")
        formData.append(user?.imgUrl ?? "", forKey: "img_url")
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

        return try await apiClient.uploadString(.createFeature(slug: slug), formData: formData)
    }

    #if canImport(UIKit)
    /// Create a new feature request with UIImage (iOS)
    public func createFeature(
        slug: String,
        title: String,
        description: String,
        tags: [String]? = nil,
        user: User? = nil,
        image: UIImage? = nil
    ) async throws -> String {
        var imageData: Data? = nil
        if let image = image {
            imageData = image.jpegData(compressionQuality: 0.8)
        }

        return try await createFeature(
            slug: slug,
            title: title,
            description: description,
            tags: tags,
            user: user,
            imageData: imageData,
            fileName: "image.jpg"
        )
    }
    #elseif canImport(AppKit)
    /// Create a new feature request with NSImage (macOS)
    public func createFeature(
        slug: String,
        title: String,
        description: String,
        tags: [String]? = nil,
        user: User? = nil,
        image: NSImage? = nil
    ) async throws -> String {
        var imageData: Data? = nil
        if let image = image,
           let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData) {
            imageData = bitmapImage.representation(
                using: .jpeg,
                properties: [.compressionFactor: 0.8]
            )
        }

        return try await createFeature(
            slug: slug,
            title: title,
            description: description,
            tags: tags,
            user: user,
            imageData: imageData,
            fileName: "image.jpg"
        )
    }
    #endif
}
