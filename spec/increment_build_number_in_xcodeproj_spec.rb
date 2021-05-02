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

    def current_target_build_number
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj(target: 'versioning_fixture_project')
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

    it "should explicitly set a target build number if specified" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(build_number:'22', target: 'versioning_fixture_project')
      end").runner.execute(:test)

      expect(current_target_build_number).to eq("22")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("22")
    end

    it "should only change the configuration in the scheme specified" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme.xcodeproj',
          scheme: 'multischeme_a',
          build_configuration_name: 'ReleaseA')
      end").runner.execute(:test)

      expect(result).to eq("2") # this was 1, and has now had a bump
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("2")

      other_scheme_version = Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj(
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme.xcodeproj',
          scheme: 'multischeme_b',
          build_configuration_name: 'ReleaseB')
      end").runner.execute(:test)

      expect(other_scheme_version).to eq("4") # this was 4, and should stay as 4
    end

    it "should not crash when specifying build configuration name, target and project" do
      file = Fastlane::FastFile.new.parse("
        lane :increment do
          increment_build_number_in_xcodeproj(
            xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project.xcodeproj',
            target: 'versioning_fixture_project',
            build_configuration_name: 'Release'
          )
        end")
        
        expect { 
          result = file.runner.execute(:increment)
          expect(result).to eq("2")
        }.not_to raise_error
    end

    it "should not crash when specifying  build configuration name, target, project and build number" do
      file = Fastlane::FastFile.new.parse("
        lane :increment do
          increment_build_number_in_xcodeproj(
            xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project.xcodeproj',
            target: 'versioning_fixture_project',
            build_configuration_name: 'Release',
            build_number: '50'
          )
        end")
        
        expect { 
          result = file.runner.execute(:increment)
          expect(result).to eq("50")
        }.not_to raise_error
    end
    
    after do
      cleanup_fixtures
    end
  end
end
