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

        bv = BlockValidator.new(@options, request)
        return @app.call(env) if bv.valid?

        # If post method check :code_param value
        if request.post? and bv.valid_code?(request.params[@options[:code_param].to_s]) 
          [301, {'Location' => request.path, 'Set-Cookie' => "#{@options[:key]}=#{request.params[@options[:code_param].to_s]}; domain=#{'.' + request.host}; expires=30-Dec-2039 23:59:59 GMT"}, ['']] # Redirect if code is valid
        else
          [200, {'Content-Type' => 'text/html'}, [
            'Password: <form action="" method="post"><input type="password" name="code" /><input type="submit" /></form>'
          ]]
        end
      end
    end

    class BlockValidator
      attr_accessor :options, :request

      def initialize options, request
        @options = options
        @request = request
      end

      def valid?
        valid_path? || valid_code?(@request.cookies[@options[:key].to_s]) || valid_ip?
      end

      def valid_ip?
        return false if @options[:ip_whitelist].nil?
        @options[:ip_whitelist].include? @request.ip.to_s
      end

      def valid_path?
        @request.path =~ /transactions|xml|rss|json|attachments|update_photo/
      end

      def valid_code? code
        return false if @options[:auth_codes].nil?
        @options[:auth_codes].include? code
      end
    end
  end
end
