import SwiftUI

/// Tag selector view for creating features
public struct TagSelectorView: View {
    let availableTags: [Tag]
    @Binding var selectedTags: Set<String>
    let theme: Theme

    public var body: some View {
        if !availableTags.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Tags (optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                FlowLayout(spacing: 8) {
                    ForEach(availableTags) { tag in
                        tagButton(for: tag)
                    }
                }
            }
        }
    }

    private func tagButton(for tag: Tag) -> some View {
        let isSelected = selectedTags.contains(tag.label)

        return Button {
            if isSelected {
                selectedTags.remove(tag.label)
            } else {
                selectedTags.insert(tag.label)
            }
        } label: {
            Text(tag.label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(hex: tag.theme).opacity(0.2) : Color.secondary.opacity(0.1))
                )
                .foregroundColor(isSelected ? Color(hex: tag.theme) : .secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(hex: tag.theme) : Color.clear, lineWidth: 2)
                )
                .contentShape(Rectangle())
        }
        // Inside a Form/List cell, multiple default-styled buttons share one tap
        // target and all fire together — tapping one tag selected every tag.
        // An explicit button style isolates each tag's hit area.
        .buttonStyle(.borderless)
    }
}

/// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
