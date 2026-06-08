# FeaturesVote Test Apps

This directory holds demonstration / reference apps for the FeaturesVote Swift SDK. They showcase the SDK widgets, test SDK functionality, and serve as reference implementations for integrating the SDK into your own apps:

- **iOS** — [`FeaturesVoteTestApp/`](./FeaturesVoteTestApp/): an Xcode SwiftUI app with a `TabView` over Board, Roadmap, Changelog, a Configuration/Theme playground, and the UIKit view‑controller bridges. Documented below.
- **macOS** — [`FeaturesVoteMacExample/`](./FeaturesVoteMacExample/): a SwiftPM executable (`swift run`) covering the same widgets minus the iOS‑only UIKit bridges, and documenting the macOS‑specific hosting workarounds. See its own [README](./FeaturesVoteMacExample/README.md).

The rest of this document describes the **iOS** app.

## Table of Contents

1. [Overview](#overview)
2. [Related Documentation](#related-documentation)
3. [Project Structure](#project-structure)
4. [Getting Started](#getting-started)
5. [App Architecture](#app-architecture)
6. [File Descriptions](#file-descriptions)
7. [Features Demonstrated](#features-demonstrated)
8. [Contributing](#contributing)
9. [Testing Checklist](#testing-checklist)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The FeaturesVote Test App is an iOS application that:

- **Demonstrates** all FeaturesVote SDK widgets (VotingBoard, Roadmap, Changelog, CreateFeature; FeatureDetail via card tap)
- **Tests** SDK functionality including voting, comments, subscriptions, and user management
- **Validates** both SwiftUI and UIKit integration patterns
- **Provides** a reference implementation for SDK configuration and theming

This app is essential for:
- SDK development and debugging
- Validating new SDK features before release
- Demonstrating SDK capabilities to stakeholders
- Testing SDK integration patterns

---

## Related Documentation

### FeaturesVote SDK Documentation

| Document | Description | Link |
|----------|-------------|------|
| **SDK User Guide** | Complete guide for using the SDK - widgets, configuration, theming, localization, user management, and all available parameters | [DOCUMENTATION.md](../DOCUMENTATION.md) |
| **SDK Architecture Guide** | Technical deep-dive for SDK contributors - codebase structure, MVVM pattern, services, networking layer | [ARCHITECTURE.md](../ARCHITECTURE.md) |

### Quick Links to SDK Features

For detailed information on SDK widgets and parameters used in this test app:

- **VotingBoardView** - See [DOCUMENTATION.md#votingboardview](../DOCUMENTATION.md#votingboardview)
- **FeatureDetailView** - See [DOCUMENTATION.md#featuredetailview](../DOCUMENTATION.md#featuredetailview)
- **CreateFeatureView** - See [DOCUMENTATION.md#createfeatureview](../DOCUMENTATION.md#createfeatureview)
- **ChangelogView** - See [DOCUMENTATION.md#changelogview](../DOCUMENTATION.md#changelogview)
- **RoadmapView** - See [DOCUMENTATION.md#roadmapview](../DOCUMENTATION.md#roadmapview)
- **Theme Configuration** - See [DOCUMENTATION.md#theme-customization](../DOCUMENTATION.md#theme-customization)
- **Localization** - See [DOCUMENTATION.md#localization](../DOCUMENTATION.md#localization)
- **User Management** - See [DOCUMENTATION.md#user-management](../DOCUMENTATION.md#user-management)
- **UIKit Integration** - See [DOCUMENTATION.md#uikit-integration](../DOCUMENTATION.md#uikit-integration)

---

## Project Structure

```
TestApp/
├── README.md                              # This file
└── FeaturesVoteTestApp/
    ├── FeaturesVoteTestApp.xcodeproj/     # Xcode project file
    └── FeaturesVoteTestApp/
        ├── FeaturesVoteTestAppApp.swift   # App entry point & SDK initialization
        ├── ContentView.swift              # Main tab view with all demos
        ├── ConfigurationView.swift        # SDK configuration playground
        ├── UIKitDemoView.swift            # UIKit integration demo
        └── Assets.xcassets/               # App icons and colors
            ├── AccentColor.colorset/
            └── AppIcon.appiconset/
```

---

## Getting Started

### Prerequisites

- **Xcode 15.0+** (for iOS 17 SDK)
- **macOS 14.0+** (Sonoma) — to build/run this demo project
- **A Features.Vote project slug** - Get one at [features.vote](https://features.vote)

> The SDK itself supports **iOS 16.0+ / macOS 13.0+** (per `Package.swift`). The higher versions above are only what this TestApp's Xcode project targets.

### Opening the Project

1. **Open in Xcode**
   ```bash
   cd /Users/gp/Documents/manta/features-vote-sdk/TestApp/FeaturesVoteTestApp
   open FeaturesVoteTestApp.xcodeproj
   ```

2. **Configure Your Project Slug**

   Edit `FeaturesVoteTestAppApp.swift` and replace the slug:
   ```swift
   FeaturesVote.configure(with: "your-project-slug")
   ```

3. **Run the App**
   - Select a simulator (iPhone 15 Pro recommended)
   - Press `Cmd + R` or click the Run button

### Adding the SDK (Already Configured)

The FeaturesVote SDK is already linked as a local package dependency. If you need to re-add it:

1. **File > Add Package Dependencies**
2. Click **"Add Local..."**
3. Navigate to: `/Users/gp/Documents/manta/features-vote-sdk`
4. Click **"Add Package"**
5. Select **"FeaturesVote"** target

---

## App Architecture

The test app follows a simple architecture to demonstrate SDK integration:

```
┌─────────────────────────────────────────────────────────────┐
│                  FeaturesVoteTestAppApp                      │
│                    (App Entry Point)                         │
│         - SDK Initialization                                 │
│         - Theme Configuration                                │
│         - User Setup                                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       ContentView                            │
│                    (TabView Container)                       │
└─────────────────────────────────────────────────────────────┘
      │          │          │            │            │
      ▼          ▼          ▼            ▼            ▼
 ┌─────────┐ ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐
 │  Board  │ │ Roadmap │ │Changelog │ │ Settings │ │  UIKit  │
 │  (Tab)  │ │  (Tab)  │ │  (Tab)   │ │  (Tab)   │ │  (Tab)  │
 └─────────┘ └─────────┘ └──────────┘ └──────────┘ └─────────┘
      │          │          │            │            │
      ▼          ▼          ▼            ▼            ▼
 VotingBoard  Roadmap   Changelog   Configuration  UIKitDemo
   View()     View()     View()         View          View
                                    (theme/config/  (…View
                                     user + Create   Controller
                                     sheet)          bridges)
```

---

## File Descriptions

### FeaturesVoteTestAppApp.swift

**Purpose**: App entry point and SDK initialization

**Key Responsibilities**:
- Initialize FeaturesVote SDK with project slug
- Configure default theme (optional)
- Set up test user credentials (optional)

**SDK Methods Used**:
```swift
FeaturesVote.configure(with: "slug")      // Required: Initialize SDK
FeaturesVote.theme.primaryColor = .blue   // Optional: Customize theme
FeaturesVote.updateUser(email: "...")     // Optional: Set user email
FeaturesVote.updateUser(name: "...")      // Optional: Set user name
```

### ContentView.swift

**Purpose**: Main container with TabView for navigating between demos

**Key Responsibilities**:
- Display the SwiftUI VotingBoard, Roadmap, and Changelog widgets as tabs
- Provide navigation to ConfigurationView (Settings)
- Provide navigation to UIKitDemoView

**SDK Widgets Used**:
```swift
FeaturesVote.VotingBoardView()  // Board tab
FeaturesVote.RoadmapView()      // Roadmap tab
FeaturesVote.ChangelogView()    // Changelog tab
```

### ConfigurationView.swift

**Purpose**: Interactive playground for testing SDK configuration

**Key Responsibilities**:
- Toggle every `Configuration.UI` option (status badge, comment count, tags, watermark, avatars, pull-to-refresh, max description lines)
- Toggle every `Configuration.Behavior` option (anonymous voting/comments, require email, optimistic updates, confirm voting/unsubscribe)
- Change theme colors dynamically (primary, background, surface)
- Test user management (set/clear user)
- Present the SwiftUI `CreateFeatureView` as a sheet

**SDK Methods Used**:
```swift
FeaturesVote.config.ui.<option> = true/false
FeaturesVote.config.behavior.<option> = ...
FeaturesVote.theme.primaryColor = Color
FeaturesVote.updateUser(email: "...")
FeaturesVote.clearUser()
FeaturesVote.CreateFeatureView(onSuccess:)  // presented as a sheet
```

### UIKitDemoView.swift

**Purpose**: Demonstrate UIKit integration with SDK

**Key Responsibilities**:
- Present VotingBoardViewController
- Present RoadmapViewController
- Present ChangelogViewController
- Present CreateFeatureViewController

**SDK Methods Used**:
```swift
FeaturesVote.votingBoardViewController      // UIViewController for voting board
FeaturesVote.roadmapViewController          // UIViewController for roadmap
FeaturesVote.changelogViewController        // UIViewController for changelog
FeaturesVote.createFeatureViewController()  // UIViewController for create feature
```

---

## Features Demonstrated

### Tab 1: Voting Board (SwiftUI)

Demonstrates the main SDK widget:

| Feature | Description |
|---------|-------------|
| Feature List | Scrollable list of feature requests |
| Voting | Tap to vote/unvote on features |
| Tabs | Switch between Open and Done features |
| Search | Expandable search bar |
| Create | Button to create new feature requests |
| Pull-to-Refresh | Refresh feature list |
| Navigation | Tap feature to see detail view |
| Feature Detail | Full detail with comments, subscribe, share |

### Tab 2: Roadmap (SwiftUI)

Demonstrates the Kanban roadmap widget:

| Feature | Description |
|---------|-------------|
| Status Columns | Features grouped by status (Pending → Done) |
| Voting | Vote on cards directly from the board |
| Detail Sheet | Tap a card to open its detail view |
| Layout | Horizontal scroll on iOS, grid on macOS |

### Tab 3: Changelog (SwiftUI)

Demonstrates the changelog widget:

| Feature | Description |
|---------|-------------|
| Release List | Product releases with version, title, date |
| Markdown | Release notes rendered as Markdown |
| Detail | Tap a release to view full notes and linked features |

### Tab 4: Settings (Configuration)

Demonstrates SDK configuration:

| Feature | Description |
|---------|-------------|
| UI Toggles | Every `Configuration.UI` option (badges, tags, avatars, watermark, etc.) |
| Behavior Toggles | Every `Configuration.Behavior` option (anonymous, optimistic, confirm dialogs) |
| Theme Colors | Color pickers for primary, background, surface |
| User Management | Set test user or clear user data |
| Create (SwiftUI) | Present `CreateFeatureView` as a sheet |

### Tab 5: UIKit (Integration)

Demonstrates UIKit bridging:

| Feature | Description |
|---------|-------------|
| Voting Board | Present as modal UIViewController |
| Roadmap | Present roadmap as modal |
| Changelog | Present changelog as modal |
| Create Feature | Present create form as modal |

---

## Contributing

### Making Changes to the Test App

1. **Adding a New Demo Tab**

   Edit `ContentView.swift`:
   ```swift
   TabView {
       // Existing tabs...

       NewDemoView()
           .tabItem {
               Label("New Demo", systemImage: "star")
           }
   }
   ```

2. **Testing New SDK Features**

   Create a new view file and add it to the tab view, then import and use the new SDK feature.

3. **Adding Test Scenarios**

   Add new buttons/toggles in `ConfigurationView.swift` to test SDK configuration options.

### Code Style

- Follow Swift conventions
- Use SwiftUI for new views
- Add comments explaining SDK methods being demonstrated
- Keep each file focused on a single demonstration area

### Testing Changes

1. Build and run on iOS Simulator
2. Test all five tabs (Board, Roadmap, Changelog, Settings, UIKit)
3. Verify SDK functionality works as expected
4. Test both light and dark modes
5. Test on different device sizes

---

## Testing Checklist

Use this checklist when validating SDK functionality:

### VotingBoard Tests
- [ ] Features load from API
- [ ] Voting up/down works
- [ ] Tab switching (Open/Done) works
- [ ] Search filters features
- [ ] Pull-to-refresh works
- [ ] Create button opens modal
- [ ] Feature tap navigates to detail
- [ ] Anonymous voting works (if enabled)
- [ ] Dark mode renders correctly

### FeatureDetail Tests
- [ ] Feature details display correctly
- [ ] Voting works
- [ ] Subscribe/unsubscribe works
- [ ] Comments load
- [ ] Add comment works
- [ ] Emoji reactions work
- [ ] Share button works
- [ ] Created by user displays

### CreateFeature Tests
- [ ] Form validation works
- [ ] Title/description required
- [ ] Tag selection works
- [ ] Submit creates feature
- [ ] Success message appears
- [ ] Modal dismisses after submit

### Configuration Tests
- [ ] Theme color changes apply immediately
- [ ] UI config toggles work
- [ ] User set/clear works
- [ ] Changes persist across tab switches

### UIKit Integration Tests
- [ ] ViewControllers present correctly
- [ ] Navigation works within presented VCs
- [ ] Dismissal works
- [ ] All four VCs function properly (Voting Board, Roadmap, Changelog, Create Feature)

### Visual Tests
- [ ] Light mode appearance
- [ ] Dark mode appearance
- [ ] iPhone SE layout
- [ ] iPhone 15 Pro Max layout
- [ ] iPad layout (if applicable)

---

## Troubleshooting

### "FeaturesVote not configured" Error

**Cause**: SDK not initialized before views are created

**Solution**: Ensure `FeaturesVote.configure(with:)` is called in `App.init()`:
```swift
@main
struct FeaturesVoteTestApp: App {
    init() {
        FeaturesVote.configure(with: "your-slug")  // Must be first!
    }
    // ...
}
```

### Features Not Loading

**Possible Causes**:
1. Invalid project slug
2. No network connection
3. API endpoint unavailable

**Solution**:
- Check Console for API errors (`Cmd + Shift + C`)
- Verify slug matches your Features.Vote project
- Check network connectivity

### Voting Not Working

**Possible Causes**:
1. Anonymous voting disabled in project settings
2. User already voted
3. Network error

**Solution**:
- Set user credentials in ConfigurationView
- Check project settings at features.vote
- Check Console for error messages

### Theme Changes Not Applying

**Cause**: Views may cache initial theme

**Solution**:
- Switch tabs and return
- Restart the app for full theme refresh

### UIKit Presentation Issues

**Cause**: Root view controller not found

**Solution**: Ensure app has a visible window before presenting:
```swift
if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
   let rootViewController = windowScene.windows.first?.rootViewController {
    rootViewController.present(viewController, animated: true)
}
```

### Build Errors After SDK Changes

**Solution**:
1. Clean build folder: `Cmd + Shift + K`
2. Reset package caches: `File > Packages > Reset Package Caches`
3. Rebuild: `Cmd + B`

---

## Required Setup

### 1. Get Your Project Slug

1. Go to [https://features.vote](https://features.vote)
2. Create or select your project
3. Note your project slug from the URL: `your-slug.features.vote`

### 2. Configure SDK

Edit `FeaturesVoteTestAppApp.swift`:
```swift
FeaturesVote.configure(with: "your-slug-here")
```

### 3. Optional: Configure Test User

```swift
FeaturesVote.updateUser(email: "test@example.com")
FeaturesVote.updateUser(name: "Test User")
FeaturesVote.updateUser(customID: "user-123")
```

---

## Performance Testing

When testing SDK performance:

1. **Large Data Sets**: Load 100+ features - should scroll smoothly
2. **Rapid Interactions**: Rapid voting - should handle optimistic updates
3. **Network Errors**: Test with airplane mode - should show error states
4. **Poor Connection**: Use Network Link Conditioner - should show loading states

---

## Screenshots

When taking screenshots for documentation:

1. Run on iPhone 15 Pro simulator
2. Navigate to each screen
3. Take screenshots: `Cmd + S`
4. Test both light and dark modes
5. Save to `/docs/screenshots/` (if created)

---

## Next Steps

After setting up the test app:

1. Replace project slug with your actual slug
2. Run through the testing checklist
3. Report any SDK issues found
4. Take screenshots for documentation
5. Add new test scenarios as SDK evolves

---

## Links

- **FeaturesVote SDK**: [../Sources/FeaturesVote](../Sources/FeaturesVote)
- **SDK Documentation**: [../DOCUMENTATION.md](../DOCUMENTATION.md)
- **SDK Architecture**: [../ARCHITECTURE.md](../ARCHITECTURE.md)
- **Features.Vote Website**: [https://features.vote](https://features.vote)
