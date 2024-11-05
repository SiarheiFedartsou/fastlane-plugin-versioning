module Fastlane
  module Actions
    class GetAppStoreVersionNumberAction < Action

      require 'json'
      require 'securerandom'

      def self.run(params)
        if params[:bundle_id]
          bundle_id = params[:bundle_id]
        else
          if Helper.test?
            plist = "/tmp/fastlane/tests/fastlane/plist/Info.plist"
          else
            plist = GetInfoPlistPathAction.run(params)
          end
          bundle_id = GetInfoPlistValueAction.run(path: plist, key: 'CFBundleIdentifier') # TODO: add same kind of flag to support build setting variables
        end

        random = Helper.test? ? "123" : SecureRandom.uuid

        if params[:country]
          uri = URI("https://itunes.apple.com/lookup?bundleId=#{bundle_id}&country=#{params[:country]}&rand=#{random}")
        else
          uri = URI("https://itunes.apple.com/lookup?bundleId=#{bundle_id}&rand=#{random}")
        end
        Net::HTTP.get(uri)

        response = Net::HTTP.get_response(uri)
        case response
        when Net::HTTPSuccess
          response_body = JSON.parse(response.body)
        when Net::HTTPRedirection
          UI.crash!("iTunes Search API resolved with status code 302, but no redirect url has been received") unless response['location']
          UI.important("iTunes Search API resolved with status code 302, redirecting to new url")

          new_url = response['location']
          response = Net::HTTP.get_response(URI(new_url))
          UI.crash!("Unexpected status code from iTunes Search API") unless response.kind_of?(Net::HTTPSuccess)

          response_body = JSON.parse(response.body)
        else
          UI.crash!("Unexpected status code from iTunes Search API")
        end

        UI.user_error!("Cannot find app with #{bundle_id} bundle ID in the App Store") if response_body["resultCount"] == 0

        response_body["results"][0]["version"]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the version number of your app in the App Store"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :bundle_id,
                             env_name: "FL_APPSTORE_VERSION_NUMBER_BUNDLE_ID",
                             description: "Bundle ID of the application",
                             optional: true,
                             conflicting_options: %i[xcodeproj target scheme build_configuration_name],
                             is_string: true),
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                             env_name: "FL_VERSION_NUMBER_PROJECT",
                             description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                             optional: true,
                             conflicting_options: [:bundle_id],
                             verify_block: proc do |value|
                               UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with? ".xcworkspace"
                               UI.user_error!("Could not find Xcode project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end),
          FastlaneCore::ConfigItem.new(key: :target,
                             env_name: "FL_VERSION_NUMBER_TARGET",
                             optional: true,
                             conflicting_options: %i[bundle_id scheme],
                             description: "Specify a specific target if you have multiple per project, optional"),
          FastlaneCore::ConfigItem.new(key: :scheme,
                             env_name: "FL_VERSION_NUMBER_SCHEME",
                             optional: true,
                             conflicting_options: %i[bundle_id target],
                             description: "Specify a specific scheme if you have multiple per project, optional"),
          FastlaneCore::ConfigItem.new(key: :build_configuration_name,
                             optional: true,
                             conflicting_options: [:bundle_id],
                             description: "Specify a specific build configuration if you have different Info.plist build settings for each configuration"),
          FastlaneCore::ConfigItem.new(key: :country,
                             optional: true,
                             description: "Pass an optional country code, if your app's availability is limited to specific countries",
                             is_string: true),
          FastlaneCore::ConfigItem.new(key: :skip_package_dependencies_resolution,
                             description: "Skips resolution of Swift Package Manager dependencies",
                             type: Boolean,
                             default_value: false)
        ]
      end

      def self.authors
        ["SiarheiFedartsou", "jdouglas-nz", "raymondjacobson"]
      end

      def self.is_supported?(platform)
        %i[ios mac].include? platform
      end
    end
  end
end
