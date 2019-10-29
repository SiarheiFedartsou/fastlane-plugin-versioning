require 'spec_helper'

describe Fastlane::Actions::IncrementBuildNumberInPlistAction do
  describe "Increment Build Number in Info.plist Integration" do
    let (:test_path) { "/tmp/fastlane/tests/fastlane" }
    let (:plist_file) { File.join("plist/", "Info.plist") }

    # Action parameters
    let (:info_plist_file) { File.join(test_path, plist_file) }

    before do
      copy_info_plist_fixtures
      copy_xcodeproj_fixtures
    end

    def current_build_number
      Fastlane::FastFile.new.parse("lane :test do
        get_info_plist_value(path: '#{info_plist_file}', key: 'CFBundleVersion')
      end").runner.execute(:test)
    end

    it "should set explicitly provided version number to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist(build_number: '1.9.4.1')
      end").runner.execute(:test)

      expect(current_build_number).to eq("1.9.4.1")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("1.9.4.1")
    end

    it "should increment build number by default and set it to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist
      end").runner.execute(:test)

      expect(current_build_number).to eq("0.9.14.2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("0.9.14.2")
    end

    after do
      cleanup_fixtures
    end
  end
end
