require 'spec_helper'

describe Fastlane::Actions::GetAppStoreVersionNumberAction do
  describe "Get App Store Version Number Integration" do
    before do
      copy_info_plist_fixtures
      fake_api_responses
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

    it "should return current AppStore version number for app with provided bundle id in given country" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_app_store_version_number(bundle_id: 'com.apple.Numbers', country: 'us')
      end").runner.execute(:test)
      expect(result).to eq("11.1")
    end

    it "should manage HTTP 302 redirect and return current AppStore version number for app with provided bundle id" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_app_store_version_number(bundle_id: 'com.apple.Numbers.with.redirect')
      end").runner.execute(:test)
      expect(result).to eq("2.6.2")
    end

    it "should return an error if a error response is handled" do
      error_msg = "Unexpected status code from iTunes Search API"
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          get_app_store_version_number(bundle_id: 'com.apple.with.error')
        end").runner.execute(:test)
      end.to raise_error(error_msg)
    end

    after do
      cleanup_fixtures
    end
  end
end
