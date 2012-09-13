require "netguru/airbrake"
require "netguru/version"
require "netguru/capistrano"
require "netguru/railtie" if defined?(Rails) and Rails.version >= '3'
require "netguru/middleware/block"
require 'konf'
require 'pry'
module Netguru

  def self.airbrake_account
    "netguru"
  end

  def self.config
    @@config ||= Konf.new('config/netguru.yml')
  end
end
