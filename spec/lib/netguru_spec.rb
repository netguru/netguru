require 'spec_helper'

describe Netguru do
  it "define default airbrake account as 'netguru'" do
    expect(Netguru.airbrake_account).to eq "netguru"
  end

  it "be able to configure airbrake account" do
    Netguru.setup do |config|
      config.airbrake_account = "test"
    end
    expect(Netguru.airbrake_account.should).to eq "test"
  end
end
