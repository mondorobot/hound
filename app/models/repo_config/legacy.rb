module RepoConfig
  class Legacy
    pattr_initialize :commit, :hound_config

    def config(language)
      if legacy? && language == "ruby"
        hound_config.config
      else
        {}
      end
    end

    def raw_config(language)
      if legacy? && language == "ruby"
        hound_config.raw_config
      else
        ""
      end
    end

    private

    def legacy?
      (configured_languages & supported_languages).empty?
    end

    def configured_languages
      hound_config.config.keys
    end

    def supported_languages
      RepoConfig::Language::SUPPORTED_LANGUAGES
    end
  end
end
