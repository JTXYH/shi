import AppKit
import CoreGraphics
import Darwin
import Foundation
import IOKit
import IOKit.graphics

final class BrightnessController: @unchecked Sendable {
    static let shared = BrightnessController()

    private let lock = NSLock()
    private var saved: [CGDirectDisplayID: Float] = [:]
    private var gammaDimmed: Set<CGDirectDisplayID> = []
    private let dimTarget: Float = 0.16
    /// External monitors expose no brightness API, so they are dimmed through the
    /// display gamma table instead. 0.02 reads as black while the panel stays on.
    private let gammaTarget: Float = 0.02
    private let valuesKey = "shi.savedBrightness"
    private let flagKey = "shi.needsBrightnessRestore"
    private let rampQueue = DispatchQueue(label: "shi.brightness.ramp", qos: .userInteractive)
    private var rampGeneration = 0
    private var isRamping = false
    private var rampStarts: [CGDirectDisplayID: Float] = [:]
    private let restoreDuration = 2.4
    private let restoreSteps = 120

    private typealias GetBrightness = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32
    private typealias SetBrightness = @convention(c) (CGDirectDisplayID, Float) -> Int32

    private var getDisplayServices: GetBrightness?
    private var setDisplayServices: SetBrightness?

    private init() {
        loadDisplayServices()
        restoreLeftoverIfNeeded()
    }

    func dim() {
        restore(animated: false)
        var snapshot: [CGDirectDisplayID: Float] = [:]
        var starts: [CGDirectDisplayID: Float] = [:]
        let ids = displayIDs()
        shiDiag("dim: displays=\(ids)")
        var gammaTargets: Set<CGDirectDisplayID> = []
        for id in ids {
            let reading = getBrightness(id)
            shiDiag("dim: display=\(id) brightness=\(String(describing: reading)) builtin=\(CGDisplayIsBuiltin(id))")
            if let current = reading {
                snapshot[id] = current
                let applied = min(current, dimTarget)
                if current > dimTarget {
                    setBrightness(id, applied)
                }
                starts[id] = applied
            } else {
                // No brightness API on this display (typical for external
                // monitors). Dim it via the gamma table so it goes dark too.
                setGamma(id, scale: gammaTarget)
                gammaTargets.insert(id)
                shiDiag("dim: display=\(id) dimmed via gamma")
            }
        }
        if snapshot.isEmpty && gammaTargets.isEmpty {
            snapshot = dimViaIOKit()
            if let current = snapshot[CGMainDisplayID()] {
                starts[CGMainDisplayID()] = min(current, dimTarget)
            }
        }
        lock.lock()
        saved = snapshot
        rampStarts = starts
        gammaDimmed = gammaTargets
        lock.unlock()
        persist(snapshot)
    }

    /// Restores brightness. When `animated`, ramps back over `restoreDuration`
    /// so the screen fades up instead of snapping (which is harsh on the eyes).
    func restore(animated: Bool = true) {
        lock.lock()
        if animated, isRamping {
            lock.unlock()
            return
        }
        rampGeneration += 1
        let gen = rampGeneration
        isRamping = animated
        let memory = saved
        saved = [:]
        let starts = rampStarts
        rampStarts = [:]
        let gamma = gammaDimmed
        gammaDimmed = []
        lock.unlock()

        let snapshot = memory.isEmpty ? loadPersisted() : memory

        guard !snapshot.isEmpty || !gamma.isEmpty else {
            lock.lock()
            isRamping = false
            lock.unlock()
            restoreViaIOKit()
            clearPersisted()
            return
        }

        guard animated else {
            applyFinal(snapshot: snapshot, gamma: gamma)
            return
        }

        let startTime = DispatchTime.now()
        applyRamp(
            snapshot: snapshot,
            starts: starts,
            gamma: gamma,
            t: Self.restoreEase(1 / Float(restoreSteps)),
            useIOKit: false
        )

        rampQueue.async { [weak self] in
            guard let self else { return }
            let duration = self.restoreDuration
            let steps = self.restoreSteps
            for step in 2...steps {
                Self.sleepUntil(start: startTime, duration: duration, step: step, steps: steps)
                guard self.currentGeneration() == gen else { return }
                let t = Float(step) / Float(steps)
                self.applyRamp(
                    snapshot: snapshot,
                    starts: starts,
                    gamma: gamma,
                    t: Self.restoreEase(t),
                    useIOKit: false
                )
            }
            guard self.currentGeneration() == gen else { return }
            self.applyFinal(snapshot: snapshot, gamma: gamma)
        }
    }

