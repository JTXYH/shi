import SwiftUI

struct AtmosphereView: View {
    let skin: Skin
    let sessionStart: Date
    let reduceMotion: Bool

    @State private var engine = ParticleEngine()

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 0.25 : 1.0 / 60.0, paused: false)) { timeline in
            Canvas { context, size in
                let seconds = timeline.date.timeIntervalSince(sessionStart)
                let dt: TimeInterval
                if let last = engine.lastDate {
                    dt = min(0.04, timeline.date.timeIntervalSince(last))
                } else {
                    dt = 1.0 / 60.0
                }
                engine.lastDate = timeline.date
                engine.ensure(size: size, enabled: skin == .wipe && !reduceMotion)

                let cloth = drawAtmosphere(
                    context: &context,
                    size: size,
                    skin: skin,
                    seconds: seconds,
                    reduceMotion: reduceMotion
                )

                guard skin == .wipe, !reduceMotion else { return }
                engine.tick(dt: dt, size: size, cloth: cloth)
                for particle in engine.particles {
                    var dot = context
                    let rect = CGRect(
                        x: particle.x - particle.r,
                        y: particle.y - particle.r,
                        width: particle.r * 2,
                        height: particle.r * 2
                    )
                    dot.opacity = particle.a
                    dot.fill(Path(ellipseIn: rect), with: .color(Color(red: 0.90, green: 0.925, blue: 0.96)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ClothState {
    var x: CGFloat
    var y: CGFloat
    var active: Bool
}

func clothProgress(seconds: TimeInterval, cycle: TimeInterval = 7.2) -> CGFloat {
    let u = seconds.truncatingRemainder(dividingBy: cycle) / cycle
    let wait: TimeInterval = 0.08
    if u < wait { return 0 }
    if u > 1 - wait { return 1 }
    let x = (u - wait) / (1 - 2 * wait)
    return CGFloat(x * x * (3 - 2 * x))
}

func drawWipeSweep(
    context: inout GraphicsContext,
    size: CGSize,
    seconds: TimeInterval,
    cycle: TimeInterval = 7.2,
    strength: CGFloat = 1
) {
    let t = clothProgress(seconds: seconds, cycle: cycle)
    let cx = -size.width * 0.18 + t * size.width * 1.36
    let cy = -size.height * 0.12 + t * size.height * 1.24

    var cloth = context
    cloth.translateBy(x: cx, y: cy)
    cloth.rotate(by: .radians(Double.pi / 5.1))
    cloth.scaleBy(x: 1.85, y: 0.52)
    let radius = max(size.width, size.height) * 0.42
    let oval = CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)
    cloth.fill(
        Path(ellipseIn: oval),
        with: .radialGradient(
            Gradient(stops: [
                .init(color: Color.white.opacity(0.46 * strength), location: 0),
                .init(color: Color(red: 214 / 255, green: 228 / 255, blue: 245 / 255).opacity(0.18 * strength), location: 0.22),
                .init(color: Color(red: 170 / 255, green: 198 / 255, blue: 230 / 255).opacity(0.06 * strength), location: 0.55),
                .init(color: .clear, location: 1)
            ]),
            center: .zero,
            startRadius: 0,
            endRadius: radius
        )
    )

    let specRadius = max(size.width, size.height) * 0.12
    let specRect = CGRect(
        x: cx - 18 - specRadius,
        y: cy - 14 - specRadius,
        width: specRadius * 2,
        height: specRadius * 2
    )
    context.fill(
        Path(ellipseIn: specRect),
        with: .radialGradient(
            Gradient(stops: [
                .init(color: Color(red: 1, green: 0.988, blue: 0.96).opacity(0.42 * strength), location: 0),
                .init(color: Color.white.opacity(0.12 * strength), location: 0.45),
                .init(color: .clear, location: 1)
            ]),
            center: CGPoint(x: cx - 18, y: cy - 14),
            startRadius: 0,
            endRadius: specRadius
        )
    )
}

private func drawAtmosphere(
    context: inout GraphicsContext,
    size: CGSize,
    skin: Skin,
    seconds: TimeInterval,
    reduceMotion: Bool
) -> ClothState {
    let t = clothProgress(seconds: seconds)
    let cx = -size.width * 0.18 + t * size.width * 1.36
    let cy = -size.height * 0.12 + t * size.height * 1.24

    if skin == .night {
        let breath = 0.5 + 0.5 * sin(seconds * Double.pi * 2 / 8)
        let radius = size.height * 0.55
        let rect = CGRect(
            x: size.width * 0.5 - radius,
            y: size.height * 0.5 - radius,
            width: radius * 2,
            height: radius * 2
        )
        context.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: Color(red: 210 / 255, green: 224 / 255, blue: 245 / 255).opacity(0.025 + breath * 0.035), location: 0),
                    .init(color: Color(red: 160 / 255, green: 180 / 255, blue: 210 / 255).opacity(0.02), location: 0.55),
                    .init(color: .clear, location: 1)
                ]),
                center: CGPoint(x: size.width * 0.5, y: size.height * 0.46),
                startRadius: 0,
                endRadius: radius
            )
        )
        return ClothState(x: cx, y: cy, active: false)
    }

    if reduceMotion {
        return ClothState(x: cx, y: cy, active: false)
    }

    if skin == .white {
        var cloth = context
        cloth.translateBy(x: cx, y: cy)
        cloth.rotate(by: .radians(Double.pi / 5.1))
        cloth.scaleBy(x: 1.85, y: 0.52)
        let radius = max(size.width, size.height) * 0.38
        let oval = CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)
        cloth.fill(
            Path(ellipseIn: oval),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: Color(red: 40 / 255, green: 42 / 255, blue: 48 / 255).opacity(0.07), location: 0),
                    .init(color: Color(red: 60 / 255, green: 58 / 255, blue: 52 / 255).opacity(0.03), location: 0.35),
                    .init(color: .clear, location: 1)
                ]),
                center: .zero,
                startRadius: 0,
                endRadius: radius
            )
        )
        return ClothState(x: cx, y: cy, active: true)
    }

    drawWipeSweep(context: &context, size: size, seconds: seconds)
    return ClothState(x: cx, y: cy, active: true)
}

