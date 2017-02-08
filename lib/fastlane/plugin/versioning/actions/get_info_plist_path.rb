module Fastlane
  module Actions
    class GetInfoPlistPathAction < Action
      require 'xcodeproj'
      require 'pathname'

      def self.run(params)
        unless params[:xcodeproj]
          if Helper.test?
            params[:xcodeproj] = "/tmp/fastlane/tests/fastlane/bundle.xcodeproj"
          else
            params[:xcodeproj] = Dir["*.xcodeproj"][0] unless params[:xcodeproj]
          end
        end

        config = {project: params[:xcodeproj], scheme: params[:target], configuration: params[:build_configuration_name]}
        project = FastlaneCore::Project.new(config)
        project.select_scheme

        path = project.build_settings(key: 'INFOPLIST_FILE')
        unless (Pathname.new path).absolute?
          path = File.join(Pathname.new(project.path).parent.to_path, path)
        end

        path
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the version number of your project"
      end

      def self.details
        [
          "This action will return path to Info.plist for specific target in your project."
        ].join(' ')
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                             env_name: "FL_INFO_PLIST_PROJECT",
                             description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory or if you have multiple *.xcodeproj's in the root directory",
                             optional: true,
                             verify_block: proc do |value|
                               UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with? ".xcworkspace"
                               UI.user_error!("Could not find Xcode project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end),
          FastlaneCore::ConfigItem.new(key: :target,
                             env_name: "FL_INFO_PLIST_TARGET",
                             optional: true,
                             description: "Specify a specific target if you have multiple per project, optional"),
          FastlaneCore::ConfigItem.new(key: :build_configuration_name,
                             optional: true,
                             description: "Specify a specific build configuration if you have different Info.plist build settings for each configuration")

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
