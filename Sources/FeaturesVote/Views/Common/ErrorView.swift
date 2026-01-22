import SwiftUI

/// Error state view with retry action
public struct ErrorView: View {
    let error: APIError
    let theme: Theme
    let retryAction: () -> Void

    public init(error: APIError, theme: Theme = .default, retryAction: @escaping () -> Void) {
        self.error = error
        self.theme = theme
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(theme.errorColor)

            Text("Error")
                .font(.headline)
                .foregroundColor(theme.textPrimaryColor)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(theme.textSecondaryColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: retryAction) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(theme.primaryColor)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: .networkError("Connection failed")) {
            print("Retry tapped")
        }
    }
}
#endif
