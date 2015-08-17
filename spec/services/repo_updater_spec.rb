require "rails_helper"

describe RepoUpdater do
  describe "#run" do
    context "For an active repo" do
      it "updates the repo full_github_name" do
        expected_repo_name = "foo/bar"
        repo = create(:repo, :active)
        payload = double(
          "Payload",
          github_repo_id: repo.github_id,
          full_repo_name: expected_repo_name,
          private_repo?: repo.private,
        )

        RepoUpdater.new(payload).run

        repo.reload
        expect(repo.full_github_name).to eq(expected_repo_name)
      end

      it "updates the private flag for repo" do
        expected_status = true
        repo = create(:repo, :active)
        payload = double(
          "Payload",
          github_repo_id: repo.github_id,
          full_repo_name: repo.full_github_name,
          private_repo?: expected_status,
        )

        RepoUpdater.new(payload).run

        repo.reload
        expect(repo.private).to eq(expected_status)
      end

      context "when repo become private from public" do
        it "deactivates repo" do
          repo = create(:repo, :active, private: false)
          payload = double(
            "Payload",
            github_repo_id: repo.github_id,
            full_repo_name: repo.full_github_name,
            private_repo?: true,
          )

          RepoUpdater.new(payload).run

          repo.reload
          expect(repo).not_to be_active
        end
      end

      context "when repo become public from private" do
        it "will do nothing" do
          repo = create(:repo, :active, private: true)
          payload = double(
            "Payload",
            github_repo_id: repo.github_id,
            full_repo_name: repo.full_github_name,
            private_repo?: false,
          )

          RepoUpdater.new(payload).run

          repo.reload
          expect(repo).to be_active
        end
      end
    end

    context "for a inactive repo" do
      context "when repo become private from public" do
        it "will do nothing" do
          repo = create(:repo, :inactive, private: true)
          payload = double(
            "Payload",
            github_repo_id: repo.github_id,
            full_repo_name: repo.full_github_name,
            private_repo?: true,
          )

          RepoUpdater.new(payload).run

          repo.reload
          expect(repo).not_to be_active
        end
      end

      context "when repo become public from private" do
        it "will do nothing" do
          repo = create(:repo, :inactive, private: false)
          payload = double(
            "Payload",
            github_repo_id: repo.github_id,
            full_repo_name: repo.full_github_name,
            private_repo?: true,
          )

          RepoUpdater.new(payload).run

          repo.reload
          expect(repo).not_to be_active
        end
      end
    end
  end
end
