import SwiftUI
import Combine
import FeaturesVote

/// Shared demo state. The SDK widgets snapshot `FeaturesVote.theme`/`config` when
/// their body is first built, so changing a setting at runtime does not affect an
/// already-visible widget. To make the Settings tab actually reflect changes, we
/// bump `revision` whenever a setting changes and key each widget's `.id(...)` to it,
/// which forces SwiftUI to rebuild the widget (re-reading the latest theme/config)
/// the next time its tab is shown.
final class DemoSettings: ObservableObject {
    @Published var revision = 0
    func reloadWidgets() { revision += 1 }
}

struct ContentView: View {
    @StateObject private var demo = DemoSettings()

    var body: some View {
        TabView {
            // SwiftUI: Voting Board
            FeaturesVote.VotingBoardView()
                .id("board-\(demo.revision)")
                .tabItem {
                    Label("Board", systemImage: "list.bullet")
                }

            // SwiftUI: Roadmap (Kanban)
            FeaturesVote.RoadmapView()
                .id("roadmap-\(demo.revision)")
                .tabItem {
                    Label("Roadmap", systemImage: "rectangle.split.3x1")
                }

            // SwiftUI: Changelog
            FeaturesVote.ChangelogView()
                .id("changelog-\(demo.revision)")
                .tabItem {
                    Label("Changelog", systemImage: "sparkles")
                }

            // Configuration + SwiftUI Create demo
            ConfigurationView()
                .environmentObject(demo)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }

            // UIKit bridges
            UIKitDemoView()
                .tabItem {
                    Label("UIKit", systemImage: "rectangle.stack")
                }
        }
    }
}
