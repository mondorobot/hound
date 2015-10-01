module RepoConfig
  class Hound
    HOUND_CONFIG = ".hound.yml"

    attr_reader :commit

    def initialize(commit)
      @commit = commit
    end

    delegate :[], to: :config

    def config
      hound_config
    end

    private

    def hound_config
      @hound_config ||= load_hound_config
    end

    def load_hound_config
      config = load_config
      if config.is_a?(Hash)
        convert_legacy_keys(config)
      else
        {}
      end
    end

    def load_config
      YAML.safe_load content_for(HOUND_CONFIG), [Regexp]
    rescue Psych::Exception => exception
      raise_repo_config_parser_error(exception, HOUND_CONFIG)
    end

    def content_for(filepath)
      commit.file_content(filepath)
    end

    def raise_repo_config_parser_error(exception, filepath)
      message = "#{exception.class}: #{exception.message}"

      raise RepoConfig::ParserError.new(message, filename: filepath)
    end

    def convert_legacy_keys(config)
      converted_config = config.except("java_script", "coffee_script")

      if config["java_script"]
        converted_config["javascript"] = config["java_script"]
      end
      if config["coffee_script"]
        converted_config["coffeescript"] = config["coffee_script"]
      end

      converted_config
    end
  end
end
