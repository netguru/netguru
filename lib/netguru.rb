require "netguru/version"
require "netguru/capistrano"
require "netguru/railtie" if defined?(Rails) and Rails.version >= '3'
require "netguru/middleware/block"

module Netguru
  # Your awesome code goes here...
end
