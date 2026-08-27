# Security Policy

## Supported versions

安全修复仅提供给最新发布版本。请先确认问题仍可在最新 GitHub Release 中复现。

## Reporting a vulnerability

请优先使用 GitHub 仓库的 Private Vulnerability Reporting，不要在公开 Issue 中披露可利用细节。报告应包含受影响版本、macOS 版本、复现步骤、影响范围和最小化测试样例。

## Security boundaries

拭需要 macOS 辅助功能权限来实现全局输入拦截，因此不能使用 App Sandbox。应用只在清洁模式期间处理输入事件，只读取 Shift、Esc 和事件状态，不保存按键，不执行 shell 命令，也不上传输入数据。

自动更新由 Sparkle 2 提供，更新源必须使用 HTTPS，appcast 和发布归档必须通过项目内置的 Ed25519 公钥验证。当前公开分发包使用 ad-hoc 代码签名且未经过 Apple 公证；首次运行前，用户应确认文件来自本仓库的 GitHub Releases。未来如改用 Developer ID，所有嵌套组件必须使用同一身份签名并通过 Apple 公证。
