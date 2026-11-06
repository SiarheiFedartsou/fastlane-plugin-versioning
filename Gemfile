source 'https://rubygems.org'

gemspec

gem 'rake'
gem 'webmock'
gem 'xcodeproj'
# Ruby 3
gem 'abbrev'
gem 'mutex_m'
gem 'logger'
# Ruby 4
gem 'ostruct'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
