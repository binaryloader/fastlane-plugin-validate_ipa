[English](../../../README.md) | [한국어](../ko/README.md) | 日本語

# fastlane-plugin-validate_ipa

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)
[![Gem Version](https://img.shields.io/gem/v/fastlane-plugin-validate_ipa?style=flat)](https://rubygems.org/gems/fastlane-plugin-validate_ipa)

App Store Connectへアップロードする前にAppleの`altool`でIPAファイルを検証する[fastlane](https://github.com/fastlane/fastlane)プラグインです。メンテナンスが止まっている[validate_app](https://github.com/fastlane-community/fastlane-plugin-validate_app)プラグインの後継として提供します。

## Features

- IPAファイル検証：altool実行前にファイルの存在と拡張子を確認します
- 構造化されたエラーレポート：altoolのXML出力をパースし、失敗理由を含む番号付きリストで表示します
- フォールバックエラー処理：欠落フィールド、空レスポンス、パース不能な出力を安全に処理します
- 機密パラメータのマスキング：fastlaneログ上でパスワードがマスクされます

## Installation

```bash
fastlane add_plugin validate_ipa
```

または`Gemfile`に追加します。

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

Apple IDで2ファクタ認証を利用している場合は[App用パスワード](https://support.apple.com/ja-jp/102654)を渡してください。

## Parameters

| キー | 説明 | 環境変数 | 必須 |
|-----|-------------|---------|----------|
| `path` | IPAファイルのパス | `FL_VALIDATE_IPA_PATH` | はい |
| `platform` | 対象プラットフォーム(`ios`または`macos`) | `FL_VALIDATE_IPA_PLATFORM` | はい |
| `username` | Apple ID | `FL_VALIDATE_IPA_USERNAME` | はい |
| `password` | App用パスワード | `FL_VALIDATE_IPA_PASSWORD` | はい |

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.
