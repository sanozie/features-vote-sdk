import SwiftUI

/// Empty state view
public struct EmptyStateView: View {
    let message: String
    let icon: String

    public init(message: String, icon: String = "tray") {
        self.message = message
        self.icon = icon
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#if DEBUG
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(message: "No feature requests yet")
    }
}
#endif
