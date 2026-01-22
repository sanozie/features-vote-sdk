import SwiftUI
import FeaturesVote

struct UIKitDemoView: View {
   var body: some View {
       NavigationStack {
           List {
               Button("Show Voting Board (UIKit)") {
                   presentViewController(FeaturesVote.votingBoardViewController)
               }

               Button("Create Feature (UIKit)") {
                   presentViewController(FeaturesVote.createFeatureViewController())
               }

               Button("Show Changelog (UIKit)") {
                   presentViewController(FeaturesVote.changelogViewController)
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
