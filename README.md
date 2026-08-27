# 拭（Shi）

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

拭是一款 macOS 键盘与屏幕清洁辅助工具。进入清洁模式后，它会临时拦截键盘输入和鼠标点击、降低显示器亮度，并提供一个明确的退出组合键，避免清洁过程中发生误操作。

## 截图

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="拭的主界面" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="拭镜清洁模式" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="白屏清洁模式" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="夜钟清洁模式" width="31%">
</p>

<p align="center"><sub>拭镜 · 白屏 · 夜钟</sub></p>

## 功能

- 六种界面语言：简体中文、繁體中文、English、日本語、한국어、Español
- 首次启动自动使用 macOS 首选语言；在设置中手动选择后保留用户选择
- 三种清洁画面：拭镜、白屏、夜钟
- 同时按住左右 Shift，或按住 Shift + Esc，安全退出清洁模式
- 可配置退出长按时间、最长清洁时间和鼠标点击拦截
- 使用 Sparkle 2 检查和安装签名更新
- Universal 2 构建，同时支持 Apple Silicon 与 Intel Mac

## 系统要求

- macOS 14 或更高版本
- 清洁模式需要“系统设置 › 隐私与安全性 › 辅助功能”权限

辅助功能权限仅用于在清洁模式期间拦截输入。应用不会记录按键内容，也不会上传使用数据。除通过 HTTPS 检查软件更新外，应用不发起网络请求。

## 下载

[⬇️ 前往 GitHub Releases 下载最新版](https://github.com/JTXYH/shi/releases/latest)

下载 ZIP 后解压，将 `Shi.app` 拖入“应用程序”目录。

### 首次打开时被 macOS 拦截

当前安装包使用 ad-hoc 签名，尚未经过 Apple 公证。如果首次启动时出现“Apple 无法检查是否包含恶意软件”或“无法验证开发者”，请先确认应用下载自本仓库的 [GitHub Releases](https://github.com/JTXYH/shi/releases)，然后使用以下任一方法：

1. 在 Finder 中进入“应用程序”，右键点击 `Shi.app`，选择“打开”，然后在确认窗口中再次点击“打开”。
2. 或先尝试启动一次，再进入“系统设置 › 隐私与安全性”，在安全性区域点击“仍要打开”。

不要通过关闭 Gatekeeper 或执行来源不明的终端命令来绕过系统保护。如果 macOS 明确提示应用包含恶意软件，请删除文件并重新从官方 Release 下载。

首次放行后，Sparkle 会使用 Ed25519 签名验证并安装后续更新。由于 ad-hoc 签名没有稳定的 Team ID，更新后 macOS 可能要求重新开启辅助功能权限。

## 从源码构建

需要 Xcode 16 或更高版本。项目固定使用 Sparkle 2.9.2；Xcode 首次构建时会解析 Swift Package 依赖。

```sh
./scripts/build-app.sh debug
```

构建产物位于 `dist/Shi.app`。默认使用 ad-hoc 签名，并在打包时将主应用与 Sparkle 的所有嵌套可执行组件重新签名。

## 发布

当前发布方式与 Codex Meter 一致：使用 ad-hoc 代码签名，并通过 Sparkle Ed25519 对更新包和 appcast 签名。发布脚本会构建 Universal 2 应用、验证嵌套签名并生成 ZIP、SHA-256 和 appcast。

```sh
./scripts/package-release.sh
```

创建 GitHub Release `vX.Y.Z`，上传脚本生成的 ZIP、SHA-256 和 `appcast.xml`。如果以后取得 Developer ID，可通过环境变量启用正式签名和 Apple 公证；具体命令见发布说明。

完整发布说明见 [docs/releasing.md](docs/releasing.md)。

## 安全设计

- 当前公开包使用 ad-hoc 签名且未经过 Apple 公证，因此首次打开会触发 Gatekeeper 提示。ad-hoc 构建不启用 Library Validation，以允许无 Team ID 的 Sparkle 框架正常加载。
- Sparkle 更新源仅使用 HTTPS，并要求签名 appcast 与 Ed25519 更新签名。
- 更新框架和应用内所有可执行组件均在打包时验证代码签名。
- 应用不启用 App Sandbox，因为全局事件拦截需要沙盒外的辅助功能权限；权限范围和原因会在首次使用时明确说明。
- 调试诊断使用 macOS Unified Logging，不写入可被符号链接劫持的固定 `/tmp` 文件。
- 显示器亮度优先使用系统接口；部分机型会回退到 Apple 未公开的 DisplayServices 接口，因此需要在目标 macOS 版本上进行回归测试。

安全问题请参阅 [SECURITY.md](SECURITY.md)。

## License

[MIT](LICENSE)
