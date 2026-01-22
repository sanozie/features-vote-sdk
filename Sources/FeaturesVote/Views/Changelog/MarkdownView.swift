import SwiftUI

/// View that renders markdown text (matching JS widget's markdown rendering)
public struct MarkdownView: View {
    let markdown: String
    let theme: Theme

    @State private var markdownSegments: [MarkdownSegment] = []

    public init(markdown: String, theme: Theme = .default) {
        self.markdown = markdown
        self.theme = theme
    }

    public var body: some View {
        if markdownSegments.isEmpty {
            Text(markdown)
                .foregroundColor(theme.textPrimaryColor)
                .task {
                    await parseMarkdown()
                }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(markdownSegments.enumerated()), id: \.offset) { index, segment in
                    switch segment {
                    case .text(let attributedString):
                        Text(attributedString)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    case .divider:
                        Divider()
                            .padding(.vertical, 4)
                    case .image(let url, let alt):
                        AsyncImage(url: Self.resolveImageURL(url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                            case .failure:
                                VStack(spacing: 4) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 24))
                                        .foregroundColor(.secondary)
                                    if let alt = alt, !alt.isEmpty {
                                        Text(alt)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
        }
    }

    private static let storageBaseURL = "https://gsvxtxhayvayudcjyhbw.supabase.co/storage/v1/object/public/images"

    /// Resolves an image URL - if it's already a full URL, use it as-is; otherwise prepend the storage base URL
    private static func resolveImageURL(_ urlString: String) -> URL? {
        // If it's already a full URL, use it directly
        if let url = URL(string: urlString), url.scheme?.hasPrefix("http") == true {
            return url
        }

        // Otherwise, treat it as a file path and prepend the storage base URL
        let fullURLString = "\(storageBaseURL)/\(urlString)"
        FVLog.debug("Resolved image URL: \(urlString) -> \(fullURLString)", category: .ui)
        return URL(string: fullURLString)
    }

    /// Resolves relative links in an AttributedString to full URLs
    private static func resolveLinks(in attributedString: AttributedString) -> AttributedString {
        var result = attributedString

        // Iterate through runs to find and fix link attributes
        for run in result.runs {
            if let link = run.link {
                let urlString = link.absoluteString

                // If it's already a full URL, leave it alone
                if link.scheme?.hasPrefix("http") == true {
                    continue
                }

                // Otherwise, resolve it against the storage base URL
                let fullURLString = "\(storageBaseURL)/\(urlString)"
                if let resolvedURL = URL(string: fullURLString) {
                    FVLog.debug("Resolved link: \(urlString) -> \(fullURLString)", category: .ui)
                    let range = run.range
                    result[range].link = resolvedURL
                }
            }
        }

        return result
    }

    private func parseMarkdown() async {
        // First, extract images from markdown
        let imagePattern = #"!\[([^\]]*)\]\(([^)]+)\)"#
        let regex = try? NSRegularExpression(pattern: imagePattern, options: [])
        let nsString = markdown as NSString
        let matches = regex?.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
        
        // Build segments by processing markdown and replacing images with placeholders
        var processedMarkdown = markdown
        var imageMap: [String: (url: String, alt: String?)] = [:]
        
        // Replace images with placeholders and store image info
        for (index, match) in matches.enumerated().reversed() {
            let placeholder = "___IMAGE_PLACEHOLDER_\(index)___"
            let altRange = match.range(at: 1)
            let urlRange = match.range(at: 2)
            let alt = altRange.location != NSNotFound ? nsString.substring(with: altRange) : nil
            let url = urlRange.location != NSNotFound ? nsString.substring(with: urlRange) : ""
            
            imageMap[placeholder] = (url: url, alt: alt)
            processedMarkdown = (processedMarkdown as NSString).replacingCharacters(in: match.range, with: placeholder)
        }
        
        // Split by horizontal rules and images
        let horizontalRulePattern = #"^[\s]*([-*_]{3,})[\s]*$"#
        let lines = processedMarkdown.components(separatedBy: .newlines)
        
        var segments: [MarkdownSegment] = []
        var currentText: [String] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Check if line is a horizontal rule
            if trimmedLine.range(of: horizontalRulePattern, options: .regularExpression) != nil {
                // Process accumulated text first
                if !currentText.isEmpty {
                    let textBlock = currentText.joined(separator: "\n")
                    if let textSegments = await parseTextBlock(textBlock, imageMap: imageMap) {
                        segments.append(contentsOf: textSegments)
                    }
                    currentText = []
                }
                // Add divider
                segments.append(.divider)
            } else if trimmedLine.hasPrefix("___IMAGE_PLACEHOLDER_") && trimmedLine.hasSuffix("___") {
                // Process accumulated text first
                if !currentText.isEmpty {
                    let textBlock = currentText.joined(separator: "\n")
                    if let textSegments = await parseTextBlock(textBlock, imageMap: imageMap) {
                        segments.append(contentsOf: textSegments)
                    }
                    currentText = []
                }
                // Add image
                if let imageInfo = imageMap[trimmedLine] {
                    segments.append(.image(url: imageInfo.url, alt: imageInfo.alt))
                }
            } else {
                currentText.append(line)
            }
        }
        
        // Process remaining text
        if !currentText.isEmpty {
            let textBlock = currentText.joined(separator: "\n")
            if let textSegments = await parseTextBlock(textBlock, imageMap: imageMap) {
                segments.append(contentsOf: textSegments)
            }
        }
        
        // If no segments were created, parse entire markdown as text
        if segments.isEmpty {
            if let textSegments = await parseTextBlock(markdown, imageMap: imageMap) {
                segments.append(contentsOf: textSegments)
            }
        }
        
        await MainActor.run {
            markdownSegments = segments
        }
    }
    
    private func parseTextBlock(_ text: String, imageMap: [String: (url: String, alt: String?)]) async -> [MarkdownSegment]? {
        // Split text by image placeholders to handle inline images
        var segments: [MarkdownSegment] = []
        let remainingText = text
        
        // Find all image placeholders in the text
        let placeholders = imageMap.keys.sorted { $0.count > $1.count } // Sort by length to handle nested cases
        var foundPlaceholders: [(range: Range<String.Index>, placeholder: String)] = []
        
        for placeholder in placeholders {
            var searchRange = remainingText.startIndex..<remainingText.endIndex
            while let range = remainingText.range(of: placeholder, range: searchRange) {
                foundPlaceholders.append((range: range, placeholder: placeholder))
                searchRange = range.upperBound..<remainingText.endIndex
            }
        }
        
        // Sort by position
        foundPlaceholders.sort { $0.range.lowerBound < $1.range.lowerBound }
        
        // Split text by placeholders
        var currentIndex = remainingText.startIndex
        
        for (range, placeholder) in foundPlaceholders {
            // Add text before placeholder
            if currentIndex < range.lowerBound {
                let textSegment = String(remainingText[currentIndex..<range.lowerBound])
                if let parsedSegments = await parseTextSegment(textSegment) {
                    segments.append(contentsOf: parsedSegments)
                }
            }
            
            // Add image
            if let imageInfo = imageMap[placeholder] {
                segments.append(.image(url: imageInfo.url, alt: imageInfo.alt))
            }
            
            currentIndex = range.upperBound
        }
        
        // Add remaining text
        if currentIndex < remainingText.endIndex {
            let textSegment = String(remainingText[currentIndex...])
            if let parsedSegments = await parseTextSegment(textSegment) {
                segments.append(contentsOf: parsedSegments)
            }
        }
        
        return segments.isEmpty ? nil : segments
    }
    
    private func parseTextSegment(_ text: String) async -> [MarkdownSegment]? {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }
        
        // Split by double newlines to preserve paragraph breaks, then process each paragraph
        let paragraphs = text.components(separatedBy: "\n\n")
        var segments: [MarkdownSegment] = []
        
        for (index, paragraph) in paragraphs.enumerated() {
            let trimmed = paragraph.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                continue
            }
            
            // Process each paragraph, preserving single newlines within paragraphs
            let lines = paragraph.components(separatedBy: .newlines)
            var processedLines: [String] = []
            
            for (lineIndex, line) in lines.enumerated() {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                if trimmedLine.isEmpty {
                    continue
                }
                
                // For single newlines within a paragraph, add two spaces to create hard breaks
                if lineIndex < lines.count - 1 && !lines[lineIndex + 1].trimmingCharacters(in: .whitespaces).isEmpty {
                    processedLines.append(line + "  ")
                } else {
                    processedLines.append(line)
                }
            }
            
            let processedText = processedLines.joined(separator: "\n")
            
            do {
                // Use SwiftUI's built-in markdown parsing with full syntax support
                var parsed = try AttributedString(
                    markdown: processedText,
                    options: AttributedString.MarkdownParsingOptions(
                        interpretedSyntax: .full,
                        failurePolicy: .returnPartiallyParsedIfPossible
                    )
                )

                // Apply theme colors
                parsed.foregroundColor = theme.textPrimaryColor

                // Resolve relative links to full URLs
                parsed = Self.resolveLinks(in: parsed)

                segments.append(.text(parsed))
                
                // Add spacing between paragraphs (except for last one)
                if index < paragraphs.count - 1 {
                    // Add a small spacing segment
                    var spacing = AttributedString("\n")
                    spacing.foregroundColor = theme.textPrimaryColor
                    segments.append(.text(spacing))
                }
            } catch {
                // Fallback to plain text with preserved newlines
                var attributedString = AttributedString(processedText)
                attributedString.foregroundColor = theme.textPrimaryColor
                segments.append(.text(attributedString))
            }
        }
        
        return segments.isEmpty ? nil : segments
    }
}

/// Represents a segment of markdown content
private enum MarkdownSegment {
    case text(AttributedString)
    case divider
    case image(url: String, alt: String?)
}

#if DEBUG
struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 16) {
            MarkdownView(
                markdown: """
                # Heading 1
                ## Heading 2

                This is **bold** and this is *italic*.

                - Item 1
                - Item 2
                - Item 3

                [Link](https://example.com)

                `code`
                """
            )
        }
        .padding()
    }
}
#endif