private struct Particle {
    var x: Double
    var y: Double
    var r: Double
    var a: Double
    var tw: Double
    var sp: Double

    static func random(in size: CGSize) -> Particle {
        Particle(
            x: Double.random(in: 0...Double(size.width)),
            y: Double.random(in: 0...Double(size.height)),
            r: Double.random(in: 0.35...1.5),
            a: Double.random(in: 0.06...0.22),
            tw: Double.random(in: 0...(2 * Double.pi)),
            sp: Double.random(in: 0.12...0.47)
        )
    }
}

private final class ParticleEngine {
    var particles: [Particle] = []
    var lastDate: Date?
    private var configured = CGSize.zero

    func ensure(size: CGSize, enabled: Bool) {
        guard enabled else {
            particles = []
            configured = .zero
            return
        }
        let same = abs(configured.width - size.width) < 1 && abs(configured.height - size.height) < 1
        guard !same || particles.isEmpty else { return }
        configured = size
        let count = max(24, Int((size.width * size.height) / 28000))
        particles = (0..<count).map { _ in Particle.random(in: size) }
    }

    func tick(dt: TimeInterval, size: CGSize, cloth: ClothState) {
        let reach = max(size.width, size.height) * 0.22
        for index in particles.indices {
            particles[index].tw += dt * 0.0008 * particles[index].sp * 1000
            particles[index].y += sin(particles[index].tw) * 0.015
            if cloth.active {
                let dx = particles[index].x - cloth.x
                let dy = particles[index].y - cloth.y
                let dist = hypot(dx, dy)
                if dist < reach {
                    let force = 1 - dist / reach
                    particles[index].x += 0.55 * force
                    particles[index].y += 0.32 * force
                    particles[index].a *= 1 - force * 0.045
                }
            }
            if particles[index].a < 0.012 {
                particles[index] = Particle.random(in: size)
            }
        }
    }
}
