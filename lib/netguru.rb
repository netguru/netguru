require "netguru/version"
require "netguru/capistrano"
require "netguru/railtie" if defined?(Rails) and Rails.version >= '3'
require "netguru/middleware/block"
require "netguru/api"
require 'konf'
require 'pry'
module Netguru
  def self.config
    @@config ||= Konf.new('config/netguru.yml')
  end

  def self.devtools
    config.fetch('devtools') { Konf.new({}) }
  end
end
