require 'spec_helper'
require 'netguru'
require 'netguru/middleware/block'

describe Netguru::Middleware::BlockValidator do
  let(:options){ Hash.new }

  describe "valid ip" do
    let(:options) { Hash[ip_whitelist: ["127.0.0.1"]] }
    it "be true when ip is whitelisted" do
      request = mock "Request", ip: "127.0.0.1"
      bv = Netguru::Middleware::BlockValidator.new(options, request)
      bv.valid_ip?.should be_true
    end

    it "be false when ip is not whitelisted" do
      request = mock "Request", ip: "192.168.0.1"
      bv = Netguru::Middleware::BlockValidator.new(options, request)
      bv.valid_ip?.should be_false
    end
  end

  describe "valid path" do
    it "be true when path looks like asset" do
      %w[transactions xml rss json attachments update_photo].each do |asset|
        request = mock "Request", path: asset 
        bv = Netguru::Middleware::BlockValidator.new(options, request)
        bv.valid_path?.should be_true
      end
    end

    it "be false when path doesn't looks like asset" do
      %w[products orders users].each do |asset|
        request = mock "Request", path: asset 
        bv = Netguru::Middleware::BlockValidator.new(options, request)
        bv.valid_path?.should be_false
      end
    end
  end

  describe "valid code" do
    let(:options) { Hash[auth_codes: ["secret"], key: :staging_auth] }
    let(:request) { mock "Request" }

    it "be true when code is correct" do
      bv = Netguru::Middleware::BlockValidator.new(options, request)
      bv.valid_code?("secret").should be_true
    end

    it "be false when code is incorrect" do
      bv = Netguru::Middleware::BlockValidator.new(options, request)
      bv.valid_code?("incorrect_secret").should be_false
    end
  end
end
