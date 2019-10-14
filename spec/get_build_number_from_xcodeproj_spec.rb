require 'spec_helper'

describe Fastlane::Actions::GetBuildNumberFromXcodeprojAction do
  describe "Get Build Number from Xcodeproj Integration" do
    before do
      copy_xcodeproj_fixtures
    end

    it "should return build number from Xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj
      end").runner.execute(:test)
      expect(result).to eq("1")
    end

    it "should set BUILD_NUMBER shared value" do
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj
      end").runner.execute(:test)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("1")
    end

    after do
      remove_xcodeproj_fixtures
    end
  end
end
