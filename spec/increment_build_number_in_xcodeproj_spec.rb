require 'spec_helper'

describe Fastlane::Actions::IncrementBuildNumberInXcodeprojAction do
  describe "Increment Version Number in xcodeproj Integration" do

    before do
      copy_xcodeproj_fixtures
    end

    def current_build_number
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj
      end").runner.execute(:test)
    end

    it "should set explicitly provided version number to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(build_number: '1.9.4.1')
      end").runner.execute(:test)

      expect(current_build_number).to eq("1.9.4.1")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("1.9.4.1")
    end

    it "should increment build number by default and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj
      end").runner.execute(:test)

      expect(current_build_number).to eq("2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("2")
    end

    after do
      cleanup_fixtures
    end
  end
end
