# fastlane-plugin-versioning `fastlane` Plugin

[![CI Status](http://img.shields.io/travis/SiarheiFedartsou/fastlane-plugin-versioning.svg?style=flat)](https://travis-ci.org/SiarheiFedartsou/fastlane-plugin-versioning)
[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-versioning)


## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with fastlane-plugin-versioning, add it to your project by running:

```bash
fastlane add_plugin versioning
```

## About versioning

Allows to work set/get app version directly to/from Info.plist

## Actions

### increment_version_number_in_plist

```ruby
increment_version_number_in_plist # Automatically increment patch version number.
increment_version_number_in_plist(
  bump_type: "patch" # Automatically increment patch version number
)
increment_version_number_in_plist(
  bump_type: "minor" # Automatically increment minor version number
)
increment_version_number_in_plist(
  bump_type: "major" # Automatically increment major version number
)
increment_version_number_in_plist(
  version_number: '2.1.1' # Set a specific version number
)

increment_version_number_in_plist(
  version_number: '2.1.1',                # specify specific version number (optional, omitting it increments patch version number)
  xcodeproj: './path/to/MyApp.xcodeproj'  # (optional, you must specify the path to your main Xcode project if it is not in the project root directory or you have a multiple xcodeproj's in the root directory)
  target: 'TestTarget' # (optional)
)
```

### get_version_number_from_plist


```ruby
version = get_version_number_from_plist(xcodeproj: "Project.xcodeproj", # optional
                                        target: 'TestTarget', # optional
                                        build_configuration_name: 'Release') # optional, must be specified if you have different Info.plist build settings for different build configurations
```

### get_info_plist_path

Get a path to target's Info.plist
```ruby
get_info_plist_path(xcodeproj: 'Test.xcodeproj', # optional
                       target: 'TestTarget', # optional
     build_configuration_name: 'Release' # optional, must be specified if you have different Info.plist build settings for different build configurations
                       )
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

For some more detailed help with plugins problems, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md) in the main `fastlane` repo.

## About `fastlane`

`fastlane` automates building, testing, and releasing your app for beta and app store distributions. To learn more about `fastlane`, check out [fastlane.tools](https://fastlane.tools).
