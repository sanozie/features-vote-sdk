import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Builder for multipart/form-data requests
public class MultipartFormData {
    private var body = Data()
    private let boundary: String

    public init() {
        self.boundary = "Boundary-\(UUID().uuidString)"
    }

    /// Add a text field to the form data
    public func append(_ value: String, forKey key: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    /// Add a file to the form data
    public func append(
        _ fileData: Data,
        withName name: String,
        fileName: String,
        mimeType: String
    ) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
    }

    #if canImport(UIKit)
    /// Add a UIImage to the form data (iOS)
    public func append(
        _ image: UIImage,
        withName name: String,
        fileName: String = "image.jpg",
        compressionQuality: CGFloat = 0.8
    ) {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return
        }
        append(imageData, withName: name, fileName: fileName, mimeType: "image/jpeg")
    }
    #elseif canImport(AppKit)
    /// Add an NSImage to the form data (macOS)
    public func append(
        _ image: NSImage,
        withName name: String,
        fileName: String = "image.jpg",
        compressionQuality: CGFloat = 0.8
    ) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let imageData = bitmapImage.representation(
                using: .jpeg,
                properties: [.compressionFactor: compressionQuality]
              ) else {
            return
        }
        append(imageData, withName: name, fileName: fileName, mimeType: "image/jpeg")
    }
    #endif

    /// Get the complete multipart form data body
    public func finalize() -> Data {
        var finalBody = body
        finalBody.append("--\(boundary)--\r\n")
        return finalBody
    }

    /// Get the Content-Type header value
    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
}

// MARK: - Data Extension

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
