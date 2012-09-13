require 'spec_helper'
describe Netguru do
  it "define default airbrake account as 'netguru'" do
    expect(Netguru.airbrake_account).to eq "netguru"
  end

  it "be able to configure airbrake account through konf" do
    Konf.should_receive(:new)
    Netguru.config
  end
end
