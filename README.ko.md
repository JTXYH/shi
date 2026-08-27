# 拭 (Shi)

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

拭는 macOS 키보드 및 화면 청소 보조 도구입니다. 청소 모드에서는 키보드 입력과 포인터 클릭을 잠시 차단하고 디스플레이를 어둡게 하여 청소 중 오작동을 방지합니다.

## 스크린샷

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="拭 메인 화면" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="닦기 청소 모드" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="화이트 청소 모드" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="야간 시계 청소 모드" width="31%">
</p>

<p align="center"><sub>닦기 · 화이트 · 야간 시계</sub></p>

## 기능

- 간체 중국어, 번체 중국어, 영어, 일본어, 한국어, 스페인어 지원
- 첫 실행 시 macOS의 첫 번째 선호 언어를 사용하며, 설정에서 선택한 언어는 저장
- 닦기, 화이트, 야간 시계의 세 가지 청소 화면
- 양쪽 Shift 또는 Shift + Esc를 길게 눌러 안전하게 청소 모드 종료
- 종료 누름 시간, 최대 청소 시간, 포인터 클릭 차단 설정
- Sparkle 2를 사용한 서명된 업데이트
- Apple Silicon과 Intel Mac을 모두 지원하는 Universal 2 빌드

## 시스템 요구 사항

- macOS 14 이상
- 청소 모드는 시스템 설정 › 개인정보 보호 및 보안 › 손쉬운 사용 권한 필요

손쉬운 사용 권한은 청소 모드에서 입력을 차단하는 데만 사용됩니다. 키 입력을 기록하거나 사용 데이터를 전송하지 않습니다. HTTPS 업데이트 확인 외의 네트워크 요청도 보내지 않습니다.

## 다운로드

[⬇️ GitHub Releases에서 최신 버전 다운로드](https://github.com/JTXYH/shi/releases/latest)

ZIP의 압축을 풀고 `Shi.app`을 응용 프로그램 폴더로 옮기세요.

### 첫 실행 시 macOS가 앱을 차단하는 경우

현재 패키지는 ad-hoc 서명을 사용하며 Apple 공증을 받지 않았습니다. macOS에서 악성 소프트웨어를 확인할 수 없거나 개발자를 확인할 수 없다는 메시지가 표시되면, 먼저 이 저장소의 [GitHub Releases](https://github.com/JTXYH/shi/releases)에서 다운로드했는지 확인한 후 다음 중 하나를 사용하세요.

1. Finder에서 응용 프로그램을 열고 `Shi.app`을 Control-클릭하거나 마우스 오른쪽 버튼으로 클릭한 뒤 열기를 선택하고, 확인 창에서 다시 열기를 선택합니다.
2. 또는 앱 실행을 한 번 시도한 다음 시스템 설정 › 개인정보 보호 및 보안의 보안 영역에서 확인 없이 열기를 선택합니다.

Gatekeeper를 비활성화하거나 출처를 알 수 없는 터미널 명령으로 보호 기능을 우회하지 마세요. macOS가 악성 소프트웨어를 명확히 감지한 경우 파일을 삭제하고 공식 Release에서 다시 다운로드하세요.

최초 허용 이후에는 Sparkle이 Ed25519 서명을 검증하여 후속 업데이트를 설치합니다. ad-hoc 서명에는 안정적인 Team ID가 없으므로 업데이트 후 손쉬운 사용 권한을 다시 활성화해야 할 수 있습니다.

## 소스에서 빌드

Xcode 16 이상이 필요하며 Sparkle 2.9.2를 고정해 사용합니다.

```sh
./scripts/build-app.sh debug
```

결과는 `dist/Shi.app`에 생성됩니다. 기본적으로 ad-hoc 서명을 사용하고 메인 앱과 포함된 모든 Sparkle 실행 파일을 다시 서명합니다.

## 배포

현재 배포 방식은 Codex Meter와 동일합니다. ad-hoc 코드 서명과 Sparkle Ed25519를 사용해 업데이트 압축 파일 및 appcast에 서명합니다. 배포 스크립트는 Universal 2 앱을 빌드하고 포함된 서명을 검증한 뒤 ZIP, SHA-256, appcast를 생성합니다.

```sh
./scripts/package-release.sh
```

`vX.Y.Z` GitHub Release를 만들고 생성된 ZIP, SHA-256 및 `appcast.xml`을 업로드하세요. 추후 Developer ID를 취득하면 동일한 스크립트에서 정식 서명과 Apple 공증을 활성화할 수 있습니다.

자세한 절차는 [docs/releasing.md](docs/releasing.md)를 확인하세요.

## 보안 설계

- 현재 공개 빌드는 ad-hoc 서명이며 Apple 공증을 받지 않았으므로 첫 실행 시 Gatekeeper 경고가 표시됨
- HTTPS, 서명된 appcast, Ed25519로 Sparkle 업데이트 검증
- 전역 입력 차단을 위해 App Sandbox는 비활성화
- macOS Unified Logging을 사용하고 예측 가능한 `/tmp` 파일을 생성하지 않음
- 일부 Mac은 비공개 DisplayServices로 대체되므로 대상 macOS에서 회귀 테스트 필요

보안 문제 제보는 [SECURITY.md](SECURITY.md)를 참고하세요.

## 라이선스

[MIT](LICENSE)
