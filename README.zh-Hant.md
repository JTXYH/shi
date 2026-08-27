# 拭（Shi）

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

拭是一款 macOS 鍵盤與螢幕清潔輔助工具。進入清潔模式後，它會暫時攔截鍵盤輸入和滑鼠點擊、降低顯示器亮度，並提供明確的離開快捷鍵，避免清潔過程中誤操作。

## 截圖

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="拭的主介面" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="拭鏡清潔模式" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="白屏清潔模式" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="夜鐘清潔模式" width="31%">
</p>

<p align="center"><sub>拭鏡 · 白屏 · 夜鐘</sub></p>

## 功能

- 六種介面語言：簡體中文、繁體中文、English、日本語、한국어、Español
- 首次啟動自動使用 macOS 首選語言；在設定中手動選擇後會保留用戶選擇
- 三種清潔畫面：拭鏡、白屏、夜鐘
- 同時按住左右 Shift，或按住 Shift + Esc，安全離開清潔模式
- 可設定離開長按時間、最長清潔時間與滑鼠點擊遮擋
- 使用 Sparkle 2 檢查與安裝簽名更新
- Universal 2 建置，支援 Apple Silicon 與 Intel Mac

## 系統需求

- macOS 14 或更新版本
- 清潔模式需要「系統設定 › 隱私權與安全性 › 輔助使用」權限

輔助使用權限只用於在清潔模式期間遮擋輸入。應用程式不會記錄按鍵內容，也不會上傳使用資料。除了通過 HTTPS 檢查軟體更新外，不發出網路請求。

## 下載

[⬇️ 前往 GitHub Releases 下載最新版本](https://github.com/JTXYH/shi/releases/latest)

下載 ZIP 後解壓縮，將 `Shi.app` 拖入「應用程式」資料夾。

### 首次開啟時被 macOS 阻擋

目前安裝包使用 ad-hoc 簽章，尚未經過 Apple 公證。若首次啟動時顯示「Apple 無法檢查 App 是否包含惡意軟體」或「無法驗證開發者」，請先確認 App 下載自本倉庫的 [GitHub Releases](https://github.com/JTXYH/shi/releases)，再使用以下任一方式：

1. 在 Finder 中開啟「應用程式」，右鍵點擊 `Shi.app`，選擇「開啟」，並在確認視窗中再次點擊「開啟」。
2. 或先嘗試啟動一次，再前往「系統設定 › 隱私權與安全性」，在安全性區域點擊「仍要開啟」。

請勿關閉 Gatekeeper，也不要執行來源不明的終端機指令來繞過系統保護。若 macOS 明確提示 App 包含惡意軟體，請刪除檔案並重新從官方 Release 下載。

首次允許後，Sparkle 會使用 Ed25519 簽章驗證並安裝後續更新。由於 ad-hoc 簽章沒有穩定的 Team ID，更新後 macOS 可能要求重新開啟輔助使用權限。

## 從原始碼建置

需要 Xcode 16 或更新版本。專案固定使用 Sparkle 2.9.2；Xcode 會在首次建置時解析 Swift Package 相依項目。

```sh
./scripts/build-app.sh debug
```

建置產物位於 `dist/Shi.app`。預設使用 ad-hoc 簽章，並重新簽署主應用程式與 Sparkle 的所有內嵌可執行元件。

## 發佈

目前的發佈方式與 Codex Meter 相同：使用 ad-hoc 程式碼簽章，並以 Sparkle Ed25519 簽署更新包與 appcast。發佈腳本會建置 Universal 2 App、驗證內嵌簽章並產生 ZIP、SHA-256 與 appcast。

```sh
./scripts/package-release.sh
```

建立 GitHub Release `vX.Y.Z`，上傳腳本產生的 ZIP、SHA-256 與 `appcast.xml`。日後若取得 Developer ID，可透過環境變數啟用正式簽章與 Apple 公證。

完整流程請參閱 [docs/releasing.md](docs/releasing.md)。

## 安全設計

- 目前公開包使用 ad-hoc 簽章且未經 Apple 公證，因此首次開啟會顯示 Gatekeeper 提示。
- Sparkle 更新來源只使用 HTTPS，並要求已簽名的 appcast 與 Ed25519 安裝檔簽名。
- 應用不啟用 App Sandbox，因為全域輸入遮擋需要沙盒外的輔助使用權限。
- 診斷記錄使用 macOS Unified Logging，不寫入可預測的 `/tmp` 檔案。
- 部分機型的亮度調整會回退至 Apple 未公開的 DisplayServices 介面，需在目標 macOS 版本進行回歸測試。

安全問題請參閱 [SECURITY.md](SECURITY.md)。

## 授權

[MIT](LICENSE)
