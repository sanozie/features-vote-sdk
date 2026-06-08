# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

`features-vote-sdk` is the native **Swift SDK** for embedding Features.Vote widgets into iOS (16.0+) and macOS (13.0+) applications. It provides drop-in SwiftUI components — voting board, feature detail, changelog, roadmap, and create-feature form — with full customization support. Zero external dependencies; uses only Apple native frameworks.

This codebase is a **pure API consumer** of the main `features-vote` app's `/api/public/*` endpoints. It does not require an API key — it uses the project slug for identification and optional user tokens for authenticated actions.

## Package Manager & Build

**Package manager:** Swift Package Manager (SPM). No other build tools.

```bash
swift build                          # Build the library
swift test                           # Run tests
swift build -c release               # Release build
```

**Minimum platforms:** iOS 16.0, macOS 13.0 (per `Package.swift`)
**Swift version:** 5.9+
**Xcode:** 15.0+

## Installation (for SDK consumers)

In Xcode → File → Add Package Dependencies, or in `Package.swift`:
```swift
.package(url: "https://github.com/features-vote/features-vote-sdk.git", from: "2.0.0")
```

## Architecture

**Pattern:** MVVM with dependency injection. Async/await concurrency throughout. SwiftUI-first with UIKit bridges.

```
Sources/FeaturesVote/
├── FeaturesVote.swift              # Public entry point (singleton configuration)
├── Networking/
│   ├── APIClient.swift             # Generic HTTP client (GET/POST/multipart)
│   ├── APIEndpoint.swift           # All endpoint URL definitions ← KEY FILE
│   ├── APIError.swift              # Typed API error enum
│   └── MultipartFormData.swift     # File upload support
├── Services/                       # One service per domain
│   ├── FeatureService.swift
│   ├── VoteService.swift
│   ├── CommentService.swift
│   ├── SubscriptionService.swift
│   ├── ReleaseService.swift
│   ├── UserService.swift
│   └── FeatureUserService.swift
├── Models/                         # Codable data models
│   ├── Feature.swift
│   ├── Comment.swift               # Comment + CreateCommentRequest + CommentReactionRequest
│   ├── Release.swift
│   ├── Project.swift               # Project + Customization
│   ├── Tag.swift
│   ├── User.swift
│   ├── FeatureUser.swift           # Display info (name, avatar) for authors/commenters
│   └── FeatureStatus.swift         # Enum: pending, approved, inProgress, done, rejected
├── ViewModels/                     # MVVM view models (one per main view)
│   ├── VotingBoardViewModel.swift
│   ├── FeatureDetailViewModel.swift
│   ├── CreateFeatureViewModel.swift
│   ├── ChangelogViewModel.swift
│   ├── RoadmapViewModel.swift
│   └── CommentsViewModel.swift
├── Views/                          # SwiftUI components (7 subdirectories)
│   ├── VotingBoard/                # VotingBoardView, FeatureRowView, FilterTabsView, TagsView, VoteButtonView
│   ├── FeatureDetail/              # FeatureDetailView, FeatureHeaderView
│   ├── CreateFeature/              # CreateFeatureView, TagSelectorView
│   ├── Changelog/                  # ChangelogView, ReleaseCardView, ReleaseDetailView, MarkdownView
│   ├── Roadmap/                    # RoadmapView, RoadmapColumnView, RoadmapCardView
│   ├── Comments/                   # CommentsListView, CommentRowView, CommentInputView
│   └── Common/                     # Shared components (avatars, spinners, markdown, HTML, image viewer, etc.)
├── Utilities/                      # Extensions.swift, Logger.swift (FVLog), UUIDManager.swift
└── Configuration/
    ├── Theme.swift                  # Colors, fonts, corner radius
    ├── Configuration.swift          # UI, behavior, and button toggles
    └── Localization.swift           # All user-facing strings
```

**Test apps:** `TestApp/FeaturesVoteTestApp/` — full working **iOS** example (Xcode project) for manual verification. Tabs: **Board** (SwiftUI `VotingBoardView`), **Roadmap** (`RoadmapView`), **Changelog** (`ChangelogView`), **Settings** (every `Theme`/`Configuration` option live + a SwiftUI `CreateFeatureView` sheet), and **UIKit** (all view-controller bridges). `FeatureDetailView` is reached by tapping a card on Board/Roadmap. `TestApp/FeaturesVoteMacExample/` — the **macOS** example, a SwiftPM executable run with `swift run` (no `.xcodeproj`); same widgets minus the UIKit tab (the bridges are `#if canImport(UIKit)`, iOS-only) and carrying the macOS hosting workarounds. See `docs/features/macos-example-app.md`.

## Public API (SDK Entry Point)

Everything starts from the `FeaturesVote` singleton in `FeaturesVote.swift`:

```swift
// Required — call at app launch
FeaturesVote.configure(with: "your-project-slug")

// Optional user identification (any combination)
FeaturesVote.updateUser(email: "user@example.com")
FeaturesVote.updateUser(customID: "user_123")
FeaturesVote.updateUser(name: "Jane Doe")
FeaturesVote.updateUser(imageUrl: "https://...")
FeaturesVote.updateUser(spend: 299.0)      // Customer LTV, shown in admin
FeaturesVote.setToken("jwt_token")          // For authenticated sessions
FeaturesVote.clearUser()                    // Clear session

// Customization
FeaturesVote.theme = Theme(primaryColor: .blue, ...)
FeaturesVote.config = Configuration(allowAnonymousVoting: false, ...)
FeaturesVote.localization = Localization(boardTitle: "Feature Requests", ...)
```

