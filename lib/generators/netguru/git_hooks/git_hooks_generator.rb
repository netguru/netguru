class Netguru::GitHooksGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def install_hooks
    install_post_merge_hook
    chmod '.git/hooks/*', 0755
  end

  private

  def install_post_merge_hook
    template 'post-merge.sh', '.git/hooks/post-merge'
  end

end
