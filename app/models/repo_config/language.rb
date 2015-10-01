module RepoConfig
  class Language
    SUPPORTED_LANGUAGES = %w(
      coffeescript
      go
      haml
      javascript
      python
      ruby
      scss
      swift
    )

    pattr_initialize :hound_config

    def config(language)
      if has_language? language
        config_file_path = config_path_for(language)

        load_config(config_file_path, FILE_TYPES.fetch(language))
      else
        {}
      end
    end

    def raw_config(language)
      if has_language? language
        config_file_path = config_path_for(language)

        content_for(config_file_path)
      else
        ""
      end
    end

    private

    FILE_TYPES = {
      "coffeescript" => "json",
      "haml" => "yaml",
      "javascript" => "json",
      "ruby" => "yaml",
      "scss" => "yaml",
    }

    def has_language?(language)
      hound_config.config[language].present?
    end

    def config_path_for(language)
      hound_config.config[language] &&
        hound_config.config[language]["config_file"]
    end

    def load_config(filepath, filetype)
      if filetype == "yaml"
        load_yaml(filepath)
      elsif filetype == "json"
        load_json(filepath)
      else
        {}
      end
    end

    def load_yaml(filepath)
      YAML.safe_load content_for(filepath), [Regexp]
    rescue Psych::Exception => exception
      raise_repo_config_parser_error(exception, filepath)
    end

    def load_json(filepath)
      JSON.parse content_for(filepath)
    rescue JSON::ParserError => exception
      raise_repo_config_parser_error(exception, filepath)
    end

    def raise_repo_config_parser_error(exception, filepath)
      message = "#{exception.class}: #{exception.message}"

      raise RepoConfig::ParserError.new(message, filename: filepath)
    end

    def content_for(filepath)
      if filepath.present?
        hound_config.commit.file_content(filepath)
      else
        ""
      end
    end
  end
end
