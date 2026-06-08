# macOS Example App & Integration Guidance

The repo ships a macOS example app at [`TestApp/FeaturesVoteMacExample/`](../../TestApp/FeaturesVoteMacExample/) — a standalone **SwiftPM executable** that hosts the SDK's SwiftUI views in a normal AppKit window. It is the macOS counterpart to the iOS `FeaturesVoteTestApp`, and doubles as the canonical reference for **how to integrate the SDK on macOS**.

## What it is

- A SwiftPM `.executableTarget` (not an `.xcodeproj`), launchable with `swift run` or via `open Package.swift` in Xcode.
- Depends on the SDK by **local path** (`.package(path: "../..")`), so it always builds against the in-repo SDK source.
- Targets **macOS 14** (the SDK supports macOS 13+; the example targets 14 to use the two-parameter `.onChange(of:)` and `NSHostingController.sceneBridgingOptions`).
- Demonstrates the SwiftUI views `VotingBoardView`, `RoadmapView`, `ChangelogView`, and `CreateFeatureView`, plus a live `Configuration`/`Theme` playground.

## Why macOS needs its own example

SwiftUI renders the SDK's views differently on macOS than on iOS, and hosting them in an AppKit window via `NSHostingController` surfaces several quirks. The example encodes the fixes; they are equally relevant to any real macOS consumer.

### Integration guidance (the macOS workarounds)

1. **Host through `NSHostingController` in an `NSWindow`** you own (manual `NSApplication` bootstrap, or an `NSWindow` opened from your existing app). This is what lets you apply the rest.
2. **`hostingController.sceneBridgingOptions = []`** (macOS 14+) — prevents the SDK views' `NavigationStack` toolbars from bridging into the window titlebar (otherwise per-view titles and stray toolbar items crowd the chrome).
3. **Force light**: `.preferredColorScheme(.light)` on the hosted content and `window.appearance = NSAppearance(named: .aqua)`. The SDK ships a **light-only** theme (`Theme.surfaceColor` defaults to `.white`); some elements use system-adaptive colors that become invisible on white cards in Dark Mode.
4. **Wrap `RoadmapView` in a horizontal `ScrollView`** sized to `max(1330, availableWidth)`. The roadmap is a fixed-width 5-column kanban inside a vertical-only scroll view; without a horizontal scroll, narrow windows clip the trailing columns.
5. **Provide your own "back to list"** for list→detail navigation. The SDK uses a `NavigationStack`; on macOS there's no swipe-back/system back button when hosted in AppKit. Rebuilding the view (e.g. bumping a token folded into its `.id`) returns it to the root list.
6. **Rebuild widgets after `theme`/`config` changes.** The SDK snapshots `FeaturesVote.theme`/`config` at first build; change a widget's `.id` to force it to re-read the latest values.
7. **Add an Edit menu** if you bootstrap your own `NSApplication` (SwiftPM executables get no menu for free) so the Create form's text fields support cut/copy/paste/select-all.

These are demonstrated end-to-end in `FeaturesVoteMacExample/Sources/FeaturesVoteMacExample/{AppDelegate,FeedbackWindow,ConfigurationView}.swift` and explained in the example's [README](../../TestApp/FeaturesVoteMacExample/README.md).

## Feature parity with the iOS TestApp

| Surface | iOS `FeaturesVoteTestApp` | macOS `FeaturesVoteMacExample` |
|---------|---------------------------|--------------------------------|
| Voting Board (`VotingBoardView`) | ✅ | ✅ |
| Roadmap (`RoadmapView`) | ✅ | ✅ (horizontal-scroll wrapper) |
| Changelog (`ChangelogView`) | ✅ | ✅ |
| Configuration/Theme playground | ✅ | ✅ |
| Create Feature sheet (`CreateFeatureView`) | ✅ | ✅ |
| Feature Detail (`FeatureDetailView`) | via card tap | via card tap |
| UIKit view-controller bridges | ✅ | ❌ — bridges are `#if canImport(UIKit)`, **iOS-only** |

## How to run

```bash
cd TestApp/FeaturesVoteMacExample
swift run
```

Or `open Package.swift` in Xcode, select the `FeaturesVoteMacExample` scheme, and ⌘R.

## Maintenance

When the SDK's view behavior on macOS changes (navigation, toolbar usage, theming, the roadmap layout), update both this example and this doc so the integration guidance stays accurate.
