import SwiftUI
import FeaturesVote

struct ContentView: View {
   var body: some View {
       TabView {
           // SwiftUI Demo
           FeaturesVote.VotingBoardView()
               .tabItem {
                   Label("Voting Board", systemImage: "list.bullet")
               }

           // Configuration Demo
           ConfigurationView()
               .tabItem {
                   Label("Settings", systemImage: "gear")
               }

           // UIKit Demo
           UIKitDemoView()
               .tabItem {
                   Label("UIKit", systemImage: "rectangle.stack")
               }
       }
   }
}
