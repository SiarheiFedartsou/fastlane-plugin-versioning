# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/versioning/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-versioning'
  spec.version       = Fastlane::Versioning::VERSION
  spec.author        = %q{Siarhei Fiedartsou}
  spec.email         = %q{siarhei.fedartsou@gmail.com}

  spec.summary       = %q{Allows to work set/get app version directly to/from Info.plist}
  spec.homepage      = https://github.com/SiarheiFedartsou/fastlane-plugin-versioning
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'fastlane', '>= 1.93.1'
end
