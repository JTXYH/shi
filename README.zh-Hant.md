# 拭（Shi）

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

拭是一款免費、開源的 macOS 鍵盤與螢幕清潔輔助工具。進入清潔模式後，它會暫時攔截鍵盤輸入，預設阻擋觸控板和滑鼠點擊，並讓螢幕變暗，減少擦拭時的誤操作。清潔完成後，按住離開組合鍵即可恢復使用。

[下載最新版本](https://github.com/JTXYH/shi/releases/latest) · [回報問題](https://github.com/JTXYH/shi/issues) · [MIT 授權條款](LICENSE)

## 功能

- **清潔時暫停輸入**：攔截鍵盤輸入，可選擇是否同時阻擋觸控板和滑鼠點擊。
- **三種清潔畫面**：拭鏡、白屏、夜鐘，支援在多個顯示器上顯示清潔畫面。
- **螢幕變暗與恢復**：清潔時調暗顯示器，離開後恢復；實際效果取決於顯示器和 macOS 的支援情況。
- **快速開始與離開**：應用程式執行時，按 `Control + Option + Command + C` 開始；按住左右兩個 `Shift`，或 `Shift + Esc` 離開。
- **可調整的清潔時間**：設定離開所需的長按時間和自動結束時間，避免清潔模式一直保持開啟。
- **六種介面語言**：簡體中文、繁體中文、English、日本語、한국어、Español。
- **應用程式內更新**：透過 Sparkle 檢查更新，並驗證更新簽章。

## 截圖

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="拭的主介面" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="拭鏡清潔畫面" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="白屏清潔畫面" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="夜鐘清潔畫面" width="31%">
</p>

<p align="center"><sub>拭鏡 · 白屏 · 夜鐘</sub></p>

## 系統需求

- macOS 14 Sonoma 或更新版本。
- Apple Silicon 或 Intel Mac，建置產物為 Universal 2 應用程式。
- 清潔模式需要 macOS「輔助使用」權限。

## 安裝

1. 從 [GitHub Releases](https://github.com/JTXYH/shi/releases/latest) 下載應用程式 ZIP 壓縮檔。
2. 解壓縮後，將 `Shi.app` 移至「應用程式」資料夾。
3. 開啟應用程式，按照下方說明開始使用。

目前預設採用 ad-hoc 簽章發佈，未經過 Apple 公證。若首次啟動時提示無法驗證開發者或無法檢查惡意軟體，請先確認檔案來自本儲存庫且未遭竄改，再依照 [Apple 的開啟說明](https://support.apple.com/en-us/102445) 操作。請勿忽略 macOS 明確偵測到惡意軟體的提示。

## 使用方式

1. 開啟拭，選擇喜歡的清潔畫面，按下「開始清潔」。應用程式執行時也可使用 `Control + Option + Command + C`。
2. 首次使用時，依照引導前往「系統設定 › 隱私權與安全性 › 輔助使用」，為拭開啟權限。如果列表中沒有拭，可使用 `+` 加入 `Shi.app`。**完成授權後會自動開始清潔。**
3. 清潔完成後，同時按住左右兩個 `Shift`，或按住 `Shift + Esc`。預設持續 **1.5 秒**即可離開，恢復輸入和螢幕亮度。

可在設定中調整：

| 設定 | 預設值 | 可選值 |
| --- | --- | --- |
| 離開所需長按時間 | 1.5 秒 | 1 秒、1.5 秒、2 秒 |
| 最長清潔時間 | 10 分鐘 | 5 分鐘、10 分鐘、關閉自動結束 |
| 阻擋觸控板和滑鼠點擊 | 開啟 | 開啟或關閉 |

首次啟動會依據 macOS 的首選語言選擇介面語言；不支援該語言時使用英語。手動選擇的語言會儲存在本機。

電源鍵和 Touch ID 無法被攔截。離開電腦時請使用 macOS 系統鎖定畫面。

## 權限、隱私與更新

- 輔助使用權限用於在清潔模式期間攔截鍵盤輸入；應用程式不記錄按鍵內容，不收集使用統計，偏好設定儲存在本機。
- 清潔功能可以離線使用，無需註冊帳號。檢查更新和下載更新套件需要網路連線。
- 正式建置透過 HTTPS 取得更新資訊，並使用 Sparkle 的 Ed25519 簽章驗證 appcast 和更新套件。可在設定中手動檢查更新；除錯建置停用更新檢查。
- 採用 ad-hoc 簽章的應用程式更新或重新建置後，macOS 可能要求重新授予輔助使用權限。如果無法開始清潔，請在輔助使用列表中重新啟用拭。

安全漏洞請依照 [安全政策](SECURITY.md) 私下回報。

## 從原始碼建置

開發環境需要 macOS 和 Xcode 16 或更新版本，並將命令列工具指向該 Xcode。專案使用 Swift、SwiftUI 和 AppKit，透過 Swift Package Manager 引入 [Sparkle](https://github.com/sparkle-project/Sparkle)，目前鎖定版本為 2.9.2。首次建置需要連線下載相依套件。

```sh
git clone https://github.com/JTXYH/shi.git
cd shi
./scripts/build-app.sh debug
open dist/Shi.app
```

腳本會建置同時包含 `arm64` 和 `x86_64` 的 `dist/Shi.app`，預設使用 ad-hoc 簽章，本機建置無需 Developer ID 憑證。也可以在 Xcode 中開啟 `Shi.xcodeproj`，選擇 `Shi` scheme 進行開發和除錯。

在儲存庫根目錄執行現有的語言選擇檢查：

```sh
./scripts/test-language-selection.sh
```

此檢查涵蓋系統語言辨識和已儲存語言的優先順序，不能取代在實際 Mac 上進行的清潔、權限與顯示器測試。

## 參與貢獻

歡迎透過 [Issues](https://github.com/JTXYH/shi/issues) 和 [Pull Requests](https://github.com/JTXYH/shi/pulls) 提交問題、改進和翻譯。

- 回報問題時，請提供應用程式版本、macOS 版本、Mac 型號、重現步驟和預期結果；顯示問題請補充顯示器配置。
- 提交變更時，請說明修改原因和驗證方式。介面變更請附截圖；輸入攔截、離開或亮度相關變更請在實際 Mac 上驗證。
- 修改功能說明或翻譯時，請同步六份 README；應用程式內文案位於 [Shi/Localization.swift](Shi/Localization.swift)。

## 授權條款

本專案由 [JTXYH](https://github.com/JTXYH) 維護，採用 [MIT 授權條款](LICENSE)。第三方相依套件遵循各自的授權條款。
