$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/versioning' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

def copy_info_plist_fixture
  FileUtils.mkdir_p("/tmp/fastlane/tests/fastlane")
  source = "./spec/fixtures/plist/Info.plist"
  destination = "/tmp/fastlane/tests/fastlane/Info.plist"

  FileUtils.cp_r(source, destination)
end

def remove_info_plist_fixture
  FileUtils.rm_r("/tmp/fastlane/tests/fastlane")
end
