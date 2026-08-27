import AppKit
import SwiftUI

struct OverlayView: View {
    @Bindable var model: AppModel
    var showsChrome: Bool

    var body: some View {
        ZStack {
            model.skin.background
            AtmosphereView(
                skin: model.skin,
                sessionStart: model.sessionStart,
                reduceMotion: model.reduceMotion
            )
            vignette
            sheen

            if showsChrome {
                chrome
            }
        }
        .foregroundStyle(model.skin.foreground)
        .opacity(model.isExiting ? 0 : 1)
        .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.7), value: model.isExiting)
        .ignoresSafeArea()
    }

    private var vignette: some View {
        RadialGradient(
            colors: [
                .clear,
                (model.skin == .white ? Color(red: 0.55, green: 0.52, blue: 0.42).opacity(0.22) : Color.black.opacity(0.38))
            ],
            center: .center,
            startRadius: 240,
            endRadius: 980
        )
        .allowsHitTesting(false)
    }

    private var sheen: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(model.skin == .white ? 0.45 : 0.055),
                .clear
            ],
            startPoint: .top,
            endPoint: UnitPoint(x: 0.5, y: 0.22)
        )
        .allowsHitTesting(false)
    }

    private var chrome: some View {
        ZStack {
            VStack {
                Text(L10n.text(.inputPaused, language: model.language))
                    .font(.system(size: 13, weight: .regular))
                    .tracking(1.8)
                    .opacity(model.showTeach ? 0.62 : 0)
                    .padding(.top, 72)
                Spacer()
            }

            VStack(spacing: 14) {
                Text(L10n.text(.cleaning, language: model.language))
                    .font(.system(size: 15, weight: .regular))
                    .tracking(6.3)
                    .opacity(model.skin == .night ? 0.4 : 0.62)
                Text(model.formattedElapsed)
                    .font(.system(size: model.skin.elapsedSize, weight: .ultraLight))
                    .monospacedDigit()
                    .tracking(3.8)
            }

            VStack {
                Spacer()
                VStack(spacing: 14) {
                    holdRing
                        .opacity(model.holdProgress > 0.01 ? 1 : 0)
                        .scaleEffect(model.holdProgress > 0.01 ? 1 : 0.92)
                    Text(L10n.text(.exitHint, language: model.language))
                        .font(.system(size: 12, weight: .regular))
                        .tracking(1.9)
                        .opacity(model.holdProgress > 0.01 ? 0.92 : 0.5)
                }
                .padding(.bottom, 56)
                .animation(.easeOut(duration: 0.25), value: model.holdProgress > 0.01)
            }
        }
        .allowsHitTesting(false)
    }

    private var holdRing: some View {
        ZStack {
            Circle()
                .stroke(model.skin.foreground.opacity(0.18), lineWidth: 1.4)
            Circle()
                .trim(from: 0, to: model.holdProgress)
                .stroke(model.skin.foreground, style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 36, height: 36)
    }
}
