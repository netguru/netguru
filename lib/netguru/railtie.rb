require 'netguru/middleware/review'
require 'netguru/lib/bullet_enabler'
module Netguru

  def self.application_name
    Rails.application.class.parent_name.downcase
  end

  class Railtie < Rails::Railtie
    if Rails.env.development?
      initializer "netguru.railties" do |app|
        app.config.middleware.use Netguru::Middleware::Review

        BulletEnabler.enable!(app)
      end
    end
  end
end
