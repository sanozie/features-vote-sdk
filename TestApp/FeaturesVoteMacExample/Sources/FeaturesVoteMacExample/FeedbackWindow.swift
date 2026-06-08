import AppKit
import SwiftUI
import FeaturesVote

/// The surfaces shown in the example, driving the segmented switcher.
private enum DemoTab: String, CaseIterable, Identifiable {
    case board     = "Board"
    case roadmap   = "Roadmap"
    case changelog = "Changelog"
    case settings  = "Settings"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .board:     return "list.bullet"
        case .roadmap:   return "rectangle.split.3x1"
        case .changelog: return "sparkles"
        case .settings:  return "gear"
        }
    }
}

/// Hosts the SDK's macOS-compatible SwiftUI views behind a segmented tab bar.
///
/// This is the heart of the macOS integration. Several non-obvious workarounds live here
/// (each explained inline); they were discovered while shipping the SDK in a real macOS
/// app and are documented in this example's README and in `docs/features/macos-example-app.md`.
struct FeedbackBoardView: View {
    @StateObject private var demo = DemoSettings()
    @State private var tab: DemoTab = .board
    @State private var resetToken = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                // The SDK's list → detail navigation uses a NavigationStack. On macOS there
                // is no swipe-back gesture and (hosted in an AppKit window) no system back
                // button, so we provide one: bumping `resetToken` is folded into the active
                // surface's `.id`, which rebuilds it at its root list — i.e. "back".
                Button {
                    resetToken &+= 1
                } label: {
                    Image(systemName: "chevron.backward").fontWeight(.semibold)
                }
                .buttonStyle(.borderless)
                .help("Back to list")

                Picker("", selection: $tab) {
                    ForEach(DemoTab.allCases) { t in
                        Label(t.rawValue, systemImage: t.symbol).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .padding(12)

            Divider()

            // Only the selected surface is instantiated (a `switch`, not a `TabView`).
            // Each SDK widget is keyed to `resetToken` (back button) and `demo.revision`
            // (Settings changes) so it rebuilds when either changes. The Settings tab is
            // deliberately NOT keyed to `revision`, so toggling a switch there doesn't tear
            // down and reset the form you're interacting with.
            Group {
                switch tab {
                case .board:
                    FeaturesVote.VotingBoardView()
                        .id("board-\(resetToken)-\(demo.revision)")
                case .roadmap:
                    roadmap
                        .id("roadmap-\(resetToken)-\(demo.revision)")
                case .changelog:
                    FeaturesVote.ChangelogView()
                        .id("changelog-\(resetToken)-\(demo.revision)")
                case .settings:
                    ConfigurationView()
                        .environmentObject(demo)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 600)
        // The SDK ships a light-only theme (light-gray background, white cards). Some
        // elements use system-adaptive colors that flip to white in Dark Mode and become
        // invisible on the white cards, so pin the whole surface to light.
        .preferredColorScheme(.light)
    }

    /// The SDK's `RoadmapView` is a fixed-width 5-column Kanban (~1330pt) inside a
    /// vertical-only ScrollView. In a narrower window the trailing columns overflow with no
    /// way to reach them, so wrap it in a horizontal ScrollView wide enough for all columns.
    /// Vertical scrolling inside each column is preserved; when the window is widened past
    /// the content width, the roadmap simply fills it (no extra horizontal scroll).
    private var roadmap: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: true) {
                FeaturesVote.RoadmapView()
                    .frame(width: max(1330, geo.size.width), height: geo.size.height)
            }
        }
    }
}

/// Shared demo state. The SDK widgets snapshot `FeaturesVote.theme` / `FeaturesVote.config`
/// when their body is first built, so changing a setting at runtime does not affect an
/// already-built widget. Bumping `revision` (keyed into each widget's `.id`) forces SwiftUI
/// to rebuild the widget — re-reading the latest theme/config — the next time its tab shows.
/// Mirrors the iOS TestApp's `DemoSettings`.
final class DemoSettings: ObservableObject {
    @Published var revision = 0
    func reloadWidgets() { revision += 1 }
}
