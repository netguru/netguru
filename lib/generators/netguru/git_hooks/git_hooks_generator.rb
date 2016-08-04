class Netguru::GitHooksGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def install_hooks
    install_post_merge_hook
    install_prepare_commit_msg
  end

  private

  def install_post_merge_hook
    template 'post-merge.sh', '.git/hooks/post-merge'
    chmod '.git/hooks/post-merge', 0755
  end

  def install_prepare_commit_msg
    template 'prepare-commit-msg.sh', '.git/hooks/prepare-commit-msg'
    chmod '.git/hooks/prepare-commit-msg', 0755
  end

end
