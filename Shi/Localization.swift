import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case english = "en"
    case japanese = "ja"
    case korean = "ko"
    case spanish = "es"

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .simplifiedChinese: "简体中文"
        case .traditionalChinese: "繁體中文"
        case .english: "English"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .spanish: "Español"
        }
    }

    static func systemDefault(from preferredLanguages: [String]) -> AppLanguage {
        guard let identifier = preferredLanguages.first else { return .english }
        let components = identifier
            .replacingOccurrences(of: "_", with: "-")
            .split(separator: "-")
            .map { $0.lowercased() }

        guard let languageCode = components.first else { return .english }
        switch languageCode {
        case "zh":
            if components.contains("hant")
                || components.contains("tw")
                || components.contains("hk")
                || components.contains("mo") {
                return .traditionalChinese
            }
            return .simplifiedChinese
        case "en": return .english
        case "ja": return .japanese
        case "ko": return .korean
        case "es": return .spanish
        default: return .english
        }
    }

    /// Uses an explicit in-app choice when one exists. Otherwise the app starts
    /// in the first language selected in macOS, falling back to English when the
    /// system language is not supported.
    static func initialLanguage(
        storedValue: String?,
        preferredLanguages: [String]
    ) -> AppLanguage {
        storedValue
            .flatMap(AppLanguage.init(rawValue:))
            ?? systemDefault(from: preferredLanguages)
    }
}

enum L10n {
    enum Key {
        case appName
        case tagline
        case startCleaning
        case exitHintShort
        case skinWipe
        case skinWhite
        case skinNight
        case inputPaused
        case cleaning
        case exitHint
        case permissionTitle
        case permissionDescription
        case permissionStepOpen
        case permissionStepEnable
        case permissionMissingHint
        case openAccessibilitySettings
        case permissionWaiting
        case back
        case tapCreateFailed
        case tapInterrupted
        case appearance
        case exitHold
        case lockPointer
        case maxCleaning
        case settingsDescription
        case securityWarning
        case language
        case updates
        case currentVersion
        case appUpdates
        case automaticUpdateHint
        case debugBuildUpdateHint
        case checkForUpdates
        case checkingForUpdates
        case upToDate
        case updateCheckFailed
        case off
    }

    static func text(_ key: Key, language: AppLanguage) -> String {
        switch language {
        case .simplifiedChinese: simplifiedChinese(key)
        case .traditionalChinese: traditionalChinese(key)
        case .english: english(key)
        case .japanese: japanese(key)
        case .korean: korean(key)
        case .spanish: spanish(key)
        }
    }

    static func seconds(_ value: Double, language: AppLanguage) -> String {
        let number = String(format: "%.1f", value)
        return switch language {
        case .simplifiedChinese, .traditionalChinese: "\(number) 秒"
        case .english: "\(number) sec"
        case .japanese: "\(number) 秒"
        case .korean: "\(number)초"
        case .spanish: "\(number) s"
        }
    }

    static func minutes(_ value: Int, language: AppLanguage) -> String {
        switch language {
        case .simplifiedChinese: "\(value) 分钟"
        case .traditionalChinese: "\(value) 分鐘"
        case .english: value == 1 ? "1 minute" : "\(value) minutes"
        case .japanese: "\(value) 分"
        case .korean: "\(value)분"
        case .spanish: value == 1 ? "1 minuto" : "\(value) minutos"
        }
    }

    static func updateAvailableStatus(version: String, language: AppLanguage) -> String {
        switch language {
        case .simplifiedChinese: "发现新版本 \(version)"
        case .traditionalChinese: "發現新版本 \(version)"
        case .english: "Version \(version) is available"
        case .japanese: "バージョン \(version) を利用できます"
        case .korean: "버전 \(version) 사용 가능"
        case .spanish: "La versión \(version) está disponible"
        }
    }

