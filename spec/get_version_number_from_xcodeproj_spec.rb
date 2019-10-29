require 'spec_helper'

describe Fastlane::Actions::GetVersionNumberFromXcodeprojAction do
  describe "Get Version Number from Xcodeproject" do
    before do
      copy_xcodeproj_fixtures
    end

    it "should return version number from Xcodeproject" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj
      end").runner.execute(:test)
      expect(result).to eq("0.0.1")
    end

    it "should set VERSION_NUMBER shared value" do
      Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj
      end").runner.execute(:test)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.1")
    end

    after do
      cleanup_fixtures
    end
  end
end
