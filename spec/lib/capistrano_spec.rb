#require 'spec_helper'

require 'capistrano/configuration'
require 'netguru/capistrano'

describe Netguru::Capistrano do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.set(:application, 'dummy_test')
    @configuration.set(:stage, 'test')
    @configuration.set(:webserver, 'example.com')
    Netguru::Capistrano.load_into(@configuration)
    @configuration.dry_run = true

  end

  it "should define ng_conf" do
    @configuration.fetch(:ng_conf).should_not be_nil
  end

  # should "define airbrake:deploy task" do
  #   assert_not_nil @configuration.find_task('airbrake:deploy')
  # end

  # should "log when calling airbrake:deploy task" do
  #   @configuration.set(:current_revision, '084505b1c0e0bcf1526e673bb6ac99fbcb18aecc')
  #   @configuration.set(:repository, 'repository')
  #   io = StringIO.new
  #   logger = Capistrano::Logger.new(:output => io)
  #   logger.level = Capistrano::Logger::MAX_LEVEL
    
  #   @configuration.logger = logger
  #   @configuration.find_and_execute_task('airbrake:deploy')
    
  #   assert io.string.include?('** Notifying Airbrake of Deploy')
  #   assert io.string.include?('** Airbrake Notification Complete')
  # end
end