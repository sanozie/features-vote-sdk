import SwiftUI

/// Create feature form view
public struct CreateFeatureView: View {
    @StateObject private var viewModel: CreateFeatureViewModel
    @Environment(\.dismiss) private var dismiss

    private let theme: Theme
    private let config: Configuration
    private let localization: Localization
    private let onSuccess: (() -> Void)?

    public init(
        slug: String,
        availableTags: [Tag],
        theme: Theme = .default,
        config: Configuration = .default,
        localization: Localization = .default,
        projectCustomization: Customization? = nil,
        onSuccess: (() -> Void)? = nil,
        userService: UserService? = nil
    ) {
        _viewModel = StateObject(wrappedValue: CreateFeatureViewModel(
            slug: slug,
            availableTags: availableTags,
            featureService: FeatureService(),
            userService: userService ?? UserService(),
            configuration: config,
            projectCustomization: projectCustomization
        ))
        self.theme = theme
        self.config = config
        self.localization = localization
        self.onSuccess = onSuccess
    }

    public var body: some View {
        NavigationStack {
            Form {
                // MARK: Title & Description
                Section {
                    TextField(localization.titlePlaceholder, text: $viewModel.title)
                        #if os(iOS)
                        .textInputAutocapitalization(.sentences)
                        #endif

                    TextField(localization.descriptionPlaceholder, text: $viewModel.description, axis: .vertical)
                        .lineLimit(5...10)
                        #if os(iOS)
                        .textInputAutocapitalization(.sentences)
                        #endif
                }

                // MARK: Image Attachment
                Section {
                    if let imageData = viewModel.selectedImage {
                        // Show preview with remove button
                        ImagePreview(imageData: imageData) {
                            viewModel.selectedImage = nil
                        }
                    } else {
                        // Show picker button
                        HStack {
                            #if canImport(UIKit)
                            if #available(iOS 16.0, *) {
                                ImagePicker(selectedImageData: $viewModel.selectedImage, theme: theme)
                            } else {
                                ImagePickerButton(selectedImageData: $viewModel.selectedImage, theme: theme)
                            }
                            #elseif canImport(AppKit)
                            ImagePicker(selectedImageData: $viewModel.selectedImage, theme: theme)
                            #endif

                            Spacer()

                            Text("Optional")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Attachment")
                }

                // MARK: Tags
                if !viewModel.availableTags.isEmpty {
                    Section {
                        TagSelectorView(
                            availableTags: viewModel.availableTags,
                            selectedTags: $viewModel.selectedTags,
                            theme: theme
                        )
                    }
                }

                // MARK: Email required warning
                if viewModel.emailRequired {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(theme.errorColor)
                            Text("An email address is required to submit a feature request.")
                                .font(.caption)
                                .foregroundColor(theme.errorColor)
                        }
                    }
                }

                // MARK: Error
                if let error = viewModel.error {
                    Section {
                        Text(error.localizedDescription)
                            .foregroundColor(theme.errorColor)
                            .font(.caption)
                    }
                }
            }
            #if os(macOS)
            // macOS defaults Form to a label-on-left column grid with bare text
            // fields; the grouped style matches the inset iOS layout the rest of the
            // SDK is designed around.
            .formStyle(.grouped)
            #endif
            .navigationTitle(viewModel.customHeaderText ?? localization.createFeatureTitle)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            // Apply primary color to Cancel/Submit buttons and any other tinted controls
            .tint(theme.primaryColor)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.submit) {
                        Task {
                            let success = await viewModel.submit()
                            if success {
                                onSuccess?()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSubmitting)
                }
            }
            .disabled(viewModel.isSubmitting)
            .overlay {
                if viewModel.isSubmitting {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(theme.primaryColor)
                }
            }
        }
    }
}

#if DEBUG
struct CreateFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFeatureView(
            slug: "demo",
            availableTags: [
                Tag(label: "Feature", theme: "#3B82F6"),
                Tag(label: "Bug", theme: "#EF4444"),
                Tag(label: "Enhancement", theme: "#10B981")
            ]
        )
    }
}
#endif
