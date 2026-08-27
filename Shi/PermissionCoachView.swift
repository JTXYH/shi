import SwiftUI

struct PermissionCoachView: View {
    @Bindable var model: AppModel

    private let ink = Color(red: 0.114, green: 0.114, blue: 0.126)
    private let accent = Color(red: 0.039, green: 0.518, blue: 1.0)

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 26)

            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(accent.opacity(0.12))
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(accent)
            }
            .frame(width: 62, height: 62)

            Text(L10n.text(.permissionTitle, language: model.language))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(ink)
                .padding(.top, 16)

            Text(L10n.text(.permissionDescription, language: model.language))
                .font(.system(size: 13))
                .foregroundStyle(ink.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 16) {
                StepRow(index: 1, accent: accent) {
                    Text(L10n.text(.permissionStepOpen, language: model.language))
                        .foregroundColor(ink.opacity(0.78))
                }
                StepRow(index: 2, accent: accent) {
                    Text(L10n.text(.permissionStepEnable, language: model.language))
                        .foregroundColor(ink.opacity(0.78))
                }
            }
            .font(.system(size: 13))
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.07), lineWidth: 1)
            )
            .padding(.top, 22)

            Text(L10n.text(.permissionMissingHint, language: model.language))
                .font(.system(size: 11))
                .foregroundStyle(ink.opacity(0.38))
                .padding(.top, 10)

            Button {
                model.openAccessibilityHelp()
            } label: {
                Text(L10n.text(.openAccessibilitySettings, language: model.language))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 220, height: 44)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.219, green: 0.596, blue: 1.0),
                                    Color(red: 0.0, green: 0.435, blue: 0.949)
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                    )
                    .shadow(color: accent.opacity(0.30), radius: 12, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.top, 20)

            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text(L10n.text(.permissionWaiting, language: model.language))
                    .font(.system(size: 12))
                    .foregroundStyle(ink.opacity(0.45))
            }
            .padding(.top, 16)

            Button(L10n.text(.back, language: model.language)) {
                model.dismissPermissionCoach()
            }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(ink.opacity(0.40))
                .padding(.top, 10)

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 40)
    }
}

private struct StepRow<Content: View>: View {
    let index: Int
    let accent: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(accent))
            content()
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}
