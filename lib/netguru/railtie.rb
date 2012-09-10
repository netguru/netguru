require 'netguru/middleware/review'
module Netguru

  def self.application_name
    Rails.application.class.parent_name.downcase
  end

  class Railtie < Rails::Railtie

    def right_time_for_bullet?
      Time.now.tuesday? && Time.now.to_date.cweek.modulo(2).zero?
    end

    def may_bullet_be_initialized?
      defined?(Bullet) && Rails.env.development? && right_time?
    end

    if Rails.env.development?
      initializer "netguru.insert_middleware" do |app|
        app.config.middleware.use Netguru::Middleware::Review
      end

      if may_bullet_be_initialized?
        config.after_initialize do
          Bullet.enable = true
          Bullet.alert = true
          Bullet.bullet_logger = true
        end
      end

    end
  end
end
