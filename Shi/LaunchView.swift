import AppKit
import SwiftUI

private enum LaunchChrome {
    static let paperTop = Color(red: 0.996, green: 0.997, blue: 0.999)
    static let paperBottom = Color(red: 0.941, green: 0.945, blue: 0.953)
    static let ink = Color(red: 0.114, green: 0.114, blue: 0.126)
    static let inkSoft = Color(red: 0.114, green: 0.114, blue: 0.126).opacity(0.60)
    static let muted = Color(red: 0.114, green: 0.114, blue: 0.126).opacity(0.42)
    static let faint = Color(red: 0.114, green: 0.114, blue: 0.126).opacity(0.32)
    static let cardStroke = Color.black.opacity(0.07)
    static let window = NSColor(srgbRed: 0.996, green: 0.997, blue: 0.999, alpha: 1)
    static let accent = Color(red: 0.039, green: 0.518, blue: 1.0)
    static let buttonTop = Color(red: 0.219, green: 0.596, blue: 1.0)
    static let buttonBottom = Color(red: 0.0, green: 0.435, blue: 0.949)
}

struct LaunchView: View {
    @Bindable var model: AppModel

    var body: some View {
        ZStack {
            background
            LaunchWindowConfigurator()
            Group {
                if model.showPermissionCoach {
                    PermissionCoachView(model: model)
                } else {
                    home
                }
            }
        }
        .frame(width: 488, height: 528)
        .preferredColorScheme(.light)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            model.checkPermissionAndContinue()
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [LaunchChrome.paperTop, LaunchChrome.paperBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color.white.opacity(0.55), .clear],
                center: UnitPoint(x: 0.5, y: 0.02),
                startRadius: 0,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }

    private var home: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 30)

            LogoBadge()

            Text(L10n.text(.tagline, language: model.language))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(LaunchChrome.inkSoft)
                .padding(.top, 18)

            HStack(spacing: 12) {
                ForEach(Skin.allCases) { skin in
                    SkinTile(
                        skin: skin,
                        selected: model.skin == skin,
                        language: model.language
                    ) {
                        withAnimation(.easeOut(duration: 0.18)) { model.skin = skin }
                    }
                }
            }
            .padding(.top, 30)

            if let message = model.tapFailedMessage {
                Text(L10n.text(message, language: model.language))
                    .font(.system(size: 12))
                    .foregroundStyle(LaunchChrome.muted)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, 12)
            }

            Button(action: model.startCleaning) {
                Text(L10n.text(.startCleaning, language: model.language))
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(Color.white)
                    .frame(width: 208, height: 46)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [LaunchChrome.buttonTop, LaunchChrome.buttonBottom],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                            )
                    )
                    .shadow(color: LaunchChrome.accent.opacity(0.32), radius: 14, y: 6)
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 30)
            .disabled(model.isCleaning)
            .opacity(model.isCleaning ? 0.55 : 1)
            .keyboardShortcut(.defaultAction)

            Text(L10n.text(.exitHintShort, language: model.language))
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(LaunchChrome.faint)
                .padding(.top, 16)

            Spacer(minLength: 28)
        }
        .padding(.horizontal, 36)
    }
}

private struct LogoBadge: View {
    var body: some View {
        Image("AppLogo")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.14), radius: 16, y: 8)
            .shadow(color: Color.black.opacity(0.06), radius: 2, y: 1)
    }
}

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct SkinTile: View {
    let skin: Skin
    let selected: Bool
    let language: AppLanguage
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                    ZStack {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(skin.background)
                        switch skin {
                        case .wipe:
                            WipePreviewSweep()
                        case .white:
                            WhitePreviewSheen()
                        case .night:
                            NightPreviewClock()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .padding(6)
                }
                .frame(width: 118, height: 76)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(selected ? LaunchChrome.accent : LaunchChrome.cardStroke,
                                lineWidth: selected ? 2 : 1)
                )
                .overlay(alignment: .topTrailing) {
                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(LaunchChrome.accent))
                            .overlay(Circle().strokeBorder(Color.white, lineWidth: 1.5))
                            .offset(x: 6, y: -6)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .shadow(color: selected ? LaunchChrome.accent.opacity(0.18) : Color.black.opacity(0.05),
                        radius: selected ? 10 : 6, y: selected ? 4 : 2)

                Text(skin.label(language: language))
                    .font(.system(size: 12.5, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? LaunchChrome.ink : LaunchChrome.muted)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct WipePreviewSweep: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
            let seconds = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                drawWipeSweep(
                    context: &context,
                    size: size,
                    seconds: seconds,
                    cycle: 2.6,
                    strength: 1.35
                )
            }
        }
        .allowsHitTesting(false)
    }
}

private struct WhitePreviewSheen: View {
    var body: some View {
        LinearGradient(
            colors: [Color.white.opacity(0.9), Color(red: 0.90, green: 0.89, blue: 0.87)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [Color.white.opacity(0.85), .clear],
                center: UnitPoint(x: 0.35, y: 0.28),
                startRadius: 0,
                endRadius: 70
            )
        )
        .allowsHitTesting(false)
    }
}

private struct NightPreviewClock: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            Text(Self.timeString(timeline.date))
                .font(.system(size: 13, weight: .ultraLight))
                .monospacedDigit()
                .tracking(1)
                .foregroundStyle(Color.white.opacity(0.9))
        }
    }

    private static func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

private struct LaunchWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { configure(view) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { configure(nsView) }
    }

    private func configure(_ view: NSView) {
        guard let window = view.window else { return }
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = LaunchChrome.window
        window.appearance = NSAppearance(named: .aqua)
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }
}
