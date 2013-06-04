require 'spec_helper'
describe Netguru do
  it "is able to configure rollbar account through konf" do
    Konf.should_receive(:new)
    Netguru.config
  end
end
