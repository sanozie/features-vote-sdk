import SwiftUI
import FeaturesVote

@main
struct FeaturesVoteTestApp: App {
   init() {
       // Replace with your project slug
       FeaturesVote.configure(with: "pulse")

       // Optional: Customize theme
       FeaturesVote.theme.primaryColor = .blue

       // Optional: Set test user
       FeaturesVote.updateUser(email: "test@example.com")
       FeaturesVote.updateUser(name: "Test User")

       // Optional: Attach contextual metadata to posts this user creates
       FeaturesVote.updateMetadata([
           "app_version": "1.2.3",
           "page": "settings",
           "device": "simulator"
       ])
   }

   var body: some Scene {
       WindowGroup {
           ContentView()
       }
   }
}