    private static func simplifiedChinese(_ key: Key) -> String {
        switch key {
        case .appName: "拭"
        case .tagline: "挡住键盘，擦干净再回来"
        case .startCleaning: "开始清洁"
        case .exitHintShort: "按住两个 Shift 退出"
        case .skinWipe: "拭镜"
        case .skinWhite: "白屏"
        case .skinNight: "夜钟"
        case .inputPaused: "输入已暂停，可以擦键盘和屏幕"
        case .cleaning: "清洁中"
        case .exitHint: "同时按住两个 Shift 退出"
        case .permissionTitle: "开启辅助功能权限"
        case .permissionDescription: "拭需要辅助功能权限，才能在清洁时拦截键盘和触控板，避免误触。"
        case .permissionStepOpen: "打开“系统设置 › 隐私与安全性 › 辅助功能”"
        case .permissionStepEnable: "在列表里找到“拭”，打开右侧开关"
        case .permissionMissingHint: "若列表中没有“拭”，点列表下方的 + 号添加即可"
        case .openAccessibilitySettings: "打开辅助功能设置"
        case .permissionWaiting: "完成授权后将自动开始清洁"
        case .back: "返回"
        case .tapCreateFailed: "无法拦截输入，请在“辅助功能”中重新勾选“拭”。"
        case .tapInterrupted: "输入拦截被系统中断，已退出清洁模式。"
        case .appearance: "画面"
        case .exitHold: "退出按住"
        case .lockPointer: "同时挡住触控板和鼠标点击"
        case .maxCleaning: "最长清洁"
        case .settingsDescription: "开始清洁后，键盘、触控栏和鼠标点击会被暂时挡住，屏幕亮度也会降低。同时按住两个 Shift 退出清洁模式；只有一个 Shift 时，按住 Shift + Esc。"
        case .securityWarning: "无法拦截电源键和 Touch ID。离开座位请使用系统锁屏。"
        case .language: "语言"
        case .updates: "更新"
        case .currentVersion: "当前版本"
        case .appUpdates: "软件更新"
        case .automaticUpdateHint: "启动时检查，此后每 6 小时检查一次"
        case .debugBuildUpdateHint: "调试版本不检查更新"
        case .checkForUpdates: "检查更新"
        case .checkingForUpdates: "正在检查更新…"
        case .upToDate: "已是最新版本"
        case .updateCheckFailed: "暂时无法检查更新"
        case .off: "关闭"
        }
    }

    private static func traditionalChinese(_ key: Key) -> String {
        switch key {
        case .appName: "拭"
        case .tagline: "擋住鍵盤，擦乾淨再回來"
        case .startCleaning: "開始清潔"
        case .exitHintShort: "按住兩個 Shift 離開"
        case .skinWipe: "拭鏡"
        case .skinWhite: "白屏"
        case .skinNight: "夜鐘"
        case .inputPaused: "輸入已暫停，可以擦拭鍵盤和螢幕"
        case .cleaning: "清潔中"
        case .exitHint: "同時按住兩個 Shift 離開"
        case .permissionTitle: "開啟輔助使用權限"
        case .permissionDescription: "拭需要輔助使用權限，才能在清潔時攔截鍵盤和觸控板，避免誤觸。"
        case .permissionStepOpen: "開啟「系統設定 › 隱私權與安全性 › 輔助使用」"
        case .permissionStepEnable: "在列表中找到「拭」，開啟右側開關"
        case .permissionMissingHint: "若列表中沒有「拭」，請按下方的 + 加入"
        case .openAccessibilitySettings: "開啟輔助使用設定"
        case .permissionWaiting: "完成授權後會自動開始清潔"
        case .back: "返回"
        case .tapCreateFailed: "無法攔截輸入，請在「輔助使用」中重新勾選「拭」。"
        case .tapInterrupted: "輸入攔截被系統中斷，已離開清潔模式。"
        case .appearance: "畫面"
        case .exitHold: "按住多久離開"
        case .lockPointer: "同時擋住觸控板和滑鼠點擊"
        case .maxCleaning: "最長清潔"
        case .settingsDescription: "開始清潔後，鍵盤、觸控列和滑鼠點擊會暫時被擋住，螢幕亮度也會降低。同時按住兩個 Shift 離開清潔模式；只有一個 Shift 時，按住 Shift + Esc。"
        case .securityWarning: "無法攔截電源鍵和 Touch ID。離開座位請使用系統鎖定畫面。"
        case .language: "語言"
        case .updates: "更新"
        case .currentVersion: "目前版本"
        case .appUpdates: "軟體更新"
        case .automaticUpdateHint: "啟動時檢查，之後每 6 小時檢查一次"
        case .debugBuildUpdateHint: "除錯版本不檢查更新"
        case .checkForUpdates: "檢查更新"
        case .checkingForUpdates: "正在檢查更新…"
        case .upToDate: "已是最新版本"
        case .updateCheckFailed: "暫時無法檢查更新"
        case .off: "關閉"
        }
    }