    /// Ease-out-quad mixed with smoothstep: the first frames move enough to
    /// read as motion, while the top end still settles instead of slamming.
    private static func restoreEase(_ t: Float) -> Float {
        let x = min(1, max(0, t))
        let out = 1 - (1 - x) * (1 - x)
        let smooth = x * x * (3 - 2 * x)
        return 0.55 * out + 0.45 * smooth
    }

    private func applyRamp(
        snapshot: [CGDirectDisplayID: Float],
        starts: [CGDirectDisplayID: Float],
        gamma: Set<CGDirectDisplayID>,
        t: Float,
        useIOKit: Bool
    ) {
        for (id, target) in snapshot {
            let start = starts[id] ?? dimTarget
            setBrightness(id, start + (target - start) * t, useIOKit: useIOKit)
        }
        for id in gamma {
            setGamma(id, scale: gammaTarget + (1 - gammaTarget) * t)
        }
    }

    private func applyFinal(snapshot: [CGDirectDisplayID: Float], gamma: Set<CGDirectDisplayID>) {
        for (id, value) in snapshot {
            setBrightness(id, value)
        }
        for id in gamma {
            resetGamma(id)
        }
        lock.lock()
        isRamping = false
        lock.unlock()
        clearPersisted()
    }

    private func setGamma(_ id: CGDirectDisplayID, scale: Float) {
        guard scale.isFinite else { return }
        let clamped = min(1, max(0, scale))
        _ = CGSetDisplayTransferByFormula(
            id,
            0, clamped, 1,
            0, clamped, 1,
            0, clamped, 1
        )
    }

    private func resetGamma(_ id: CGDirectDisplayID) {
        _ = CGSetDisplayTransferByFormula(id, 0, 1, 1, 0, 1, 1, 0, 1, 1)
    }

