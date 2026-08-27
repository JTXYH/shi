# 拭（Shi）

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

拭は macOS 向けのキーボードと画面の清掃補助ツールです。清掃モードではキーボード入力とポインタのクリックを一時的に遮断し、ディスプレイを暗くして、清掃中の誤操作を防ぎます。

## スクリーンショット

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="拭のメイン画面" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="ワイプ清掃モード" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="ホワイト清掃モード" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="ナイトクロック清掃モード" width="31%">
</p>

<p align="center"><sub>ワイプ · ホワイト · ナイトクロック</sub></p>

## 機能

- 6 言語：簡体字中国語、繁体字中国語、英語、日本語、韓国語、スペイン語
- 初回起動時は macOS の優先言語を使用し、設定で選択した言語は保存
- 3 種類の清掃表示：ワイプ、ホワイト、ナイトクロック
- 左右の Shift、または Shift + Esc を長押しして安全に終了
- 終了までの長押し時間、最大清掃時間、クリック遮断を設定可能
- Sparkle 2 による署名付き更新
- Apple Silicon と Intel Mac に対応する Universal 2 ビルド

## 動作環境

- macOS 14 以降
- 清掃モードには「システム設定 › プライバシーとセキュリティ › アクセシビリティ」の許可が必要

アクセシビリティの許可は、清掃中の入力遮断にのみ使用します。キー入力の記録や利用データの送信は行いません。HTTPS による更新確認以外のネットワーク通信も行いません。

## ダウンロード

[⬇️ GitHub Releases から最新版をダウンロード](https://github.com/JTXYH/shi/releases/latest)

ZIP を解凍し、`Shi.app` を「アプリケーション」フォルダへ移動してください。

### 初回起動時に macOS でブロックされる場合

現在のパッケージは ad-hoc 署名で、Apple の公証を受けていません。「Apple はこのアプリに悪意のあるソフトウェアが含まれていないか確認できません」または「開発元を検証できません」と表示された場合は、まず本リポジトリの [GitHub Releases](https://github.com/JTXYH/shi/releases) から取得したことを確認し、次のいずれかを行ってください。

1. Finder で「アプリケーション」を開き、`Shi.app` を Control キーを押しながらクリックするか右クリックして「開く」を選び、確認画面でもう一度「開く」を選びます。
2. または一度起動を試した後、「システム設定 › プライバシーとセキュリティ」のセキュリティ欄で「このまま開く」を選びます。

Gatekeeper を無効にしたり、出所不明のターミナルコマンドを実行したりしないでください。macOS がマルウェアを明示的に検出した場合はファイルを削除し、公式 Release から再ダウンロードしてください。

初回許可後の更新は、Sparkle が Ed25519 署名を検証してインストールします。ad-hoc 署名には安定した Team ID がないため、更新後にアクセシビリティの再許可を求められる場合があります。

## ソースからビルド

Xcode 16 以降が必要です。Sparkle 2.9.2 を固定して使用しています。

```sh
./scripts/build-app.sh debug
```

ビルド結果は `dist/Shi.app` に出力されます。既定では ad-hoc 署名を使用し、メイン App と内蔵 Sparkle 実行ファイルを再署名します。

## リリース

現在の配布方式は Codex Meter と同じで、ad-hoc コード署名と Sparkle Ed25519 による更新アーカイブおよび appcast の署名を使用します。リリーススクリプトは Universal 2 App をビルドし、内蔵署名を検証して ZIP、SHA-256、appcast を生成します。

```sh
./scripts/package-release.sh
```

`vX.Y.Z` の GitHub Release を作成し、生成された ZIP、SHA-256、`appcast.xml` をアップロードします。将来 Developer ID を取得した場合は、同じスクリプトで正式署名と Apple 公証を有効にできます。

詳細は [docs/releasing.md](docs/releasing.md) を参照してください。

## セキュリティ

- 現在の公開ビルドは ad-hoc 署名で Apple 公証を受けていないため、初回起動時に Gatekeeper の警告が表示される
- HTTPS、署名付き appcast、Ed25519 で Sparkle 更新を検証
- グローバル入力遮断のため App Sandbox は無効
- 診断に macOS Unified Logging を使い、予測可能な `/tmp` ファイルは作成しない
- 一部の Mac では非公開の DisplayServices にフォールバックするため、対象 macOS での回帰テストが必要

脆弱性の報告は [SECURITY.md](SECURITY.md) を参照してください。

## ライセンス

[MIT](LICENSE)
