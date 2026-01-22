import SwiftUI

/// Tags display view
public struct TagsView: View {
    let tags: [String]
    let availableTags: [Tag]

    public init(tags: [String], availableTags: [Tag] = []) {
        self.tags = tags
        self.availableTags = availableTags
    }

    public var body: some View {
        if !tags.isEmpty {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    tagView(for: tag)
                }
            }
        }
    }

    private func tagView(for tag: String) -> some View {
        let tagTheme = availableTags.first(where: { $0.label == tag })?.theme
        let colors = chakraColors(for: tagTheme ?? "gray")

        return HStack(spacing: 4) {
            Text(tag)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(colors.background)
        )
        .foregroundColor(colors.text)
    }

    /// Map Chakra UI v2 colorScheme to actual colors (subtle variant)
    private func chakraColors(for theme: String) -> (background: Color, text: Color) {
        switch theme.lowercased() {
        case "gray":
            return (Color(hex: "#EDF2F7"), Color(hex: "#4A5568"))
        case "red":
            return (Color(hex: "#FED7D7"), Color(hex: "#C53030"))
        case "orange":
            return (Color(hex: "#FEEBC8"), Color(hex: "#C05621"))
        case "yellow":
            return (Color(hex: "#FEFCBF"), Color(hex: "#B7791F"))
        case "green":
            return (Color(hex: "#C6F6D5"), Color(hex: "#2F855A"))
        case "teal":
            return (Color(hex: "#B2F5EA"), Color(hex: "#285E61"))
        case "blue":
            return (Color(hex: "#BEE3F8"), Color(hex: "#2C5282"))
        case "cyan":
            return (Color(hex: "#C4F1F9"), Color(hex: "#00A3C4"))
        case "purple":
            return (Color(hex: "#E9D8FD"), Color(hex: "#6B46C1"))
        case "pink":
            return (Color(hex: "#FED7E2"), Color(hex: "#B83280"))
        default:
            return (Color(hex: "#EDF2F7"), Color(hex: "#4A5568")) // Default to gray
        }
    }
}

#if DEBUG
struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            TagsView(
                tags: ["Feature Requests", "Bugs and Fixes"],
                availableTags: [
                    Tag(label: "Feature Requests", theme: "#EF4444"),
                    Tag(label: "Bugs and Fixes", theme: "#8B5CF6")
                ]
            )
            
            TagsView(
                tags: ["Medevio", "Feature Requests"],
                availableTags: [
                    Tag(label: "Medevio", theme: "#10B981"),
                    Tag(label: "Feature Requests", theme: "#EF4444")
                ]
            )
        }
        .padding()
        .background(Color(hex: "#F3F4F6"))
    }
}
#endif
