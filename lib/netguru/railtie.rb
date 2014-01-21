require 'netguru/middleware/git_change'
require 'netguru/lib/bullet_enabler'
module Netguru

  def self.application_name
    Rails.application.class.parent_name.downcase
  end

  class Railtie < Rails::Railtie
    if Rails.env.development?
      initializer "netguru.railties" do |app|
        BulletEnabler.enable!(app)
      end
    end
  end
end
