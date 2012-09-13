require 'rails/generators'

class NetguruGenerator < Rails::Generators::Base

  def self.source_root
    @_netguru_source_root ||= File.expand_path("../../../generators/netguru/templates", __FILE__)
  end

  def install
    install_nginx
    install_capistrano
    install_konf
    install_rvm
    install_pow
  end

  private

  def install_pow
    template 'powrc', '.powrc'
  end

  def install_rvm
    template 'rvmrc', '.rvmrc'
  end

  def install_konf
    template 'preinitializer.rb', 'config/preinitializer.rb'
    template 'config.yml', 'config/config.yml'
    template 'netguru.yml', 'config/netguru.yml'
    template 'sec_config.yml.sample', 'config/sec_config.yml.sample'
    puts "Add require File.expand_path('../preinitializer', __FILE__) to your application.rb"
  end

  def install_capistrano
    template 'deploy.rb.erb', "config/deploy.rb"
    template 'Capfile', 'Capfile'
  end

  def install_nginx
    template 'nginx.staging.conf', "config/nginx.staging.#{Netguru.application_name}.conf"
  end

  def install_backup_mongo
    template "backup.rb.erb", "config/backup.rb"
    template "backup.rake", "lib/tasks/backup.rake"
    template "schedule.rb.erb", "config/schedule.rb"
  end

end
