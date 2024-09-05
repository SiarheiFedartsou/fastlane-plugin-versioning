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

    it "should retrieve version from project level" do
      xcodeproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_at_project_level.xcodeproj"

      result = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(
          xcodeproj: '#{xcodeproj_path}',
        )
      end").runner.execute(:test)
      expect(result).to eq("0.1.0")
    end

    it "should not crash when specifying both build configuration name and target" do
      file = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(
          target: 'versioning_fixture_project',
          build_configuration_name: 'Release'
        )
      end")

      expect {
        result = file.runner.execute(:test)
        expect(result).to eq("0.0.1")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.1")
      }.not_to raise_error
    end

    it "should return a different result for Debug and Release if they are different" do
      xcodeproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_different_version_numbers.xcodeproj"

      release_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(
          xcodeproj: '#{xcodeproj_path}',
          target: 'versioning_fixture_project_different_version_numbers',
          build_configuration_name: 'Release'
        )
      end").runner.execute(:test)

      debug_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(
          xcodeproj: '#{xcodeproj_path}',
          target: 'versioning_fixture_project_different_version_numbers',
          build_configuration_name: 'Debug'
        )
      end").runner.execute(:test)

      expect(release_version).to eq("1.0.0")
      expect(debug_version).to eq("1.0.1")
    end

    after do
      cleanup_fixtures
    end
  end
end
