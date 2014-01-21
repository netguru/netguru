class BulletEnabler
  class << self
    def enable!(app)
      app.config.after_initialize do
        require "bullet"
        Bullet.enable = true
        Bullet.alert = true
        Bullet.bullet_logger = true
      end if enabled? && right_time_for_bullet?
    end

    def enabled?
      Netguru.devtools.fetch('bullet'){ true }
    end

    def right_time_for_bullet?
      Time.now.tuesday? && Time.now.to_date.cweek.modulo(2).zero?
    end
  end
end
