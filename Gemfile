source 'https://rubygems.org'

gemspec

gem 'xcodeproj', '~> 1.1.0'
gem 'rake'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
