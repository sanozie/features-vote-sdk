import SwiftUI
import FeaturesVote

/// Demonstrates the SDK's `Configuration` (all `UI` + `Behavior` options), a few
/// representative `Theme` colors, and user options, plus a button to present the
/// SwiftUI `CreateFeatureView` as a sheet. (Not exhaustive: `Configuration.Buttons`
/// icons and most `Theme` fonts/colors are not exercised here.)
///
/// The SDK snapshots `theme`/`config` when a widget is first built, so after changing
/// a value here we call `demo.reloadWidgets()` to rebuild the widget tabs (see
/// `DemoSettings` in ContentView). Change a setting, then switch to the Board or
/// Roadmap tab to see it take effect.
struct ConfigurationView: View {
    @EnvironmentObject private var demo: DemoSettings

    // MARK: - UI configuration mirrors Configuration.UI
    @State private var showStatusBadge = FeaturesVote.config.ui.showStatusBadge
    @State private var showCommentCount = FeaturesVote.config.ui.showCommentCount
    @State private var showTags = FeaturesVote.config.ui.showTags
    @State private var showWatermark = FeaturesVote.config.ui.showWatermark
    @State private var enablePullToRefresh = FeaturesVote.config.ui.enablePullToRefresh
    @State private var showAvatars = FeaturesVote.config.ui.showAvatars
    @State private var maxDescriptionLines = Double(FeaturesVote.config.ui.maxDescriptionLines)

    // MARK: - Behavior configuration mirrors Configuration.Behavior
    @State private var allowAnonymousVoting = FeaturesVote.config.behavior.allowAnonymousVoting
    @State private var allowAnonymousComments = FeaturesVote.config.behavior.allowAnonymousComments
    @State private var requireEmailForCreate = FeaturesVote.config.behavior.requireEmailForCreate
    @State private var enableOptimisticUpdates = FeaturesVote.config.behavior.enableOptimisticUpdates
    @State private var confirmVoting = FeaturesVote.config.behavior.confirmVoting
    @State private var confirmUnsubscribe = FeaturesVote.config.behavior.confirmUnsubscribe

    // MARK: - Local view state
    @State private var showingCreateSheet = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Change a setting, then switch to the Board or Roadmap tab to see it applied. (Widgets snapshot config when first shown, so they are rebuilt on change.)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                // MARK: UI
                Section("UI — Configuration.UI") {
                    Toggle("Show Status Badge", isOn: $showStatusBadge)
                        .onChange(of: showStatusBadge) { _, v in FeaturesVote.config.ui.showStatusBadge = v; demo.reloadWidgets() }
                    Toggle("Show Comment Count", isOn: $showCommentCount)
                        .onChange(of: showCommentCount) { _, v in FeaturesVote.config.ui.showCommentCount = v; demo.reloadWidgets() }
                    Toggle("Show Tags", isOn: $showTags)
                        .onChange(of: showTags) { _, v in FeaturesVote.config.ui.showTags = v; demo.reloadWidgets() }
                    Toggle("Show Watermark", isOn: $showWatermark)
                        .onChange(of: showWatermark) { _, v in FeaturesVote.config.ui.showWatermark = v; demo.reloadWidgets() }
                    Toggle("Show Avatars", isOn: $showAvatars)
                        .onChange(of: showAvatars) { _, v in FeaturesVote.config.ui.showAvatars = v; demo.reloadWidgets() }
                    Toggle("Enable Pull-to-Refresh", isOn: $enablePullToRefresh)
                        .onChange(of: enablePullToRefresh) { _, v in FeaturesVote.config.ui.enablePullToRefresh = v; demo.reloadWidgets() }

                    VStack(alignment: .leading) {
                        Text("Max Description Lines: \(Int(maxDescriptionLines))")
                        Slider(value: $maxDescriptionLines, in: 1...10, step: 1)
                            .onChange(of: maxDescriptionLines) { _, v in
                                FeaturesVote.config.ui.maxDescriptionLines = Int(v)
                                demo.reloadWidgets()
                            }
                    }
                }

                // MARK: Behavior
                Section("Behavior — Configuration.Behavior") {
                    Toggle("Allow Anonymous Voting", isOn: $allowAnonymousVoting)
                        .onChange(of: allowAnonymousVoting) { _, v in FeaturesVote.config.behavior.allowAnonymousVoting = v; demo.reloadWidgets() }
                    Toggle("Allow Anonymous Comments", isOn: $allowAnonymousComments)
                        .onChange(of: allowAnonymousComments) { _, v in FeaturesVote.config.behavior.allowAnonymousComments = v; demo.reloadWidgets() }
                    Toggle("Require Email for Create", isOn: $requireEmailForCreate)
                        .onChange(of: requireEmailForCreate) { _, v in FeaturesVote.config.behavior.requireEmailForCreate = v; demo.reloadWidgets() }
                    Toggle("Optimistic Updates", isOn: $enableOptimisticUpdates)
                        .onChange(of: enableOptimisticUpdates) { _, v in FeaturesVote.config.behavior.enableOptimisticUpdates = v; demo.reloadWidgets() }
                    Toggle("Confirm Before Voting", isOn: $confirmVoting)
                        .onChange(of: confirmVoting) { _, v in FeaturesVote.config.behavior.confirmVoting = v; demo.reloadWidgets() }
                    Toggle("Confirm Before Unsubscribe", isOn: $confirmUnsubscribe)
                        .onChange(of: confirmUnsubscribe) { _, v in FeaturesVote.config.behavior.confirmUnsubscribe = v; demo.reloadWidgets() }
                }

                // MARK: Theme
                Section("Theme") {
                    ColorPicker("Primary Color", selection: Binding(
                        get: { FeaturesVote.theme.primaryColor },
                        set: { FeaturesVote.theme.primaryColor = $0; demo.reloadWidgets() }
                    ))
                    ColorPicker("Background Color", selection: Binding(
                        get: { FeaturesVote.theme.backgroundColor },
                        set: { FeaturesVote.theme.backgroundColor = $0; demo.reloadWidgets() }
                    ))
                    ColorPicker("Surface Color", selection: Binding(
                        get: { FeaturesVote.theme.surfaceColor },
                        set: { FeaturesVote.theme.surfaceColor = $0; demo.reloadWidgets() }
                    ))
                }

                // MARK: User
                Section("User") {
                    Button("Set Test User") {
                        FeaturesVote.updateUser(email: "test@example.com")
                        FeaturesVote.updateUser(name: "Test User")
                        demo.reloadWidgets()
                    }
                    Button("Clear User") {
                        FeaturesVote.clearUser()
                        demo.reloadWidgets()
                    }
                }

                // MARK: SwiftUI views that need presentation
                Section("SwiftUI Views") {
                    Button("Create Feature (SwiftUI sheet)") {
                        showingCreateSheet = true
                    }
                    Text("FeatureDetailView is reached by tapping a card on the Board or Roadmap tab.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Configuration")
            .sheet(isPresented: $showingCreateSheet) {
                FeaturesVote.CreateFeatureView(onSuccess: {
                    showingCreateSheet = false
                })
            }
        }
    }
}
