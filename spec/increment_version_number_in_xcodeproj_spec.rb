require 'spec_helper'

describe Fastlane::Actions::IncrementVersionNumberInXcodeprojAction do
  describe "Increment Version Number in xcodeproj Integration" do

    before do
      copy_xcodeproj_fixtures
      copy_info_plist_fixtures
      fake_api_responses
    end

    def current_version
      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj
      end").runner.execute(:test)
      version
    end

    def current_target_version
      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(target: 'versioning_fixture_project')
      end").runner.execute(:test)
      version
    end

    it "should set explicitly provided version number to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(version_number: '1.9.4')
      end").runner.execute(:test)

      expect(current_version).to eq("1.9.4")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.9.4")
    end

    it "should bump patch version by default and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj
      end").runner.execute(:test)

      expect(current_version).to eq("0.0.2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.2")
    end

    it "should bump patch version and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'patch')
      end").runner.execute(:test)

      expect(current_version).to eq("0.0.2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.2")
    end

    it "should bump minor version and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'minor')
      end").runner.execute(:test)

      expect(current_version).to eq("0.1.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.1.0")
    end

    it "should omit zero in patch version if omit_zero_patch_version is true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'minor', omit_zero_patch_version: true)
      end").runner.execute(:test)

      expect(current_version).to eq("0.1")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.1")
    end

    it "should bump major version and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'major')
      end").runner.execute(:test)

      expect(current_version).to eq("1.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.0.0")
    end

    it "should bump version using App Store version as a source" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'major', version_source: 'appstore')
      end").runner.execute(:test)

      expect(current_version).to eq("3.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("3.0.0")
    end

    it "should explicitly set a target version number if specified" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(version_number:'1.0.0', target: 'versioning_fixture_project')
      end").runner.execute(:test)

      expect(current_target_version).to eq("1.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.0.0")
    end


    it "should only change the configuration in the scheme specified" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme.xcodeproj',
          scheme: 'multischeme_a',
          build_configuration_name: 'ReleaseA',
          bump_type: 'minor')
      end").runner.execute(:test)

      expect(result).to eq("1.2.0") # this _was_ 1.1.0, and has now had a minor bump
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.2.0")

      other_scheme_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme.xcodeproj',
          scheme: 'multischeme_b',
          build_configuration_name: 'ReleaseB')
      end").runner.execute(:test)

      expect(other_scheme_version).to eq("1.3.0") # this was 1.3.0, and should stay as 1.3.0
    end
    
    after do
      cleanup_fixtures
    end
  end
end
