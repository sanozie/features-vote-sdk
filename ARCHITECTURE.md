# FeaturesVote SDK Architecture Guide

This document provides a comprehensive overview of the FeaturesVote Swift SDK architecture for engineers who want to contribute to or understand the codebase. For user-facing documentation on how to use the SDK, see [DOCUMENTATION.md](./DOCUMENTATION.md).

## Table of Contents

1. [Overview](#overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Architecture Pattern](#architecture-pattern)
5. [Folder Organization](#folder-organization)
6. [File Naming Conventions](#file-naming-conventions)
7. [Core Components Deep Dive](#core-components-deep-dive)
8. [Data Flow](#data-flow)
9. [Building & Testing](#building--testing)
10. [Adding New Features](#adding-new-features)
11. [Code Style Guidelines](#code-style-guidelines)

---

## Overview

The FeaturesVote Swift SDK is a native iOS/macOS library that provides UI components for integrating feature voting, changelogs, and roadmaps into Swift applications. It's designed as a drop-in solution with minimal configuration required.

### Key Design Principles

1. **SwiftUI-First**: All views are built using SwiftUI with UIKit bridges for compatibility
2. **MVVM Architecture**: Clear separation between Views, ViewModels, and Services
3. **Dependency Injection**: Services are injected into ViewModels for testability
4. **Protocol-Oriented**: Extensible through protocols where appropriate
5. **Cross-Platform**: Single codebase supporting iOS and macOS with conditional compilation

---

## Technology Stack

### Dependencies

| Component | Technology | Version |
|-----------|------------|---------|
| UI Framework | SwiftUI | iOS 16+ / macOS 13+ |
| Language | Swift | 5.9+ |
| Package Manager | Swift Package Manager | Built-in |
| Networking | URLSession | Foundation |
| Image Loading | AsyncImage | SwiftUI native |
| JSON Parsing | Codable | Foundation |

### Package.swift Configuration

```swift
// swift-tools-version: 5.9
let package = Package(
    name: "FeaturesVote",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FeaturesVote",
            targets: ["FeaturesVote"]
        ),
    ],
    targets: [
        .target(
            name: "FeaturesVote",
            dependencies: []
        ),
        .testTarget(
            name: "FeaturesVoteTests",
            dependencies: ["FeaturesVote"]
        ),
    ]
)
```

**Note**: The SDK has **zero external dependencies** - it relies entirely on Apple's frameworks.

---

## Project Structure

```
features-vote-sdk/
├── Package.swift                    # SPM package definition
├── DOCUMENTATION.md                 # User-facing documentation
├── ARCHITECTURE.md                  # This file
├── Sources/
│   └── FeaturesVote/
│       ├── FeaturesVote.swift       # Main entry point & public API
│       ├── Configuration/           # Theme, Localization, Config
│       ├── Models/                  # Data models (Codable structs)
│       ├── Networking/              # API client, endpoints, errors
│       ├── Services/                # Business logic services
│       ├── Utilities/               # Extensions & helpers
│       ├── ViewModels/              # MVVM ViewModels
│       └── Views/                   # SwiftUI Views
│           ├── Changelog/
│           ├── Comments/
│           ├── Common/
│           ├── CreateFeature/
│           ├── FeatureDetail/
│           ├── Roadmap/
│           └── VotingBoard/
└── Tests/
    └── FeaturesVoteTests/           # Unit tests
```

---

## Architecture Pattern

The SDK follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
┌─────────────────────────────────────────────────────────────────┐
│                         FeaturesVote                             │
│                    (Singleton Entry Point)                       │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                            Views                                 │
│         (SwiftUI Views - Presentation Layer)                     │
│   VotingBoardView, FeatureDetailView, ChangelogView, etc.       │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         ViewModels                               │
│        (State Management & Business Logic)                       │
│  VotingBoardViewModel, FeatureDetailViewModel, etc.             │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                          Services                                │
│            (API Communication & Data Operations)                 │
│   FeatureService, VoteService, CommentService, etc.             │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Networking                               │
│              (HTTP Layer & Error Handling)                       │
│              APIClient, APIEndpoint, APIError                    │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                           Models                                 │
│                    (Data Structures)                             │
│        Feature, Comment, Release, User, Tag, etc.               │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility | Example |
|-------|---------------|---------|
| **FeaturesVote** | Public API, SDK initialization, global state | `FeaturesVote.configure(with:)` |
| **Views** | UI rendering, user interaction handling | `VotingBoardView` |
| **ViewModels** | State management, data transformation, business logic | `VotingBoardViewModel` |
| **Services** | API calls, data operations, domain logic | `FeatureService.fetchFeatures()` |
| **Networking** | HTTP requests, response parsing, error handling | `APIClient.request()` |
| **Models** | Data structures, JSON decoding/encoding | `Feature`, `Comment` |

---

## Folder Organization

### `/Configuration`

Contains all customization-related structures:

| File | Purpose |
|------|---------|
| `Configuration.swift` | Nested options: `UI` (badges, tags, avatars, etc.), `Behavior` (anonymous voting/comments, optimistic updates, `confirmVoting`, `confirmUnsubscribe`), and `Buttons` (customizable `upvoteIcon`/`subscribeIcon`/`subscribedIcon`) |
| `Theme.swift` | Visual styling (colors, fonts, corner radius) |
| `Localization.swift` | All user-facing text strings |

> **Note:** Every `Configuration` option is actively enforced by the views/view models, and is covered by unit tests (see [Building & Testing](#building--testing)).

### `/Models`

Data structures that map to API responses:

| File | Model | Description |
|------|-------|-------------|
| `Feature.swift` | `Feature` | Feature request with votes, status, comments |
| `Comment.swift` | `Comment`, `CreateCommentRequest`, `CommentReactionRequest` | Comment with reactions |
| `FeatureStatus.swift` | `FeatureStatus` | Enum: pending, approved, inProgress, done, rejected |
| `Release.swift` | `Release` | Product release for changelog |
| `Tag.swift` | `Tag` | Feature tag with label and color |
| `User.swift` | `User` | User authentication info |
| `FeatureUser.swift` | `FeatureUser` | User info for display (name, avatar) |
| `Project.swift` | `Project`, `Customization` | Project configuration from API |

### `/Networking`

HTTP communication layer:

| File | Purpose |
|------|---------|
| `APIClient.swift` | Core HTTP client with request/response handling |
| `APIEndpoint.swift` | Endpoint definitions with paths and methods |
| `APIError.swift` | Error types and handling |
| `MultipartFormData.swift` | File upload support |

### `/Services`

Business logic and API communication:

| File | Service | Responsibility |
|------|---------|----------------|
| `FeatureService.swift` | `FeatureService` | Fetch features, create features |
| `VoteService.swift` | `VoteService` | Vote/unvote operations |
| `CommentService.swift` | `CommentService` | Comments and reactions |
| `SubscriptionService.swift` | `SubscriptionService` | Subscribe/unsubscribe to features |
| `ReleaseService.swift` | `ReleaseService` | Changelog releases |
| `UserService.swift` | `UserService` | User state management |
| `FeatureUserService.swift` | `FeatureUserService` | Fetch user details by ID |

### `/ViewModels`

State management for views:

| File | ViewModel | Associated View |
|------|-----------|-----------------|
| `VotingBoardViewModel.swift` | `VotingBoardViewModel` | `VotingBoardView` |
| `FeatureDetailViewModel.swift` | `FeatureDetailViewModel` | `FeatureDetailView` |
| `CreateFeatureViewModel.swift` | `CreateFeatureViewModel` | `CreateFeatureView` |
| `ChangelogViewModel.swift` | `ChangelogViewModel` | `ChangelogView` |
| `RoadmapViewModel.swift` | `RoadmapViewModel` | `RoadmapView` |
| `CommentsViewModel.swift` | `CommentsViewModel` | `CommentsListView` |

### `/Views`

SwiftUI views organized by feature:

```
Views/
├── Changelog/
│   ├── ChangelogView.swift         # Main changelog screen
│   ├── ReleaseCardView.swift       # Release list item
│   ├── ReleaseDetailView.swift     # Release detail screen
│   └── MarkdownView.swift          # Markdown renderer
├── Comments/
│   ├── CommentsListView.swift      # Comments section
│   ├── CommentRowView.swift        # Single comment
│   └── CommentInputView.swift      # Comment input field
├── Common/
│   ├── AvatarView.swift            # User avatar
│   ├── EmptyStateView.swift        # Empty state message
│   ├── ErrorView.swift             # Error with retry
│   ├── HTMLText.swift              # HTML text renderer
│   ├── ImagePicker.swift           # Photo picker wrapper
│   ├── ImageViewerOverlay.swift    # Full-screen image viewer
│   ├── LoadingView.swift           # Loading spinner
│   ├── MarkdownText.swift          # Simple markdown text
│   ├── StatusBadgeView.swift       # Status badge
│   ├── ThumbnailImageView.swift    # Image thumbnail
│   └── UserDisplayView.swift       # User name + avatar
├── CreateFeature/
│   ├── CreateFeatureView.swift     # Create feature form
│   └── TagSelectorView.swift       # Tag multi-select
├── FeatureDetail/
│   ├── FeatureDetailView.swift     # Feature detail screen
│   └── FeatureHeaderView.swift     # Feature header with vote
├── Roadmap/
│   ├── RoadmapView.swift           # Kanban board
│   ├── RoadmapColumnView.swift     # Status column
│   └── RoadmapCardView.swift       # Feature card
└── VotingBoard/
    ├── VotingBoardView.swift       # Main voting board
    ├── FeatureRowView.swift        # Feature list item
    ├── FilterTabsView.swift        # Open/Done tabs
    ├── TagsView.swift              # Tags display
    └── VoteButtonView.swift        # Vote button
```

### `/Utilities`

Helper code:

| File | Contents |
|------|----------|
| `Extensions.swift` | Color, Date, String, View extensions |
| `Logger.swift` | `FVLog` — internal logging via Apple's unified logging (`os.log`); leveled (`debug`/`info`/`warning`/`error`/`none`) with convenience `request`/`response` network helpers, and categorized (`network`/`ui`/`data`/`general`) |
| `UUIDManager.swift` | Anonymous user ID management |

---

## File Naming Conventions

### General Rules

1. **Views**: `{Feature}View.swift` (e.g., `VotingBoardView.swift`)
2. **ViewModels**: `{Feature}ViewModel.swift` (e.g., `VotingBoardViewModel.swift`)
3. **Services**: `{Domain}Service.swift` (e.g., `FeatureService.swift`)
4. **Models**: `{ModelName}.swift` (e.g., `Feature.swift`)
5. **Sub-views**: `{Parent}{Component}View.swift` (e.g., `FeatureRowView.swift`)

### Naming Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Main views | `{Feature}View` | `VotingBoardView` |
| Detail views | `{Feature}DetailView` | `FeatureDetailView` |
| List items | `{Item}RowView` or `{Item}CardView` | `FeatureRowView`, `ReleaseCardView` |
| Input components | `{Item}InputView` | `CommentInputView` |
| Common components | `{Description}View` | `AvatarView`, `LoadingView` |
| ViewModels | `{Feature}ViewModel` | `VotingBoardViewModel` |
| Services | `{Domain}Service` | `FeatureService` |

---

## Core Components Deep Dive

### FeaturesVote.swift (Entry Point)

The main entry point provides:

1. **SDK Configuration**: `FeaturesVote.configure(with: slug)`
2. **Global State Access**: `FeaturesVote.theme`, `FeaturesVote.config`, `FeaturesVote.localization`
3. **User Management**: `FeaturesVote.updateUser(...)`, `FeaturesVote.clearUser()`
4. **Public Views**: Wrapper views that inject dependencies
5. **UIKit Bridges**: `UIHostingController` wrappers for UIKit apps

**Key Implementation Details:**

```swift
// Thread-safe singleton pattern
private static let lock = NSLock()
private static var _shared: FeaturesVoteInstance?

internal static var shared: FeaturesVoteInstance {
    lock.lock()
    defer { lock.unlock() }
    guard let instance = _shared else {
        fatalError("FeaturesVote not configured. Call FeaturesVote.configure(with:) first.")
    }
    return instance
}
```

The `FeaturesVoteInstance` class holds:
- Project slug
- Theme, Config, Localization
- All service instances (APIClient, FeatureService, VoteService, etc.)

### APIClient.swift (Networking)

The networking layer uses:

1. **URLSession**: Native Apple networking
2. **Codable**: JSON encoding/decoding
3. **async/await**: Modern concurrency
4. **Custom Date Decoding**: ISO8601 with fractional seconds

**Key Features:**

```swift
// Generic request methods (two overloads: GET-style without a body, and with a body)
func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
func request<T: Decodable>(_ endpoint: APIEndpoint, body: Encodable) async throws -> T

// Date decoding strategy with fallbacks
let dateFormatter = ISO8601DateFormatter()
dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
```

### ViewModels

All ViewModels follow this pattern:

```swift
@MainActor
class SomeViewModel: ObservableObject {
    // Published state
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var error: Error?

    // Dependencies (injected)
    private let someService: SomeService
    private let userService: UserService

    // Initialization
    init(someService: SomeService, userService: UserService) {
        self.someService = someService
        self.userService = userService
    }

    // Async methods
    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await someService.fetch()
        } catch {
            self.error = error
        }
    }
}
```

**Key Patterns:**

1. `@MainActor` for thread safety
2. `@Published` for SwiftUI binding
3. Dependency injection through initializer
4. `async/await` for async operations
5. Optimistic updates where appropriate

---

## Data Flow

### Example: Voting on a Feature

```
┌─────────────────┐
│   User taps     │
│   vote button   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  VotingBoardView │  ──► onVote closure called
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ VotingBoard-    │
│   ViewModel     │  ──► toggleVote(for: feature)
└────────┬────────┘
         │
         ├──► Optimistic update: increment vote count, set hasVoted
         │
         ▼
┌─────────────────┐
│   VoteService   │  ──► upvote(featureId:, user:)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    APIClient    │  ──► POST /api/public/upvote
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  API Response   │
└────────┬────────┘
         │
         ├──► Success: Keep optimistic state
         │
         └──► Failure: Revert to original state, show error
```

### Example: Loading Features

```
VotingBoardView.task {
    await viewModel.loadProject()
    await viewModel.loadFeatures()
}
         │
         ▼
VotingBoardViewModel.loadFeatures() {
    isLoading = true
    features = try await featureService.fetchFeatures(slug, user)
    isLoading = false
}
         │
         ▼
FeatureService.fetchFeatures() {
    return try await apiClient.request(endpoint: .features(...))
}
         │
         ▼
APIClient.request() {
    // URLSession data task
    // JSON decoding with custom date formatter
    // Error handling
}
```

---

## Building & Testing

### Building the Package

```bash
# Navigate to project directory
cd features-vote-sdk

# Build for all platforms
swift build

# Build for specific platform
swift build -Xswiftc "-target" -Xswiftc "arm64-apple-ios16.0-simulator"
```

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter FeaturesVoteTests.SomeTestClass
```

The test target (`Tests/FeaturesVoteTests/`) covers the view models against mocked services:

| File | Covers |
|------|--------|
| `VotingBoardViewModelTests.swift` | Voting board state, filtering, optimistic vote flow |
| `FeatureDetailViewModelTests.swift` | Feature detail, comments, subscribe state |
| `CommentsViewModelTests.swift` | Comment loading, posting, reactions |
| `CreateFeatureViewModelTests.swift` | Create-feature validation and submission |
| `Mock*Service.swift` | Stubbed `Feature`/`Vote`/`Comment`/`Subscription` services |
| `TestFixtures.swift` | Shared sample models for tests |

### Xcode

1. Open `Package.swift` in Xcode
2. Select scheme: `FeaturesVote`
3. Build: `Cmd + B`
4. Test: `Cmd + U`

---

## Adding New Features

### Adding a New View

1. **Create the ViewModel** (if needed):

```swift
// ViewModels/NewFeatureViewModel.swift
@MainActor
class NewFeatureViewModel: ObservableObject {
    @Published var data: [Item] = []
    @Published var isLoading = false

    private let service: SomeService

    init(service: SomeService) {
        self.service = service
    }

    func loadData() async {
        // Implementation
    }
}
```

2. **Create the View**:

```swift
// Views/NewFeature/NewFeatureView.swift
public struct NewFeatureView: View {
    @StateObject private var viewModel: NewFeatureViewModel

    private let theme: Theme
    private let config: Configuration

    public init(
        viewModel: NewFeatureViewModel,
        theme: Theme = .default,
        config: Configuration = .default
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme
        self.config = config
    }

    public var body: some View {
        // View implementation
    }
}
```

3. **Add Public Wrapper** (in FeaturesVote.swift):

```swift
public struct NewFeatureView: View {
    public init() {}

    public var body: some View {
        let instance = FeaturesVote.shared
        return InternalNewFeatureView(
            viewModel: NewFeatureViewModel(...),
            theme: instance.theme,
            config: instance.config
        )
    }
}
```

4. **Add UIKit Bridge** (if needed):

```swift
#if canImport(UIKit)
public static var newFeatureViewController: UIViewController {
    UIHostingController(rootView: NewFeatureView())
}
#endif
```

### Adding a New API Endpoint

1. **Add to APIEndpoint.swift**:

```swift
case newEndpoint(param: String)

var path: String {
    case .newEndpoint(let param):
        return "/public/new-endpoint?param=\(param)"
}

var method: HTTPMethod {
    case .newEndpoint:
        return .get  // or .post
}
```

2. **Add Service Method**:

```swift
// Services/SomeService.swift
func newOperation(param: String) async throws -> ResponseType {
    return try await apiClient.request(
        endpoint: .newEndpoint(param: param)
    )
}
```

### Adding a New Model

```swift
// Models/NewModel.swift
public struct NewModel: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"  // Map snake_case
    }

    // Custom decoding if needed
    public init(from decoder: Decoder) throws {
        // Handle edge cases
    }
}

// Mock data for previews
extension NewModel {
    public static func mock() -> NewModel {
        NewModel(id: "123", name: "Test", createdAt: Date())
    }
}
```

---

## Code Style Guidelines

### Swift Style

1. **Access Control**: Use `public` for SDK API, `internal` (default) for implementation
2. **Optionals**: Prefer `if let` over force unwrapping
3. **Closures**: Use trailing closure syntax
4. **Naming**: Use descriptive names, avoid abbreviations

### SwiftUI Patterns

1. **State Management**:
   - `@State` for local view state
   - `@StateObject` for owned ViewModels
   - `@ObservedObject` for passed ViewModels
   - `@Published` in ViewModels

2. **View Composition**:
   - Extract sub-views to private computed properties
   - Use `@ViewBuilder` for conditional content
   - Prefer composition over inheritance

3. **Platform Handling**:
   ```swift
   #if os(iOS)
   // iOS-specific code
   #elseif os(macOS)
   // macOS-specific code
   #endif
   ```

### Documentation

1. Add `///` doc comments for public API
2. Include parameter descriptions
3. Add usage examples where helpful

```swift
/// Fetches all features for the given project
/// - Parameters:
///   - slug: The project slug
///   - user: Optional user for vote tracking
/// - Returns: Array of features
/// - Throws: `APIError` on failure
public func fetchFeatures(slug: String, user: User?) async throws -> [Feature]
```

### Error Handling

1. Use `throws` for recoverable errors
2. Use `Result` type when callbacks are needed
3. Always handle errors gracefully in UI

```swift
do {
    data = try await service.fetch()
} catch {
    self.error = error
    // Log error if needed
}
```

---

## Quick Reference

### Common Tasks

| Task | Location |
|------|----------|
| Add new localization string | `Configuration/Localization.swift` |
| Add new theme color | `Configuration/Theme.swift` |
| Add new config option | `Configuration/Configuration.swift` |
| Add new API endpoint | `Networking/APIEndpoint.swift` |
| Add new data model | `Models/` directory |
| Add new service | `Services/` directory |
| Add new view | `Views/{Feature}/` directory |
| Add new ViewModel | `ViewModels/` directory |
| Add helper function | `Utilities/Extensions.swift` |

### File Templates

**ViewModel Template:**
```swift
import Foundation

@MainActor
class {Name}ViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?

    private let service: {Service}

    init(service: {Service}) {
        self.service = service
    }
}
```

**View Template:**
```swift
import SwiftUI

public struct {Name}View: View {
    @StateObject private var viewModel: {Name}ViewModel

    private let theme: Theme

    public init(viewModel: {Name}ViewModel, theme: Theme = .default) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme
    }

    public var body: some View {
        // Implementation
    }
}

#if DEBUG
struct {Name}View_Previews: PreviewProvider {
    static var previews: some View {
        {Name}View(viewModel: {Name}ViewModel(...))
    }
}
#endif
```

---

## Related Documentation

- [DOCUMENTATION.md](./DOCUMENTATION.md) - User-facing SDK documentation
- [TestApp/README.md](./TestApp/README.md) - Test app documentation and usage
- [Package.swift](./Package.swift) - SPM package configuration

---

## Test App

The SDK includes a test application for validation and demonstration purposes. The test app is located in the `TestApp/` directory.

### Running the Test App

```bash
cd TestApp/FeaturesVoteTestApp
open FeaturesVoteTestApp.xcodeproj
```

The test app demonstrates:
- All SDK widgets (VotingBoard, Roadmap, Changelog, CreateFeature; FeatureDetail via card tap)
- Theme and configuration customization (every `Configuration.UI`/`Behavior` option, live)
- UIKit integration via ViewControllers (board, roadmap, changelog, create)
- User management

For detailed test app documentation, see [TestApp/README.md](./TestApp/README.md).

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the code style guidelines
4. Add tests for new functionality
5. Update documentation as needed
6. Submit a pull request

For questions, open an issue on GitHub.
