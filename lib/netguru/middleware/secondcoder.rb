require 'open-uri'
module Netguru
  module Middleware
    class Secondcoder
      def initialize(app)
        @app = app
      end

      def call(env)
        original_response = @app.call(env)
        if env["REQUEST_PATH"] =~ /\/assets\//
          original_response
        elsif env["HTTP_ACCEPT"] =~ /html/
          status, headers, response = original_response
          if response.present? && response.body.respond_to?(:gsub)
            [status, headers, [response.body.gsub("</body>", "#{secondcoder_response}</body>")]]
          else
            original_response
          end
        else
          original_response
        end
      end

      def application_name
        Rails.application.class.parent_name.downcase
      end

      def secondcoder_response
        response = (timeout(0.5){ open("http://secondcoder.com/api/netguru/#{application_name}/check").read } rescue "To slow to access secondcoder.")
        %{
          <div id='secondcoder'>
          #{response}
          </div>
          #{styles}
        }
      end

      def styles
        %{
          <style>
          #secondcoder {
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
