require "spec_helper"
require "app/models/repository_config"

describe RepoConfig do
  describe ".for" do
    context "for a language based hound config" do
      it "returns the configs" do
        commit = stubbed_commit(
          "config/rubocop.yml" => <<-EOS.strip_heredoc
            StringLiterals:
              EnforcedStyle: single_quotes

            LineLength:
              Max: 90
          EOS
        )

        result = RepoConfig.for(commit, "ruby")

        expect(result.config).to eq(
          "StringLiterals" => { "EnforcedStyle" => "single_quotes" },
          "LineLength" => { "Max" => 90 },
        )
      end
    end

    context "for a rubocop based hound config" do
      it "returns the configs" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            StringLiterals:
              EnforcedStyle: single_quotes

            LineLength:
              Max: 90
          EOS
        )

        result = RepoConfig.for(commit, "ruby")

        expect(result.config).to eq(
          "StringLiterals" => { "EnforcedStyle" => "single_quotes" },
          "LineLength" => { "Max" => 90 },
        )
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
