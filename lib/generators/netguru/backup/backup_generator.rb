class Netguru::BackupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def install
    install_safe
    install_rake
    install_schedule
    puts "Add astrails-safe or netguru-safe(mongodb) to your Gemfile manually."
    puts "Now go and visit config/safe.rb and lib/tasks/backup.rake to make sure you are using proper settings!"
  end

  private

  def install_safe
    template 'safe.rb.erb', 'config/safe.rb'
  end

  def install_rake
    template 'backup.rake.erb', 'lib/tasks/backup.rake'
  end

  def install_schedule
    template 'schedule.rb.erb', 'config/schedule.rb'
  end

end
