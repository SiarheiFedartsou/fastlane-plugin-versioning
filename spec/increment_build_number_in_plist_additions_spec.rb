require 'spec_helper'

describe Fastlane::Actions::IncrementBuildNumberInPlistAction do
  describe "Increment new format of Build Number in Info.plist Integration" do

    let (:test_path) { "/tmp/fastlane/tests/fastlane" }
    let (:plist_file) { File.join("plist/", "Info.plist") }

    # Action parameters
    let (:info_plist_file) { File.join(test_path, plist_file) }

    before do
      copy_xcodeproj_fixtures
      copy_non_literal_style_plist
    end

    def current_xcodeproj_build_number
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj
      end").runner.execute(:test)
    end

    def current_build_number_plist 
      Fastlane::FastFile.new.parse("lane :test do
        get_info_plist_value(path: '#{info_plist_file}', key: 'CFBundleVersion')
      end").runner.execute(:test)
    end

    it "should set explicitly provided build number to xcodeproj if the value is non literal with plist_build_setting_support: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist(plist_build_setting_support: true, build_number: '0.0.4')
      end").runner.execute(:test)

      expect(current_xcodeproj_build_number).to eq("0.0.4")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("0.0.4")
    end

    it "should increment number to xcodeproj if the value is non literal with plist_build_setting_support: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist(plist_build_setting_support: true)
      end").runner.execute(:test)

      expect(current_xcodeproj_build_number).to eq("2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("2")
    end

    it "should not set explicitly provided build number to xcodeproj if the plist_build_setting_support: false" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist(build_number: '0.0.3')
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("0.0.3")
      expect(current_xcodeproj_build_number).to_not eq("0.0.3")
    end

    it "should not increment number to plist with plist_build_setting_support: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(plist_build_setting_support: true, version_number: '0.0.4')
      end").runner.execute(:test)

      expect(current_build_number_plist).to_not eq("0.0.4")
      expect(current_build_number_plist).to eq("$(CURRENT_PROJECT_VERSION)")
    end

    after do
      cleanup_fixtures
    end
  end
end
