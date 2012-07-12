class Netguru::GitHooksGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def install_hooks
    install_post_merge_hook
    install_pre_commit_hook
  end

  private

  def install_post_merge_hook
    template 'post-merge.sh', '.git/hooks/post-merge'
    chmod '.git/hooks/post-merge', 0755
  end

  def install_pre_commit_hook
    template 'pre-commit.sh', '.git/hooks/pre-commit'
    chmod '.git/hooks/pre-commit', 0755
  end

end
