module Fastlane
  module Actions
    class GetBuildNumberFromPlistAction < Action
      def self.run(params)
        if Helper.test?
          plist = "/tmp/fastlane/tests/fastlane/Info.plist"
        else
          plist = GetInfoPlistPathAction.run(params)
        end

        version_number = GetInfoPlistValueAction.run(path: plist, key: 'CFBundleVersion')
        # Store the number in the shared hash
        Actions.lane_context[SharedValues::BUILD_NUMBER] = version_number
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the build number of your project"
      end

      def self.details
        [
          "This action will return the current build number set on your project's Info.plist."
        ].join(' ')
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                             env_name: "FL_BUILD_NUMBER_PROJECT",
                             description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                             optional: true,
                             verify_block: proc do |value|
                               UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with? ".xcworkspace"
                               UI.user_error!("Could not find Xcode project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end),
          FastlaneCore::ConfigItem.new(key: :target,
                             env_name: "FL_BUILD_NUMBER_TARGET",
                             optional: true,
                             conflicting_options: [:scheme],
                             description: "Specify a specific target if you have multiple per project, optional"),
          FastlaneCore::ConfigItem.new(key: :scheme,
                             env_name: "FL_BUILD_NUMBER_SCHEME",
                             optional: true,
                             conflicting_options: [:target],
                             description: "Specify a specific scheme if you have multiple per project, optional"),
          FastlaneCore::ConfigItem.new(key: :build_configuration_name,
                             optional: true,
                             description: "Specify a specific build configuration if you have different Info.plist build settings for each configuration")

        ]
      end

      def self.output
        [
          ['BUILD_NUMBER', 'The build number']
        ]
      end

      def self.authors
        ["SiarheiFedartsou"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
