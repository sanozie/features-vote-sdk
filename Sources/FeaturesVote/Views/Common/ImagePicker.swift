import SwiftUI

#if canImport(UIKit)
import UIKit
import PhotosUI

/// Image picker for iOS using PhotosUI
@available(iOS 16.0, *)
public struct ImagePicker: View {
    @Binding var selectedImageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    let theme: Theme

    public init(selectedImageData: Binding<Data?>, theme: Theme = .default) {
        self._selectedImageData = selectedImageData
        self.theme = theme
    }

    public var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
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
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    // Validate file size (max 5MB)
                    let maxSize = 5 * 1024 * 1024
                    if data.count <= maxSize {
                        selectedImageData = data
                    } else {
                        FVLog.warning("File size exceeds 5MB limit (\(data.count / 1024 / 1024)MB)", category: .ui)
                    }
                }
            }
        }
    }
}

/// Fallback image picker for iOS 15
@available(iOS 15.0, *)
public struct ImagePickerLegacy: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?
    @Environment(\.presentationMode) var presentationMode

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerLegacy

        init(_ parent: ImagePickerLegacy) {
            self.parent = parent
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImageData = image.jpegData(compressionQuality: 0.8)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#elseif canImport(AppKit)
import AppKit

/// Image picker for macOS
public struct ImagePicker: View {
    @Binding var selectedImageData: Data?
    let theme: Theme

    public init(selectedImageData: Binding<Data?>, theme: Theme = .default) {
        self._selectedImageData = selectedImageData
        self.theme = theme
    }

    public var body: some View {
        Button {
            selectImage()
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
        .buttonStyle(.plain)
    }

    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.jpeg, .png]

        if panel.runModal() == .OK, let url = panel.url {
            if let data = try? Data(contentsOf: url) {
                // Validate file size (max 5MB)
                let maxSize = 5 * 1024 * 1024
                if data.count <= maxSize {
                    selectedImageData = data
                } else {
                    FVLog.warning("File size exceeds 5MB limit (\(data.count / 1024 / 1024)MB)", category: .ui)
                }
            }
        }
    }
}
#endif

/// Image preview view
public struct ImagePreview: View {
    let imageData: Data
    let onRemove: () -> Void

    public var body: some View {
        HStack(spacing: 8) {
            #if canImport(UIKit)
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            }
            #elseif canImport(AppKit)
            if let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            }
            #endif

            VStack(alignment: .leading, spacing: 2) {
                Text("Image attached")
                    .font(.caption)
                    .fontWeight(.medium)
                Text("\(imageData.count / 1024) KB")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
