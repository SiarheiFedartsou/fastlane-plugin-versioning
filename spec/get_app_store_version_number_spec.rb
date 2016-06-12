require 'spec_helper'
require 'webmock/rspec'

describe Fastlane::Actions::GetAppStoreVersionNumberAction do
  describe "Get App Store Version Number Integration" do
    before do
      copy_info_plist_fixture

      fake_existing_response = File.read('./spec/fixtures/responses/numbers_lookup_response')
      stub_request(:get, "http://itunes.apple.com/lookup?bundleId=com.apple.Numbers").to_return(fake_existing_response)
      fake_nonexistent_response = File.read('./spec/fixtures/responses/nonexistent_lookup_response')
      stub_request(:get, "http://itunes.apple.com/lookup?bundleId=com.some.nonexistent.app").to_return(fake_nonexistent_response)
    end

    it "should return current AppStore version number for app with provided bundle id" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_app_store_version_number(bundle_id: 'com.apple.Numbers')
      end").runner.execute(:test)
      expect(result).to eq("2.6.2")
    end

    it "should get bundle identifier from Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_app_store_version_number
      end").runner.execute(:test)
      expect(result).to eq("2.6.2")
    end

    it "should raise error if app with provided bundle id does not exists" do
      error_msg = "Cannot find app with com.some.nonexistent.app bundle ID in the App Store"
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          get_app_store_version_number(bundle_id: 'com.some.nonexistent.app')
        end").runner.execute(:test)
      end.to raise_error(error_msg)
    end

    after do
      remove_info_plist_fixture
    end
  end
end
