import SwiftUI

/// View that renders HTML text using the system font (San Francisco)
public struct HTMLText: View {
    let html: String
    let font: Font
    let fontSize: CGFloat
    let color: Color
    let linkColor: Color

    @State private var attributedString: AttributedString?

    public init(
        _ html: String,
        font: Font = .body,
        fontSize: CGFloat = 15,
        color: Color = .primary,
        // Defaults to the configured theme's primary color so embedded links
        // match the host app's branding instead of the SDK's default purple.
        linkColor: Color = FeaturesVote.theme.primaryColor
    ) {
        self.html = html
        self.font = font
        self.fontSize = fontSize
        self.color = color
        self.linkColor = linkColor
    }

    public var body: some View {
        Group {
            if let attributedString = attributedString {
                Text(attributedString)
            } else {
                // Placeholder while async parse is in flight
                Text(html)
                    .font(font)
                    .foregroundColor(.secondary)
            }
        }
        // Re-run whenever html content changes (handles view reuse)
        .task(id: html) {
            await parseHTML()
        }
    }

    private func parseHTML() async {
        // Inject CSS so WebKit uses the system font (-apple-system = San Francisco on Apple platforms)
        // instead of the default Times New Roman it falls back to when no font is specified.
        let linkHex = linkColor.hexString ?? "#7C3AED"
        let colorHex = color.hexString ?? "#FFFFFF"
        let styledHtml = """
        <html><head><meta charset="utf-8"><style>
        body {
            font-family: -apple-system, 'SF Pro Text', 'Helvetica Neue', sans-serif;
            font-size: \(Int(fontSize))px;
            color: \(colorHex);
            line-height: 1.6;
            margin: 0;
            padding: 0;
        }
        p  { margin: 0 0 0.5em 0; }
        p:last-child { margin-bottom: 0; }
        strong, b { font-weight: 600; }
        em, i     { font-style: italic; }
        a         { color: \(linkHex); text-decoration: underline; }
        code      { font-family: 'Menlo', 'Courier New', monospace; font-size: 0.88em; }
        ul, ol    { margin: 0 0 0.5em 0; padding-left: 1.5em; }
        li        { margin-bottom: 0.2em; }
        blockquote { margin: 0 0 0.5em 1em; color: #6B7280; border-left: 3px solid #D1D5DB; padding-left: 0.75em; }
        </style></head><body>\(html)</body></html>
        """

        guard let data = styledHtml.data(using: .utf8) else { return }

        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            let nsAttributedString = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )

            // Trim trailing newline that WebKit always appends
            let trimmed = nsAttributedString.string.hasSuffix("\n")
                ? nsAttributedString.attributedSubstring(
                    from: NSRange(location: 0, length: max(0, nsAttributedString.length - 1))
                  )
                : nsAttributedString

            attributedString = AttributedString(trimmed)
        } catch {
            // Fallback: try markdown, then plain text
            if let md = try? AttributedString(
                markdown: html,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            ) {
                attributedString = md
            } else {
                attributedString = AttributedString(html)
            }
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
