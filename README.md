# fastlane-plugin-validate_ipa

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)
[![Gem Version](https://img.shields.io/gem/v/fastlane-plugin-validate_ipa?style=flat)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)

A [fastlane](https://github.com/fastlane/fastlane) plugin that validates IPA files using Apple's `altool` before uploading to App Store Connect. This plugin improves upon the unmaintained [validate_app](https://github.com/fastlane-community/fastlane-plugin-validate_app) plugin.

## Features

- **IPA file validation** — Verifies file existence and extension before running altool
- **Structured error reporting** — Parses altool XML output and displays numbered error list with failure reasons
- **Fallback error handling** — Gracefully handles missing fields, empty responses, and unparseable output
- **Sensitive parameter masking** — Passwords are masked in fastlane logs

## Installation

```bash
fastlane add_plugin validate_ipa
```

Or add to your `Gemfile`:

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
