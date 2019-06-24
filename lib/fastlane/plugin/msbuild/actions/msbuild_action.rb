module Fastlane
  module Actions
    class MsbuildAction < Action
      def self.run(params)
        configuration = params[:configuration]
        platform = params[:platform]
        solution = params[:solution]

        msbuild = params[:msbuild_path] ? File.join(params[:msbuild_path], "msbuild") : "msbuild"

        unless params[:build_ipa].nil?
          if params[:build_ipa] == true
            build_ipa = "true"
          else
            build_ipa = "false"
          end
        end

        command = "#{msbuild} \"#{solution}\""
        params[:targets].each do |target|
          command << " /t:\"#{target}\""
        end
        command << " /p:Configuration=\"#{configuration}\""
        command << " /p:Platform=\"#{platform}\"" if platform
        command << " /p:AndroidSdkDirectory=\"#{params[:android_home]}\"" if params[:android_home]
        command << " /p:BuildIpa=#{build_ipa}" if build_ipa
        params[:additional_arguments].each do |param|
          command << " #{param}"
        end

        FastlaneCore::CommandExecutor.execute(command: command, print_all: true, print_command: true)
      end

      def self.description
        "Build a Xamarin.iOS or Xamarin.Android project using msbuild"
      end

      def self.authors
        ["fuzzybinary"]
      end

      def self.details
        "Build a Xamarin.iOS or Xamarin.Android project using msbuild"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :solution,
              env_name: 'FL_MSBUILD_SOLUTION',
              description: 'path to .sln file',
              verify_block: proc do |value|
                UI.user_error!('File not found'.red) unless File.file? value
              end
          ),

          FastlaneCore::ConfigItem.new(
            key: :targets,
            env_name: 'FL_MSBUILD_TARGET',
            description: 'Targets to build',
            type: Array,
            verify_block: proc do |value|
              UI.user_error!('Must supply one target to msbuild'.red) unless value.length > 0
            end
          ),

          FastlaneCore::ConfigItem.new(
            key: :platform,
            optional: true,
            env_name: 'FL_MSBUILD_PLATFORM',
            description: 'build platform (usually iPhone, iPhoneSimulator, or Android)',
            type: String
          ),

          FastlaneCore::ConfigItem.new(
            key: :configuration,
            env_name: 'FL_MSBUILD_CONFIGURATION',
            description: 'Configuration build type',
            type: String
          ),

          FastlaneCore::ConfigItem.new(
            key: :additional_arguments,
            optional: true,
            env_name: 'FL_MSBUILD_ADDITIONAL_ARGS',
            description: "An array of Additional arguments to msbuild",
            type: Array,
            default_value: []
          ),

          FastlaneCore::ConfigItem.new(
            key: :android_home,
            optional: true,
            env_name: 'ANDROID_HOME',
            description: 'Location of the Anrdoid SDK (defaults to $ANDROID_HOME)',
            type: String
          ),

          FastlaneCore::ConfigItem.new(
            key: :msbuild_path,
            env_name: 'MSBUILD_PATH',
            description: "Location of msbuild",
            optional: true,
            type: String,
            default_value: nil
          ),

          FastlaneCore::ConfigItem.new(
            key: :build_ipa,
            env_name: 'FL_MSBUILD_BUILD_IPA',
            description: "Should build ipa in iOS build",
            optional: true,
            is_string: false,
            verify_block: proc do |value|
              UI.user_error!("Invalid value #{value}. It must either be true or false") unless [true, false].include?(value)
            end
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
