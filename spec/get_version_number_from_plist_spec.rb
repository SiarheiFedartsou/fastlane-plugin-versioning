require 'spec_helper'

describe Fastlane::Actions::GetVersionNumberFromPlistAction do
  describe "Get Version Number from Info.plist Integration" do

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

    it "should return version number from Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_plist
      end").runner.execute(:test)
      expect(result).to eq("0.9.14")
    end

    it "should set VERSION_NUMBER shared value" do
      Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_plist
      end").runner.execute(:test)
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.9.14")
    end

    after do
      FileUtils.rm_r(test_path)
    end

  end
end
