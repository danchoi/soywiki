require 'pathname'

module PathHelper

  def repo_path=(repo_path)
    @repo_path = repo_path
  end

  def repo_path
    @repo_path
  end

  def repo_relative(path)
    ensure_path(path).relative_path_from(repo_path)
  end

  def in_repo(path)
    repo_path.join(path)
  end

  def ensure_path(path)
    path.is_a?(Pathname) ? path : Pathname.new(path)
  end
end
