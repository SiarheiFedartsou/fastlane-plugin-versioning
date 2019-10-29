require 'spec_helper'

describe Fastlane::Actions::GetBuildNumberFromPlistAction do
  describe "Get Build Number from Info.plist Integration" do

    let (:test_path) { "/tmp/fastlane/tests/fastlane" }
    let (:plist_file) { File.join("plist/", "Info.plist") }

    # Action parameters
    let (:info_plist_file) { File.join(test_path, plist_file) }

    before do
      copy_info_plist_fixtures
      copy_xcodeproj_fixtures
    end

    def current_build_number_plist 
      Fastlane::FastFile.new.parse("lane :test do
        get_info_plist_value(path: '#{info_plist_file}', key: 'CFBundleVersion')
      end").runner.execute(:test)
    end

    def current_build_number_xcodeproj
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj
      end").runner.execute(:test)
    end 

    it "should return build number from Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_plist
      end").runner.execute(:test)
      expect(result).to eq(current_build_number_plist)
    end
    
    it "should set BUILD_NUMBER shared value" do
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_plist
      end").runner.execute(:test)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("0.9.14.1")
    end

    it "should return build number from from xcodeproj if plist_build_setting_support: true" do
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_plist(plist_build_setting_support: true)
      end").runner.execute(:test)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq(current_build_number_xcodeproj)
    end

    after do
      cleanup_fixtures
    end
  end
end
