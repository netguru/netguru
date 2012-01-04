require 'netguru/middleware'
module Netguru
  class Railtie < Rails::Railtie
    initializer "netguru.insert_middleware" do |app|
      app.config.middleware.use Netguru::Middleware
    end
  end
end