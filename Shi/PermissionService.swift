import AppKit
import ApplicationServices
import CoreGraphics
import Foundation

enum PermissionService {
    static var isAccessibilityTrusted: Bool {
        AXIsProcessTrusted()
    }

    static var canListenEvents: Bool {
        CGPreflightListenEventAccess()
    }

    static var isReady: Bool {
        isAccessibilityTrusted
    }

    static func promptAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    static func promptInputMonitoring() {
        CGRequestListenEventAccess()
    }

    static func requestAll() {
        promptInputMonitoring()
        promptAccessibility()
    }

    static func openAccessibilitySettings() {
        openSettings(path: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        openSettings(path: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility")
    }

    static func openInputMonitoringSettings() {
        openSettings(path: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
        openSettings(path: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ListenEvent")
    }

    private static func openSettings(path: String) {
        guard let url = URL(string: path) else { return }
        NSWorkspace.shared.open(url)
    }
}
