$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/versioning' # import the actual plugin
require 'webmock/rspec'

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

def fake_api_responses
  source = "./spec/fixtures/responses/"
  destination = "/tmp/fastlane/tests/fastlane/responses/"

  FileUtils.cp_r(source, destination)

  fake_existing_response = File.read(File.join(destination, '/numbers_lookup_response'))
  stub_request(:get, "https://itunes.apple.com/lookup?bundleId=com.apple.Numbers&rand=123").to_return(fake_existing_response)
  fake_existing_in_country_response = File.read(File.join(destination, '/numbers_lookup_country_us_response'))
  stub_request(:get, "https://itunes.apple.com/lookup?bundleId=com.apple.Numbers&country=us&rand=123").to_return(fake_existing_in_country_response)
  fake_nonexistent_response = File.read(File.join(destination, '/nonexistent_lookup_response'))
  stub_request(:get, "https://itunes.apple.com/lookup?bundleId=com.some.nonexistent.app&rand=123").to_return(fake_nonexistent_response)
  fake_redirect_response = File.read(File.join(destination, '/found_redirect_response'))
  stub_request(:get, "https://itunes.apple.com/lookup?bundleId=com.apple.Numbers.with.redirect&rand=123").to_return(fake_redirect_response)
  stub_request(:get, "https://new.itunes.api.com/lookup?bundleId=com.apple.Numbers.with.redirect&rand=123").to_return(fake_existing_response)
  fake_internal_server_error_response = File.read(File.join(destination, '/internal_server_error_response'))
  stub_request(:get, "https://itunes.apple.com/lookup?bundleId=com.apple.with.error&rand=123").to_return(fake_internal_server_error_response)
end

def copy_info_plist_fixtures
  FileUtils.mkdir_p("/tmp/fastlane/tests/fastlane/plist")

  copy_non_literal_style_plist("InfoV2.plist")
  copy_literal_value_style_plist
end

def copy_literal_value_style_plist(filename = "Info.plist")
  FileUtils.mkdir_p("/tmp/fastlane/tests/fastlane/plist")
  source = "./spec/fixtures/plist/Info.plist"
  destination = File.join("/tmp/fastlane/tests/fastlane/plist/", filename)

  FileUtils.cp_r(source, destination)
end

def copy_non_literal_style_plist(filename = "Info.plist")
  FileUtils.mkdir_p("/tmp/fastlane/tests/fastlane/plist")
  source = "./spec/fixtures/plist/New-Info.plist"
  destination = File.join("/tmp/fastlane/tests/fastlane/plist/", filename)
  FileUtils.cp_r(source, destination)
end

def remove_info_plist_fixture
  FileUtils.rm_r("/tmp/fastlane/tests/fastlane/plist")
end

def copy_xcodeproj_fixtures
  # Create test folder
  FileUtils.mkdir_p("/tmp/fastlane/tests/fastlane/xcodeproj")
  source = "./spec/fixtures/xcodeproj"
  destination = "/tmp/fastlane/tests/fastlane"

  # Copy .xcodeproj fixtures, as it will be modified during the test
  FileUtils.cp_r(source, destination)
end

def remove_xcodeproj_fixtures
  FileUtils.rm_r("/tmp/fastlane/tests/fastlane/xcodeproj")
end

def cleanup_fixtures
  FileUtils.rm_r("/tmp/fastlane/tests/fastlane")
end

def line_from_file(line_number, file_path)
  File.open(file_path) do |f|
    (line_number-1).times { f.gets } # skip lines preceeding line N
    f.gets                 # read line N contents
  end
end