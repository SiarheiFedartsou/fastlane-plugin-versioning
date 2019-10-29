require 'spec_helper'

describe Fastlane::Actions::GetInfoPlistPathAction do
  describe "Get Info.plist Path Integration" do
    before do
      copy_xcodeproj_fixtures
      copy_info_plist_fixtures
    end

    describe "for targets with the same Info.plist paths for all build configurations" do
      # Variables
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:fixtures_path) { "./spec/fixtures" }

      let (:xcodeproj_test_path) { File.join(test_path, "xcodeproj/") }
      let (:proj_file) { "bundle.xcodeproj" }

      # Action parameters
      let (:xcodeproj) { File.join(xcodeproj_test_path, proj_file) }
      let (:target) { "bundle" }

      it "should return Info.plist path with explicitly provided xcodeproj and target" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_path ({
            xcodeproj: '#{xcodeproj}',
            target: '#{target}'
          })
        end").runner.execute(:test)
        expect(result).to eq(File.join(xcodeproj_test_path, "bundle/Info.plist"))
      end

      it "should detect xcodeproj in the root directory and return Info.plist path for explicitly provided target" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_path ({
            target: '#{target}'
          })
        end").runner.execute(:test)
        expect(result).to eq(File.join(xcodeproj_test_path, "bundle/Info.plist"))
      end

      it "should detect target and return its Info.plist path for explicitly provided xcodeproj" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_path ({
            xcodeproj: '#{xcodeproj}'
          })
        end").runner.execute(:test)
        expect(result).to eq(File.join(xcodeproj_test_path, "bundle/Info.plist"))
      end

      it "should detect xcodeproj in the root directory and target and return its Info.plist path" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_path
        end").runner.execute(:test)
        expect(result).to eq(File.join(xcodeproj_test_path, "bundle/Info.plist"))
      end
    end

    describe "for targets with different Info.plist paths for all build configurations" do
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:fixtures_path) { "./spec/fixtures/xcodeproj" }

      let (:xcodeproj_test_path) { File.join(test_path, "xcodeproj/") }
      let (:proj_file) { "get_info_plist_path.xcodeproj" }

      # Action parameters
      let (:xcodeproj) { File.join(xcodeproj_test_path, proj_file) }
      let (:target) { "get_info_plist_path" }

      it "should return its Info.plist path" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_path ({
            xcodeproj: '#{xcodeproj}',
            target: '#{target}',
            build_configuration_name: 'Debug'
          })
        end").runner.execute(:test)
        expect(result).to eq(File.join(xcodeproj_test_path, "get_info_plist_path/Info_Debug.plist"))

        # it will also check an $(SRCROOT) substitution
        result = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_path ({
            xcodeproj: '#{xcodeproj}',
            target: '#{target}',
            build_configuration_name: 'Release'
          })
        end").runner.execute(:test)
        expect(result).to eq(File.join(xcodeproj_test_path, "get_info_plist_path/Info_Release.plist"))
      end
    end

    describe "for Info.plist path containing ${SRCROOT}" do
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:fixtures_path) { "./spec/fixtures/xcodeproj" }
      let (:xcodeproj_test_path) { File.join(test_path, "xcodeproj/") }

      let (:proj_file) { "get_info_plist_path2.xcodeproj" }

      let (:xcodeproj) { File.join(xcodeproj_test_path, proj_file) }
      let (:target) { "get_info_plist_path" }

      it "should substitute ${SRCROOT} variable with project root path" do
        result = Fastlane::FastFile.new.parse("lane :test do
        get_info_plist_path ({
          xcodeproj: '#{xcodeproj}',
          target: '#{target}',
          build_configuration_name: 'Release'
        })
        end").runner.execute(:test)
        expect(result).to eq(File.join(xcodeproj_test_path, "get_info_plist_path/Info_Release.plist"))
      end
    end

    after do
      cleanup_fixtures
    end
  end
end
