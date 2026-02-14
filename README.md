# fastlane-plugin-validate_ipa

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)
[![Gem Version](https://badge.fury.io/rb/fastlane-plugin-validate_ipa.svg)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)

A [fastlane](https://github.com/fastlane/fastlane) plugin that validates IPA files using Apple's `altool`.

This plugin improves upon the [validate_app](https://github.com/fastlane-community/fastlane-plugin-validate_app) plugin, which is no longer maintained. If your Apple ID uses two-factor authentication, pass an [app-specific password](https://support.apple.com/en-us/102654).

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

| Key | Description | Env Var | Required |
|-----|-------------|---------|----------|
| `path` | Path to the IPA file | `FL_VALIDATE_IPA_PATH` | Yes |
| `platform` | Target platform (`ios` or `macos`) | `FL_VALIDATE_IPA_PLATFORM` | Yes |
| `username` | Apple ID | `FL_VALIDATE_IPA_USERNAME` | Yes |
| `password` | Apple ID or app-specific password | `FL_VALIDATE_IPA_PASSWORD` | Yes |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
