require 'spec_helper'

describe Fastlane::Actions::IncrementVersionNumberInPlistAction do
  describe "Increment new format of Version Number in Info.plist Integration" do

    let (:test_path) { "/tmp/fastlane/tests/fastlane" }
    let (:plist_file) { File.join("plist/", "Info.plist") }

    # Action parameters
    let (:info_plist_file) { File.join(test_path, plist_file) }

    before do
      copy_xcodeproj_fixtures
      copy_non_literal_style_plist
    end

    def current_xcodeproj_version_number
      Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj
      end").runner.execute(:test)
    end

    def current_version_number_plist 
      Fastlane::FastFile.new.parse("lane :test do
        get_info_plist_value(path: '#{info_plist_file}', key: 'CFBundleShortVersionString')
      end").runner.execute(:test)
    end

    it "should not set explicitly provided version number to xcodeproj if the plist_build_setting_support: false" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(version_number: '0.0.3')
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.3")
      expect(current_xcodeproj_version_number).to_not eq("0.0.3")
    end

    it "should set explicitly provided build number to xcodeproj if the value is non literal with plist_build_setting_support: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(plist_build_setting_support: true, version_number: '0.0.4')
      end").runner.execute(:test)

      expect(current_xcodeproj_version_number).to eq("0.0.4")
      expect(current_version_number_plist).to_not eq("0.0.4")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.4")
    end

    it "should not increment number to plist with plist_build_setting_support: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(plist_build_setting_support: true, version_number: '0.0.4')
      end").runner.execute(:test)

      expect(current_version_number_plist).to_not eq("0.0.4")
      expect(current_version_number_plist).to eq("$(MARKETING_VERSION)")
    end

    after do
      cleanup_fixtures
    end
  end
end
