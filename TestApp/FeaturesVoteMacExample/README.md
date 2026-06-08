# FeaturesVote — macOS Example

A standalone **SwiftPM executable** macOS app that demonstrates how to host the FeaturesVote SDK's SwiftUI views on macOS. It is the macOS counterpart to the iOS [`FeaturesVoteTestApp`](../FeaturesVoteTestApp/): it exercises every macOS-compatible widget (Board, Roadmap, Changelog) plus a live Configuration/Theme playground, and — crucially — documents the macOS-specific hosting workarounds that real consumers need.

> **Why a separate example?** SwiftUI renders the SDK's views differently on macOS than on iOS, and hosting them in an AppKit window surfaces a handful of quirks (no swipe-back, dark-mode contrast, a wide Roadmap kanban, `NavigationStack` toolbar bridging). This app shows the fixes, all in one place.

## Table of contents

1. [Requirements](#requirements)
2. [Getting started](#getting-started)
3. [Project structure](#project-structure)
4. [File descriptions](#file-descriptions)
5. [macOS-specific workarounds (and why)](#macos-specific-workarounds-and-why)
6. [Differences from the iOS example](#differences-from-the-ios-example)
7. [Troubleshooting](#troubleshooting)

---

## Requirements

- macOS **14+** (the SDK itself supports macOS 13+; this example targets 14 so it can use the two-parameter `.onChange(of:)` and `NSHostingController.sceneBridgingOptions` — see the workarounds below).
- Swift 5.9+ / Xcode 15+.

## Getting started

From the command line:

```bash
cd TestApp/FeaturesVoteMacExample
swift run            # debug build; add -c release for an optimized one
```

Or in Xcode:

```bash
open Package.swift   # then pick the "FeaturesVoteMacExample" scheme and press ⌘R
```

**Set your project slug.** The example ships with the shared demo project `"pulse"`. Change it in `AppDelegate.configureSDK()`:

```swift
FeaturesVote.configure(with: "your-project-slug")
```

No API key is required — just the slug.

## Project structure

```
FeaturesVoteMacExample/
├── Package.swift                       # SwiftPM executable; local path dependency on the SDK (../..)
├── README.md                           # this file
└── Sources/FeaturesVoteMacExample/
    ├── main.swift                      # NSApplication bootstrap (.regular policy)
    ├── AppDelegate.swift               # SDK configuration + the main NSWindow + app menu
    ├── FeedbackWindow.swift            # FeedbackBoardView: the segmented Board/Roadmap/Changelog/Settings host
    └── ConfigurationView.swift         # live Configuration + Theme playground (+ Create sheet)
```

The example depends on the SDK via a **local path** (`.package(path: "../..")`), so it always builds against the in-repo SDK source — the same approach the iOS example uses.

## File descriptions

| File | Responsibility |
|------|----------------|
| **`main.swift`** | Boots `NSApplication` manually with `.regular` activation policy (a normal Dock app), rather than a SwiftUI `@main App`, so the app can own its `NSWindow` and apply the AppKit-level workarounds below. |
| **`AppDelegate.swift`** | Calls `FeaturesVote.configure(with:)`, sets anonymous voting/comments, a brand color and a test user; builds the main window (`NSWindow` + `NSHostingController(FeedbackBoardView())`); builds a minimal App + Edit menu. |
| **`FeedbackWindow.swift`** | `FeedbackBoardView` — a segmented switcher over `VotingBoardView`, the wrapped `RoadmapView`, `ChangelogView`, and `ConfigurationView`, plus the "back to list" control and the `DemoSettings` reload mechanism. This is where the macOS workarounds live. |
| **`ConfigurationView.swift`** | A near-verbatim port of the iOS example's playground: every `Configuration.UI` and `Configuration.Behavior` option, representative `Theme` colors, user set/clear, and a `CreateFeatureView` sheet. |

## macOS-specific workarounds (and why)

These are the heart of the example. Each is annotated inline in the source.

1. **Manual `NSApplication` bootstrap instead of `@main App`/`WindowGroup`** (`main.swift`) — needed to own the `NSWindow` so we can set `sceneBridgingOptions`, the window appearance, and a custom menu. A pure SwiftUI `WindowGroup` can't express these.
2. **`.regular` activation policy** — a normal Dock app (the menu-bar/`.accessory` style isn't appropriate for an example).
3. **`hosting.sceneBridgingOptions = []`** (`AppDelegate`, macOS 14+) — stops the SDK views' `NavigationStack` toolbars from bridging into the window titlebar, which otherwise crowds it with the per-view title and stray toolbar items.
4. **`.preferredColorScheme(.light)` + `window.appearance = NSAppearance(named: .aqua)`** — the SDK ships a **light-only** theme (white cards); some elements use system-adaptive colors that turn white in Dark Mode and become invisible. Pin the whole surface and the window chrome to light.
5. **Roadmap horizontal `ScrollView` wrapper** (`FeedbackBoardView.roadmap`) — `RoadmapView` is a fixed-width 5-column kanban (~1330pt) in a vertical-only scroll view; in a narrower window the trailing columns are unreachable. Wrapping it in `ScrollView(.horizontal)` at `max(1330, windowWidth)` makes every column reachable while preserving each column's vertical scroll.
6. **"Back to list" button + `.id(resetToken)` rebuild** — the SDK's list→detail uses a `NavigationStack`, and on macOS (hosted in AppKit) there's no system back button. Bumping `resetToken` (folded into each widget's `.id`) rebuilds the active surface at its root list.
7. **`DemoSettings.revision` + `.id(...)`** — the SDK snapshots `theme`/`config` when a widget is first built. Bumping `revision` after a Settings change forces a rebuild so the change is reflected (the same trick the iOS example uses).
8. **Custom App + Edit menu** (`AppDelegate.buildMenu`) — a SwiftPM GUI executable gets no menu bar for free; the Edit menu gives the Create form's text fields the standard ⌘X/⌘C/⌘V/⌘A shortcuts.
9. **No UIKit tab** — the SDK's UIKit view-controller bridges (`votingBoardViewController`, etc.) are gated behind `#if canImport(UIKit)` and therefore **don't exist on macOS**. Use the SwiftUI views directly (as this example does).

## Differences from the iOS example

| Aspect | iOS (`FeaturesVoteTestApp`) | macOS (this app) |
|--------|----------------------------|------------------|
| Project format | Xcode `.xcodeproj` | SwiftPM executable (`swift run`) |
| App shell | SwiftUI `@main App` + `WindowGroup` + `TabView` | `NSApplication` + `NSWindow` + `NSHostingController` + segmented `Picker` |
| Board / Roadmap / Changelog / Settings | ✅ | ✅ |
| UIKit bridges tab | ✅ | ❌ (iOS-only API) |
| Special hosting code | none needed | the 9 workarounds above |

## Troubleshooting

- **"FeaturesVote not configured" crash** — `configure(with:)` must run before any SDK view is built. It is the first thing `applicationDidFinishLaunching` does, in `configureSDK()`.
- **No features / empty board** — check the slug in `configureSDK()` and your network connection; the board loads live data from the project.
- **Window appears behind the terminal** — handled by `NSApp.activate(ignoringOtherApps:)`; click the Dock icon if needed.
- **Roadmap columns look clipped** — scroll horizontally, or widen the window; see workaround #5.
- **Settings change didn't apply** — switch to the Board/Roadmap tab; widgets rebuild on tab change via `DemoSettings.revision` (#7).
- **Clean rebuild** — `rm -rf .build Package.resolved && swift run`.

---

See [`docs/features/macos-example-app.md`](../../docs/features/macos-example-app.md) for the same workarounds framed as integration guidance for any macOS consumer, and the top-level [README](../../README.md) / [DOCUMENTATION.md](../../DOCUMENTATION.md) for the full SDK reference.
