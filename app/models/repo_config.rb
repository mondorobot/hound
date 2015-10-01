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
  end

  private

  PARSERS = [
    Language,
    Legacy,
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
