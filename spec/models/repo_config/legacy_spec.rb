require "spec_helper"
require "app/models/repo_config/legacy"
require "app/models/repo_config/language"

describe RepoConfig::Legacy do
  describe "#config" do
    context "when the configuration is a legacy configuration" do
      context "when the given language is Ruby" do
        it "returns the configuration as a hash" do
          hound_config = double(
            "HoundConfig",
            config: {
              "StringLiterals" => { "EnforcedStyle" => "single_quotes" },
              "LineLength" => { "Max" => 90 },
            },
          )
          legacy_config = RepoConfig::Legacy.new(hound_config)

          result = legacy_config.config("ruby")

          expect(result).to eq hound_config.config
        end
      end
    end

    context "when the given language is not Ruby" do
      it "returns an empty hash" do
        hound_config = double(
          "HoundConfig",
          config: {
            "StringLiterals" => { "EnforcedStyle" => "single_quotes" },
            "LineLength" => { "Max" => 90 },
          },
        )
        legacy_config = RepoConfig::Legacy.new(hound_config)

        result = legacy_config.config("coffeescript")

        expect(result).to eq({})
      end
    end

    context "when the configuration is a not a legacy configuration" do
      it "returns an empty hash" do
        hound_config = double(
          "HoundConfig",
          config: {
            "ruby" => {
              "enabled" => true,
              "config_file" => "config/rubocop.yml",
            },
          },
        )
        legacy_config = RepoConfig::Legacy.new(hound_config)

        result = legacy_config.config("ruby")

        expect(result).to eq({})
      end
    end
  end

  describe "#raw_config" do
    context "when the configuration is a legacy configuration" do
      context "when the given language is Ruby" do
        it "returns the configuration as a string" do
          hound_config = double(
            "HoundConfig",
            config: {},
            raw_config: <<-EOS.strip_heredoc
              StringLiterals:
                EnforcedStyle: single_quotes

              LineLength:
                Max: 90
            EOS
          )
          legacy_config = RepoConfig::Legacy.new(hound_config)

          result = legacy_config.raw_config("ruby")

          expect(result).to eq hound_config.raw_config
        end
      end
    end

    context "when the given language is not Ruby" do
      it "returns an empty string" do
        hound_config = double(
          "HoundConfig",
          config: {},
          raw_config: <<-EOS.strip_heredoc
              StringLiterals:
                EnforcedStyle: single_quotes

              LineLength:
                Max: 90
          EOS
        )
        legacy_config = RepoConfig::Legacy.new(hound_config)

        result = legacy_config.raw_config("coffeescript")

        expect(result).to eq ""
      end
    end

    context "when the configuration is a not a legacy configuration" do
      it "returns an empty string" do
        hound_config = double(
          "HoundConfig",
          config: {
            "ruby" => {
              "enabled" => true,
              "config_file" => "config/rubocop.yml",
            },
          },
        )
        legacy_config = RepoConfig::Legacy.new(hound_config)

        result = legacy_config.raw_config("ruby")

        expect(result).to eq ""
      end
    end
  end
end
