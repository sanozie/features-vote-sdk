import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// ViewModel for create feature form
@MainActor
public final class CreateFeatureViewModel: ObservableObject {
    // MARK: - Published State

    @Published public var title = ""
    @Published public var description = ""
    @Published public var selectedTags: Set<String> = []
    @Published public var selectedImage: Data? = nil
    @Published private(set) var isSubmitting = false
    @Published private(set) var error: APIError?
    @Published public var showSuccess = false

    // MARK: - Dependencies

    private let slug: String
    private let featureService: FeatureServiceProtocol
    private let userService: UserService
    private let config: Configuration
    public let availableTags: [Tag]

    /// Optional project customization for custom popup messages.
    public var projectCustomization: Customization?

    // MARK: - Computed Properties

    /// Whether the form is ready to submit
    public var isValid: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasDescription = !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailOk = !config.behavior.requireEmailForCreate || userService.getUser().email != nil
        return hasTitle && hasDescription && emailOk
    }

    /// Whether an email is required but missing (drives inline warning in the view)
    public var emailRequired: Bool {
        config.behavior.requireEmailForCreate && userService.getUser().email == nil
    }

    /// Custom navigation title from project (falls back to localization)
    public var customHeaderText: String? {
        projectCustomization?.suggestPopupHeaderText
    }

    /// Custom success message from project (used after successful submission)
    public var customSuccessMessage: String? {
        projectCustomization?.suggestPopupSuccessMsg
    }

    /// Validation error message
    public var validationError: String? {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Title is required"
        }
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Description is required"
        }
        if emailRequired {
            return "An email address is required to submit a feature request."
        }
        return nil
    }

    // MARK: - Initialization

    public init(
        slug: String,
        availableTags: [Tag],
        featureService: FeatureServiceProtocol,
        userService: UserService,
        configuration: Configuration = .default,
        projectCustomization: Customization? = nil
    ) {
        self.slug = slug
        self.availableTags = availableTags
        self.featureService = featureService
        self.userService = userService
        self.config = configuration
        self.projectCustomization = projectCustomization
    }

    // MARK: - Actions

    /// Submit the feature request
    public func submit() async -> Bool {
        guard isValid else {
            error = .unknown(validationError ?? "Form is invalid")
            return false
        }

        isSubmitting = true
        error = nil

        do {
            let user = userService.getUser()
            let tags = Array(selectedTags)

            _ = try await featureService.createFeature(
                slug: slug,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                tags: tags.isEmpty ? nil : tags,
                user: user,
                imageData: selectedImage,
                fileName: "image.jpg"
            )

            showSuccess = true
            reset()
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

    /// Toggle tag selection
    public func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    /// Reset form
    public func reset() {
        title = ""
        description = ""
        selectedTags.removeAll()
        selectedImage = nil
        error = nil
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
