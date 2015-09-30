require "spec_helper"
require "app/models/repo_config/hound"
require "app/models/repo_config/parser_error"

describe RepoConfig::Hound do
  describe "#[]" do
    it "delegates it to #config" do
      commit = stubbed_commit(
        RepoConfig::Hound::HOUND_CONFIG => <<-EOS.strip_heredoc
          ruby:
            enabled: true
            config_file: config/rubocop.yml
        EOS
      )
      hound_config = RepoConfig::Hound.new(commit)

      expect(hound_config["ruby"]).to eq(
        {
          "enabled" => true,
          "config_file" => "config/rubocop.yml",
        }
      )
    end
  end

  describe "#config" do
    context "when the configuration does not include legacy formatted keys" do
      it "returns the hound config as is" do
        commit = stubbed_commit(
          RepoConfig::Hound::HOUND_CONFIG => <<-EOS.strip_heredoc
            ruby:
              enabled: true
              config_file: config/rubocop.yml
          EOS
        )
        hound_config = RepoConfig::Hound.new(commit)

        expect(hound_config.config).to eq(
          "ruby" => {
            "enabled" => true,
            "config_file" => "config/rubocop.yml",
          }
        )
      end
    end

    context "when the configuration includes legacy formatted keys" do
      context "for coffee_script" do
        it "returns the hound config normalized" do
          commit = stubbed_commit(
            RepoConfig::Hound::HOUND_CONFIG => <<-EOS.strip_heredoc
              coffee_script:
                enabled: true
                config_file: config/coffeescript.json
            EOS
          )
          hound_config = RepoConfig::Hound.new(commit)

          expect(hound_config.config).to eq(
            "coffeescript" => {
              "enabled" => true,
              "config_file" => "config/coffeescript.json",
            }
          )
        end
      end
    end

    context "for java_script" do
      it "returns the hound config normalized" do
        commit = stubbed_commit(
          RepoConfig::Hound::HOUND_CONFIG => <<-EOS.strip_heredoc
            java_script:
              enabled: true
              config_file: config/javascript.json
          EOS
        )
        hound_config = RepoConfig::Hound.new(commit)

        expect(hound_config.config).to eq(
          "javascript" => {
            "enabled" => true,
            "config_file" => "config/javascript.json",
          }
        )
      end
    end
  end

  def stubbed_commit(configuration)
    commit = double("Commit")

    configuration.each do |filename, contents|
      allow(commit).to receive(:file_content).with(filename).
        and_return(contents)
    end

    commit
  end
end
