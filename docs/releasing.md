# 发布拭

本项目默认采用与 Codex Meter 相同的发布方式：ad-hoc 代码签名 + Sparkle 2 Ed25519 更新签名 + GitHub Releases。当前流程不需要 Apple Developer ID 证书，但用户首次打开时会看到 Gatekeeper 提示。

## 一次性准备

### Sparkle 更新密钥

Sparkle 私钥保存在 macOS 登录钥匙串，不能提交到仓库。当前 `Info.plist` 使用与 Codex Meter 相同的公钥，脚本默认读取钥匙串中的 `codex-meter` 账户。

确认本机公钥：

```sh
build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_keys \
  --account codex-meter \
  -p
```

输出必须与 `Shi/Info.plist` 中的 `SUPublicEDKey` 完全一致。私钥丢失后，已经安装的版本将无法验证新更新，因此应将它备份到仓库外的安全位置：

```sh
build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_keys \
  --account codex-meter \
  -x /path/outside/repository/codex-meter-sparkle-private-key
```

备份文件等同于更新签名密码，不得提交到 Git、上传到 Release 或发送给其他人。

### GitHub 地址

当前发布仓库是 `JTXYH/shi`：

- appcast：`https://github.com/JTXYH/shi/releases/latest/download/appcast.xml`
- ZIP：`https://github.com/JTXYH/shi/releases/download/vX.Y.Z/Shi-X.Y.Z-macOS.zip`
- Release：`https://github.com/JTXYH/shi/releases/tag/vX.Y.Z`

如果以后再次更换仓库，必须同时修改：

- `Shi/Info.plist` 中的 `SUFeedURL`
- `scripts/package-release.sh` 中的下载地址和发布页地址
- 六种 README 中的下载链接

更新源和 ZIP 必须通过公开、无需登录的 HTTPS 地址访问。

## 每次发布

1. 同时更新版本号，并保持 `Shi/Info.plist` 与 Xcode target 一致：

   - `CFBundleShortVersionString` / `MARKETING_VERSION`：用户版本，使用 `x.y.z`
   - `CFBundleVersion` / `CURRENT_PROJECT_VERSION`：严格递增的整数

2. 执行无证书打包：

   ```sh
   ./scripts/package-release.sh
   ```

   脚本默认使用 `CODE_SIGN_IDENTITY=-`，对主 App 和 Sparkle 所有嵌套可执行组件执行 ad-hoc 签名，并使用钥匙串中的 Ed25519 私钥签署更新归档和 appcast。

3. 脚本会在 `dist/` 生成：

   - `Shi.app`
   - `Shi-x.y.z-macOS.zip`
   - `Shi-x.y.z-macOS.zip.sha256`
   - `appcast.xml`

4. 发布前检查：

   ```sh
   codesign --verify --deep --strict --verbose=2 dist/Shi.app
   lipo -archs dist/Shi.app/Contents/MacOS/Shi
   (
     cd dist
     shasum -a 256 -c Shi-x.y.z-macOS.zip.sha256
   )
   ```

   `lipo` 输出必须同时包含 `arm64` 和 `x86_64`。ad-hoc 包没有 Apple 信任链，因此 `spctl --assess` 不会显示 Developer ID 的 `accepted`，这是当前分发模式的预期结果。

5. 创建已发布、非草稿的 GitHub Release `vX.Y.Z`，上传：

   - `Shi-x.y.z-macOS.zip`
   - `Shi-x.y.z-macOS.zip.sha256`
   - `appcast.xml`

   文件名和 Release tag 必须与 `appcast.xml` 中的 URL 完全一致。生成后不得手工修改 ZIP 或 appcast，否则 Ed25519 签名会失效。

## 用户首次安装

公开包未经过 Apple 公证。用户应先确认下载地址属于 `github.com/JTXYH/shi`，然后在 Finder 中右键点击 `Shi.app` 并选择「打开」，或在「系统设置 › 隐私与安全性」中点击「仍要打开」。不要建议用户全局关闭 Gatekeeper。

拭还需要辅助功能权限。ad-hoc 签名没有稳定的 Team ID，更新后 macOS 可能把新版本视为不同代码身份并要求用户重新授权。这不会影响 Sparkle 对更新包完整性的验证。

## 以后升级到 Developer ID（可选）

取得 `Developer ID Application` 证书后，先把公证凭据保存到钥匙串：

```sh
xcrun notarytool store-credentials shi-notary \
  --apple-id "your-apple-id@example.com" \
  --team-id "TEAMID"
```

终端会安全提示输入 App 专用密码。正式打包命令：

```sh
CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
NOTARYTOOL_PROFILE="shi-notary" \
SPARKLE_ACCOUNT="codex-meter" \
./scripts/package-release.sh
```

脚本会统一签署主 App 和 Sparkle 嵌套组件、启用 Hardened Runtime、提交 Apple 公证、装订公证票据，再生成最终 ZIP 和签名 appcast。
