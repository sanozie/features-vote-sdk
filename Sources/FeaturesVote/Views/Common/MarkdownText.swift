import SwiftUI

/// View that renders markdown text
public struct MarkdownText: View {
    let markdown: String
    let font: Font
    let color: Color

    public init(_ markdown: String, font: Font = .body, color: Color = .primary) {
        self.markdown = markdown
        self.font = font
        self.color = color
    }

    public var body: some View {
        if let attributedString = try? AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attributedString)
                .font(font)
                .foregroundColor(color)
        } else {
            // Fallback to plain text if markdown parsing fails
            Text(markdown)
                .font(font)
                .foregroundColor(color)
        }
    }
}

#if DEBUG
struct MarkdownText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 16) {
            MarkdownText("**Bold text** and *italic text*")
            MarkdownText("A [link](https://example.com)")
            MarkdownText("`inline code` example")
            MarkdownText("Plain text fallback")
        }
        .padding()
    }
}
#endif
