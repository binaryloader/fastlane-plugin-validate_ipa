English | [한국어](docs/i18n/ko/README.md) | [日本語](docs/i18n/ja/README.md)

# fastlane-plugin-validate_ipa

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)
[![Gem Version](https://img.shields.io/gem/v/fastlane-plugin-validate_ipa?style=flat)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)

A [fastlane](https://github.com/fastlane/fastlane) plugin that validates IPA files with Apple's `altool` before they are uploaded to App Store Connect. This plugin is a maintained replacement for the unmaintained [validate_app](https://github.com/fastlane-community/fastlane-plugin-validate_app) plugin.

## Features

- IPA file validation - verifies file existence and extension before running altool
- Structured error reporting - parses altool XML output and displays a numbered error list with failure reasons
- Fallback error handling - gracefully handles missing fields, empty responses, and unparseable output
- Sensitive parameter masking - passwords are masked in fastlane logs

## Installation

```bash
fastlane add_plugin validate_ipa
```

Or add it to your `Gemfile`:

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

If your Apple ID uses two-factor authentication, pass an [app-specific password](https://support.apple.com/en-us/102654).

## Parameters

| Key | Description | Env Var | Required |
|-----|-------------|---------|----------|
| `path` | Path to the IPA file | `FL_VALIDATE_IPA_PATH` | Yes |
| `platform` | Target platform (`ios` or `macos`) | `FL_VALIDATE_IPA_PLATFORM` | Yes |
| `username` | Apple ID | `FL_VALIDATE_IPA_USERNAME` | Yes |
| `password` | App-specific password | `FL_VALIDATE_IPA_PASSWORD` | Yes |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
