require "app/models/repo_config/language"
require "app/models/repo_config/legacy"
require "app/models/repo_config/hound"

module RepoConfig
  def self.for(commit, language)
    hound_config = build_hound_config(commit)
    config = build_and_merge_configs(hound_config, language)

    Config.new(config: config, hound_config: hound_config)
  end

  class Config
    attr_reader :config, :hound_config

    def initialize(config:, hound_config:)
      @config = config
      @hound_config = hound_config
    end

    delegate :[], to: :hound_config

    def enabled_for?(language)
      !disabled?(language)
    end

    def raw_config
      # dump the formatted config.
    end

    private

    def beta?(language)
      Language::BETA_LANGUAGES.include?(language)
    end

    def default_options_for(language)
      { "enabled" => !beta?(language) }
    end

    def options_for(language)
      hound_config[language] ||
        hound_config[language_camelize(language)] ||
        default_options_for(language)
    end

    def disabled?(language)
      options = options_for(language)
      options["enabled"] == false || options["Enabled"] == false
    end

    def language_camelize(language)
      case language.downcase
      when "coffeescript"
        "CoffeeScript"
      when "javascript"
        "JavaScript"
      else
        language.camelize
      end
    end
  end

  private

  PARSERS = [
    RepoConfig::Language,
    RepoConfig::Legacy,
  ]

  def self.build_and_merge_configs(hound_config, language)
    configs = PARSERS.map do |config|
      config.new(hound_config).config(language)
    end

    configs.reduce({}) do |result, config|
      result.merge(config)
    end
  end

  def self.build_hound_config(commit)
    Hound.new(commit)
  end
end
