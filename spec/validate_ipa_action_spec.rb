require 'spec_helper'

describe Fastlane::Actions::ValidateIpaAction do
  describe '#run' do
    let(:params) do
      {
        path: ipa_path,
        platform: "ios",
        username: "test@example.com",
        password: "test-password"
      }
    end
    let(:ipa_path) { File.join(Dir.tmpdir, "test.ipa") }

    before do
      FileUtils.touch(ipa_path)
    end

    after do
      FileUtils.rm_f(ipa_path)
    end

    context "IPA file validation" do
      it "raises error when IPA file does not exist" do
        FileUtils.rm_f(ipa_path)
        expect do
          Fastlane::Actions::ValidateIpaAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /IPA file not found/)
      end

      it "raises error when file is not an IPA" do
        non_ipa = File.join(Dir.tmpdir, "test.txt")
        FileUtils.touch(non_ipa)
        begin
          expect do
            Fastlane::Actions::ValidateIpaAction.run(params.merge(path: non_ipa))
          end.to raise_error(FastlaneCore::Interface::FastlaneError, /Not an IPA file/)
        ensure
          FileUtils.rm_f(non_ipa)
        end
      end
    end

    context "altool execution" do
      it "raises error when altool fails" do
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_raise(StandardError.new("command not found"))
        expect do
          Fastlane::Actions::ValidateIpaAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /altool execution failed/)
      end

      it "calls altool with correct arguments" do
        expected_cmd = "xcrun altool --validate-app --file #{ipa_path} --type ios --username test@example.com --password test-password --output-format xml"
        success_xml = { "success-message" => "No errors." }.to_plist
        expect(Fastlane::Actions::ValidateIpaAction).to receive(:sh).with(expected_cmd).and_return(success_xml)
        Fastlane::Actions::ValidateIpaAction.run(params)
      end
    end

    context "output parsing" do
      it "raises error on empty output" do
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return("")
        expect do
          Fastlane::Actions::ValidateIpaAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /altool returned empty output/)
      end

      it "raises error when no plist found in output" do
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return("some random text without xml")
        expect do
          Fastlane::Actions::ValidateIpaAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /No plist found/)
      end

      it "extracts plist from output with extra lines" do
        plist_xml = { "success-message" => "OK" }.to_plist
        output_with_prefix = "$ xcrun altool --validate-app ...\n#{plist_xml}\n"
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return(output_with_prefix)
        expect(Fastlane::UI).to receive(:success).with(/OK/)
        Fastlane::Actions::ValidateIpaAction.run(params)
      end
    end

    context "validation result" do
      it "succeeds with valid IPA" do
        plist_xml = { "success-message" => "No errors validating archive." }.to_plist
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return(plist_xml)
        expect(Fastlane::UI).to receive(:success).with(/No errors validating archive/)
        Fastlane::Actions::ValidateIpaAction.run(params)
      end

      it "shows fallback message when success-message is missing" do
        plist_xml = {}.to_plist
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return(plist_xml)
        expect(Fastlane::UI).to receive(:success).with(/No errors found/)
        Fastlane::Actions::ValidateIpaAction.run(params)
      end

      it "fails with product errors using NSLocalizedFailureReason" do
        plist_xml = {
          "product-errors" => [
            {
              "message" => "Invalid signature",
              "userInfo" => {
                "NSLocalizedFailureReason" => "The signature is invalid."
              }
            }
          ]
        }.to_plist
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return(plist_xml)
        expect(Fastlane::UI).to receive(:error).with(/The signature is invalid/)
        expect do
          Fastlane::Actions::ValidateIpaAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /IPA validation failed/)
      end

      it "falls back to message field when NSLocalizedFailureReason is missing" do
        plist_xml = {
          "product-errors" => [
            { "userInfo" => { "NSLocalizedFailureReason" => "Invalid provisioning profile." } },
            { "message" => "Missing icon" }
          ]
        }.to_plist
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return(plist_xml)
        expect(Fastlane::UI).to receive(:error).with(/Invalid provisioning profile.*Missing icon/m)
        expect do
          Fastlane::Actions::ValidateIpaAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /IPA validation failed/)
      end

      it "shows error count in failure message" do
        plist_xml = {
          "product-errors" => [
            { "message" => "Error A" },
            { "message" => "Error B" }
          ]
        }.to_plist
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return(plist_xml)
        expect(Fastlane::UI).to receive(:error).with(/2 error\(s\)/)
        expect do
          Fastlane::Actions::ValidateIpaAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end

      it "shows 'Unknown error' when both fields are missing" do
        plist_xml = { "product-errors" => [{}] }.to_plist
        allow(Fastlane::Actions::ValidateIpaAction).to receive(:sh).and_return(plist_xml)
        expect(Fastlane::UI).to receive(:error).with(/Unknown error/)
        expect do
          Fastlane::Actions::ValidateIpaAction.run(params)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end

    context "actual altool invocation" do
      let(:dummy_ipa_path) { File.join(Dir.tmpdir, "dummy_validate_test.ipa") }

      before do
        # Create a minimal zip (IPA is a zip archive)
        require 'zip'
        Zip::OutputStream.open(dummy_ipa_path) do |zos|
          zos.put_next_entry("Payload/Test.app/Info.plist")
          zos.write({ "CFBundleIdentifier" => "com.test.app" }.to_plist)
        end
      rescue LoadError
        # rubyzip not available, create an empty file as fallback
        FileUtils.touch(dummy_ipa_path)
      end

      after do
        FileUtils.rm_f(dummy_ipa_path)
      end

      it "invokes altool and handles authentication failure gracefully" do
        skip("xcrun altool not available") unless system("xcrun altool --help > /dev/null 2>&1")

        expect do
          Fastlane::Actions::ValidateIpaAction.run(
            path: dummy_ipa_path,
            platform: "ios",
            username: "invalid@test.com",
            password: "invalid-password"
          )
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end
  end

  describe '#available_options' do
    let(:options) { Fastlane::Actions::ValidateIpaAction.available_options }

    it "has 4 options" do
      expect(options.length).to eq(4)
    end

    it "rejects unsupported platform" do
      option = options.find { |o| o.key == :platform }
      expect do
        option.verify!("android")
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /Unsupported platform/)
    end

    it "accepts ios platform" do
      option = options.find { |o| o.key == :platform }
      expect { option.verify!("ios") }.not_to raise_error
    end

    it "accepts macos platform" do
      option = options.find { |o| o.key == :platform }
      expect { option.verify!("macos") }.not_to raise_error
    end

    it "rejects empty path" do
      option = options.find { |o| o.key == :path }
      expect { option.verify!("") }.to raise_error(FastlaneCore::Interface::FastlaneError, /must not be empty/)
    end

    it "rejects empty username" do
      option = options.find { |o| o.key == :username }
      expect { option.verify!("") }.to raise_error(FastlaneCore::Interface::FastlaneError, /must not be empty/)
    end

    it "rejects empty password" do
      option = options.find { |o| o.key == :password }
      expect { option.verify!("") }.to raise_error(FastlaneCore::Interface::FastlaneError, /must not be empty/)
    end

    it "marks password as sensitive" do
      option = options.find { |o| o.key == :password }
      expect(option.sensitive).to be(true)
    end
  end

  describe '#is_supported?' do
    it "supports ios" do
      expect(Fastlane::Actions::ValidateIpaAction.is_supported?(:ios)).to be(true)
    end

    it "supports mac" do
      expect(Fastlane::Actions::ValidateIpaAction.is_supported?(:mac)).to be(true)
    end

    it "does not support android" do
      expect(Fastlane::Actions::ValidateIpaAction.is_supported?(:android)).to be(false)
    end
  end

  describe '#metadata' do
    it "returns description" do
      expect(Fastlane::Actions::ValidateIpaAction.description).not_to be_empty
    end

    it "returns details" do
      expect(Fastlane::Actions::ValidateIpaAction.details).not_to be_empty
    end

    it "returns authors" do
      expect(Fastlane::Actions::ValidateIpaAction.authors).to include("binaryloader")
    end
  end
end
