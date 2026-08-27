import SwiftUI

enum Skin: String, CaseIterable, Identifiable {
    case wipe
    case white
    case night

    var id: String { rawValue }

    func label(language: AppLanguage) -> String {
        switch self {
        case .wipe: L10n.text(.skinWipe, language: language)
        case .white: L10n.text(.skinWhite, language: language)
        case .night: L10n.text(.skinNight, language: language)
        }
    }

    var background: Color {
        switch self {
        case .wipe: return Color(red: 0.07, green: 0.078, blue: 0.098)
        case .white: return Color(red: 0.955, green: 0.945, blue: 0.925)
        case .night: return Color(red: 0.048, green: 0.052, blue: 0.068)
        }
    }

    var foreground: Color {
        switch self {
        case .white: return Color(red: 0.22, green: 0.23, blue: 0.28)
        case .wipe, .night: return Color(red: 0.92, green: 0.93, blue: 0.95)
        }
    }

    var elapsedSize: CGFloat {
        self == .night ? 72 : 64
    }
}

enum MaxCleanMinutes: Int, CaseIterable, Identifiable {
    case off = 0
    case five = 5
    case ten = 10

    var id: Int { rawValue }

    func label(language: AppLanguage) -> String {
        self == .off
            ? L10n.text(.off, language: language)
            : L10n.minutes(rawValue, language: language)
    }
}
