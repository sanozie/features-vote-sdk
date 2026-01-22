import SwiftUI

/// View that renders HTML text
public struct HTMLText: View {
    let html: String
    let font: Font
    let fontSize: CGFloat
    let color: Color

    @State private var attributedString: AttributedString?

    public init(_ html: String, font: Font = .body, fontSize: CGFloat = 15, color: Color = .primary) {
        self.html = html
        self.font = font
        self.fontSize = fontSize
        self.color = color
    }

    public var body: some View {
        if let attributedString = attributedString {
            Text(attributedString)
                .font(font)
                // Don't override color - let the AttributedString handle it
        } else {
            // Fallback to plain text if HTML parsing fails
            Text(html)
                .font(font)
                .foregroundColor(Color(hex: "#6B7280"))
                .task {
                    await parseHTML()
                }
        }
    }

    private func parseHTML() async {
        // Convert HTML to AttributedString
        guard let data = html.data(using: .utf8) else {
            return
        }

        do {
            // Try to parse as HTML
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            let nsAttributedString = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )

            // Convert to SwiftUI AttributedString
            var swiftAttributedString = AttributedString(nsAttributedString)

            // Set foreground color to be slightly lighter (gray)
            swiftAttributedString.foregroundColor = Color(hex: "#6B7280")

            attributedString = swiftAttributedString
        } catch {
            // If HTML parsing fails, try markdown as fallback
            attributedString = try? AttributedString(
                markdown: html,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            )
        }
    }
}

#if DEBUG
struct HTMLText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 16) {
            HTMLText("<p><strong>Bold text</strong> and <em>italic text</em></p>")
            HTMLText("<p>A <a href='https://example.com'>link</a></p>")
            HTMLText("<p>Some <code>inline code</code> example</p>")
            HTMLText("<p>Line 1<br>Line 2</p>")
        }
        .padding()
    }
}
#endif