    private static func english(_ key: Key) -> String {
        switch key {
        case .appName: "Shi"
        case .tagline: "Block input, clean up, then come right back"
        case .startCleaning: "Start Cleaning"
        case .exitHintShort: "Hold both Shift keys to exit"
        case .skinWipe: "Wipe"
        case .skinWhite: "White"
        case .skinNight: "Night Clock"
        case .inputPaused: "Input is paused — clean your keyboard and screen"
        case .cleaning: "CLEANING"
        case .exitHint: "Hold both Shift keys to exit"
        case .permissionTitle: "Enable Accessibility Access"
        case .permissionDescription: "Shi needs Accessibility access to block keyboard and trackpad input while you clean."
        case .permissionStepOpen: "Open System Settings › Privacy & Security › Accessibility"
        case .permissionStepEnable: "Find Shi in the list and turn on its switch"
        case .permissionMissingHint: "If Shi is missing, use the + button below the list to add it"
        case .openAccessibilitySettings: "Open Accessibility Settings"
        case .permissionWaiting: "Cleaning will start automatically after access is granted"
        case .back: "Back"
        case .tapCreateFailed: "Input could not be blocked. Re-enable Shi in Accessibility settings."
        case .tapInterrupted: "macOS interrupted input blocking, so cleaning mode was stopped."
        case .appearance: "Appearance"
        case .exitHold: "Exit Hold"
        case .lockPointer: "Also block trackpad and mouse clicks"
        case .maxCleaning: "Maximum Cleaning Time"
        case .settingsDescription: "Cleaning mode temporarily blocks the keyboard, Touch Bar, and pointer clicks, and dims the display. Hold both Shift keys to exit cleaning mode; with one Shift key, hold Shift + Esc."
        case .securityWarning: "The power button and Touch ID cannot be blocked. Use the macOS lock screen when you step away."
        case .language: "Language"
        case .updates: "Updates"
        case .currentVersion: "Current Version"
        case .appUpdates: "Software Updates"
        case .automaticUpdateHint: "Checks at launch and every 6 hours afterward"
        case .debugBuildUpdateHint: "Update checks are disabled in debug builds"
        case .checkForUpdates: "Check for Updates"
        case .checkingForUpdates: "Checking for updates…"
        case .upToDate: "Shi is up to date"
        case .updateCheckFailed: "Could not check for updates"
        case .off: "Off"
        }
    }

