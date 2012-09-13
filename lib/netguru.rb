require "netguru/airbrake"
require "netguru/version"
require "netguru/capistrano"
require "netguru/railtie" if defined?(Rails) and Rails.version >= '3'
require "netguru/middleware/block"

module Netguru
  @@airbrake_account = 'netguru'
  def self.airbrake_account
    @@airbrake_account
  end

  def self.airbrake_account= value
    @@airbrake_account = value
  end

  @@airbrake_project_id = ''
  def self.airbrake_project_id
    @@airbrake_project_id
  end

  def self.airbrake_project_id= value
    @@airbrake_project_id = value
  end

  def self.setup
    yield self
  end
end
