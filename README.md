<h1 align="center"><a href="https://features.vote/?ref=github">Features.Vote</a></h1>
<h4 align="center">In-App Feature Requests, Roadmap & Changelog. Native for iOS & macOS.</h4>

<p align="center">
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-Elastic%202.0-7C3AED.svg" alt="Elastic License 2.0"></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9-7C3AED.svg" alt="Swift 5.9"></a>
    <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/Platforms-iOS%2016%20|%20macOS%2013-7C3AED.svg" alt="Platforms"></a>
</p>

<p align="center">
Let your users <b>request, vote on, and follow</b> features right inside your app — with drop-in SwiftUI views that <b>just work ✨</b><br/>
Zero external dependencies. Apple-native frameworks only.
</p>

<p align="center">
  <img src="https://ik.imagekit.io/mantatech/fv_ios_mockup_1.jpg" width="100%" alt="Feedback board and feedback form" />
</p>

<p align="center">
  <img src="https://ik.imagekit.io/mantatech/fv_ios_mockup_2.jpg" width="100%" alt="Roadmap and changelog widgets" />
</p>

## Index
- [Setup (SwiftUI)](#swiftui)
- [Setup (UIKit)](#uikit)
- [Views](#views)
- [Theming](#theming)
- [Configuration](#configuration)
- [User Identification](#user-identification)
- [Localization](#localization)

---

# SwiftUI

## 1. Add Features.Vote as a dependency in Xcode.

In Xcode → **File → Add Package Dependencies**, paste:

```
https://github.com/features-vote/features-vote-sdk.git
```

Or add it to your `Package.swift`:

```swift
.package(url: "https://github.com/features-vote/features-vote-sdk.git", from: "2.0.0")
```

## 2. Configure Features.Vote with your project slug.
###### No API key required — just the project slug you set up at [features.vote](https://features.vote).

```swift
import SwiftUI
import FeaturesVote

@main
struct MyApp: App {
    init() {
        FeaturesVote.configure(with: "your-project-slug")
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

## 3. Now use the views wherever you want!

```swift
import SwiftUI
import FeaturesVote

struct ContentView: View {
    var body: some View {
        FeaturesVote.VotingBoardView()
    }
}
```
###### NOTE: Wrap a view in a `NavigationStack` if you want push navigation into feature details.

---

# UIKit

## 1. Add Features.Vote as a dependency in Xcode.

```
https://github.com/features-vote/features-vote-sdk.git
```

## 2. Configure Features.Vote with your project slug.

```swift
import UIKit
import FeaturesVote

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FeaturesVote.configure(with: "your-project-slug")
        return true
    }
}
```

## 3. Now present any of the view controllers.

```swift
import UIKit
import FeaturesVote

class HomeViewController: UIViewController {
    @objc func buttonTapped() {
        let board = FeaturesVote.votingBoardViewController
        present(UINavigationController(rootViewController: board), animated: true)
    }
}
```

---

# Views

Five drop-in views cover the full feedback loop. Each has a SwiftUI struct and a matching UIKit view controller.

| What it does | SwiftUI | UIKit |
|---|---|---|
| Voting board with filter & sort | `FeaturesVote.VotingBoardView()` | `FeaturesVote.votingBoardViewController` |
| Feature detail with comments & reactions | `FeaturesVote.FeatureDetailView(feature:)` | `FeaturesVote.featureDetailViewController(for:)` |
| Submit a new feature request | `FeaturesVote.CreateFeatureView()` | `FeaturesVote.createFeatureViewController()` |
| Changelog of shipped releases | `FeaturesVote.ChangelogView()` | `FeaturesVote.changelogViewController` |
| Kanban-style public roadmap | `FeaturesVote.RoadmapView()` | `FeaturesVote.roadmapViewController` |

```swift
// SwiftUI
FeaturesVote.VotingBoardView()
FeaturesVote.ChangelogView()
FeaturesVote.RoadmapView()

// UIKit
present(FeaturesVote.votingBoardViewController, animated: true)
```

---

# Theming
#### Theme Features.Vote to match your app's brand. 🎨

```swift
FeaturesVote.theme = Theme(
    // Buttons, accents, and the vote button
    primaryColor: Color(hex: "#7C3AED"),
    secondaryColor: .purple,

    // Surfaces
    backgroundColor: Color(hex: "#F3F4F6"),
    surfaceColor: .white,
    textPrimaryColor: .primary,
    textSecondaryColor: .secondary,

    // Status colors (pending / approved / in progress / done / rejected)
    pendingColor: Color(hex: "#718096"),
    approvedColor: Color(hex: "#06B6D4"),
    inProgressColor: Color(hex: "#F97316"),
    doneColor: Color(hex: "#10B981"),
    rejectedColor: Color(hex: "#EF4444"),

    // Layout
    cornerRadius: 16
)
```

You can also set fonts (`titleFont`, `bodyFont`, `captionFont`) and `errorColor` / `successColor`. Dark mode is supported out of the box. See [DOCUMENTATION.md](./DOCUMENTATION.md) for every property.

---

# Configuration
#### Toggle UI elements and behavior to fit your app.

```swift
FeaturesVote.config = Configuration(
    ui: Configuration.UI(
        showStatusBadge: true,       // e.g. pending, approved, done
        showCommentCount: true,
        showTags: true,
        showWatermark: true,         // "Powered by Features.Vote"
        enablePullToRefresh: true,
        maxDescriptionLines: 3,
        showAvatars: true
    ),
    behavior: Configuration.Behavior(
        allowAnonymousVoting: true,
        allowAnonymousComments: true,
        requireEmailForCreate: false,
        enableOptimisticUpdates: true,   // update UI instantly, revert on error
        confirmVoting: false,
        confirmUnsubscribe: true
    ),
    buttons: Configuration.Buttons(
        upvoteIcon: Image(systemName: "arrow.up"),
        subscribeIcon: Image(systemName: "bell"),
        subscribedIcon: Image(systemName: "bell.fill")
    )
)
```

The vote, subscribe, and subscribed-state button icons are customizable via `Configuration.Buttons`.

---

# User Identification
#### 💰 Revenue indication: share how much a user is worth.

```swift
// Customer lifetime value — shown in your admin dashboard so you can
// prioritize a request with 2 votes and $299 behind it over one with 7 votes and $0.
FeaturesVote.updateUser(spend: 299.0)
```

#### 📧 Identify your users (any combination).

```swift
FeaturesVote.updateUser(email: "user@example.com")
FeaturesVote.updateUser(name: "Jane Doe")
FeaturesVote.updateUser(imageUrl: "https://example.com/avatar.jpg")

// If you manage user IDs yourself, let Features.Vote track by your ID.
FeaturesVote.updateUser(customID: "user_123")

// For platforms that issue signed sessions.
FeaturesVote.setToken("your-jwt-token")

// Clear the session on logout.
FeaturesVote.clearUser()
```

###### If no user is set, the SDK generates an anonymous ID so votes still stay consistent on-device.

---

# Localization
#### Localize any text by overriding the defaults.

```swift
FeaturesVote.localization = Localization(
    votingBoardTitle: "Feature Requests",
    openTab: "Open",
    doneTab: "Done",
    createFeatureTitle: "Suggest a Feature",
    submit: "Submit",
    cancel: "Cancel"
    // ...and every other user-facing string. See DOCUMENTATION.md.
)

// You can assign NSLocalizedString values too.
FeaturesVote.localization.openTab = NSLocalizedString("board.open", comment: "")
```

---

### Platforms

- iOS 16+
- macOS 13+
- Swift 5.9+ · Xcode 15+

### Example Project

Check out the [`TestApp`](./TestApp/FeaturesVoteTestApp/) directory for a complete, working example app that exercises every view.

### Documentation

- **[DOCUMENTATION.md](./DOCUMENTATION.md)** — full SDK reference: all configuration options, data models, and API.
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** — internal architecture guide for contributors.

### License

Elastic License 2.0 — you may use, copy, modify, and distribute the software, but you may **not** offer it as a hosted/managed service or competing product, or remove licensing notices. See [LICENSE](./LICENSE) for full terms.

### Support

- Website: [features.vote](https://features.vote)
- Feedback board: [swift-sdk.features.vote/board](https://swift-sdk.features.vote/board)
