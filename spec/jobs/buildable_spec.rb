require "rails_helper"

describe Buildable do
  class BuildableTestJob < ActiveJob::Base
    include Buildable
  end

  describe "perform" do
    it 'runs build runner' do
      build_runner = double(:build_runner, run: nil)
      payload_data = "some data"
      payload = double("Payload", github_repo_id: 1)
      allow(Payload).to receive(:new).with(payload_data).and_return(payload)
      allow(BuildRunner).to receive(:new).and_return(build_runner)

      BuildableTestJob.perform_now(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(BuildRunner).to have_received(:new).with(payload)
      expect(build_runner).to have_received(:run)
    end

    it "runs repo updater" do
      repo_updater = double(:repo_updater, run: nil)
      payload = double("Payload", github_repo_id: 1)
      allow(Payload).to receive(:new).with(payload_data).and_return(payload)
      allow(RepoUpdater).to receive(:new).and_return(repo_updater)

      BuildableTestJob.perform_now(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(RepoUpdater).to have_received(:new).with(payload)
      expect(repo_updater).to have_received(:run)
    end
  end

  describe "#after_retry_exhausted" do
    it "sets internal server error on github" do
      build_runner = double(:build_runner, set_internal_error: nil)
      payload = double("Payload")
      allow(Payload).to receive(:new).with(payload_data).and_return(payload)
      allow(BuildRunner).to receive(:new).and_return(build_runner)

      BuildableTestJob.new(payload_data).after_retry_exhausted

      expect(Payload).to have_received(:new).with(payload_data)
      expect(BuildRunner).to have_received(:new).with(payload)
      expect(build_runner).to have_received(:set_internal_error)
    end
  end

  def payload_data(github_id: 1234, name: "test")
    {
      "repository" => {
        "owner" => {
          "id" => github_id,
          "login" => name,
          "type" => "Organization"
        }
      }
    }
  end
end