    private func currentGeneration() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return rampGeneration
    }

    func restoreLeftoverIfNeeded() {
        guard UserDefaults.standard.bool(forKey: flagKey) else { return }
        restore(animated: false)
    }

    private func displayIDs() -> [CGDirectDisplayID] {
        var ids: [CGDirectDisplayID] = []
        for screen in NSScreen.screens {
            if let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
                ids.append(CGDirectDisplayID(number.uint32Value))
            }
        }
        if ids.isEmpty {
            ids.append(CGMainDisplayID())
        }
        return ids
    }

    private func getBrightness(_ id: CGDirectDisplayID) -> Float? {
        if let getDisplayServices {
            var value: Float = 0
            if getDisplayServices(id, &value) == 0,
               let brightness = Self.validBrightness(value) {
                return brightness
            }
        }
        return ioKitBrightness()
    }

    private func setBrightness(_ id: CGDirectDisplayID, _ value: Float, useIOKit: Bool = true) {
        guard let clamped = Self.validBrightness(value) else { return }
        if let setDisplayServices {
            _ = setDisplayServices(id, clamped)
            if !useIOKit { return }
        }
        setIOKitBrightness(clamped)
    }

    private static func sleepUntil(start: DispatchTime, duration: TimeInterval, step: Int, steps: Int) {
        let targetNs = start.uptimeNanoseconds
            + UInt64(duration * 1_000_000_000 * Double(step) / Double(steps))
        let now = DispatchTime.now().uptimeNanoseconds
        guard targetNs > now else { return }
        let remaining = targetNs - now
        guard remaining > 400_000 else { return }
        var ts = timespec(
            tv_sec: Int(remaining / 1_000_000_000),
            tv_nsec: Int(remaining % 1_000_000_000)
        )
        nanosleep(&ts, nil)
    }

    private func loadDisplayServices() {
        let paths = [
            "/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices",
            "/System/Library/PrivateFrameworks/DisplayServices.framework/Versions/A/DisplayServices",
            "/System/Library/PrivateFrameworks/DisplayServices.framework/Versions/Current/DisplayServices"
        ]
        for path in paths {
            guard let handle = dlopen(path, RTLD_LAZY) else { continue }
            if getDisplayServices == nil, let getSym = dlsym(handle, "DisplayServicesGetBrightness") {
                getDisplayServices = unsafeBitCast(getSym, to: GetBrightness.self)
            }
            if setDisplayServices == nil, let setSym = dlsym(handle, "DisplayServicesSetBrightness") {
                setDisplayServices = unsafeBitCast(setSym, to: SetBrightness.self)
            }
            if getDisplayServices != nil || setDisplayServices != nil {
                return
            }
        }
    }

    private func ioKitBrightness() -> Float? {
        var found: Float?
        forEachDisplayService { service in
            var value: Float = 0
            if IODisplayGetFloatParameter(service, 0, "brightness" as CFString, &value) == KERN_SUCCESS,
               let brightness = Self.validBrightness(value) {
                found = brightness
            }
        }
        return found
    }

    private func setIOKitBrightness(_ value: Float) {
        forEachDisplayService { service in
            IODisplaySetFloatParameter(service, 0, "brightness" as CFString, value)
        }
    }

    private func dimViaIOKit() -> [CGDirectDisplayID: Float] {
        var snapshot: [CGDirectDisplayID: Float] = [:]
        if let current = ioKitBrightness() {
            snapshot[CGMainDisplayID()] = current
            if current > dimTarget {
                setIOKitBrightness(dimTarget)
            }
        }
        return snapshot
    }

    private func restoreViaIOKit() {
        let persisted = loadPersisted()
        if let value = persisted.values.first {
            setIOKitBrightness(value)
        }
    }

    private func forEachDisplayService(_ body: (io_service_t) -> Void) {
        var iterator = io_iterator_t()
        let result = IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        )
        guard result == KERN_SUCCESS else { return }
        defer { IOObjectRelease(iterator) }
        while true {
            let service = IOIteratorNext(iterator)
            if service == 0 { break }
            body(service)
            IOObjectRelease(service)
        }
    }

    private func persist(_ snapshot: [CGDirectDisplayID: Float]) {
        var boxed: [String: Float] = [:]
        for (id, value) in snapshot {
            guard let brightness = Self.validBrightness(value) else { continue }
            boxed[String(id)] = brightness
        }
        UserDefaults.standard.set(boxed, forKey: valuesKey)
        UserDefaults.standard.set(true, forKey: flagKey)
    }

    private func loadPersisted() -> [CGDirectDisplayID: Float] {
        guard let boxed = UserDefaults.standard.dictionary(forKey: valuesKey) else {
            return [:]
        }
        var snapshot: [CGDirectDisplayID: Float] = [:]
        for (key, value) in boxed {
            guard let id = UInt32(key), let number = value as? NSNumber,
                  let brightness = Self.validBrightness(number.floatValue) else { continue }
            snapshot[id] = brightness
        }
        return snapshot
    }

    private static func validBrightness(_ value: Float) -> Float? {
        guard value.isFinite else { return nil }
        return min(1, max(0, value))
    }

    private func clearPersisted() {
        UserDefaults.standard.removeObject(forKey: valuesKey)
        UserDefaults.standard.set(false, forKey: flagKey)
    }
}
