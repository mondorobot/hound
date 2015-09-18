# Filters files to reviewable subset.
# Builds style guide based on file extension.
# Delegates to style guide for line violations.
class StyleChecker
  pattr_initialize :pull_request, :build do
    @linters = {}
  end
  attr_private :linters

  def review_files
    commit_files_to_check.each do |commit_file|
      build_linter(commit_file.filename).file_review(commit_file)
    end
  end

  private

  def commit_files_to_check
    pull_request.commit_files.select do |file|
      linter = build_linter(file.filename)
      linter.enabled? && linter.file_included?(file)
    end
  end

  def build_linter(filename)
    linter_class = linter_class(filename)
    linters[linter_class] ||= linter_class.new(
      repo_config: config,
      build: build,
      repository_owner_name: pull_request.repository_owner_name,
    )
  end

  def linter_class(filename)
    Linter.for(filename)
  end

  def config
    @config ||= RepoConfig.new(pull_request.head_commit)
  end
end
