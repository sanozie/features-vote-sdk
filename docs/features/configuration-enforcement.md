# Configuration Enforcement

All settings in `FeaturesVote.config` (and their server-side equivalents in `Project.Customization`) are now fully enforced throughout the SDK.

## Behavior Settings

### `allowAnonymousVoting` (default: `true`)

Controls whether anonymous users (users without an email, customID, or token) can vote.

```swift
FeaturesVote.config = Configuration(
    behavior: .init(allowAnonymousVoting: false)
)
```

When set to `false`, anonymous users see a "Sign In Required" alert when tapping the vote button. The alert message can be customized via the server-side `disabledAnonMessage` project setting.

**Server override:** `Customization.isAnonDisabled = true` blocks anonymous voting and commenting regardless of this local config. (It does not gate feature creation.)

---

### `allowAnonymousComments` (default: `true`)

Controls whether anonymous users can submit comments.

```swift
FeaturesVote.config = Configuration(
    behavior: .init(allowAnonymousComments: false)
)
```

When set to `false`, the comment input is hidden and replaced with a sign-in prompt for anonymous users.

---

### `requireEmailForCreate` (default: `false`)

Requires an email address to be set before a user can submit a new feature request.

```swift
FeaturesVote.config = Configuration(
    behavior: .init(requireEmailForCreate: true)
)
```

When set to `true`:
- The Submit button is disabled when no email is set
- An inline warning is shown in the create form
- `FeaturesVote.updateUser(email:)` must be called to enable submission

---

### `enableOptimisticUpdates` (default: `true`)

Controls whether vote changes are reflected in the UI immediately (before the API call completes).

```swift
FeaturesVote.config = Configuration(
    behavior: .init(enableOptimisticUpdates: false)
)
```

When `true`: Vote count and state update immediately on tap, and revert if the API call fails.  
When `false`: UI only updates after the API call succeeds.

---

### `confirmVoting` (default: `false`)

Shows a confirmation alert before casting a vote.

```swift
FeaturesVote.config = Configuration(
    behavior: .init(confirmVoting: true)
)
```

When `true`, tapping the vote button shows "Are you sure you want to cast your vote for this feature?" with Vote/Cancel options.

---

### `confirmUnsubscribe` (default: `true`)

Shows a confirmation alert before unsubscribing from feature notifications.

```swift
FeaturesVote.config = Configuration(
    behavior: .init(confirmUnsubscribe: false)
)
```

When `true`, tapping the subscribe button to unsubscribe shows a confirmation. Subscribing never requires confirmation.

## UI Settings

### `showWatermark` (default: `true`)

Controls the "Powered by Features.Vote" link in the voting board footer.

```swift
FeaturesVote.config = Configuration(
    ui: .init(showWatermark: false)
)
```

**Server override:** `Customization.hideWatermark = true` hides the watermark regardless of this local config.

---

### `showAvatars` (default: `true`)

Controls whether user avatars appear in feature rows.

```swift
FeaturesVote.config = Configuration(
    ui: .init(showAvatars: false)
)
```

---

### `showCommentCount` (default: `true`)

Controls whether the comment count bubble appears on feature rows.

```swift
FeaturesVote.config = Configuration(
    ui: .init(showCommentCount: false)
)
```

---

### `enablePullToRefresh` (default: `true`)

Controls whether the pull-to-refresh gesture works on the feature list.

```swift
FeaturesVote.config = Configuration(
    ui: .init(enablePullToRefresh: false)
)
```

---

### `showStatusBadge` (default: `true`)

Controls whether the colored status badge (Pending / In Progress / etc.) appears on feature rows. Enforced in `FeatureRowView`.

```swift
FeaturesVote.config = Configuration(
    ui: .init(showStatusBadge: false)
)
```

---

### `showTags` (default: `true`)

Controls whether tag chips appear on feature rows and roadmap cards. Enforced in `FeatureRowView` and `RoadmapCardView`.

```swift
FeaturesVote.config = Configuration(
    ui: .init(showTags: false)
)
```

---

### `maxDescriptionLines` (default: `3`)

Maximum number of description lines shown on a feature row before truncation. Enforced in `FeatureRowView` via `.lineLimit(...)`.

```swift
FeaturesVote.config = Configuration(
    ui: .init(maxDescriptionLines: 5)
)
```

## Button Icons

All button icons in the voting board and feature detail views are configurable:

```swift
FeaturesVote.config = Configuration(
    buttons: .init(
        upvoteIcon: Image(systemName: "hand.thumbsup"),
        subscribeIcon: Image(systemName: "bell.badge"),
        subscribedIcon: Image(systemName: "bell.fill")
    )
)
```

Available button slots: `upvoteIcon`, `subscribeIcon`, `subscribedIcon`. (These are the only button icons the SDK currently renders.)

## Server-Side Project Customization

The following `Customization` fields (returned by `/api/public/project`) affect SDK behavior:

| Field | Effect |
|-------|--------|
| `isAnonDisabled` | Blocks anonymous voting and commenting regardless of local config (does not affect feature creation) |
| `disabledAnonMessage` | Custom message shown when an anonymous user is blocked |
| `hideWatermark` | Hides the "Powered by Features.Vote" watermark |
| `isInProgressOnTop` | When `true` (default), pins in-progress features to the top of the voting board |
| `suggestPopupHeaderText` | Custom title for the create feature form |
| `suggestPopupSuccessMsg` | Custom success message after creating a feature |

## Anonymous User Detection

A user is considered **anonymous** when no explicit identification has been provided via:

```swift
FeaturesVote.updateUser(email: "user@example.com")  // email
FeaturesVote.updateUser(customID: "user_123")         // custom ID
FeaturesVote.setToken("jwt_token")                    // JWT token
```

Auto-generated device UUIDs (used for anonymous vote tracking) do **not** count as identification. Calling `FeaturesVote.clearUser()` resets the user to anonymous.
