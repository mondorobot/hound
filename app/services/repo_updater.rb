class RepoUpdater
  pattr_initialize :payload

  def run
    if repo
      repo.update_attributes(repo_attributes)
      deactive_repo(repo)
    end
  end

  private

  def repo
    @repo ||= Repo.active.find_by(github_id: payload.github_repo_id)
  end

  def repo_attributes
    {
      full_github_name: payload.full_repo_name,
      private: payload.private_repo?,
    }
  end

  def deactive_repo(repo)
    if repo.previous_changes[:private] == change_public_to_private
      repo.deactivate
    end
  end

  def change_public_to_private
    # Active Record Dirty objects keep track after save
    [false, true]
  end
end
