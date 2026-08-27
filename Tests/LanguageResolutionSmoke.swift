import Foundation

@main
enum LanguageResolutionSmoke {
    static func main() {
        expect(nil, ["zh-Hans-CN"], .simplifiedChinese)
        expect(nil, ["zh_CN"], .simplifiedChinese)
        expect(nil, ["zh-Hant-TW"], .traditionalChinese)
        expect(nil, ["zh_TW"], .traditionalChinese)
        expect(nil, ["en-GB"], .english)
        expect(nil, ["ja-JP"], .japanese)
        expect(nil, ["ko-KR"], .korean)
        expect(nil, ["es-419"], .spanish)
        expect(nil, ["de-DE"], .english)
        expect("es", ["ja-JP"], .spanish)
        expect("invalid", ["ja-JP"], .japanese)
        print("Language resolution checks passed.")
    }

    private static func expect(
        _ storedValue: String?,
        _ preferredLanguages: [String],
        _ expected: AppLanguage
    ) {
        let actual = AppLanguage.initialLanguage(
            storedValue: storedValue,
            preferredLanguages: preferredLanguages
        )
        precondition(
            actual == expected,
            "Expected \(expected.rawValue), got \(actual.rawValue)"
        )
    }
}
