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
        onSuccess: (() -> Void)? = nil,
        userService: UserService? = nil
    ) {
        _viewModel = StateObject(wrappedValue: CreateFeatureViewModel(
            slug: slug,
            availableTags: availableTags,
            featureService: FeatureService(),
            userService: userService ?? UserService()
        ))
        self.theme = theme
        self.config = config
        self.localization = localization
        self.onSuccess = onSuccess
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(localization.titlePlaceholder, text: $viewModel.title)
                        .textInputAutocapitalization(.sentences)

                    TextField(localization.descriptionPlaceholder, text: $viewModel.description, axis: .vertical)
                        .lineLimit(5...10)
                        .textInputAutocapitalization(.sentences)
                }

                if !viewModel.availableTags.isEmpty {
                    Section {
                        TagSelectorView(
                            availableTags: viewModel.availableTags,
                            selectedTags: $viewModel.selectedTags,
                            theme: theme
                        )
                    }
                }

                if let error = viewModel.error {
                    Section {
                        Text(error.localizedDescription)
                            .foregroundColor(theme.errorColor)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(localization.createFeatureTitle)
            .navigationBarTitleDisplayMode(.inline)
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
