require 'spec_helper'

describe Fastlane::Actions::IncrementBuildNumberInXcodeprojAction do
  describe "Increment Version Number in xcodeproj Integration" do

    before do
      copy_xcodeproj_fixtures
    end

    def current_build_number(json_format: false)
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj(json_format: #{json_format})
      end").runner.execute(:test)
    end

    def current_target_build_number(json_format: false)
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj(json_format: #{json_format}, target: 'versioning_fixture_project')
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

    it "should not bash any SwiftPM packages file guff" do
      file_path = '/tmp/fastlane/tests/fastlane/xcodeproj/swiftpm.xcodeproj'
      project_path = File.join(file_path, 'project.pbxproj')

      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(xcodeproj: '#{file_path}', build_number: '999')
      end").runner.execute(:test)
      
      expect(line_from_file(31, project_path)).not_to include("BuildFile ")
      expect(line_from_file(31, project_path)).to include("DeckOfPlayingCards in Frameworks")

      expect(line_from_file(14, project_path)).not_to include("BuildFile ")
      expect(line_from_file(14, project_path)).to include("DeckOfPlayingCards in Frameworks")

      expect(line_from_file(91, project_path)).not_to include("/* SwiftPackageProductDependency")
      expect(line_from_file(91, project_path)).to include("DeckOfPlayingCards")

      expect(line_from_file(121, project_path)).not_to include("/* RemoteSwiftPackageReference")
      expect(line_from_file(121, project_path)).to include('/* XCRemoteSwiftPackageReference "example-package-deckofplayingcards')

      expect(line_from_file(343, project_path)).not_to include("/* RemoteSwiftPackageReference")
      expect(line_from_file(343, project_path)).to include('* XCRemoteSwiftPackageReference "example-package-deckofplayingcards')

      expect(line_from_file(354, project_path)).not_to include("/* SwiftPackageProductDependency")
      expect(line_from_file(354, project_path)).to include("DeckOfPlayingCards")

      expect(line_from_file(356, project_path)).not_to include("/* RemoteSwiftPackageReference")
      expect(line_from_file(356, project_path)).to include('/* XCRemoteSwiftPackageReference "example-package-deckofplayingcards')
    end

    it "should set explicitly provided version number to xcproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(json_format: true, build_number: '1.9.4.1')
      end").runner.execute(:test)

      expect(current_build_number(json_format: true)).to eq("1.9.4.1")
      expect(File.read("/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_xcproj.xcodeproj/project.xcproj")).to include('"CURRENT_PROJECT_VERSION": "1.9.4.1",')
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("1.9.4.1")
    end

    it "should increment build number by default and set it to xcproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(json_format: true)
      end").runner.execute(:test)

      expect(current_build_number(json_format: true)).to eq("2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("2")
    end

    it "should explicitly set a target build number if specified with json_format: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(json_format: true, build_number:'22', target: 'versioning_fixture_project')
      end").runner.execute(:test)

      expect(current_target_build_number(json_format: true)).to eq("22")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("22")
    end

    it "should only change the configuration in the scheme specified with json_format: true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(json_format: true, 
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme_xcproj.xcodeproj',
          scheme: 'multischeme_a',
          build_configuration_name: 'ReleaseA')
      end").runner.execute(:test)

      expect(result).to eq("2") # this was 1, and has now had a bump
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("2")

      other_scheme_version = Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj(json_format: true, 
          xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/multischeme_xcproj.xcodeproj',
          scheme: 'multischeme_b',
          build_configuration_name: 'ReleaseB')
      end").runner.execute(:test)

      expect(other_scheme_version).to eq("4") # this was 4, and should stay as 4
    end

    it "should not crash when specifying build configuration name, target and project with json_format: true" do
      file = Fastlane::FastFile.new.parse("
        lane :increment do
          increment_build_number_in_xcodeproj(json_format: true, 
            xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_xcproj.xcodeproj',
            target: 'versioning_fixture_project',
            build_configuration_name: 'Release'
          )
        end")
      
        expect { 
          result = file.runner.execute(:increment)
          expect(result).to eq("2")
        }.not_to raise_error
    end

    it "should not crash when specifying  build configuration name, target, project and build number with json_format: true" do
      file = Fastlane::FastFile.new.parse("
        lane :increment do
          increment_build_number_in_xcodeproj(json_format: true, 
            xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_xcproj.xcodeproj',
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

    it "should only touch the build number and keep comments and formatting with json_format: true" do
      project_path = '/tmp/fastlane/tests/fastlane/xcodeproj/json5_features.xcodeproj/project.xcproj'
      before_lines = File.readlines(project_path)

      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(json_format: true, xcodeproj: '#{project_path}', build_number: '999')
      end").runner.execute(:test)

      expect(result).to eq("999")
      after_lines = File.readlines(project_path)
      expect(after_lines.count).to eq(before_lines.count)
      changed = after_lines.each_index.reject { |i| after_lines[i] == before_lines[i] }
      expect(changed).to eq([21])
      expect(after_lines[21]).to eq("        \"CURRENT_PROJECT_VERSION\": \"999\", // build number\n")
    end

    it "should accept the path to the project.xcproj file and to the .xcodeproj bundle" do
      %w(versioning_fixture_project_xcproj.xcodeproj versioning_fixture_project_xcproj.xcodeproj/project.xcproj).each_with_index do |path, index|
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_build_number_in_xcodeproj(json_format: true, xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/#{path}')
        end").runner.execute(:test)
        expect(result).to eq((index + 2).to_s)
      end
    end

    it "should update the project.xcproj instead of the project.pbxproj with json_format: true" do
      bundle = '/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project.xcodeproj'
      FileUtils.cp('/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project_xcproj.xcodeproj/project.xcproj', bundle)
      pbxproj = File.read(File.join(bundle, 'project.pbxproj'))

      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(xcodeproj: '#{bundle}', json_format: true, build_number: '77')
      end").runner.execute(:test)

      expect(result).to eq("77")
      expect(File.read(File.join(bundle, 'project.xcproj'))).to include('"CURRENT_PROJECT_VERSION": "77",')
      expect(File.read(File.join(bundle, 'project.pbxproj'))).to eq(pbxproj)
    end

    after do
      cleanup_fixtures
    end
  end
end
