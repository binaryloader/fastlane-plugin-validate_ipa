require 'fastlane/action'
require 'fastlane_core/configuration/config_item'
require 'plist'
require_relative '../helper/validate_ipa_helper'

module Fastlane
  module Actions
    class ValidateIpaAction < Action
      SUPPORTED_PLATFORMS = %w[ios macos].freeze

      def self.run(params)
        validate_ipa_file(params[:path])

        UI.message("Validating '#{File.basename(params[:path])}' (#{params[:platform]})...")

        output = run_altool(params)
        plist = parse_output(output)
        handle_result(plist)
      end

      def self.validate_ipa_file(path)
        UI.user_error!("IPA file not found: #{path}") unless File.exist?(path)
        UI.user_error!("Not an IPA file: #{path}") unless File.extname(path).casecmp(".ipa").zero?
      end
      private_class_method :validate_ipa_file

      def self.run_altool(params)
        command = [
          "xcrun", "altool",
          "--validate-app",
          "--file", params[:path],
          "--type", params[:platform],
          "--username", params[:username],
          "--password", params[:password],
          "--output-format", "xml"
        ]

        sh(command.join(" "))
      rescue StandardError => e
        UI.user_error!("altool execution failed: #{e.message}")
      end
      private_class_method :run_altool

      def self.parse_output(output)
        UI.user_error!("altool returned empty output") if output.to_s.strip.empty?

        xml = output[%r{(<\?xml.*</plist>)}m]&.strip
        UI.user_error!("No plist found in altool output:\n#{output}") if xml.nil?

        plist = Plist.parse_xml(xml)
        UI.user_error!("Failed to parse altool XML output:\n#{output}") if plist.nil?

        plist
      end
      private_class_method :parse_output

      def self.handle_result(plist)
        errors = plist["product-errors"]

        if errors.nil? || errors.empty?
          UI.success("Validation succeeded: #{plist['success-message'] || 'No errors found'}")
          return
        end

        reasons = errors.each_with_index.map do |error, index|
          message = error.dig("userInfo", "NSLocalizedFailureReason") || error["message"] || "Unknown error"
          "  #{index + 1}. #{message}"
        end

        UI.error("Validation failed with #{errors.size} error(s):\n#{reasons.join("\n")}")
        UI.user_error!("IPA validation failed")
      end
      private_class_method :handle_result

      def self.description
        "Validate the IPA using altool"
      end

      def self.authors
        ["binaryloader"]
      end

      def self.details
        "Validates an IPA file using Apple's altool before uploading to App Store Connect"
      end

      def self.return_value
        "nil"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :path,
            env_name: "FL_VALIDATE_IPA_PATH",
            description: "Path to the IPA file",
            type: String,
            verify_block: proc do |value|
              UI.user_error!("'path' must not be empty") if value.to_s.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :platform,
            env_name: "FL_VALIDATE_IPA_PLATFORM",
            description: "Platform type (#{SUPPORTED_PLATFORMS.join(', ')})",
            type: String,
            verify_block: proc do |value|
              UI.user_error!("'platform' must not be empty") if value.to_s.empty?
              unless SUPPORTED_PLATFORMS.include?(value)
                UI.user_error!("Unsupported platform '#{value}'. Supported: #{SUPPORTED_PLATFORMS.join(', ')}")
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :username,
            env_name: "FL_VALIDATE_IPA_USERNAME",
            description: "Apple ID",
            type: String,
            verify_block: proc do |value|
              UI.user_error!("'username' must not be empty") if value.to_s.empty?
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :password,
            env_name: "FL_VALIDATE_IPA_PASSWORD",
            description: "App-specific password",
            type: String,
            sensitive: true,
            verify_block: proc do |value|
              UI.user_error!("'password' must not be empty") if value.to_s.empty?
            end
          )
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
