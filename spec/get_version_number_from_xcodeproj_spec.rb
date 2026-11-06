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

    it "should return version number from xcproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true)
      end").runner.execute(:test)
      expect(result).to eq("0.0.1")
    end

    it "should set VERSION_NUMBER shared value with json_format: true" do
      Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true)
      end").runner.execute(:test)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.1")
    end

    it "should retrieve version from project level with json_format: true" do
      xcproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_at_project_level_xcproj.xcodeproj"

      result = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true, 
          xcodeproj: '#{xcproj_path}',
        )
      end").runner.execute(:test)
      expect(result).to eq("0.1.0")
    end

    it "should not crash when specifying both build configuration name and target with json_format: true" do
      file = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true, target: 'versioning_fixture_project',
          build_configuration_name: 'Release'
        )
      end")

      expect {
        result = file.runner.execute(:test)
        expect(result).to eq("0.0.1")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.1")
      }.not_to raise_error
    end

    it "should return a different result for Debug and Release if they are different with json_format: true" do
      xcproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_different_version_numbers_xcproj.xcodeproj"

      release_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true, 
          xcodeproj: '#{xcproj_path}',
          target: 'versioning_fixture_project_different_version_numbers',
          build_configuration_name: 'Release'
        )
      end").runner.execute(:test)

      debug_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true, 
          xcodeproj: '#{xcproj_path}',
          target: 'versioning_fixture_project_different_version_numbers',
          build_configuration_name: 'Debug'
        )
      end").runner.execute(:test)

      expect(release_version).to eq("1.0.0")
      expect(debug_version).to eq("1.0.1")
    end

    it "should read the project.xcproj instead of the project.pbxproj with json_format: true" do
      bundle = '/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project.xcodeproj'
      FileUtils.cp('/tmp/fastlane/tests/fastlane/xcodeproj/json5_features.xcodeproj/project.xcproj', bundle)

      xcproj_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(xcodeproj: '#{bundle}', json_format: true)
      end").runner.execute(:test)
      pbxproj_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(xcodeproj: '#{bundle}', target: 'versioning_fixture_project')
      end").runner.execute(:test)

      expect(xcproj_version).to eq("2.3")
      expect(pbxproj_version).to eq("0.0.1")
    end

    after do
      cleanup_fixtures
    end
  end
end
