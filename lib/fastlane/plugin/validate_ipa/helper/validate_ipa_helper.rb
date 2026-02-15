require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class ValidateIpaHelper # rubocop:disable Lint/EmptyClass
    end
  end
end
