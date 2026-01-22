import SwiftUI

/// Status badge view for feature status
public struct StatusBadgeView: View {
    let status: FeatureStatus
    let theme: Theme

    public init(status: FeatureStatus, theme: Theme = .default) {
        self.status = status
        self.theme = theme
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.caption2)

            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(theme.color(for: status).opacity(0.15))
        .foregroundColor(theme.color(for: status))
        .cornerRadius(6)
    }
}

#if DEBUG
struct StatusBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            StatusBadgeView(status: .pending)
            StatusBadgeView(status: .approved)
            StatusBadgeView(status: .inProgress)
            StatusBadgeView(status: .done)
            StatusBadgeView(status: .rejected)
        }
        .padding()
    }
}
#endif
