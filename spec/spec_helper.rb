ENV["RAILS_ENV"] = "test"

require 'rspec'
require 'netguru'
require 'support/configuration_ext'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    Netguru.setup do |netguru_config|
      netguru_config.airbrake_account = "netguru"
      netguru_config.airbrake_project_id = "super_project"
    end
  end
end
