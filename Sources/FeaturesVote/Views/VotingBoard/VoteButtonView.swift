import SwiftUI

/// Vote button view
public struct VoteButtonView: View {
    let voteCount: Int
    let hasVoted: Bool
    let theme: Theme
    let upvoteIcon: Image
    let onTap: () -> Void
    @State private var isPressed = false

    public init(
        voteCount: Int,
        hasVoted: Bool,
        theme: Theme = .default,
        upvoteIcon: Image = Image(systemName: "chevron.up"),
        onTap: @escaping () -> Void
    ) {
        self.voteCount = voteCount
        self.hasVoted = hasVoted
        self.theme = theme
        self.upvoteIcon = upvoteIcon
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onTap()
            }
        }) {
            VStack(spacing: 6) {
                upvoteIcon
                    .font(.system(size: 16, weight: .bold))

                Text("\(voteCount)")
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(width: 48, height: 68)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        hasVoted
                            ? LinearGradient(
                                colors: [theme.primaryColor, theme.primaryColor.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            : LinearGradient(
                                colors: [Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        hasVoted
                            ? theme.primaryColor.opacity(0.3)
                            : Color.gray.opacity(0.25),
                        lineWidth: hasVoted ? 0 : 1.5
                    )
            )
            .foregroundColor(hasVoted ? .white : theme.textPrimaryColor.opacity(0.8))
            .shadow(
                color: hasVoted
                    ? theme.primaryColor.opacity(0.3)
                    : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#if DEBUG
struct VoteButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 24) {
            VoteButtonView(voteCount: 42, hasVoted: false) {}
            VoteButtonView(voteCount: 43, hasVoted: true) {}
        }
        .padding()
        .background(Color(hex: "#F3F4F6"))
    }
}
#endif
