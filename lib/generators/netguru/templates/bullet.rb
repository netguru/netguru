def right_time?
  Time.now.tuesday? && Time.now.to_date.cweek.modulo(2).zero?
end

def may_be_initialized?
  defined?(Bullet) && Rails.env.development? && right_time?
end

if may_be_initialized?
  puts "CONGRATULATIONS! You'll work with bullet today, happy coding!"
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
end
