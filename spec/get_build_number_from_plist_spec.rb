require 'spec_helper'

describe Fastlane::Actions::GetBuildNumberFromPlistAction do
  describe "Get Build Number from Info.plist Integration" do
    before do
      copy_info_plist_fixture
    end

    it "should return build number from Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_plist
      end").runner.execute(:test)
      expect(result).to eq("1234")
    end

    it "should set BUILD_NUMBER shared value" do
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_plist
      end").runner.execute(:test)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("1234")
    end

    after do
      remove_info_plist_fixture
    end
  end
end
