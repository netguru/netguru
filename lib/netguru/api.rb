require 'net/http'
require 'net/https'
require 'uri'

class Netguru::Api

  #shortcut for posting data over api
  def self.post(path, data)
    url = URI.parse("#{Netguru.config.api.url}/#{path}")
    req = Net::HTTP::Post.new(url.path)
    data.merge!(token: Netguru.config.api.token)
    req.set_form_data(data)
    request(url, req)
  end

  def self.get(path)
    url = URI.parse("#{Netguru.config.api.url}/#{path}")
    req = Net::HTTP::Get.new(url.path + "?token=#{Netguru.config.api.token}")
    request(url, req)
  end

  def self.request(url, req)
    sock = Net::HTTP.new(url.host, url.port)
    sock.use_ssl = (url.scheme == 'https')
    sock.start {|http| http.request(req) }.body
  end

end
