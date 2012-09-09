require 'open-uri'
require 'rexml/document'

module Netguru
  class Airbrake
    attr_accessor :auth_token, :errors_count

    def initialize auth_token
      @auth_token = auth_token
    end

    def errors_count
      return @errors_count unless @errors_count.nil?
      doc = REXML::Document.new open(url).read
      doc.root.elements.size
    end

    def exec_capistrano_task
      if errors_count > 0
        raise "[airbrake] Computer says no! - There are #{errors_count} errors. Please fix them."
      else
        "[airbrake] There are #{errors_count} errors - OK."
      end
    end

    private

    def url
      "http://#{Netguru.airbrake_account}.airbrake.io/projects/#{Netguru.airbrake_project_id}/errors.xml?auth_token=#{@auth_token}"
    end
  end
end
