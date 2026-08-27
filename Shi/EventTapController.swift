import CoreGraphics
import Foundation
import QuartzCore

private let leftShiftKey: Int64 = 56
private let rightShiftKey: Int64 = 60
private let escapeKey: Int64 = 53
private let nxDeviceLeftShift: UInt64 = 0x00000002
private let nxDeviceRightShift: UInt64 = 0x00000004
private let systemDefinedEventRawValue: UInt32 = 14

final class EventTapController {
    var onTapFailed: (() -> Void)?

    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private let lock = NSLock()
    private var leftShift = false
    private var rightShift = false
    private var escape = false
    private var chordBegan: CFTimeInterval?
    private var lockPointer = true

    var chordStartTime: CFTimeInterval? {
        lock.lock()
        defer { lock.unlock() }
        return chordBegan
    }

    func start(lockPointer: Bool) -> Bool {
        stop()
        self.lockPointer = lockPointer

        let mask = eventMask(lockPointer: lockPointer)
        let userInfo = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: eventTapCallback,
            userInfo: userInfo
        ) else {
            return false
        }

        guard let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) else {
            return false
        }

        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        return true
    }

    func stop() {
        lock.lock()
        leftShift = false
        rightShift = false
        escape = false
        chordBegan = nil
        lock.unlock()

        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        source = nil
    }

    fileprivate func handle(type: CGEventType, event: CGEvent, proxy: CGEventTapProxy) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            DispatchQueue.main.async { [weak self] in
                self?.onTapFailed?()
            }
            return Unmanaged.passUnretained(event)
        }

        updateChord(type: type, event: event)
        return nil
    }

    private func updateChord(type: CGEventType, event: CGEvent) {
        let keycode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags.rawValue

        lock.lock()
        defer { lock.unlock() }

        switch type {
        case .flagsChanged:
            let leftBit = (flags & nxDeviceLeftShift) != 0
            let rightBit = (flags & nxDeviceRightShift) != 0
            if leftBit || rightBit {
                leftShift = leftBit
                rightShift = rightBit
            } else if keycode == leftShiftKey {
                leftShift = false
            } else if keycode == rightShiftKey {
                rightShift = false
            } else if (flags & CGEventFlags.maskShift.rawValue) == 0 {
                leftShift = false
                rightShift = false
            }
        case .keyDown:
            if keycode == escapeKey {
                escape = true
            }
        case .keyUp:
            if keycode == escapeKey {
                escape = false
            }
        default:
            break
        }

        let bothShifts = leftShift && rightShift
        let fallback = (leftShift || rightShift) && escape
        if bothShifts || fallback {
            if chordBegan == nil {
                chordBegan = CACurrentMediaTime()
            }
        } else {
            chordBegan = nil
        }
    }

    private func eventMask(lockPointer: Bool) -> CGEventMask {
        // Only intercept the keyboard. Pointer events are NOT swallowed here —
        // swallowing mouseMoved/scroll on a HID tap freezes the cursor until the
        // next click. Pointer locking is done via CGAssociateMouseAndMouseCursorPosition
        // in the overlay instead, which restores cleanly on exit.
        let mask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << systemDefinedEventRawValue)
        return mask
    }
}

private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let controller = Unmanaged<EventTapController>.fromOpaque(refcon).takeUnretainedValue()
    return controller.handle(type: type, event: event, proxy: proxy)
}
