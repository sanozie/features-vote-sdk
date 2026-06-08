import AppKit

// Manual NSApplication bootstrap (rather than a SwiftUI `@main App` / `WindowGroup`) so
// this example can own the NSWindow and host the SDK's SwiftUI views through
// NSHostingController. That hosting is what lets us apply the macOS-specific workarounds
// — `sceneBridgingOptions`, forced-light window appearance, a custom app menu — that a
// plain WindowGroup cannot express. It mirrors the proven integration in the "invizzy"
// macOS app, adapted here into a normal windowed (Dock) example app.

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// `.regular`: a normal app with a Dock icon and an app menu — NOT a menu-bar/`.accessory`
// utility. (invizzy uses `.accessory` because it is a menu-bar overlay; an example app
// should behave like an ordinary app.)
app.setActivationPolicy(.regular)

app.run()
