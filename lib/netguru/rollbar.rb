module Netguru
  class Rollbar
    attr_accessor :auth_token, :errors_count

    def initialize auth_token
      @auth_token = auth_token
    end

    def errors_count
      return @errors_count unless @errors_count.nil?
      response = prevent_from_parse_error(open(url).read)
      doc = JSON.parse(response)
      doc['result']['items'].count
    end

    def exec_capistrano_task
      if errors_count > 0
        errors = (errors_count == 20 ? "at least 20" : errors_count)
        raise "[rollbar] Computer says no! - There are #{errors} errors to fix. Check project's rollbar dashboard."
      else
        "[rollbar] There is no errors - OK."
      end
    end

    private

    def prevent_from_parse_error string
      string.gsub('\"/\"','//')
    end

    def url
      "https://api.rollbar.com/api/1/items/?access_token=#{@auth_token}&status=active"
    end

  end
end