    private static func japanese(_ key: Key) -> String {
        switch key {
        case .appName: "拭"
        case .tagline: "入力を止めて、きれいに拭いてから戻りましょう"
        case .startCleaning: "クリーニング開始"
        case .exitHintShort: "左右の Shift を長押しして終了"
        case .skinWipe: "ワイプ"
        case .skinWhite: "ホワイト"
        case .skinNight: "ナイトクロック"
        case .inputPaused: "入力を一時停止しました。キーボードと画面を清掃できます"
        case .cleaning: "清掃中"
        case .exitHint: "左右の Shift を同時に長押しして終了"
        case .permissionTitle: "アクセシビリティを許可"
        case .permissionDescription: "清掃中の誤操作を防ぐため、拭にはキーボードとトラックパッドの入力を遮断する権限が必要です。"
        case .permissionStepOpen: "「システム設定 › プライバシーとセキュリティ › アクセシビリティ」を開きます"
        case .permissionStepEnable: "一覧で「拭」を見つけ、右側のスイッチをオンにします"
        case .permissionMissingHint: "一覧に「拭」がない場合は、下の + ボタンで追加してください"
        case .openAccessibilitySettings: "アクセシビリティ設定を開く"
        case .permissionWaiting: "許可すると自動的にクリーニングを開始します"
        case .back: "戻る"
        case .tapCreateFailed: "入力を遮断できません。「アクセシビリティ」で「拭」を再度有効にしてください。"
        case .tapInterrupted: "macOS により入力の遮断が中断されたため、クリーニングモードを終了しました。"
        case .appearance: "画面"
        case .exitHold: "終了の長押し"
        case .lockPointer: "トラックパッドとマウスのクリックも遮断"
        case .maxCleaning: "最長清掃時間"
        case .settingsDescription: "清掃中はキーボード、Touch Bar、ポインターのクリックを一時的に遮断し、画面を暗くします。左右の Shift を同時に長押しして終了します。Shift が 1 つだけの場合は Shift + Esc を長押しします。"
        case .securityWarning: "電源ボタンと Touch ID は遮断できません。席を離れるときは macOS の画面ロックを使用してください。"
        case .language: "言語"
        case .updates: "アップデート"
        case .currentVersion: "現在のバージョン"
        case .appUpdates: "ソフトウェアアップデート"
        case .automaticUpdateHint: "起動時と、その後 6 時間ごとに確認します"
        case .debugBuildUpdateHint: "デバッグ版ではアップデートを確認しません"
        case .checkForUpdates: "アップデートを確認"
        case .checkingForUpdates: "アップデートを確認中…"
        case .upToDate: "最新バージョンです"
        case .updateCheckFailed: "アップデートを確認できません"
        case .off: "オフ"
        }
    }

    private static func korean(_ key: Key) -> String {
        switch key {
        case .appName: "拭"
        case .tagline: "입력을 막고 깨끗이 닦은 뒤 돌아오세요"
        case .startCleaning: "청소 시작"
        case .exitHintShort: "양쪽 Shift를 길게 눌러 종료"
        case .skinWipe: "닦기"
        case .skinWhite: "화이트"
        case .skinNight: "야간 시계"
        case .inputPaused: "입력이 일시 중지되었습니다. 키보드와 화면을 닦으세요"
        case .cleaning: "청소 중"
        case .exitHint: "양쪽 Shift를 동시에 길게 눌러 종료"
        case .permissionTitle: "손쉬운 사용 권한 켜기"
        case .permissionDescription: "청소 중 오작동을 막기 위해 拭에 키보드와 트랙패드 입력을 차단할 권한이 필요합니다."
        case .permissionStepOpen: "시스템 설정 › 개인정보 보호 및 보안 › 손쉬운 사용을 엽니다"
        case .permissionStepEnable: "목록에서 拭을 찾아 오른쪽 스위치를 켭니다"
        case .permissionMissingHint: "목록에 拭이 없으면 아래의 + 버튼으로 추가하세요"
        case .openAccessibilitySettings: "손쉬운 사용 설정 열기"
        case .permissionWaiting: "권한을 허용하면 청소가 자동으로 시작됩니다"
        case .back: "뒤로"
        case .tapCreateFailed: "입력을 차단할 수 없습니다. 손쉬운 사용 설정에서 拭을 다시 켜세요."
        case .tapInterrupted: "macOS가 입력 차단을 중단하여 청소 모드를 종료했습니다."
        case .appearance: "화면"
        case .exitHold: "종료 길게 누르기"
        case .lockPointer: "트랙패드와 마우스 클릭도 차단"
        case .maxCleaning: "최대 청소 시간"
        case .settingsDescription: "청소 모드에서는 키보드, Touch Bar, 포인터 클릭을 잠시 차단하고 화면 밝기를 낮춥니다. 양쪽 Shift를 길게 눌러 청소 모드를 종료하세요. Shift 키가 하나뿐이면 Shift + Esc를 길게 누르세요."
        case .securityWarning: "전원 버튼과 Touch ID는 차단할 수 없습니다. 자리를 비울 때는 macOS 화면 잠금을 사용하세요."
        case .language: "언어"
        case .updates: "업데이트"
        case .currentVersion: "현재 버전"
        case .appUpdates: "소프트웨어 업데이트"
        case .automaticUpdateHint: "실행 시 확인하고 이후 6시간마다 확인합니다"
        case .debugBuildUpdateHint: "디버그 빌드에서는 업데이트를 확인하지 않습니다"
        case .checkForUpdates: "업데이트 확인"
        case .checkingForUpdates: "업데이트 확인 중…"
        case .upToDate: "최신 버전입니다"
        case .updateCheckFailed: "업데이트를 확인할 수 없습니다"
        case .off: "끔"
        }
    }

