# FeaturesVote Swift SDK Documentation

A comprehensive Swift SDK for integrating Features.Vote functionality into iOS and macOS applications. This SDK provides pre-built UI components for feature voting boards, changelogs, roadmaps, and user feedback collection.

> **For Contributors**: If you're looking to contribute to or understand the internal architecture of this SDK, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Configuration](#configuration)
   - [SDK Initialization](#sdk-initialization)
   - [Theme Customization](#theme-customization)
   - [Localization](#localization)
   - [Behavior Configuration](#behavior-configuration)
4. [User Management](#user-management)
5. [Widgets & Views](#widgets--views)
   - [VotingBoardView](#votingboardview)
   - [FeatureDetailView](#featuredetailview)
   - [CreateFeatureView](#createfeatureview)
   - [ChangelogView](#changelogview)
   - [RoadmapView](#roadmapview)
6. [Data Models](#data-models)
7. [UIKit Integration](#uikit-integration)
8. [Helper Components](#helper-components)
9. [Utilities & Extensions](#utilities--extensions)
10. [Platform Support](#platform-support)

---

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/features-vote/features-vote-sdk.git", from: "2.0.0")
]
```

Or in Xcode: **File > Add Package Dependencies** and enter the repository URL.

### Requirements

- iOS 16.0+
- macOS 13.0+
- Swift 5.9+

---

## Quick Start

### 1. Initialize the SDK

```swift
import FeaturesVote

// In your app initialization (e.g., App.swift or AppDelegate)
FeaturesVote.configure(with: "your-project-slug")
```

### 2. Display the Voting Board

```swift
import SwiftUI
import FeaturesVote

struct ContentView: View {
    var body: some View {
        FeaturesVote.VotingBoardView()
    }
}
```

That's it! The SDK handles all API calls, state management, and UI rendering.

---

## Configuration

### SDK Initialization

Initialize the SDK with your project slug before using any widgets:

```swift
FeaturesVote.configure(with: "your-project-slug")
```

### Theme Customization

Customize the visual appearance using the `Theme` struct:

```swift
FeaturesVote.theme = Theme(
    // Primary Colors
    primaryColor: Color(hex: "#7C3AED"),      // Buttons, accents, interactive elements
    secondaryColor: .purple,                   // Supporting UI elements
    backgroundColor: Color(hex: "#F3F4F6"),    // Main view backgrounds
    surfaceColor: .white,                      // Cards and elevated elements

    // Text Colors
    textPrimaryColor: .primary,                // Primary text
    textSecondaryColor: .secondary,            // Less important text

    // Feedback Colors
    errorColor: .red,                          // Error messages
    successColor: .green,                      // Success messages

    // Status Colors (for feature status badges)
    pendingColor: Color(hex: "#718096"),       // Gray
    approvedColor: Color(hex: "#06B6D4"),      // Cyan
    inProgressColor: Color(hex: "#F97316"),    // Orange
    doneColor: Color(hex: "#10B981"),          // Green
    rejectedColor: Color(hex: "#EF4444"),      // Red

    // Typography
    titleFont: .system(size: 17, weight: .semibold),
    bodyFont: .system(size: 15, weight: .regular),
    captionFont: .system(size: 13, weight: .medium),

    // Layout
    cornerRadius: 16
)
```

#### Theme Properties Reference

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `primaryColor` | `Color` | `#7C3AED` | Primary brand color for buttons and accents |
| `secondaryColor` | `Color` | `.purple` | Secondary color for supporting elements |
| `backgroundColor` | `Color` | `#F3F4F6` | Main background color |
| `surfaceColor` | `Color` | `.white` | Card and surface background color |
| `textPrimaryColor` | `Color` | `.primary` | Primary text color |
| `textSecondaryColor` | `Color` | `.secondary` | Secondary text color |
| `errorColor` | `Color` | `.red` | Error state color |
| `successColor` | `Color` | `.green` | Success state color |
| `pendingColor` | `Color` | `#718096` | Pending status badge color |
| `approvedColor` | `Color` | `#06B6D4` | Approved status badge color |
| `inProgressColor` | `Color` | `#F97316` | In Progress status badge color |
| `doneColor` | `Color` | `#10B981` | Done status badge color |
| `rejectedColor` | `Color` | `#EF4444` | Rejected status badge color |
| `titleFont` | `Font` | System 17pt semibold | Font for titles and headers |
| `bodyFont` | `Font` | System 15pt regular | Font for body text |
| `captionFont` | `Font` | System 13pt medium | Font for captions |
| `cornerRadius` | `CGFloat` | `16` | Corner radius for rounded elements |

#### Creating Theme from Project

```swift
// Automatically create theme from your project's branding
let theme = Theme.from(project: project, colorScheme: .light)
```

### Localization

Customize all text strings using the `Localization` struct:

```swift
FeaturesVote.localization = Localization(
    // Voting Board
    votingBoardTitle: "Features & Bugs board",
    openTab: "Open",
    doneTab: "Done",
    sortByVotes: "Most Voted",
    sortByRecent: "Most Recent",
    noFeaturesMessage: "No feature requests yet",
    votes: "votes",
    vote: "vote",
    searchPlaceholder: "Search posts...",
    createFeatureButton: "Create",

    // Feature Detail
    comments: "comments",
    Comments: "Comments",
    comment: "comment",
    subscribe: "Subscribe",
    subscribed: "Subscribed",
    share: "Share",

    // Status Labels
    pending: "Pending",
    approved: "Approved",
    inProgress: "In Progress",
    done: "Done",
    rejected: "Rejected",

    // Create Feature
    createFeatureTitle: "Suggest a Feature",
    titlePlaceholder: "Feature title",
    descriptionPlaceholder: "Describe your feature request...",
    selectTags: "Select tags",
    attachImage: "Attach image",
    submit: "Submit",
    cancel: "Cancel",
    successMessage: "Feature request submitted!",

    // Comments
    addComment: "Add a comment",
    commentPlaceholder: "Write a comment...",
    sendComment: "Send",
    adminBadge: "Admin",

    // Errors
    errorTitle: "Error",
    retryButton: "Try Again",
    networkError: "Connection error. Please check your internet connection.",
    genericError: "An error occurred. Please try again.",

    // Loading
    loading: "Loading...",

    // Authentication
    anonymousPrompt: "Sign in to vote and comment",
    loginButton: "Sign In",

    // Validation
    titleRequired: "Title is required",
    descriptionRequired: "Description is required",
    emailInvalid: "Invalid email address"
)
```

#### Localization Properties Reference

| Category | Property | Default Value |
|----------|----------|---------------|
| **Voting Board** | `votingBoardTitle` | "Features & Bugs board" |
| | `openTab` | "Open" |
| | `doneTab` | "Done" |
| | `sortByVotes` | "Most Voted" |
| | `sortByRecent` | "Most Recent" |
| | `noFeaturesMessage` | "No feature requests yet" |
| | `votes` | "votes" |
| | `vote` | "vote" |
| | `searchPlaceholder` | "Search posts..." |
| | `createFeatureButton` | "Create" |
| **Feature Detail** | `comments` | "comments" |
| | `Comments` | "Comments" |
| | `comment` | "comment" |
| | `subscribe` | "Subscribe" |
| | `subscribed` | "Subscribed" |
| | `share` | "Share" |
| **Status Labels** | `pending` | "Pending" |
| | `approved` | "Approved" |
| | `inProgress` | "In Progress" |
| | `done` | "Done" |
| | `rejected` | "Rejected" |
| **Create Feature** | `createFeatureTitle` | "Suggest a Feature" |
| | `titlePlaceholder` | "Feature title" |
| | `descriptionPlaceholder` | "Describe your feature request..." |
| | `selectTags` | "Select tags" |
| | `attachImage` | "Attach image" |
| | `submit` | "Submit" |
| | `cancel` | "Cancel" |
| | `successMessage` | "Feature request submitted!" |
| **Comments** | `addComment` | "Add a comment" |
| | `commentPlaceholder` | "Write a comment..." |
| | `sendComment` | "Send" |
| | `adminBadge` | "Admin" |
| **Errors** | `errorTitle` | "Error" |
| | `retryButton` | "Try Again" |
| | `networkError` | "Connection error. Please check your internet connection." |
| | `genericError` | "An error occurred. Please try again." |
| **Loading** | `loading` | "Loading..." |
| **Authentication** | `anonymousPrompt` | "Sign in to vote and comment" |
| | `loginButton` | "Sign In" |
| **Validation** | `titleRequired` | "Title is required" |
| | `descriptionRequired` | "Description is required" |
| | `emailInvalid` | "Invalid email address" |

### Behavior Configuration

Control SDK behavior with the `Configuration` struct:

```swift
FeaturesVote.config = Configuration(
    ui: Configuration.UI(
        showStatusBadge: true,           // Show status badge on feature cards
        showCommentCount: true,          // Show comment count on cards
        showTags: true,                  // Show tags on feature cards
        showWatermark: true,             // Show "Powered by Features.Vote"
        enablePullToRefresh: true,       // Enable pull-to-refresh gesture
        maxDescriptionLines: 3,          // Max lines before truncation
        showAvatars: true                // Show user avatars
    ),
    behavior: Configuration.Behavior(
        allowAnonymousVoting: true,      // Allow anonymous users to vote
        allowAnonymousComments: true,    // Allow anonymous users to comment
        requireEmailForCreate: false,    // Require email when creating features
        enableOptimisticUpdates: true,   // Update UI immediately, revert on error
        confirmVoting: false,            // Show confirmation before voting
        confirmUnsubscribe: true         // Show confirmation before unsubscribing
    ),
    buttons: Configuration.Buttons(
        upvoteIcon: Image(systemName: "arrow.up"),
        subscribeIcon: Image(systemName: "bell"),
        subscribedIcon: Image(systemName: "bell.fill")
    )
)
```

#### Configuration Properties Reference

**UI Configuration (`Configuration.UI`)**

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `showStatusBadge` | `Bool` | `true` | Display status badge on feature cards |
| `showCommentCount` | `Bool` | `true` | Display comment count on feature cards |
| `showTags` | `Bool` | `true` | Display tags on feature cards |
| `showWatermark` | `Bool` | `true` | Display "Powered by Features.Vote" |
| `enablePullToRefresh` | `Bool` | `true` | Enable pull-to-refresh gesture |
| `maxDescriptionLines` | `Int` | `3` | Max description lines before truncation |
| `showAvatars` | `Bool` | `true` | Display user avatars |

**Behavior Configuration (`Configuration.Behavior`)**

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `allowAnonymousVoting` | `Bool` | `true` | Allow anonymous users to vote |
| `allowAnonymousComments` | `Bool` | `true` | Allow anonymous users to comment |
| `requireEmailForCreate` | `Bool` | `false` | Require email when creating features |
| `enableOptimisticUpdates` | `Bool` | `true` | Update UI immediately, revert on error |
| `confirmVoting` | `Bool` | `false` | Show confirmation dialog before voting |
| `confirmUnsubscribe` | `Bool` | `true` | Show confirmation before unsubscribing |

**Button Configuration (`Configuration.Buttons`)**

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `upvoteIcon` | `Image` | `arrow.up` | Icon for upvote button |
| `subscribeIcon` | `Image` | `bell` | Icon for subscribe button |
| `subscribedIcon` | `Image` | `bell.fill` | Icon for subscribed state |

---

## User Management

Identify users to track their votes, comments, and subscriptions across sessions:

### Setting User Information

```swift
// Set individual properties
FeaturesVote.updateUser(customID: "user-123")
FeaturesVote.updateUser(email: "user@example.com")
FeaturesVote.updateUser(name: "John Doe")
FeaturesVote.updateUser(imageUrl: "https://example.com/avatar.jpg")
FeaturesVote.updateUser(spend: 99.99)  // For tracking user spend/value

// Set JWT token for authenticated sessions
FeaturesVote.setToken("eyJhbGciOiJIUzI1NiIs...")
```

### Clearing User Data

```swift
// Clear user data and revert to anonymous
FeaturesVote.clearUser()
```

### User Properties

| Method | Parameter | Description |
|--------|-----------|-------------|
| `updateUser(customID:)` | `String` | Your app's unique user identifier |
| `updateUser(email:)` | `String` | User's email address |
| `updateUser(name:)` | `String` | User's display name |
| `updateUser(imageUrl:)` | `String` | URL to user's avatar image |
| `updateUser(spend:)` | `Double` | User's spend/value amount |
| `setToken(_:)` | `String` | JWT authentication token |
| `clearUser()` | - | Reset to anonymous user |

---

## Widgets & Views

### VotingBoardView

The main feature voting board displaying all feature requests with voting functionality.

**SwiftUI Usage:**

```swift
import FeaturesVote

struct ContentView: View {
    var body: some View {
        FeaturesVote.VotingBoardView()
    }
}
```

**Features:**
- Displays all feature requests in a scrollable list
- Open/Done tab filtering
- Search functionality with expandable search bar
- Pull-to-refresh support
- Vote toggling with optimistic updates
- Navigation to feature detail view
- Create new feature sheet
- User info and "Powered by" footer

---

### FeatureDetailView

Detailed view of a single feature with comments and subscription options.

**SwiftUI Usage:**

```swift
import FeaturesVote

struct FeatureView: View {
    let feature: Feature

    var body: some View {
        FeaturesVote.FeatureDetailView(feature: feature)
    }
}
```

**Features:**
- Full feature title and description (HTML supported)
- Vote count and voting button
- Subscribe/unsubscribe functionality
- Tags display
- Creator information
- Full comments section with:
  - Comment input with image attachment
  - Existing comments list
  - Emoji reactions on comments
  - Admin badge support

---

### CreateFeatureView

Form for submitting new feature requests.

**SwiftUI Usage:**

```swift
import FeaturesVote

struct CreateView: View {
    var body: some View {
        FeaturesVote.CreateFeatureView(onSuccess: {
            print("Feature created successfully!")
        })
    }
}
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `onSuccess` | `(() -> Void)?` | Optional callback when feature is created |

**Features:**
- Title and description input fields
- Tag selection (if tags are configured)
- Form validation
- Loading state during submission
- Success/error handling

---

### ChangelogView

Display product releases and updates.

**SwiftUI Usage:**

```swift
import FeaturesVote

struct ChangelogScreen: View {
    var body: some View {
        FeaturesVote.ChangelogView()
    }
}
```

**Features:**
- List of all product releases
- Release cards with version, title, and date
- Navigation to release detail view
- Markdown rendering for release notes
- Associated features per release
- Pull-to-refresh support
- Loading skeletons

---

### RoadmapView

Kanban-style board showing features organized by status.

**SwiftUI Usage:**

```swift
import FeaturesVote

struct RoadmapScreen: View {
    var body: some View {
        FeaturesVote.RoadmapView()
    }
}
```

**Features:**
- 5-column Kanban board (Pending, Approved, In Progress, Done, Rejected)
- Horizontal scrolling on iOS
- Grid layout on macOS
- Vote toggling on feature cards
- Feature detail sheet on tap
- Create feature button
- Sort order options

---

## Data Models

### Feature

Represents a feature request.

```swift
public struct Feature: Codable, Identifiable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let totalVotes: Int
    public let status: FeatureStatus
    public let createdAt: Date
    public let updatedAt: Date
    public let commentCount: Int
    public var hasVoted: Bool
    public var hasSubscribed: Bool
    public let userId: String?
    public let releaseDate: Date?
    public let tags: [String]?
    public let fileUrl: String?
    public let releaseId: String?
}
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `title` | `String` | Feature title |
| `description` | `String` | Feature description (HTML supported) |
| `totalVotes` | `Int` | Total vote count |
| `status` | `FeatureStatus` | Current status |
| `createdAt` | `Date` | Creation timestamp |
| `updatedAt` | `Date` | Last update timestamp |
| `commentCount` | `Int` | Number of comments |
| `hasVoted` | `Bool` | Whether current user has voted |
| `hasSubscribed` | `Bool` | Whether current user is subscribed |
| `userId` | `String?` | Creator's user ID |
| `releaseDate` | `Date?` | Associated release date |
| `tags` | `[String]?` | Associated tag labels |
| `fileUrl` | `String?` | Attached file/image URL |
| `releaseId` | `String?` | Associated release ID |

---

### FeatureStatus

Enumeration of possible feature statuses.

```swift
public enum FeatureStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pending"
    case approved = "Approved"
    case inProgress = "In Progress"
    case done = "Done"
    case rejected = "Rejected"

    public var id: String            // returns rawValue
    public var displayName: String
    public var iconName: String      // SF Symbol name
    public var isOpen: Bool          // true if not done/rejected
}
```

| Status | Icon | Description |
|--------|------|-------------|
| `pending` | `clock` | Awaiting review |
| `approved` | `checkmark.circle` | Approved for development |
| `inProgress` | `hammer` | Currently being developed |
| `done` | `checkmark.circle.fill` | Completed |
| `rejected` | `xmark.circle` | Not planned |

---

### Comment

Represents a comment on a feature.

```swift
public struct Comment: Codable, Identifiable, Hashable {
    public let id: String
    public let userId: String?
    public let userName: String?
    public let userImgUrl: String?
    public let featureId: String
    public let comment: String
    public let createdAt: Date
    public let reactions: [String: Int]     // emoji: count
    public let userReactions: [String]      // emojis user has reacted with
    public let isAdmin: Bool
    public let fileUrl: String?

    public var totalReactionCount: Int
    public func hasReacted(with emoji: String) -> Bool
}
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `userId` | `String?` | Commenter's user ID |
| `userName` | `String?` | Commenter's display name |
| `userImgUrl` | `String?` | Commenter's avatar URL |
| `featureId` | `String` | Parent feature ID |
| `comment` | `String` | Comment text |
| `createdAt` | `Date` | Creation timestamp |
| `reactions` | `[String: Int]` | Emoji reactions with counts |
| `userReactions` | `[String]` | Emojis current user has reacted with |
| `isAdmin` | `Bool` | Whether commenter is an admin |
| `fileUrl` | `String?` | Attached file/image URL |

---

### Release

Represents a product release.

```swift
public struct Release: Codable, Identifiable, Hashable {
    public let id: String
    public let version: String
    public let title: String
    public let shortDescription: String
    public let longDescription: String      // Markdown supported
    public let releasedAt: Date
    public let createdAt: Date
    public let projectId: String
}
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `version` | `String` | Version number (e.g., "1.0.0") |
| `title` | `String` | Release title |
| `shortDescription` | `String` | Brief description |
| `longDescription` | `String` | Full release notes (Markdown) |
| `releasedAt` | `Date` | Release date |
| `createdAt` | `Date` | Creation timestamp |
| `projectId` | `String` | Parent project ID |

---

### Tag

Represents a tag that can be applied to features.

```swift
public struct Tag: Codable, Identifiable, Hashable {
    public let label: String
    public let theme: String    // Hex color

    public var id: String       // Same as label
}
```

| Property | Type | Description |
|----------|------|-------------|
| `label` | `String` | Tag display name |
| `theme` | `String` | Tag color (hex format) |

---

### User

Represents user information for authentication.

```swift
public struct User: Codable, Equatable {
    public var name: String?
    public var email: String?
    public var appUserId: String?
    public var imgUrl: String?
    public var userSpend: Double?
    public var token: String?
    public var isGoogleAuth: Bool?

    public var isAuthenticated: Bool    // Has email, appUserId, or token
    public var isAnonymous: Bool        // Not authenticated
}
```

---

### Project

Represents project configuration.

```swift
public struct Project: Codable {
    public let name: String
    public let slug: String
    public let primaryLight: String      // Light mode primary color
    public let primaryDark: String       // Dark mode primary color
    public let logoUrl: String
    public let websiteUrl: String
    public let colorMode: String?
    public let customization: Customization
}
```

---

### Customization

Project-specific customization settings.

```swift
public struct Customization: Codable {
    public let tags: [Tag]?
    public let hideWatermark: Bool?
    public let votingBoardTitle: String?
    public let isAnonDisabled: Bool?
    public let isPrivateBoard: Bool?
    public let isTokenOnly: Bool?
    public let suggestPopupSuccessMsg: String?
    public let suggestPopupHeaderText: String?
    public let isInProgressOnTop: Bool?
    public let viewAllRequestsLink: String?
    public let postLabel: String?
    public let hideViewAllRedirect: Bool?
    public let disabledAnonMessage: String?
    public let whitelistUrls: String?
    public let defaultLanguage: String?
    public let showTranslations: Bool?
}
```

---

### FeatureUser

User information for feature authors and commenters.

```swift
public struct FeatureUser: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let imgUrl: String?

    public var avatarColor: String    // Generated from name
    public var initials: String       // First letters of name
}
```

---

## UIKit Integration

For UIKit-based apps, use the provided `UIViewController` wrappers:

```swift
import UIKit
import FeaturesVote

class MyViewController: UIViewController {

    func showVotingBoard() {
        let votingBoardVC = FeaturesVote.votingBoardViewController
        navigationController?.pushViewController(votingBoardVC, animated: true)
    }

    func showFeatureDetail(feature: Feature) {
        let detailVC = FeaturesVote.featureDetailViewController(for: feature)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func showCreateFeature() {
        let createVC = FeaturesVote.createFeatureViewController(onSuccess: {
            print("Feature created!")
        })
        present(createVC, animated: true)
    }

    func showChangelog() {
        let changelogVC = FeaturesVote.changelogViewController
        navigationController?.pushViewController(changelogVC, animated: true)
    }

    func showRoadmap() {
        let roadmapVC = FeaturesVote.roadmapViewController
        navigationController?.pushViewController(roadmapVC, animated: true)
    }
}
```

### UIKit View Controllers

| Property/Method | Return Type | Description |
|-----------------|-------------|-------------|
| `votingBoardViewController` | `UIViewController` | Voting board view controller |
| `featureDetailViewController(for:)` | `UIViewController` | Feature detail view controller |
| `createFeatureViewController(onSuccess:)` | `UIViewController` | Create feature view controller |
| `changelogViewController` | `UIViewController` | Changelog view controller |
| `roadmapViewController` | `UIViewController` | Roadmap view controller |

---

## Helper Components

The SDK includes several reusable helper components:

### AvatarView

Displays a user avatar with fallback to initials.

```swift
AvatarView(
    imageUrl: "https://example.com/avatar.jpg",
    name: "John Doe",
    size: 32
)
```

### StatusBadgeView

Displays a colored status badge.

```swift
StatusBadgeView(status: .inProgress, theme: theme)
```

### LoadingView

Centered loading spinner.

```swift
LoadingView()
```

### ErrorView

Error display with retry button. The `error` parameter is typed as `APIError`, and `theme` is optional.

```swift
ErrorView(error: apiError, theme: theme) {
    // Retry action
}
```

### EmptyStateView

Empty state message display.

```swift
EmptyStateView(
    message: "No features yet",
    icon: "tray"  // Optional SF Symbol
)
```

### TagsView

Inline tag display (an `HStack` of colored capsules). Pass `availableTags` to pick up each tag's configured color.

```swift
TagsView(tags: ["Feature", "Enhancement"])

// With themed colors from the project's tags
TagsView(tags: ["Feature"], availableTags: project.customization.tags ?? [])
```

### HTMLText

Renders HTML content as styled text. Embedded links default to the configured theme's `primaryColor` (override via `linkColor`).

```swift
HTMLText(htmlString, fontSize: 16)

// Override the link color
HTMLText(htmlString, fontSize: 16, linkColor: .blue)
```

### MarkdownView

Renders Markdown content with image support. Lives in `Views/Changelog/` and is used for release notes. For lightweight inline Markdown, see `MarkdownText(_:font:color:)` in `Views/Common/`.

```swift
MarkdownView(markdown: markdownString, theme: theme)
```

### ThumbnailImageView

Image thumbnail that expands to full-screen viewer on tap.

```swift
ThumbnailImageView(
    imageURL: URL(string: "https://example.com/image.jpg"),
    maxThumbnailHeight: 150,
    cornerRadius: 8,
    theme: theme
)
```

### ImageViewerOverlay

Full-screen image viewer with zoom and pan.

```swift
ImageViewerOverlay(imageURL: url) {
    // Dismiss action
}
```

---

## Utilities & Extensions

### Color Extensions

```swift
// Initialize from hex
let color = Color(hex: "#FF5733")
let color2 = Color(hex: "FF5733")

// Get hex string (optional — returns nil if the color can't be resolved)
let hex = color.hexString  // "#FF5733"

// Get contrasting text color (white or black)
let textColor = backgroundColor.contrastingTextColor

// Check if color is light
let isLight = color.isLight
```

### Date Extensions

```swift
let date = Date()

// Relative time string
date.relativeTimeString()  // "2 hours ago"

// Short date string
date.shortDateString()     // "Jan 5, 2024"

// Date and time string
date.dateTimeString()      // "Jan 5, 2024 at 3:45 PM"
```

### String Extensions

```swift
let text = "This is a very long string"

// Truncate with ellipsis
text.truncated(to: 10)     // "This is a..."

// Email validation
"user@example.com".isValidEmail  // true
```

### View Extensions

```swift
// Conditional modifier
Text("Hello")
    .if(condition) { view in
        view.foregroundColor(.red)
    }

// Conditional modifier with else
Text("Hello")
    .if(condition,
        then: { $0.foregroundColor(.red) },
        else: { $0.foregroundColor(.blue) }
    )
```

---

## Platform Support

The SDK supports both iOS and macOS with platform-specific optimizations:

| Feature | iOS | macOS |
|---------|-----|-------|
| VotingBoardView | ✅ Full support | ✅ Full support |
| FeatureDetailView | ✅ Full support | ✅ Full support |
| CreateFeatureView | ✅ Full support | ✅ Full support |
| ChangelogView | ✅ Full support | ✅ Full support |
| RoadmapView | ✅ Horizontal scroll | ✅ Grid layout |
| Image Viewer | ✅ Full-screen cover | ✅ Sheet presentation |
| Pull-to-refresh | ✅ Native support | ✅ Native support |
| Image Picker | ✅ PhotosPicker | ✅ PhotosPicker |

### Minimum Requirements

- **iOS**: 16.0+
- **macOS**: 13.0+
- **Swift**: 5.9+

---

## API Reference

The SDK communicates with the Features.Vote API at `https://features.vote/api`. All API calls are handled internally by the SDK.

### Available Endpoints (Internal)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/public/project` | GET | Get project configuration |
| `/public/features` | GET | List all features |
| `/public/feature` | GET | Get a single feature by id |
| `/public/features/create` | POST | Create new feature |
| `/public/upvote` | POST | Add vote to feature |
| `/public/downvote` | POST | Remove vote from feature |
| `/public/comments` | GET | List comments for feature |
| `/public/comments/create` | POST | Create new comment |
| `/public/comments/add-reaction` | POST | Add emoji reaction |
| `/public/comments/remove-reaction` | POST | Remove emoji reaction |
| `/public/subscribe-post` | POST | Subscribe to feature |
| `/public/unsubscribe-post` | POST | Unsubscribe from feature |
| `/public/releases` | GET | List all releases |
| `/public/posts-by-release` | GET | Get features for release |
| `/public/user` | GET | Get user information |
| `/public/user-token` | POST | Validate a JWT user token |

---

## Support

For issues and feature requests, please visit:
- GitHub Issues: [https://github.com/your-org/features-vote-sdk/issues](https://github.com/your-org/features-vote-sdk/issues)
- Documentation: [https://features.vote/docs](https://features.vote/docs)

## Related Documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Internal architecture guide for contributors
- [TestApp/README.md](./TestApp/README.md) - Test app documentation and demo reference

---

## License

Copyright (c) Features.Vote. All rights reserved.
