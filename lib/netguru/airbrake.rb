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
        raise "[airbrake] Computer says no! - There are #{errors_count} errors - check them out at #{project_url}"
      else
        "[airbrake] There are #{errors_count} errors - OK."
      end
    end

    private

    def url
      "#{project_url}/errors.xml?auth_token=#{@auth_token}"
    end

    def project_url
      "http://#{Netguru.airbrake_account}.airbrake.io/projects/#{Netguru.config.airbrake.project_id}"
    end
  end
end
