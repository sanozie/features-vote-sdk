import AppKit
import SwiftUI
import FeaturesVote

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureSDK()
        buildMenu()
        buildMainWindow()
        // A freshly-launched app can come up behind the launching terminal; bring it forward.
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Re-open the main window when the user clicks the Dock icon after closing it.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { window?.makeKeyAndOrderFront(nil) }
        return true
    }

    /// A single-window example should quit when its window closes.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    // MARK: - SDK configuration

    private func configureSDK() {
        // Configure the SDK with your project slug. "pulse" is the shared demo project.
        // No API key is required — just the slug.
        FeaturesVote.configure(with: "pulse")

        // Let users vote and comment without signing in. The SDK already defaults these to
        // true; we set them explicitly so the intent is clear in the example. (Server-side
        // anonymous-access settings on the project dashboard can still override this.)
        FeaturesVote.config = Configuration(
            behavior: Configuration.Behavior(
                allowAnonymousVoting: true,
                allowAnonymousComments: true
            )
        )

        // Optional branding + a test user, matching the iOS TestApp.
        FeaturesVote.theme.primaryColor = .blue
        FeaturesVote.updateUser(email: "test@example.com")
        FeaturesVote.updateUser(name: "Test User")
    }

    // MARK: - Main window

    private func buildMainWindow() {
        let hosting = NSHostingController(rootView: FeedbackBoardView())
        // Stop the SDK views' NavigationStack toolbars from bridging into the window
        // titlebar on macOS 14+ (otherwise duplicate/empty toolbar items appear up there).
        hosting.sceneBridgingOptions = []

        let window = NSWindow(contentViewController: hosting)
        window.title = "FeaturesVote — macOS Example"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 900, height: 720))
        window.center()
        window.isReleasedWhenClosed = false
        // Force light chrome: the SDK ships a light-only theme (white cards), and dark-mode
        // window chrome plus system-adaptive text colors make some SDK content hard to read.
        window.appearance = NSAppearance(named: .aqua)
        self.window = window
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - Menu

    /// A SwiftPM `.executableTarget` GUI app gets no menu bar for free. Build a minimal one:
    /// an App menu (About / Quit) and an Edit menu so the SDK's Create form text fields
    /// support the standard cut / copy / paste / select-all keyboard shortcuts.
    private func buildMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        appMenu.addItem(withTitle: "About FeaturesVote Example",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                        keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit FeaturesVote Example",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")

        // Edit menu (enables ⌘C/⌘V/⌘A/⌘Z in the Create form)
        let editItem = NSMenuItem()
        mainMenu.addItem(editItem)
        let editMenu = NSMenu(title: "Edit")
        editItem.submenu = editMenu
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        NSApp.mainMenu = mainMenu
    }
}