    private static func spanish(_ key: Key) -> String {
        switch key {
        case .appName: "Shi"
        case .tagline: "Bloquea la entrada, limpia y vuelve cuando termines"
        case .startCleaning: "Empezar a limpiar"
        case .exitHintShort: "Mantén pulsadas ambas teclas Shift para salir"
        case .skinWipe: "Barrido"
        case .skinWhite: "Blanco"
        case .skinNight: "Reloj nocturno"
        case .inputPaused: "La entrada está en pausa; limpia el teclado y la pantalla"
        case .cleaning: "LIMPIANDO"
        case .exitHint: "Mantén pulsadas ambas teclas Shift para salir"
        case .permissionTitle: "Activa Accesibilidad"
        case .permissionDescription: "Shi necesita acceso a Accesibilidad para bloquear el teclado y el trackpad mientras limpias."
        case .permissionStepOpen: "Abre Ajustes del Sistema › Privacidad y seguridad › Accesibilidad"
        case .permissionStepEnable: "Busca Shi en la lista y activa su interruptor"
        case .permissionMissingHint: "Si Shi no aparece, añádelo con el botón + situado bajo la lista"
        case .openAccessibilitySettings: "Abrir ajustes de Accesibilidad"
        case .permissionWaiting: "La limpieza comenzará automáticamente al conceder el acceso"
        case .back: "Volver"
        case .tapCreateFailed: "No se pudo bloquear la entrada. Vuelve a activar Shi en Accesibilidad."
        case .tapInterrupted: "macOS interrumpió el bloqueo de entrada y se detuvo el modo de limpieza."
        case .appearance: "Apariencia"
        case .exitHold: "Pulsación para salir"
        case .lockPointer: "Bloquear también los clics del trackpad y el ratón"
        case .maxCleaning: "Tiempo máximo de limpieza"
        case .settingsDescription: "El modo de limpieza bloquea temporalmente el teclado, la Touch Bar y los clics del puntero, y atenúa la pantalla. Mantén pulsadas ambas teclas Shift para salir; con una sola tecla Shift, mantén pulsado Shift + Esc."
        case .securityWarning: "El botón de encendido y Touch ID no se pueden bloquear. Usa la pantalla de bloqueo de macOS cuando te ausentes."
        case .language: "Idioma"
        case .updates: "Actualizaciones"
        case .currentVersion: "Versión actual"
        case .appUpdates: "Actualizaciones de software"
        case .automaticUpdateHint: "Comprueba al iniciar y después cada 6 horas"
        case .debugBuildUpdateHint: "Las actualizaciones están desactivadas en la versión de depuración"
        case .checkForUpdates: "Buscar actualizaciones"
        case .checkingForUpdates: "Buscando actualizaciones…"
        case .upToDate: "Shi está actualizado"
        case .updateCheckFailed: "No se pudieron buscar actualizaciones"
        case .off: "Desactivado"
        }
    }
}
