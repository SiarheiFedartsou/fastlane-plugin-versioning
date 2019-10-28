require 'spec_helper'

describe Fastlane::Actions::IncrementBuildNumberInPlistAction do
  describe "Increment new format of Build Numberin Info.plist Integration" do
    let (:test_path) { "/tmp/fastlane/tests/fastlane" }
    let (:fixtures_path) { "./spec/fixtures/plist" }
    let (:plist_file) { "Info.plist" }

    # Action parameters
    let (:info_plist_file) { File.join(test_path, plist_file) }

    before do
      FileUtils.mkdir_p(test_path)
      source = File.join(fixtures_path, 'New-Info.plist')
      destination = File.join(test_path, plist_file)

      FileUtils.cp_r(source, destination)

      copy_xcodeproj_fixtures
    end

    def current_version
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj
      end").runner.execute(:test)
    end

    it "should set explicitly provided build number to xcodeproj if the value is non literal" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist(build_number: '0.0.3')
      end").runner.execute(:test)

      expect(current_version).to eq("1")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("1")
    end

    it "should set explicitly provided build number to xcodeproj if the value is non literal with plist_build_setting_support: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist(plist_build_setting_support: true, build_number: '0.0.4')
      end").runner.execute(:test)

      expect(current_version).to eq("0.0.4")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("0.0.4")
    end

    it "should increment number to xcodeproj if the value is non literal with plist_build_setting_support: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist(plist_build_setting_support: true, build_number: '0.0.4')
      end").runner.execute(:test)

      expect(current_version).to eq("0.0.4")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("0.0.4")
    end

    after do
      FileUtils.rm_r(test_path)
    end
  end
end
