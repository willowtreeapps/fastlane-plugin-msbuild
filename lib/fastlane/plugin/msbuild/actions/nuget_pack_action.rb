module Fastlane
  module Actions
    class NugetPackAction < Action
      def self.run(params)
        spec_file = params[:spec_file]

        nuget = params[:nuget_path] ? File.join(params[:nuget_path], "nuget") : "nuget"
        command = "#{nuget} pack #{spec_file}"
        command << " -OutputDirectory #{params[:out_dir]}" if params[:out_dir]

        FastlaneCore::CommandExecutor.execute(command: command, print_all: true, print_command: true)
      end

      def self.description
        "Package a nuspec"
      end

      def self.authors
        ["fuzzybinary"]
      end

      def self.details
        "Package a nuspec"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :spec_file,
            env_name: 'FL_NUGET_SPEC_FILE',
            description: 'path to .nuspec file',
            verify_block: proc do |value|
              UI.user_error!('File not found'.red) unless File.file? value
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :out_dir,
            env_name: 'FL_NUGET_OUT_DIR',
            description: 'directory to output nupkg',
            optional: true,
            default_value: nil
          ),
          FastlaneCore::ConfigItem.new(
            key: :nuget_path,
            env_name: 'NUGET_PATH',
            description: 'path to nuget',
            optional: true,
            default_value: nil
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
