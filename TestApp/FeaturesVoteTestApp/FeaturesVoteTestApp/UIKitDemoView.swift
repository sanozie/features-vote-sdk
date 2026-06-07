import SwiftUI
import FeaturesVote

/// Demonstrates the UIKit bridges. Every SwiftUI widget is also available as a
/// `UIViewController` via the `FeaturesVote` namespace.
struct UIKitDemoView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Present as UIViewController") {
                    Button("Voting Board (UIKit)") {
                        presentViewController(FeaturesVote.votingBoardViewController)
                    }

                    Button("Roadmap (UIKit)") {
                        presentViewController(FeaturesVote.roadmapViewController)
                    }

                    Button("Changelog (UIKit)") {
                        presentViewController(FeaturesVote.changelogViewController)
                    }

                    Button("Create Feature (UIKit)") {
                        presentViewController(FeaturesVote.createFeatureViewController(onSuccess: {
                            print("Feature created via UIKit bridge")
                        }))
                    }
                }

                Section {
                    Text("featureDetailViewController(for:) requires a Feature value, "
                         + "which you obtain by tapping a card on the Board or Roadmap tab.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("UIKit Integration")
        }
    }

    private func presentViewController(_ viewController: UIViewController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(viewController, animated: true)
        }
    }
}
