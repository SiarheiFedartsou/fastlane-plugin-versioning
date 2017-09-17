require 'spec_helper'

describe Fastlane::Actions::IncrementBuildNumberInPlistAction do
  describe "Increment Build Number in Info.plist Integration" do
    let (:test_path) { "/tmp/fastlane/tests/fastlane" }
    let (:fixtures_path) { "./spec/fixtures/plist" }
    let (:plist_file) { "Info.plist" }

    # Action parameters
    let (:info_plist_file) { File.join(test_path, plist_file) }

    before do
      FileUtils.mkdir_p(test_path)
      source = File.join(fixtures_path, plist_file)
      destination = File.join(test_path, plist_file)

      FileUtils.cp_r(source, destination)
    end

    def current_version
      Fastlane::FastFile.new.parse("lane :test do
        get_info_plist_value(path: '#{info_plist_file}', key: 'CFBundleVersion')
      end").runner.execute(:test)
    end

    it "should set explicitly provided version number to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist(build_number: '1.9.4.1')
      end").runner.execute(:test)

      expect(current_version).to eq("1.9.4.1")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("1.9.4.1")
    end

    it "should increment build number by default and set it to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_plist
      end").runner.execute(:test)

      expect(current_version).to eq("0.9.14.2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("0.9.14.2")
    end

    after do
      FileUtils.rm_r(test_path)
    end
  end
end
