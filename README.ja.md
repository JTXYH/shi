# 拭（Shi）

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

拭は、macOS のキーボードと画面を清掃するための無料のオープンソースツールです。清掃モードではキーボード入力を一時的に遮断し、初期設定ではトラックパッドとマウスのクリックも遮断します。画面を暗くして、拭き掃除中の誤操作を減らします。清掃が終わったら、終了用のキーの組み合わせを長押しして通常の操作に戻れます。

[最新版をダウンロード](https://github.com/JTXYH/shi/releases/latest) · [問題を報告](https://github.com/JTXYH/shi/issues) · [MIT ライセンス](LICENSE)

## 機能

- **清掃中の入力を一時停止**：キーボード入力を遮断し、トラックパッドとマウスのクリック遮断も選択できます。
- **3 種類の清掃画面**：ワイプ、ホワイト、ナイトクロック。複数のディスプレイに清掃画面を表示できます。
- **画面の減光と復元**：清掃中に画面を暗くし、終了時に元に戻します。動作はディスプレイと macOS の対応状況によって異なります。
- **ショートカットで開始・終了**：アプリの起動中に `Control + Option + Command + C` で開始し、左右両方の `Shift` または `Shift + Esc` を長押しして終了します。
- **時間の調整**：終了に必要な長押し時間と、清掃を自動終了するまでの時間を設定できます。
- **6 言語に対応**：簡体字中国語、繁体字中国語、英語、日本語、韓国語、スペイン語。
- **アプリ内アップデート**：Sparkle で更新を確認し、更新の署名を検証します。

## スクリーンショット

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="拭のメイン画面" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="ワイプの清掃画面" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="ホワイトの清掃画面" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="ナイトクロックの清掃画面" width="31%">
</p>

<p align="center"><sub>ワイプ · ホワイト · ナイトクロック</sub></p>

## 動作環境

- macOS 14 Sonoma 以降。
- Apple Silicon または Intel 搭載の Mac。ビルドは Universal 2 形式です。
- 清掃モードには macOS のアクセシビリティの許可が必要です。

## インストール

1. [GitHub Releases](https://github.com/JTXYH/shi/releases/latest) からアプリの ZIP ファイルをダウンロードします。
2. 展開して `Shi.app` を「アプリケーション」フォルダに移動します。
3. アプリを開き、以下の手順で使い始めます。

現在の標準の配布方式では ad-hoc 署名を使用しており、Apple の公証を受けていません。初回起動時に開発元を検証できない、または悪意のあるソフトウェアを確認できないと表示された場合は、本リポジトリから入手した未改変のファイルであることを確認し、[Apple の起動手順](https://support.apple.com/en-us/102445) に従ってください。macOS がマルウェアを明示的に検出した場合、その警告を無視しないでください。

## 使い方

1. 拭を開いて清掃画面を選び、「クリーニング開始」をクリックします。アプリの起動中は `Control + Option + Command + C` も使えます。
2. 初回は案内に従い、「システム設定 › プライバシーとセキュリティ › アクセシビリティ」で拭を許可します。一覧にない場合は `+` で `Shi.app` を追加してください。**許可すると自動的に清掃が始まります。**
3. 終了するには左右両方の `Shift`、または `Shift + Esc` を長押しします。初期設定では **1.5 秒**で終了し、入力と画面の明るさが元に戻ります。

設定で変更できる項目：

| 設定 | 初期値 | 選択肢 |
| --- | --- | --- |
| 終了に必要な長押し時間 | 1.5 秒 | 1 秒、1.5 秒、2 秒 |
| 最大清掃時間 | 10 分 | 5 分、10 分、自動終了なし |
| トラックパッドとマウスのクリック遮断 | オン | オン・オフ |

初回起動時は macOS の最優先の言語を使い、未対応の言語の場合は英語になります。手動で選んだ言語は Mac に保存されます。

電源ボタンと Touch ID は遮断できません。席を離れるときは macOS の画面ロックを使用してください。

## 権限・プライバシー・更新

- アクセシビリティの許可は、清掃モード中のキーボード入力の遮断に使用します。キー入力の内容や利用統計は記録せず、設定は Mac に保存します。
- 清掃機能はオフラインで使え、アカウントは不要です。更新の確認とダウンロードにはネットワーク接続が必要です。
- リリースビルドでは HTTPS で更新情報を取得し、Sparkle の Ed25519 署名で appcast と更新アーカイブを検証します。設定から手動で更新を確認できます。デバッグビルドでは更新確認は無効です。
- ad-hoc 署名のアプリを更新または再ビルドした後は、アクセシビリティの再許可が必要になる場合があります。清掃を開始できない場合は、アクセシビリティの一覧で拭を再度有効にしてください。

脆弱性は [セキュリティポリシー](SECURITY.md) に従い、非公開で報告してください。

## ソースからビルド

開発には macOS と Xcode 16 以降が必要です。コマンドラインツールの参照先をその Xcode に設定してください。Swift、SwiftUI、AppKit を使用し、Swift Package Manager 経由で [Sparkle](https://github.com/sparkle-project/Sparkle) を導入しています。現在の固定バージョンは 2.9.2 です。初回ビルドには依存関係を取得するためのネットワーク接続が必要です。

```sh
git clone https://github.com/JTXYH/shi.git
cd shi
./scripts/build-app.sh debug
open dist/Shi.app
```

スクリプトは `arm64` と `x86_64` の両方を含む `dist/Shi.app` を生成します。標準では ad-hoc 署名を使うため、ローカルビルドに Developer ID 証明書は不要です。Xcode で `Shi.xcodeproj` を開き、`Shi` scheme を選んで開発・デバッグすることもできます。

リポジトリのルートで既存の言語選択チェックを実行できます：

```sh
./scripts/test-language-selection.sh
```

このチェックではシステム言語の判定と保存済み言語の優先順位を確認します。清掃、権限、ディスプレイの動作は実際の Mac でのテストが必要です。

## 貢献

[Issues](https://github.com/JTXYH/shi/issues) と [Pull Requests](https://github.com/JTXYH/shi/pulls) で、不具合報告、改善、翻訳を受け付けています。

- 不具合報告には、アプリのバージョン、macOS のバージョン、Mac の機種、再現手順、期待する結果を記載してください。表示の問題にはディスプレイ構成も添えてください。
- 変更の理由と検証方法を説明してください。画面の変更にはスクリーンショットを添え、入力遮断・終了・明るさに関する変更は実際の Mac で検証してください。
- 機能説明や翻訳を変更する際は、6 言語の README を同期してください。アプリ内の文言は [Shi/Localization.swift](Shi/Localization.swift) にあります。

## ライセンス

[JTXYH](https://github.com/JTXYH) がメンテナンスしており、[MIT ライセンス](LICENSE) で公開しています。サードパーティの依存ライブラリにはそれぞれのライセンスが適用されます。
