[English](../../../README.md) | **한국어** | [日本語](../ja/README.md)

# fastlane-plugin-validate_ipa

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)
[![Gem Version](https://img.shields.io/gem/v/fastlane-plugin-validate_ipa?style=flat)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)

App Store Connect에 업로드하기 전에 Apple의 `altool`로 IPA 파일을 검증하는 [fastlane](https://github.com/fastlane/fastlane) 플러그인이다. 더 이상 관리되지 않는 [validate_app](https://github.com/fastlane-community/fastlane-plugin-validate_app) 플러그인을 대체한다.

## Features

- IPA 파일 검증 - altool 실행 전에 파일 존재 여부와 확장자를 확인한다
- 구조화된 에러 리포트 - altool의 XML 출력을 파싱하여 실패 사유가 담긴 번호 목록 형태로 보여준다
- 폴백 에러 처리 - 누락된 필드, 빈 응답, 파싱 불가능한 출력을 안전하게 처리한다
- 민감 파라미터 마스킹 - fastlane 로그에서 비밀번호가 가려진다

## Installation

```bash
fastlane add_plugin validate_ipa
```

또는 `Gemfile`에 추가한다.

```ruby
gem 'fastlane-plugin-validate_ipa'
```

## Usage

```ruby
lane :validate do
  validate_ipa(
    path: "build/MyApp.ipa",
    platform: "ios",
    username: "your@apple.id",
    password: "app-specific-password"
  )
end
```

Apple ID에 2단계 인증을 사용 중이라면 [앱 암호](https://support.apple.com/ko-kr/102654)를 전달한다.

## Parameters

| 키 | 설명 | 환경 변수 | 필수 여부 |
|-----|-------------|---------|----------|
| `path` | IPA 파일 경로 | `FL_VALIDATE_IPA_PATH` | 예 |
| `platform` | 대상 플랫폼(`ios` 또는 `macos`) | `FL_VALIDATE_IPA_PLATFORM` | 예 |
| `username` | Apple ID | `FL_VALIDATE_IPA_USERNAME` | 예 |
| `password` | 앱 암호 | `FL_VALIDATE_IPA_PASSWORD` | 예 |

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.
