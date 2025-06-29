source 'https://rubygems.org'

gemspec

gem 'rake'
gem 'webmock'
gem 'xcodeproj'

# Ruby 3.4+ compatibility - these gems are no longer default gems
# Added unconditionally to ensure they're available in CI environments
gem 'abbrev'
gem 'mutex_m'
gem 'logger'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
