require 'netguru/middleware/secondcoder'
module Netguru
  class Railtie < Rails::Railtie
    if Rails.env.development?
      initializer "netguru.insert_middleware" do |app|
        app.config.middleware.use Netguru::Middleware::Secondcoder
      end
    end
    rake_tasks do
      load "tasks/netguru.rake"
    end
  end
end
