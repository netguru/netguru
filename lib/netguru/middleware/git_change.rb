require 'open-uri'
module Netguru
  module Middleware
    class GitChange
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
            [status, headers, [response.body.gsub("</body>", "#{git_log}</body>")]]
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

      def git_log
        response = begin
          `cd #{Rails.root} && git log -g --pretty=format:"%ar" -1`
        rescue
          "Can't git log info."
        end
        %{
          <div id='git_log'>
          Last git action:
          #{response}
          </div>
          #{styles}
        }
      end

      def styles
        %{
          <style>
          #git_log {
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
