import AppKit
import Foundation
import Observation
import QuartzCore

@MainActor
@Observable
final class AppModel {
    var isCleaning = false
    var isExiting = false
    var showTeach = true
    var holdProgress: Double = 0
    var elapsed: TimeInterval = 0
    var showPermissionCoach = false
    var tapFailedMessage: L10n.Key?
    var sessionStart = Date()

    var skin: Skin {
        didSet { UserDefaults.standard.set(skin.rawValue, forKey: Keys.skin) }
    }

    var holdDuration: Double {
        didSet {
            let sanitized = Self.sanitizedHoldDuration(holdDuration)
            guard sanitized == holdDuration else {
                holdDuration = sanitized
                return
            }
            UserDefaults.standard.set(holdDuration, forKey: Keys.holdDuration)
        }
    }

    var lockPointer: Bool {
        didSet { UserDefaults.standard.set(lockPointer, forKey: Keys.lockPointer) }
    }

    var maxMinutes: MaxCleanMinutes {
        didSet { UserDefaults.standard.set(maxMinutes.rawValue, forKey: Keys.maxMinutes) }
    }

    var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Keys.language) }
    }

    var reduceMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    private let tap = EventTapController()
    private let overlay = OverlayController()
    private var tick: Timer?
    private var teachTask: Task<Void, Never>?
    private var exitTask: Task<Void, Never>?
    private var permissionPoll: Timer?

    private enum Keys {
        static let skin = "shi.skin"
        static let holdDuration = "shi.holdDuration"
        static let lockPointer = "shi.lockPointer"
        static let maxMinutes = "shi.maxMinutes"
        static let didPrompt = "shi.didPromptAccessibility"
        static let language = "shi.language"
    }

    init() {
        let storedSkin = UserDefaults.standard.string(forKey: Keys.skin) ?? Skin.wipe.rawValue
        skin = Skin(rawValue: storedSkin) ?? .wipe
        let storedHold = UserDefaults.standard.object(forKey: Keys.holdDuration) as? Double
        holdDuration = Self.sanitizedHoldDuration(storedHold ?? 1.5)
        lockPointer = UserDefaults.standard.object(forKey: Keys.lockPointer) as? Bool ?? true
        let storedMax = UserDefaults.standard.object(forKey: Keys.maxMinutes) as? Int ?? 10
        maxMinutes = MaxCleanMinutes(rawValue: storedMax) ?? .ten
        language = AppLanguage.initialLanguage(
            storedValue: UserDefaults.standard.string(forKey: Keys.language),
            preferredLanguages: Locale.preferredLanguages
        )

        overlay.attach(model: self)
        tap.onTapFailed = { [weak self] in
            Task { @MainActor in
                self?.handleTapFailed()
            }
        }

        HotKeyCenter.shared.onPressed = { [weak self] in
            Task { @MainActor in
                self?.startCleaning()
            }
        }
        HotKeyCenter.shared.register()
    }

    var formattedElapsed: String {
        let total = Int(elapsed)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startCleaning() {
        guard !isCleaning else { return }
        tapFailedMessage = nil
        shiDiag("startCleaning: trusted=\(PermissionService.isAccessibilityTrusted) listen=\(PermissionService.canListenEvents)")

        if !PermissionService.isReady {
            presentPermissionCoach()
            return
        }

        beginCleanSession()
    }

    func checkPermissionAndContinue() {
        guard showPermissionCoach else { return }
        // Must use the exact same gate as `startCleaning()`. This used to also
        // require Input Monitoring — a separate permission that is never granted
        // here — so the poll could never finish and the user had to back out and
        // start over manually.
        guard PermissionService.isReady else { return }

        permissionPoll?.invalidate()
        permissionPoll = nil
        showPermissionCoach = false
        shiDiag("permission: granted, auto-continuing")

        // TCC needs a moment to propagate before an event tap can be created.
        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            self?.beginCleanSession()
        }
    }

    private func presentPermissionCoach() {
        let alreadyShowing = showPermissionCoach
        showPermissionCoach = true
        shiDiag("presentPermissionCoach: showing=\(alreadyShowing) trusted=\(PermissionService.isAccessibilityTrusted)")

        if !alreadyShowing {
            let promptedBefore = UserDefaults.standard.bool(forKey: Keys.didPrompt)
            // Registers 拭 into the Accessibility list. macOS only ever shows
            // this dialog once per app.
            PermissionService.promptAccessibility()
            UserDefaults.standard.set(true, forKey: Keys.didPrompt)

            // Once the app has been prompted before (e.g. the user granted it and
            // later removed it from the list), the system dialog stays silent
            // forever. Take the user straight to the list instead of leaving them
            // with no way forward.
            if promptedBefore {
                shiDiag("presentPermissionCoach: system dialog is spent, opening Settings")
                PermissionService.openAccessibilitySettings()
            } else {
                // The flag above is only known from our own history. If the
                // system dialog silently did nothing (TCC already had a record),
                // fall back to opening the list so the user is never stranded.
                Task { [weak self] in
                    try? await Task.sleep(for: .seconds(3))
                    guard let self, self.showPermissionCoach,
                          !PermissionService.isAccessibilityTrusted else { return }
                    shiDiag("presentPermissionCoach: no grant after 3s, opening Settings")
                    PermissionService.openAccessibilitySettings()
                }
            }
        }

        permissionPoll?.invalidate()
        let timer = Timer(timeInterval: 0.45, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPermissionAndContinue()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        permissionPoll = timer
    }

    /// Open the Accessibility settings pane (no system dialog).
    func openAccessibilityHelp() {
        PermissionService.openAccessibilitySettings()
    }

    /// Leave the permission coach and return to the launch screen.
    func dismissPermissionCoach() {
        permissionPoll?.invalidate()
        permissionPoll = nil
        showPermissionCoach = false
    }

    private func beginCleanSession() {
        guard !isCleaning else { return }

        sessionStart = Date()
        elapsed = 0
        holdProgress = 0
        isExiting = false
        showTeach = true
        isCleaning = true

        overlay.show()

        if !tap.start(lockPointer: lockPointer) {
            overlay.hide()
            isCleaning = false
            shiDiag("tap.start failed; trusted=\(PermissionService.isAccessibilityTrusted)")
            tapFailedMessage = .tapCreateFailed
            // Always coach here. `AXIsProcessTrusted()` keeps reporting `true`
            // for a while after the user removes the app from the Accessibility
            // list, so a failed tap is the only trustworthy signal.
            presentPermissionCoach()
            return
        }

        hideLaunchWindows()
        BrightnessController.shared.dim()
        startTick()
        teachTask?.cancel()
        teachTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(4800))
            guard !Task.isCancelled else { return }
            self?.showTeach = false
        }
    }

    func endSession(quit: Bool = false, restoreBrightness: Bool = true) {
        exitTask?.cancel()
        teachTask?.cancel()
        permissionPoll?.invalidate()
        permissionPoll = nil
        stopTick()
        tap.stop()
        if restoreBrightness {
            BrightnessController.shared.restore()
        }
        overlay.hide()
        isCleaning = false
        isExiting = false
        holdProgress = 0
        elapsed = 0
        showTeach = true
        if quit {
            NSApp.terminate(nil)
        } else {
            showLaunchWindows()
        }
    }

    private func showLaunchWindows() {
        NSApp.setActivationPolicy(.regular)
        for window in NSApp.windows where !(window is OverlayWindow) {
            window.setIsVisible(true)
            window.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func requestExit() {
        guard isCleaning, !isExiting else { return }
        isExiting = true
        holdProgress = 1
        // Start the brightness ramp immediately, overlapping the overlay fade.
        // Waiting until endSession made the launch screen sit at 16% brightness
        // for ~0.7s (the "stuck, then fade up" hitch).
        BrightnessController.shared.restore()
        showLaunchWindows()
        exitTask?.cancel()
        exitTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(720))
            guard !Task.isCancelled else { return }
            self?.endSession(restoreBrightness: false)
        }
    }

    private func handleTapFailed() {
        tapFailedMessage = .tapInterrupted
        endSession()
    }

    private static func sanitizedHoldDuration(_ value: Double) -> Double {
        guard value.isFinite else { return 1.5 }
        return min(max(value, 0.5), 5)
    }

    private func startTick() {
        stopTick()
        let timer = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tickOnce()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        tick = timer
    }

    private func stopTick() {
        tick?.invalidate()
        tick = nil
    }

    private func tickOnce() {
        guard isCleaning else { return }
        elapsed = Date().timeIntervalSince(sessionStart)

        if let began = tap.chordStartTime {
            let progress = min(1, (CACurrentMediaTime() - began) / holdDuration)
            holdProgress = progress
            if progress >= 1 {
                requestExit()
            }
        } else if holdProgress != 0, !isExiting {
            holdProgress = 0
        }

        if maxMinutes != .off, elapsed >= Double(maxMinutes.rawValue) * 60 {
            requestExit()
        }
    }

    private func hideLaunchWindows() {
        for window in NSApp.windows where !(window is OverlayWindow) {
            window.orderOut(nil)
        }
    }
}
