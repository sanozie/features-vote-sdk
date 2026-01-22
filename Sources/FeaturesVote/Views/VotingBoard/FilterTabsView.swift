import SwiftUI

/// Filter tabs for Open/Done features
public struct FilterTabsView: View {
    @Binding var selectedTab: FeatureTab
    let theme: Theme

    public init(selectedTab: Binding<FeatureTab>, theme: Theme = .default) {
        self._selectedTab = selectedTab
        self.theme = theme
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(FeatureTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? theme.primaryColor : theme.textSecondaryColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(selectedTab == tab ? theme.primaryColor.opacity(0.1) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

#if DEBUG
struct FilterTabsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FilterTabsView(selectedTab: .constant(.open))
            FilterTabsView(selectedTab: .constant(.done))
        }
        .padding()
        .background(Color(hex: "#F3F4F6"))
    }
}
#endif
