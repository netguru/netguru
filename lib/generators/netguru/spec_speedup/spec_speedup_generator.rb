class Netguru::SpecSpeedupGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  def install
    install_garbage_collector
  end

  private

  def install_garbage_collector
    template 'garbage_collector.rb', 'spec/spec_helper/garbage_collector.rb'
    puts "Add require 'spec_helper/garbage_collector' to your spec_helper.rb"
  end
end
