# FeaturesVote Test App

This is a demonstration and testing application for the FeaturesVote Swift SDK. It showcases all SDK widgets, tests SDK functionality, and serves as a reference implementation for integrating the SDK into your own applications.

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

- **Demonstrates** all FeaturesVote SDK widgets (VotingBoard, FeatureDetail, CreateFeature, Changelog)
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
- **macOS 14.0+** (Sonoma)
- **A Features.Vote project slug** - Get one at [features.vote](https://features.vote)

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
           │                  │                    │
           ▼                  ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  VotingBoard    │  │ Configuration   │  │   UIKitDemo     │
│     View        │  │     View        │  │     View        │
│   (SDK Tab)     │  │ (Settings Tab)  │  │  (UIKit Tab)    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
        │                    │                     │
        ▼                    ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ FeaturesVote    │  │ FeaturesVote    │  │ FeaturesVote    │
│ .VotingBoard    │  │ .theme          │  │ .votingBoard-   │
│     View()      │  │ .config         │  │   ViewController│
│                 │  │ .updateUser()   │  │ .createFeature- │
│                 │  │ .clearUser()    │  │   ViewController│
└─────────────────┘  └─────────────────┘  └─────────────────┘
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
- Display VotingBoardView from SDK
- Provide navigation to ConfigurationView
- Provide navigation to UIKitDemoView

**SDK Widgets Used**:
```swift
FeaturesVote.VotingBoardView()  // Main voting board widget
```

### ConfigurationView.swift

**Purpose**: Interactive playground for testing SDK configuration

**Key Responsibilities**:
- Toggle UI configuration options (status badge, comment count)
- Change theme colors dynamically
- Test user management (set/clear user)

**SDK Methods Used**:
```swift
FeaturesVote.config.ui.showStatusBadge = true/false
FeaturesVote.config.ui.showCommentCount = true/false
FeaturesVote.theme.primaryColor = Color
FeaturesVote.updateUser(email: "...")
FeaturesVote.updateUser(name: "...")
FeaturesVote.clearUser()
```

### UIKitDemoView.swift

**Purpose**: Demonstrate UIKit integration with SDK

**Key Responsibilities**:
- Present VotingBoardViewController
- Present CreateFeatureViewController
- Present ChangelogViewController

**SDK Methods Used**:
```swift
FeaturesVote.votingBoardViewController      // UIViewController for voting board
FeaturesVote.createFeatureViewController()  // UIViewController for create feature
FeaturesVote.changelogViewController        // UIViewController for changelog
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

### Tab 2: Settings (Configuration)

Demonstrates SDK configuration:

| Feature | Description |
|---------|-------------|
| UI Toggles | Toggle status badge, comment count visibility |
| Theme Color | Color picker for primary color |
| User Management | Set test user or clear user data |

### Tab 3: UIKit (Integration)

Demonstrates UIKit bridging:

| Feature | Description |
|---------|-------------|
| Voting Board | Present as modal UIViewController |
| Create Feature | Present create form as modal |
| Changelog | Present changelog as modal |

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
2. Test all three tabs
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
- [ ] All three VCs function properly

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
