import AppKit
import SwiftUI

struct SettingsView: View {
    @Bindable var model: AppModel
    @ObservedObject private var updateController = UpdateController.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .shadow(color: Color.black.opacity(0.08), radius: 3, y: 1)
                    Text(L10n.text(.appName, language: model.language))
                        .font(.system(size: 22, weight: .regular))
                }

                LabeledContent(L10n.text(.language, language: model.language)) {
                    Picker("", selection: $model.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.nativeName).tag(language)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(width: 220)
                }

                LabeledContent(L10n.text(.appearance, language: model.language)) {
                    Picker("", selection: $model.skin) {
                        ForEach(Skin.allCases) { skin in
                            Text(skin.label(language: model.language)).tag(skin)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 280)
                }

                LabeledContent(L10n.text(.exitHold, language: model.language)) {
                    Picker("", selection: $model.holdDuration) {
                        ForEach([1.0, 1.5, 2.0], id: \.self) { duration in
                            Text(L10n.seconds(duration, language: model.language)).tag(duration)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 280)
                }

                Toggle(
                    L10n.text(.lockPointer, language: model.language),
                    isOn: $model.lockPointer
                )

                LabeledContent(L10n.text(.maxCleaning, language: model.language)) {
                    Picker("", selection: $model.maxMinutes) {
                        ForEach(MaxCleanMinutes.allCases) { item in
                            Text(item.label(language: model.language)).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 280)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.text(.settingsDescription, language: model.language))
                    Text(L10n.text(.securityWarning, language: model.language))
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                Divider()

                VStack(alignment: .leading, spacing: 14) {
                    Text(L10n.text(.updates, language: model.language))
                        .font(.system(size: 15, weight: .semibold))

                    LabeledContent(L10n.text(.currentVersion, language: model.language)) {
                        Text(updateController.currentVersion)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    }

                    LabeledContent(L10n.text(.appUpdates, language: model.language)) {
                        Button {
                            updateController.checkManually()
                        } label: {
                            if updateController.state == .checking {
                                ProgressView()
                                    .controlSize(.small)
                                    .frame(width: 140)
                            } else {
                                Text(L10n.text(.checkForUpdates, language: model.language))
                                    .frame(width: 140)
                            }
                        }
                        .disabled(
                            updateController.state == .checking
                                || !updateController.isUpdateCheckingEnabled
                        )
                    }

                    Text(updateStatusText)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack {
                    Spacer()
                    Button(L10n.text(.startCleaning, language: model.language)) {
                        model.startCleaning()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.isCleaning)
                }
            }
            .padding(28)
        }
        .frame(width: 520, height: 640)
        .preferredColorScheme(.light)
    }

    private var updateStatusText: String {
        guard updateController.isUpdateCheckingEnabled else {
            return L10n.text(.debugBuildUpdateHint, language: model.language)
        }

        switch updateController.state {
        case .idle:
            return L10n.text(.automaticUpdateHint, language: model.language)
        case .checking:
            return L10n.text(.checkingForUpdates, language: model.language)
        case .upToDate:
            return L10n.text(.upToDate, language: model.language)
        case let .available(version):
            return L10n.updateAvailableStatus(version: version, language: model.language)
        case .failed:
            return L10n.text(.updateCheckFailed, language: model.language)
        }
    }
}
