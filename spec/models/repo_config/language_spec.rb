require "spec_helper"
require "app/models/repo_config/language"
require "app/models/repo_config/parser_error"

describe RepoConfig::Language do
  describe "#config" do
    context "given a language that is supported" do
      context "languages that are configured via YAML" do
        it "returns the configuration as a hash" do
          commit = stubbed_commit(
            "config/rubocop.yml" => <<-EOS.strip_heredoc
              StringLiterals:
                EnforcedStyle: single_quotes

              LineLength:
                Max: 90
            EOS
          )
          hound_config = double(
            "HoundConfig",
            commit: commit,
            config: {
              "ruby" => {
                "enabled" => true,
                "config_file" => "config/rubocop.yml",
              },
            },
          )
          language_config = RepoConfig::Language.new(hound_config)

          result = language_config.config("ruby")

          expect(result).to eq(
            "StringLiterals" => { "EnforcedStyle" => "single_quotes" },
            "LineLength" => { "Max" => 90 },
          )
        end

        context "when the config file is invalid" do
          context "with bad syntax" do
            it "raises RepoConfig::ParserError error" do
              commit = stubbed_commit(
                "config/rubocop.yml" => <<-EOS.strip_heredoc
                StringLiterals: !ruby/object
                  ;foo:
                EOS
              )
              hound_config = double(
                "HoundConfig",
                commit: commit,
                config: {
                  "ruby" => {
                    "enabled" => true,
                    "config_file" => "config/rubocop.yml",
                  },
                },
              )
              language_config = RepoConfig::Language.new(hound_config)

              expect do
                language_config.config("ruby")
              end.to raise_error do |error|
                expect(error).to be_a RepoConfig::ParserError
                expect(error.filename).to eq "config/rubocop.yml"
              end
            end
          end

          context "with unsafe yaml" do
            it "raises RepoConfig::ParserError error" do
              commit = stubbed_commit(
                "config/rubocop.yml" => <<-EOS.strip_heredoc
                StringLiterals: !ruby/object
                  ;foo:
                EOS
              )
              hound_config = double(
                "HoundConfig",
                commit: commit,
                config: {
                  "ruby" => {
                    "enabled" => true,
                    "config_file" => "config/rubocop.yml",
                  },
                }
              )
              language_config = RepoConfig::Language.new(hound_config)

              expect do
                language_config.config("ruby")
              end.to raise_error do |error|
                expect(error).to be_a RepoConfig::ParserError
                expect(error.message).to match(/Psych::DisallowedClass/)
              end
            end
          end
        end
      end

      context "languages that are configured via JSON" do
        context "when the configuration is valid" do
          it "returns the configuration as a hash" do
            commit = stubbed_commit(
              "config/coffeescript.json" => <<-EOS.strip_heredoc
                {
                  "no_unnecessary_double_quotes": {
                    "level": "error"
                  }
                }
              EOS
            )
            hound_config = double(
              "HoundConfig",
              commit: commit,
              config: {
                "coffeescript" => {
                  "enabled" => true,
                  "config_file" => "config/coffeescript.json",
                },
              },
            )
            language_config = RepoConfig::Language.new(hound_config)

            result = language_config.config("coffeescript")

            expect(result).to eq(
              "no_unnecessary_double_quotes" => { "level" => "error" },
            )
          end
        end

        context "when the config file-extension isn't .json" do
          it "returns the configuration as a hash" do
            commit = stubbed_commit(
              ".jshintrc" => <<-EOS.strip_heredoc
                {
                  "no_unnecessary_double_quotes": {
                    "level": "error"
                  }
                }
              EOS
            )
            hound_config = double(
              "HoundConfig",
              commit: commit,
              config: {
                "coffeescript" => {
                  "enabled" => true,
                  "config_file" => ".jshintrc",
                },
              },
            )
            language_config = RepoConfig::Language.new(hound_config)

            result = language_config.config("coffeescript")

            expect(result).to eq(
              "no_unnecessary_double_quotes" => { "level" => "error" },
            )
          end
        end

        context "when the configuration is invalid" do
          context "when the configuration contains invalid JSON format" do
            it "raises RepoConfig::ParserError" do
              commit = stubbed_commit(
                "config/coffeescript.json" => <<-EOS.strip_heredoc
                  {
                    "predef": ["myGlobal",]
                  }
                EOS
              )
              hound_config = double(
                "HoundConfig",
                commit: commit,
                config: {
                  "coffeescript" => {
                    "enabled" => true,
                    "config_file" => "config/coffeescript.json",
                  },
                },
              )
              language_config = RepoConfig::Language.new(hound_config)

              expect do
                language_config.config("coffeescript")
              end.to raise_error do |error|
                expect(error).to be_a RepoConfig::ParserError
                expect(error.filename).to eq "config/coffeescript.json"
              end
            end
          end
        end
      end

      context "when the config file has configured unsupported languages" do
        it "returns an empty hash" do
          commit = stubbed_commit("config/rubocop.yml" => "")
          hound_config = double(
            "HoundConfig",
            commit: commit,
            config: {
              "ruby" => {
                "enabled" => true,
                "config_file" => "config/rubocop.yml",
              },
            },
          )
          language_config = RepoConfig::Language.new(hound_config)

          result = language_config.config("coffeescript")

          expect(result).to eq({})
        end
      end
    end
  end

  describe "#raw_config" do
    context "when the given language has a configured config file" do
      it "returns the raw config" do
        raw_config = <<-EOS.strip_heredoc
          StringLiterals:
            EnforcedStyle: single_quotes

          LineLength:
            Max: 90
        EOS
        commit = stubbed_commit("config/rubocop.yml" => raw_config)
        hound_config = double(
          "HoundConfig",
          commit: commit,
          config: {
            "ruby" => {
              "enabled" => true,
              "config_file" => "config/rubocop.yml",
            },
          },
        )
        language_config = RepoConfig::Language.new(hound_config)

        result = language_config.raw_config("ruby")

        expect(result).to eq raw_config
      end
    end

    context "when the given language not dot have a configured config file" do
      it "returns an empty string" do
        raw_config = <<-EOS.strip_heredoc
          StringLiterals:
            EnforcedStyle: single_quotes

          LineLength:
            Max: 90
        EOS
        commit = stubbed_commit("config/rubocop.yml" => raw_config)
        hound_config = double(
          "HoundConfig",
          commit: commit,
          config: {
            "ruby" => {
              "enabled" => true,
              "config_file" => "",
            },
          },
        )
        language_config = RepoConfig::Language.new(hound_config)

        result = language_config.raw_config("ruby")

        expect(result).to eq ""
      end
    end
  end

  def stubbed_commit(configuration)
    commit = double("Commit", file_content: <<-EOS.strip_heredoc)
      ruby:
        enabled: true
        config_file: config/rubocop.yml
    EOS

    configuration.each do |filename, contents|
      allow(commit).to receive(:file_content).
        with(filename).and_return(contents)
    end

    commit
  end
end
