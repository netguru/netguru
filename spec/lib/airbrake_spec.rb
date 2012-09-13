require 'spec_helper'

module Netguru
  describe Airbrake do
    before do
      Netguru.stub(:config).and_return(Konf.new({"airbrake" => { "project_id" => 'super_project' }}))
    end
    let(:airbrake){ Airbrake.new "secret" }
    let(:airbrake_error_response){ File.open(File.join(File.dirname(__FILE__),  "..", "xml", "airbrake_errors.xml")) }
    let(:airbrake_ok_response){ File.open(File.join(File.dirname(__FILE__), "..", "xml", "airbrake_ok.xml")) }

    it "initialize with auth token" do
      expect(airbrake.auth_token).to eq "secret"
    end

    it "return 2 when there is 2 errors" do
      stub_error_request
      expect(airbrake.errors_count).to eq 2
    end

    it "return 0 when there is no error" do
      stub_ok_request
      expect(airbrake.errors_count).to eq 0
    end

    it "stop deploy when airbrake errors are present" do
      stub_error_request
      expect{ airbrake.exec_capistrano_task }.to raise_error
    end

    it "pass deploy when airbrake has no errors" do
      stub_ok_request
      expect(airbrake.exec_capistrano_task).to eq "[airbrake] There are 0 errors - OK."
    end

    def stub_error_request
      stub_request(:get, "http://netguru.airbrake.io/projects/super_project/errors.xml?auth_token=secret").
        to_return(status: 200, body: airbrake_error_response, headers: {})
    end

    def stub_ok_request
      stub_request(:get, "http://netguru.airbrake.io/projects/super_project/errors.xml?auth_token=secret").
        to_return(status: 200, body: airbrake_ok_response, headers: {})
    end
  end
end
