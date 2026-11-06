require 'spec_helper'

describe Fastlane::Actions::IncrementVersionNumberInXcodeprojAction do
  describe "Increment Version Number in xcodeproj Integration" do

    before do
      copy_xcodeproj_fixtures
      copy_info_plist_fixtures
      fake_api_responses
    end

    def current_project_level_version(json_format: false)
      xcodeproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_at_project_level.xcodeproj"
      xcodeproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_at_project_level_xcproj.xcodeproj" if json_format

      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(
          json_format: #{json_format},
          xcodeproj: '#{xcodeproj_path}'
          )
      end").runner.execute(:test)
      version
    end

    def current_version(json_format: false)
      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: #{json_format})
      end").runner.execute(:test)
      version
    end

    def current_target_version(json_format: false)
      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: #{json_format}, target: 'versioning_fixture_project')
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

      expect(result).to eq("1.2.0") # this was 1.1.0, and has now had a minor bump
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.2.0")

      other_scheme_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme.xcodeproj',
          scheme: 'multischeme_b',
          build_configuration_name: 'ReleaseB')
      end").runner.execute(:test)

      expect(other_scheme_version).to eq("1.3.0") # this was 1.3.0, and should stay as 1.3.0
    end

    it "should increment the project level version" do
      expect(current_project_level_version).to eq("0.1.0")

      xcodeproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_at_project_level.xcodeproj"

      Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(
          xcodeproj: '#{xcodeproj_path}'
        )
      end").runner.execute(:test)

      expect(current_project_level_version).to eq("0.1.1") # this was 0.1.0, and has now had a patch bump
    end

    it "should set explicitly provided version number to xcproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, version_number: '1.9.4')
      end").runner.execute(:test)

      expect(current_version(json_format: true)).to eq("1.9.4")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.9.4")
    end

    it "should bump patch version by default and set it to xcproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true)
      end").runner.execute(:test)

      expect(current_version(json_format: true)).to eq("0.0.2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.2")
    end

    it "should bump patch version and set it to xcproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, bump_type: 'patch')
      end").runner.execute(:test)

      expect(current_version(json_format: true)).to eq("0.0.2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.2")
    end

    it "should bump minor version and set it to xcproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, bump_type: 'minor')
      end").runner.execute(:test)

      expect(current_version(json_format: true)).to eq("0.1.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.1.0")
    end

    it "should omit zero in patch version if omit_zero_patch_version is true with json_format: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, bump_type: 'minor', omit_zero_patch_version: true)
      end").runner.execute(:test)

      expect(current_version(json_format: true)).to eq("0.1")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.1")
    end

    it "should bump major version and set it to xcproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, bump_type: 'major')
      end").runner.execute(:test)

      expect(current_version(json_format: true)).to eq("1.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.0.0")
    end

    it "should bump version using App Store version as a source with json_format: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, bump_type: 'major', version_source: 'appstore')
      end").runner.execute(:test)

      expect(current_version(json_format: true)).to eq("3.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("3.0.0")
    end

    it "should explicitly set a target version number if specified with json_format: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, version_number:'1.0.0', target: 'versioning_fixture_project')
      end").runner.execute(:test)

      expect(current_target_version(json_format: true)).to eq("1.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.0.0")
    end


    it "should only change the configuration in the scheme specified with json_format: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, 
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme_xcproj.xcodeproj',
          scheme: 'multischeme_a',
          build_configuration_name: 'ReleaseA',
          bump_type: 'minor')
      end").runner.execute(:test)

      expect(result).to eq("1.2.0") # this was 1.1.0, and has now had a minor bump
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.2.0")

      other_scheme_version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true, 
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme_xcproj.xcodeproj',
          scheme: 'multischeme_b',
          build_configuration_name: 'ReleaseB')
      end").runner.execute(:test)

      expect(other_scheme_version).to eq("1.3.0") # this was 1.3.0, and should stay as 1.3.0
    end

    it "should increment the project level version with json_format: true" do
      expect(current_project_level_version(json_format: true)).to eq("0.1.0")

      xcproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_at_project_level_xcproj.xcodeproj"

      Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, 
          xcodeproj: '#{xcproj_path}'
        )
      end").runner.execute(:test)

      expect(current_project_level_version(json_format: true)).to eq("0.1.1") # this was 0.1.0, and has now had a patch bump
    end

    it "should update every configuration when versions differ per configuration with json_format: true" do
      xcproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_different_version_numbers_xcproj.xcodeproj"

      Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, xcodeproj: '#{xcproj_path}', version_number: '2.0.0')
      end").runner.execute(:test)

      %w(Debug Release).each do |configuration|
        version = Fastlane::FastFile.new.parse("lane :test do
          get_version_number_from_xcodeproj(json_format: true, 
            xcodeproj: '#{xcproj_path}',
            target: 'versioning_fixture_project_different_version_numbers',
            build_configuration_name: '#{configuration}')
        end").runner.execute(:test)
        expect(version).to eq("2.0.0")
      end
    end

    it "should only change the requested configuration of a target with json_format: true" do
      xcproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_xcproj.xcodeproj"

      Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, 
          xcodeproj: '#{xcproj_path}',
          target: 'versioning_fixture_project',
          build_configuration_name: 'Release',
          bump_type: 'minor')
      end").runner.execute(:test)

      versions = %w(Debug Release).map do |configuration|
        Fastlane::FastFile.new.parse("lane :test do
          get_version_number_from_xcodeproj(json_format: true, target: 'versioning_fixture_project',
            build_configuration_name: '#{configuration}')
        end").runner.execute(:test)
      end
      expect(versions).to eq(["0.0.1", "0.1.0"])
      project_file = File.read("#{xcproj_path}/project.xcproj")
      expect(project_file).to include(%(        "MARKETING_VERSION": "0.0.1",\n))
      expect(project_file).to include(%(        "MARKETING_VERSION[config=Release]": "0.1.0",\n))
    end

    it "should add build-settings to a target without them and keep the rest of the file with json_format: true" do
      xcproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/json5_features.xcodeproj"
      before = File.read("#{xcproj_path}/project.xcproj")

      Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, xcodeproj: '#{xcproj_path}', target: 'json5_features_widget', version_number: '9.9')
      end").runner.execute(:test)

      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true, xcodeproj: '#{xcproj_path}', target: 'json5_features_widget')
      end").runner.execute(:test)
      expect(version).to eq("9.9")

      after = File.read("#{xcproj_path}/project.xcproj")
      expect(after).to include(%(      "product-type": "app-extension",\n      "build-settings": {\n        "MARKETING_VERSION": "9.9",\n      },\n))
      expect(after.sub(%(      "build-settings": {\n        "MARKETING_VERSION": "9.9",\n      },\n), "")).to eq(before)
    end

    it "should keep the version of the other targets with json_format: true" do
      xcproj_path = "/tmp/fastlane/tests/fastlane/xcodeproj/json5_features.xcodeproj"

      Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(json_format: true, xcodeproj: '#{xcproj_path}', target: 'json5_features_widget', version_number: '9.9')
      end").runner.execute(:test)

      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(json_format: true, xcodeproj: '#{xcproj_path}', target: 'json5_features')
      end").runner.execute(:test)
      expect(version).to eq("2.3")
    end

    after do
      cleanup_fixtures
    end
  end
end
