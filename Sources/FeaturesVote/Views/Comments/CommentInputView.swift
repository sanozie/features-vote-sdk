import SwiftUI

/// Comment input view
public struct CommentInputView: View {
    @Binding var commentText: String
    @Binding var selectedImage: Data?
    let isSubmitting: Bool
    let theme: Theme
    let localization: Localization
    let onSubmit: () -> Void

    public var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // Multiline text editor
            TextEditor(text: $commentText)
                .frame(minHeight: 80)
                .padding(8)
                .scrollContentBackground(.hidden)
                .background(theme.surfaceColor, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.textSecondaryColor.opacity(0.2), lineWidth: 1)
                )
                .foregroundColor(theme.textPrimaryColor)
                .tint(theme.primaryColor)
                .overlay(alignment: .topLeading) {
                    if commentText.isEmpty {
                        Text(localization.commentPlaceholder)
                            .foregroundColor(theme.textSecondaryColor.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
                .disabled(isSubmitting)

            // Image preview if selected
            if let imageData = selectedImage {
                ImagePreview(imageData: imageData) {
                    selectedImage = nil
                }
            }

            // Actions row: Image picker on left, Send button on right
            HStack {
                // Image picker button
                if selectedImage == nil {
                    #if canImport(UIKit)
                    if #available(iOS 16.0, *) {
                        ImagePicker(selectedImageData: $selectedImage, theme: theme)
                    } else {
                        ImagePickerButton(selectedImageData: $selectedImage, theme: theme)
                    }
                    #elseif canImport(AppKit)
                    ImagePicker(selectedImageData: $selectedImage, theme: theme)
                    #endif
                }

                Spacer()

                // Send button
                Button(action: onSubmit) {
                    HStack(spacing: 6) {
                        if isSubmitting {
                            ProgressView()
                                .frame(width: 16, height: 16)
                        }
                        Text(isSubmitting ? "Sending..." : "Send")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting
                            ? Color.secondary
                            : theme.primaryColor
                    )
                    .cornerRadius(8)
                }
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
            }
        }
        .padding()
    }
}

#if canImport(UIKit)
/// Button wrapper for iOS 15 legacy image picker
@available(iOS 15.0, *)
struct ImagePickerButton: View {
    @Binding var selectedImageData: Data?
    @State private var showImagePicker = false
    let theme: Theme

    init(selectedImageData: Binding<Data?>, theme: Theme = .default) {
        self._selectedImageData = selectedImageData
        self.theme = theme
    }

    var body: some View {
        Button {
            showImagePicker = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.system(size: 14))
                Text("Add Image")
                    .font(.system(size: 14))
            }
            .foregroundColor(theme.primaryColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(theme.primaryColor.opacity(0.1))
            .cornerRadius(6)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerLegacy(selectedImageData: $selectedImageData)
        }
    }
}
#endif
