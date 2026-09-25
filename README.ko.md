# 拭 (Shi)

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

Shi는 macOS 키보드와 화면 청소를 돕는 무료 오픈 소스 도구입니다. 청소 모드에서는 키보드 입력을 잠시 차단하며, 기본 설정에서는 트랙패드와 마우스 클릭도 차단합니다. 화면을 어둡게 하여 닦는 동안 실수로 입력하는 일을 줄여 줍니다. 청소가 끝나면 종료 단축키를 길게 눌러 Mac을 다시 사용할 수 있습니다.

[최신 버전 다운로드](https://github.com/JTXYH/shi/releases/latest) · [문제 제보](https://github.com/JTXYH/shi/issues) · [MIT 라이선스](LICENSE)

## 기능

- **청소 중 입력 일시 중지**: 키보드 입력을 차단하고, 트랙패드와 마우스 클릭 차단 여부도 선택할 수 있습니다.
- **세 가지 청소 화면**: 닦기, 화이트, 야간 시계를 제공하며 여러 디스플레이에 청소 화면을 표시합니다.
- **화면 어둡게 하기 및 복원**: 청소 중 화면을 어둡게 하고 종료하면 복원합니다. 실제 동작은 디스플레이와 macOS 지원 여부에 따라 달라집니다.
- **단축키로 시작 및 종료**: 앱 실행 중 `Control + Option + Command + C`로 시작하고, 양쪽 `Shift` 또는 `Shift + Esc`를 길게 눌러 종료합니다.
- **청소 시간 설정**: 종료에 필요한 누름 시간과 자동 종료 시간을 설정할 수 있습니다.
- **6개 언어 지원**: 간체 중국어, 번체 중국어, 영어, 일본어, 한국어, 스페인어.
- **앱 내 업데이트**: Sparkle로 업데이트를 확인하고 업데이트 서명을 검증합니다.

## 스크린샷

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="Shi 메인 화면" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="닦기 청소 화면" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="화이트 청소 화면" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="야간 시계 청소 화면" width="31%">
</p>

<p align="center"><sub>닦기 · 화이트 · 야간 시계</sub></p>

## 시스템 요구 사항

- macOS 14 Sonoma 이상.
- Apple Silicon 또는 Intel Mac. 빌드 결과물은 Universal 2 앱입니다.
- 청소 모드를 위한 macOS 손쉬운 사용 권한.

## 설치

1. [GitHub Releases](https://github.com/JTXYH/shi/releases/latest)에서 앱 ZIP 파일을 다운로드합니다.
2. 압축을 풀고 `Shi.app`을 응용 프로그램 폴더로 옮깁니다.
3. 앱을 열고 아래 사용 방법을 따릅니다.

현재 기본 배포 방식은 ad-hoc 서명을 사용하며 Apple 공증을 받지 않았습니다. 첫 실행 시 개발자를 확인할 수 없거나 악성 소프트웨어를 검사할 수 없다는 안내가 나오면, 이 저장소에서 받은 변조되지 않은 파일인지 확인한 뒤 [Apple의 앱 실행 안내](https://support.apple.com/en-us/102445)를 따르세요. macOS가 악성 소프트웨어를 명확히 감지한 경우에는 해당 경고를 무시하지 마세요.

## 사용 방법

1. Shi를 열고 청소 화면을 선택한 다음 **청소 시작**을 누릅니다. 앱이 실행 중이면 `Control + Option + Command + C`도 사용할 수 있습니다.
2. 처음 사용할 때는 안내에 따라 **시스템 설정 › 개인정보 보호 및 보안 › 손쉬운 사용**에서 Shi의 권한을 켭니다. 목록에 없으면 `+` 버튼으로 `Shi.app`을 추가하세요. **권한을 허용하면 청소가 자동으로 시작됩니다.**
3. 청소가 끝나면 왼쪽과 오른쪽 `Shift`를 동시에 누르거나 `Shift + Esc`를 길게 누릅니다. 기본값은 **1.5초**이며, 종료하면 입력과 화면 밝기가 복원됩니다.

설정에서 다음 항목을 변경할 수 있습니다.

| 설정 | 기본값 | 선택 항목 |
| --- | --- | --- |
| 종료에 필요한 누름 시간 | 1.5초 | 1초, 1.5초, 2초 |
| 최대 청소 시간 | 10분 | 5분, 10분, 자동 종료 끄기 |
| 트랙패드 및 마우스 클릭 차단 | 켬 | 켬 또는 끔 |

첫 실행 시 macOS의 첫 번째 선호 언어를 사용하며, 지원하지 않는 언어이면 영어를 사용합니다. 직접 선택한 언어는 Mac에 저장됩니다.

전원 버튼과 Touch ID는 차단할 수 없습니다. 자리를 비울 때는 macOS 잠금 화면을 사용하세요.

## 권한, 개인정보 및 업데이트

- 손쉬운 사용 권한은 청소 모드에서 키보드 입력을 차단하는 데 사용됩니다. 키 입력 내용을 기록하거나 사용 통계를 수집하지 않으며, 설정은 Mac에 저장됩니다.
- 청소 기능은 오프라인에서 사용할 수 있고 계정이 필요하지 않습니다. 업데이트 확인과 다운로드에는 네트워크 연결이 필요합니다.
- 릴리스 빌드는 HTTPS로 업데이트 정보를 가져오고 Sparkle의 Ed25519 서명으로 appcast와 업데이트 파일을 검증합니다. 설정에서 수동으로 업데이트를 확인할 수 있으며, 디버그 빌드에서는 업데이트 확인이 비활성화됩니다.
- ad-hoc 서명 앱을 업데이트하거나 다시 빌드하면 macOS에서 손쉬운 사용 권한을 다시 요청할 수 있습니다. 청소가 시작되지 않으면 손쉬운 사용 목록에서 Shi를 다시 활성화하세요.

보안 취약점은 [보안 정책](SECURITY.md)에 따라 비공개로 제보해 주세요.

## 소스에서 빌드

개발에는 macOS와 Xcode 16 이상이 필요하며, 명령줄 도구가 해당 Xcode를 사용하도록 설정해야 합니다. Swift, SwiftUI, AppKit을 사용하며, Swift Package Manager로 [Sparkle](https://github.com/sparkle-project/Sparkle)을 가져옵니다. 현재 고정 버전은 2.9.2입니다. 첫 빌드에는 의존성을 다운로드할 네트워크 연결이 필요합니다.

```sh
git clone https://github.com/JTXYH/shi.git
cd shi
./scripts/build-app.sh debug
open dist/Shi.app
```

스크립트는 `arm64`와 `x86_64`를 모두 포함하는 `dist/Shi.app`을 생성합니다. 기본적으로 ad-hoc 서명을 사용하므로 로컬 빌드에는 Developer ID 인증서가 필요하지 않습니다. Xcode에서 `Shi.xcodeproj`를 열고 `Shi` scheme을 선택하여 개발하고 디버깅할 수도 있습니다.

저장소 루트에서 기존 언어 선택 검사를 실행할 수 있습니다.

```sh
./scripts/test-language-selection.sh
```

이 검사는 시스템 언어 판별과 저장된 언어의 우선순위를 확인합니다. 청소, 권한 및 디스플레이 동작은 실제 Mac에서 별도로 테스트해야 합니다.

## 기여

[Issues](https://github.com/JTXYH/shi/issues)와 [Pull Requests](https://github.com/JTXYH/shi/pulls)를 통해 버그 제보, 개선 및 번역에 참여할 수 있습니다.

- 버그를 제보할 때는 앱 버전, macOS 버전, Mac 모델, 재현 단계, 예상 결과를 알려 주세요. 화면 문제라면 디스플레이 구성도 포함해 주세요.
- 변경 이유와 검증 방법을 설명해 주세요. 화면 변경에는 스크린샷을 첨부하고, 입력 차단·종료·밝기 관련 변경은 실제 Mac에서 확인해 주세요.
- 기능 설명이나 번역을 수정할 때는 README 6개를 함께 갱신해 주세요. 앱 내 문구는 [Shi/Localization.swift](Shi/Localization.swift)에 있습니다.

## 라이선스

[JTXYH](https://github.com/JTXYH)가 유지 관리하며 [MIT 라이선스](LICENSE)로 배포합니다. 타사 의존성에는 각각의 라이선스가 적용됩니다.
