module Fastlane
  module Helper
    class VersioningHelper
      # class methods that you define here become available in your action
      # as `Helper::VersioningHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the versioning plugin helper!")
      end
    end
  end
end
