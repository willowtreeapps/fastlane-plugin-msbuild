require 'nokogiri'

module Fastlane
  module Actions
    class NuspecPokeVersionAction < Action
      def self.run(params)
        revision = params[:prerelease_version]
        version = params[:version_number]

        doc = Nokogiri::XML(File.open(params[:file_path]))

        version_node = doc.at_xpath("/package/metadata/version")
        version_string = version ? version : version_node.content
        if revision
          prerelease_index = version_string.index('-')
          version_string = version_string[0..(prerelease_index - version_string.length - 1)] if prerelease_index
          version_string << "-#{revision}"
        end
        version_node.content = version_string
        File.write(params[:file_path], doc.to_xml)
      end

      def self.description
        "Set the version in a Nuspec file. Optionally only set the revision number"
      end

      def self.authors
        ["fuzzybinary"]
      end

      def self.details
        "Set the version in a Nuspec file. Optionally only set the revision number"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :file_path,
            env_name: 'FL_NUSPEC_FILE',
            description: 'path to Nuspec file',
            verify_block: proc do |value|
              UI.user_error!('File not found'.red) unless File.file? value
            end
          ),

          FastlaneCore::ConfigItem.new(
            key: :prerelease_version,
            optional: true,
            env_name: 'FL_NUSPEC_PRERELEASE_VERSION',
            description: 'Prerelease version',
            type: String
          ),

          FastlaneCore::ConfigItem.new(
            key: :version_number,
            optional: true,
            env_name: 'FL_NUSPEC_VERSION_NUMBER',
            description: 'The full (4 component) version number for the assembly',
            type: String
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
