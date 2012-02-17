# -*- encoding : utf-8 -*-
# author: Aleksandr Koss - kossnocorp@gmail.com
# Nice to MIT you!
module Netguru
  module Middleware
    class Block
      def initialize app, options = {}
        @app = app
        @options = {
          :key => :staging_auth,
          :code_param => :code
        }.merge options
      end

      def call env
        request = Rack::Request.new env

        # Check code in cookie and return Rails call if is valid
        return @app.call(env) if request.path =~ /transactions|xml|rss|json|attachments|update_photo/ or code_valid?(request.cookies[@options[:key].to_s].to_s)

        # If post method check :code_param value
        if request.post? and code_valid? request.params[@options[:code_param].to_s]
          [301, {'Location' => request.path, 'Set-Cookie' => "#{@options[:key]}=#{request.params[@options[:code_param].to_s]}; domain=#{'.' + request.host}; expires=30-Dec-2039 23:59:59 GMT"}, ''] # Redirect if code is valid
        else
          [200, {'Content-Type' => 'text/html'}, [
            'Password: <form action="" method="post"><input type="password" name="code" /><input type="submit" /></form>'
            ]]
        end
      end

      private
      # Validate code

      def code_valid? code
        @options[:auth_codes].include? code.to_s
      end
    end
  end
end
