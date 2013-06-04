require 'spec_helper'

module Netguru
  describe Rollbar do
    before do
      Netguru.stub(:config).and_return(Konf.new({"rollbar" => { "token" => 'super_token' }}))
    end
    let(:rollbar){ Rollbar.new "super_token" }
    let(:rollbar_error_response){ File.read("./spec/json/rollbar_errors.json") }
    let(:rollbar_ok_response){ File.read("./spec/json/rollbar_ok.json") }

    it "initialize with auth token" do
      expect(rollbar.auth_token).to eq "super_token"
    end

    it "return 2 when there is 2 errors" do
      stub_error_request
      expect(rollbar.errors_count).to eq 2
    end

    it "return 0 when there is no error" do
      stub_ok_request
      expect(rollbar.errors_count).to eq 0
    end

    it "stop deploy when rollbar errors are present" do
      stub_error_request
      expect{ rollbar.exec_capistrano_task }.to raise_error
    end

    it "pass deploy when rollbar has no errors" do
      stub_ok_request
      expect(rollbar.exec_capistrano_task).to eq "[rollbar] There are 0 errors - OK."
    end

    def stub_error_request
      stub_request(:get, "https://api.rollbar.com/api/1/items/?access_token=super_token").
        to_return(status: 200, body: rollbar_error_response, headers: {})
    end

    def stub_ok_request
      stub_request(:get, "https://api.rollbar.com/api/1/items/?access_token=super_token").
        to_return(status: 200, body: rollbar_ok_response, headers: {})
    end
  end
end
