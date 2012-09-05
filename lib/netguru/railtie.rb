require 'netguru/middleware/review'
module Netguru

  def self.application_name
    Rails.application.class.parent_name.downcase
  end

  class Railtie < Rails::Railtie
    if Rails.env.development?
      initializer "netguru.insert_middleware" do |app|
        app.config.middleware.use Netguru::Middleware::Review
      end
    end
  end
end
