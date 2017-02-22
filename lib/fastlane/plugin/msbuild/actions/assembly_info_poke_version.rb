module Fastlane
  module Actions
    class AssemblyInfoPokeVersionAction < Action
      def self.fixup_version_string(version, revision)
        versions = version.split(".")
        versions.fill(0, versions.length...4)
        versions.map! { |x| x == '*' ? '0' : x }
        versions[3] = revision
        version_string = versions.join(".")
        return version_string
      end

      def self.run(params)
        revision = params[:rev_number]
        version = params[:version_number]

        if !!revision ^ !!version
          regex = /\[assembly\:\s*AssemblyVersion\("(?<version>\d+\.\d+\.[\d\*]+(\.[\d\*]+)?)\"\)\]/
          text = File.read(params[:file_path])

          out = File.open(params[:file_path], "w")
          text.each_line do |line|
            match = line.match(regex)
            if match
              version_string = version
              version_string = fixup_version_string(match["version"], revision) if version_string.nil?
              line.gsub!(regex, "[assembly: AssemblyVersion(\"#{version_string}\")]")
            end
            out.puts(line)
          end
          out.close
        else
          UI.error("You should supply rev_number or version_number but not both")
          raise
        end
      end

      def self.description
        "Set the version in an AssemblyInfo.cs file. Optionally only set the revision number"
      end

      def self.authors
        ["fuzzybinary"]
      end

      def self.details
        "Set the version in an AssemblyInfo.cs file. Optionally only set the revision number"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :file_path,
              env_name: 'FL_ASSEMBLY_INFO_FILE',
              description: 'path to AssemblyInfo.cs file',
              verify_block: proc do |value|
                UI.user_error!('File not found'.red) unless File.file? value
              end
          ),

          FastlaneCore::ConfigItem.new(
            key: :rev_number,
            optional: true,
            env_name: 'FL_ASSEMBLY_INFO_REVISION_NUMBER',
            description: 'Revision number',
            type: String
          ),

          FastlaneCore::ConfigItem.new(
            key: :version_number,
            optional: true,
            env_name: 'FL_ASSEMBLY_INFO_VERSION_NUMBER',
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
