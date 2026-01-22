# FeaturesVote Swift SDK

A native Swift SDK for embedding [Features.Vote](https://features.vote) widgets in iOS and macOS apps.

> **For Contributors**: See [ARCHITECTURE.md](./ARCHITECTURE.md) for internal architecture details and contribution guidelines.

## Features

- Native SwiftUI views with UIKit bridges
- Feature voting board with filtering and sorting
- Create feature requests with tags and attachments
- Feature detail view with comments and reactions
- User authentication support (email, custom ID, JWT)
- Dark mode support
- Customizable themes and configuration

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/features-vote/features-vote-sdk.git", from: "1.0.0")
]
```

Or in Xcode:
1. File > Add Package Dependencies
2. Enter: `https://github.com/features-vote/features-vote-sdk.git`
3. Select version and add to your target

## Quick Start

### 1. Configure the SDK

```swift
import FeaturesVote

@main
struct MyApp: App {
    init() {
        FeaturesVote.configure(with: "your-project-slug")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Use SwiftUI Views

```swift
import SwiftUI
import FeaturesVote

struct ContentView: View {
    var body: some View {
        FeaturesVote.VotingBoardView()
    }
}
```

### 3. Or Use UIKit

```swift
import UIKit
import FeaturesVote

class ViewController: UIViewController {
    func showVotingBoard() {
        let votingBoardVC = FeaturesVote.votingBoardViewController
        present(votingBoardVC, animated: true)
    }
}
```

## Configuration

> For the complete list of all configuration options, see [DOCUMENTATION.md](./DOCUMENTATION.md#configuration).

### User Authentication

```swift
// Set user information
FeaturesVote.updateUser(email: "user@example.com")
FeaturesVote.updateUser(name: "John Doe")
FeaturesVote.updateUser(customID: "user-123")
FeaturesVote.updateUser(imageUrl: "https://example.com/avatar.jpg")
FeaturesVote.updateUser(spend: 29.99)

// Set JWT token for authenticated sessions
FeaturesVote.setToken("your-jwt-token")

// Clear user data
FeaturesVote.clearUser()
```

### Theme Customization

```swift
FeaturesVote.theme = Theme(
    primaryColor: Color(hex: "#7C3AED"),
    secondaryColor: .purple,
    backgroundColor: Color(hex: "#F3F4F6"),
    surfaceColor: .white,
    textPrimaryColor: .primary,
    textSecondaryColor: .secondary,
    pendingColor: Color(hex: "#718096"),
    approvedColor: Color(hex: "#06B6D4"),
    inProgressColor: Color(hex: "#F97316"),
    doneColor: Color(hex: "#10B981"),
    rejectedColor: Color(hex: "#EF4444"),
    cornerRadius: 16
)
```

### UI & Behavior Configuration

```swift
FeaturesVote.config = Configuration(
    ui: Configuration.UI(
        showStatusBadge: true,
        showCommentCount: true,
        showTags: true,
        showWatermark: true,
        enablePullToRefresh: true,
        maxDescriptionLines: 3,
        showAvatars: true
    ),
    behavior: Configuration.Behavior(
        allowAnonymousVoting: true,
        allowAnonymousComments: true,
        requireEmailForCreate: false,
        enableOptimisticUpdates: true,
        cacheTimeout: 300
    )
)
```

### Localization

```swift
FeaturesVote.localization = Localization(
    votingBoardTitle: "Feature Requests",
    openTab: "Open",
    doneTab: "Done",
    createFeatureTitle: "Suggest a Feature",
    submit: "Submit",
    cancel: "Cancel"
    // ... see DOCUMENTATION.md for all localization options
)
```

## Available Views

### VotingBoardView

Displays a list of feature requests with voting, filtering, and sorting.

```swift
FeaturesVote.VotingBoardView()
```

### FeatureDetailView

Shows full feature details with comments and reactions.

```swift
FeaturesVote.FeatureDetailView(feature: feature)
```

### CreateFeatureView

Form for creating new feature requests.

```swift
FeaturesVote.CreateFeatureView()
```

## UIKit Integration

All SwiftUI views have UIKit equivalents:

```swift
// Voting board
let votingBoardVC = FeaturesVote.votingBoardViewController
present(votingBoardVC, animated: true)

// Feature detail
let detailVC = FeaturesVote.featureDetailViewController(for: feature)
navigationController?.pushViewController(detailVC, animated: true)

// Create feature
let createVC = FeaturesVote.createFeatureViewController
present(createVC, animated: true)
```

## Examples

See the `TestApp` directory for a complete example app demonstrating all features.

## Documentation

- **[DOCUMENTATION.md](./DOCUMENTATION.md)** - Full SDK documentation with all configuration options, data models, and API reference
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Internal architecture guide for contributors

## License

This project is licensed under the [Elastic License 2.0](./LICENSE).

**You are free to:**
- Use, copy, and modify the software
- Distribute the software
- Contribute to the project

**You may not:**
- Provide the software as a hosted or managed service
- Create commercial wrappers or competing products
- Remove or alter licensing notices

See the [LICENSE](./LICENSE) file for complete terms.


## Support

- Documentation: [Features.Vote Platform](https://features.vote)
- Issues: [Feedback Board](https://swift-sdk.features.vote/board)
- Website: [features.vote](https://features.vote)