**SwiftUI views** (all nested under the `FeaturesVote` namespace):
```swift
FeaturesVote.VotingBoardView()
FeaturesVote.FeatureDetailView(feature: feature)        // takes a Feature value, not an id
FeaturesVote.CreateFeatureView(onSuccess: { ... })      // onSuccess is optional
FeaturesVote.ChangelogView()
FeaturesVote.RoadmapView()
```

**UIKit bridges** (iOS only, `#if canImport(UIKit)`):
```swift
FeaturesVote.votingBoardViewController                  // computed property
FeaturesVote.roadmapViewController                      // computed property
FeaturesVote.changelogViewController                    // computed property
FeaturesVote.featureDetailViewController(for: feature)  // func, takes a Feature
FeaturesVote.createFeatureViewController(onSuccess:)     // func, onSuccess optional
```

## API Endpoints Called

All endpoints are in `Sources/FeaturesVote/Networking/APIEndpoint.swift`. Base URL: `https://features.vote/api`.

**This SDK calls ONLY `/api/public/*` endpoints — no API key required.**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/public/project?slug=` | GET | Load project config and customization |
| `/public/features?slug=&app_user_id=&email=&token=` | GET | List features with user's vote/subscribe state |
| `/public/feature?featureId=` | GET | Single feature detail |
| `/public/releases?slug=` | GET | Changelog releases |
| `/public/posts-by-release?releaseId=` | GET | Features linked to a release |
| `/public/user?userId=` | GET | User profile |
| `/public/upvote` | POST | Upvote a feature |
| `/public/downvote` | POST | Remove vote |
| `/public/features/create?slug=` | POST | Submit new feature (multipart) |
| `/public/comments?featureId=` | GET | Comments for a feature |
| `/public/comments/create?slug=&featureId=` | POST | Add comment (multipart, supports file) |
| `/public/comments/add-reaction` | POST | Add emoji reaction |
| `/public/comments/remove-reaction` | POST | Remove reaction |
| `/public/subscribe-post` | POST | Subscribe to feature updates |
| `/public/unsubscribe-post` | POST | Unsubscribe |
| `/public/user-token` | POST | Validate JWT token |

## ⚠️ CRITICAL: Sync with Main App Public API

**When any `/api/public/*` endpoint in the main `features-vote` app changes** (path, query params, request body, response shape), you must update this SDK:

1. Update the URL/params in `Sources/FeaturesVote/Networking/APIEndpoint.swift`
2. Update the request/response models in the relevant `Services/` file
3. If response shape changed, update the corresponding `Models/` struct
4. Test manually using the test app in `TestApp/FeaturesVoteTestApp/`
5. Bump the version in `Package.swift` and tag a release

The same public API changes also affect `features-vote-widget` (`src/services/board-api.ts`).

## Customization Reference

**Theme** — colors, fonts, corner radius. Applied globally. Includes brand colors (`primaryColor`, `secondaryColor`, `backgroundColor`, `surfaceColor`), text colors, feedback colors (`errorColor`, `successColor`), per-status colors (`pendingColor`, `approvedColor`, `inProgressColor`, `doneColor`, `rejectedColor`), typography (`titleFont`, `bodyFont`, `captionFont`), and `cornerRadius`. `Theme.from(project:colorScheme:)` builds a theme from a project's branding.

**Configuration** — three nested structs, all enforced by the views/view models (see `docs/features/configuration-enforcement.md`):
- `Configuration.UI`: `showStatusBadge`, `showCommentCount`, `showTags`, `showWatermark`, `enablePullToRefresh`, `showAvatars` (Bool); `maxDescriptionLines` (Int)
- `Configuration.Behavior`: `allowAnonymousVoting`, `allowAnonymousComments`, `requireEmailForCreate`, `enableOptimisticUpdates`, `confirmVoting`, `confirmUnsubscribe` (Bool)
- `Configuration.Buttons`: customizable SF Symbol `Image`s — `upvoteIcon`, `subscribeIcon`, `subscribedIcon`

**Localization** — all user-visible strings (board title, tab names, button labels, placeholder text, status labels, error/validation messages, etc.)

## User Identification & Auth

- **Anonymous:** If no user set, the SDK generates a UUID-based anon ID stored in UserDefaults
- **Email-based:** `FeaturesVote.updateUser(email:)` — votes tracked by email
- **Custom ID:** `FeaturesVote.updateUser(customID:)` — use your app's user ID
- **JWT:** `FeaturesVote.setToken()` — for platforms that issue signed tokens; validated via `/public/user-token`

## ⚠️ CRITICAL: Feature Documentation

**Every new feature added to this SDK must have a corresponding `.md` file in `/docs/features/`.**

This applies to new views, new configuration options, new authentication methods, new API endpoint integrations, or any other meaningful new capability. The file should describe what the feature does, how to use it, and any relevant configuration details.

## License

Elastic License 2.0 — may use, modify, and distribute but not offer as a hosted/SaaS service or competing product.
