require 'netguru/middleware/git_change'
module Netguru

  def self.application_name
    Rails.application.class.parent_name.downcase
  end
end
