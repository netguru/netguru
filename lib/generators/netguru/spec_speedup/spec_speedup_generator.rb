class Netguru::SpecSpeedupGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  def install
    install_garbage_collector
    turn_off_logs_in_test_env
  end

  private

  def install_garbage_collector
    puts "\nRunning garbage collector only after one in ten specs..."
    template 'garbage_collector.rb', 'spec/spec_helper/garbage_collector.rb'
    puts "Add require 'spec_helper/garbage_collector' to your spec_helper.rb"
  end

  def turn_off_logs_in_test_env
    puts "\nTurning off logging when running tests..."

    code = [
      "# Turn off logging when running tests",
      "config.log_level = :fatal"
    ].reverse

    code.each do |line|
      application line, env: 'test'
    end

  end
end
