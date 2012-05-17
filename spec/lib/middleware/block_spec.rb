require 'spec_helper'
require 'netguru'
require 'netguru/middleware/block'

describe Netguru::Middleware::Block do

  it "should be a class" do
    Netguru::Middleware::Block.should be_a Class
  end

end
