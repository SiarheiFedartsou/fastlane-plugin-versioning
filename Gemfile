source 'https://rubygems.org'

gemspec

gem 'rake'
gem 'webmock'
gem 'xcodeproj', git: 'https://github.com/CocoaPods/Xcodeproj.git', ref: 'e7b69aa'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
