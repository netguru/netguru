require 'open-uri'
module Netguru
  module Middleware
    class Review
      def initialize(app)
        @app = app
      end

      def call(env)
        original_response = @app.call(env)
        path = env["REQUEST_PATH"] || env["PATH_INFO"] #legacy issues
        if path =~ /\/assets\// or path =~ /\/.+\..+/ #igonore formatted requests like users.json etc
          original_response
        elsif env["HTTP_ACCEPT"] =~ /html/
          status, headers, response = original_response
          if response.present? && response.respond_to?(:body) && response.body.respond_to?(:gsub)
            [status, headers, [response.body.gsub("</body>", "#{review_response}</body>")]]
          else
            original_response
          end
        else
          original_response
        end
      end

      def application_name
        Netguru.application_name
      end

      def review_response
          response = begin
            timeout(0.5) do
              res = JSON.parse(open("http://dashboard.netguru.pl/netguru/#{application_name}/commits/check.json").read)
              if res['commits'] and res['commits']['rejected'].to_i > 0
                "There are #{res['commits']['rejected']} rejected commits - #{res['commits']['url']}"
              else
                "Pending #{res['commits']['rejected']}, passed #{res['commits']['rejected']}"
              end
            end
          rescue
            "Can't access review info."
          end
        %{
          <div id='review'>
          #{response}
          </div>
          #{styles}
        }
      end

      def styles
        %{
          <style>
          #review {
          position: fixed;
          top: 10px;
          right: 10px;
          color: #990000;
          background-color: white;
          padding: 2px 5px;
          font-size: 12px;
          border-radius: 5px;
          font-face: "Helvetica Neue",Helvetica,Arial,sans-serif";
          border: 2px solid #990000;
        }
        </style>
      }
    end


  end
end
end
