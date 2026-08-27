import AppKit
import CoreGraphics
import SwiftUI

@main
struct ShiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            LaunchView(model: model)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 488, height: 528)

        Settings {
            SettingsView(model: model)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Defensive: if a previous run was force-quit while the pointer was
        // disassociated, the system mouse could be stuck. Always re-associate
        // on launch so movement is guaranteed to work.
        CGAssociateMouseAndMouseCursorPosition(1)
        // Same idea for the display gamma tables used to dim external monitors.
        CGDisplayRestoreColorSyncSettings()
        BrightnessController.shared.restoreLeftoverIfNeeded()
        UpdateController.shared.startIfNeeded()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationWillTerminate(_ notification: Notification) {
        BrightnessController.shared.restore(animated: false)
    }
}
