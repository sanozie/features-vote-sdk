
import SwiftUI
import FeaturesVote

struct ConfigurationView: View {
   @State private var showStatusBadge = true
   @State private var showComments = true
   @State private var primaryColorHex = "#007AFF"

   var body: some View {
       NavigationStack {
           Form {
               Section("UI Configuration") {
                   Toggle("Show Status Badge", isOn: $showStatusBadge)
                       .onChange(of: showStatusBadge) { _, new in
                           FeaturesVote.config.ui.showStatusBadge = new
                       }

                   Toggle("Show Comment Count", isOn: $showComments)
                       .onChange(of: showComments) { _, new in
                           FeaturesVote.config.ui.showCommentCount = new
                       }
               }

               Section("Theme") {
                   ColorPicker("Primary Color", selection: Binding(
                       get: { FeaturesVote.theme.primaryColor },
                       set: { FeaturesVote.theme.primaryColor = $0 }
                   ))
               }

               Section("User") {
                   Button("Set Test User") {
                       FeaturesVote.updateUser(email: "test@example.com")
                       FeaturesVote.updateUser(name: "Test User")
                   }

                   Button("Clear User") {
                       FeaturesVote.clearUser()
                   }
               }
           }
           .navigationTitle("Configuration")
       }
   }
}
