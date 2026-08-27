import AppKit
import CoreGraphics
import OSLog
import SwiftUI

@MainActor
final class OverlayController {
    private var windows: [NSWindow] = []
    private var screenObserver: NSObjectProtocol?
    private var sleepObserver: NSObjectProtocol?
    private var cursorHideDepth = 0
    private var lastScreenLayout: [CGRect] = []
    private weak var model: AppModel?

    func attach(model: AppModel) {
        self.model = model
        if screenObserver == nil {
            screenObserver = NotificationCenter.default.addObserver(
                forName: NSApplication.didChangeScreenParametersNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.rebuildIfNeeded()
                }
            }
        }
        if sleepObserver == nil {
            sleepObserver = NSWorkspace.shared.notificationCenter.addObserver(
                forName: NSWorkspace.willSleepNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.model?.endSession()
                }
            }
        }
    }

    func show() {
        guard let model else { return }
        hideWindows()
        let screens = NSScreen.screens
        lastScreenLayout = screens.map(\.frame)
        shiDiag("show: screens=\(screens.count) frames=\(screens.map(\.frame))")
        for (index, screen) in screens.enumerated() {
            let isPrimary = screen == screens.first
            let root = OverlayView(model: model, showsChrome: isPrimary)
            let hosting = NSHostingView(rootView: root)
            hosting.wantsLayer = true
            hosting.autoresizingMask = [.width, .height]
            let window = OverlayWindow(screen: screen)
            window.setFrame(screen.frame, display: false)
            window.contentView = hosting
            hosting.frame = NSRect(origin: .zero, size: screen.frame.size)
            window.ignoresMouseEvents = !model.lockPointer
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            windows.append(window)
            shiDiag("show[\(index)]: target=\(screen.frame) got=\(window.frame) visible=\(window.isVisible) alpha=\(window.alphaValue) onScreen=\(String(describing: window.screen?.frame)) hosting=\(hosting.frame)")
        }
        hideCursor()

        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard let self else { return }
            for (index, window) in self.windows.enumerated() {
                shiDiag("recheck[\(index)]: frame=\(window.frame) visible=\(window.isVisible) alpha=\(window.alphaValue) onScreen=\(String(describing: window.screen?.frame)) contentSize=\(String(describing: window.contentView?.frame.size))")
            }
        }
    }

    func hide() {
        hideWindows()
        showCursor()
        // Safety net: we never disassociate anymore, but keep this so the pointer
        // is guaranteed to stay associated with the cursor after cleaning.
        CGAssociateMouseAndMouseCursorPosition(1)
    }

    private func hideCursor() {
        guard cursorHideDepth == 0 else { return }
        NSCursor.hide()
        cursorHideDepth += 1
        shiDiag("hideCursor: depth=\(cursorHideDepth)")
    }

    /// `NSCursor.hide()` is reference counted *per process*. The app no longer
    /// quits after a session, so any imbalance leaves the cursor invisible
    /// forever, which reads as "the mouse is frozen". Unwind our own depth, then
    /// keep unhiding until the system reports a visible cursor again
    /// (`NSCursor.currentSystem` is nil while the cursor is hidden).
    private func showCursor() {
        while cursorHideDepth > 0 {
            NSCursor.unhide()
            cursorHideDepth -= 1
        }
        NSCursor.setHiddenUntilMouseMoves(false)
        CGDisplayShowCursor(CGMainDisplayID())

        var attempts = 0
        while NSCursor.currentSystem == nil && attempts < 16 {
            NSCursor.unhide()
            attempts += 1
        }
        shiDiag("showCursor: extraUnhides=\(attempts) visible=\(NSCursor.currentSystem != nil)")
    }

    /// `didChangeScreenParameters` also fires for brightness/gamma changes, which
    /// made every session tear down and rebuild its overlays milliseconds after
    /// creating them. Only rebuild when the display layout actually changed.
    private func rebuildIfNeeded() {
        guard model?.isCleaning == true else { return }
        let layout = NSScreen.screens.map(\.frame)
        guard layout != lastScreenLayout else {
            shiDiag("rebuild skipped: layout unchanged")
            return
        }
        shiDiag("rebuild: layout \(lastScreenLayout) -> \(layout)")
        show()
    }

    private func hideWindows() {
        for window in windows {
            window.orderOut(nil)
            window.close()
        }
        windows.removeAll()
    }
}

final class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        animationBehavior = .none
        acceptsMouseMovedEvents = true
        isRestorable = false
    }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }
}

private let shiLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.shi.clean",
    category: "diagnostics"
)

/// Field logger for display, cursor, and permission diagnostics.
/// Debug builds only; uses Unified Logging so a predictable temporary file
/// cannot be redirected through a symbolic link.
func shiDiag(_ message: String) {
    #if DEBUG
    shiLogger.debug("\(message, privacy: .public)")
    #endif
}
