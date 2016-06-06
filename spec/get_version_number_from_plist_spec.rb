require 'spec_helper'

describe Fastlane::Actions::GetVersionNumberFromPlistAction do
  describe "Get Version Number from Info.plist Integration" do

    before do
      copy_info_plist_fixture
    end

    it "should return version number from Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_plist
      end").runner.execute(:test)
      expect(result).to eq("0.9.14")
    end

    it "should set VERSION_NUMBER shared value" do
      Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_plist
      end").runner.execute(:test)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.9.14")
    end

    after do
      remove_info_plist_fixture
    end

  end
end
