require 'rails/generators'

class NetguruGenerator < Rails::Generators::Base

  def self.source_root
    @_netguru_source_root ||= File.expand_path("../../../generators/netguru/templates", __FILE__)
  end

  def install
    install_nginx
    install_capistrano
    install_konf
  end

  private

  def install_konf
    template 'preinitializer.rb', 'config/preinitializer.rb'
    template 'config.yml', 'config/config.yml'
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

end
