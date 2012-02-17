require 'spec_helper'
require 'netguru'
require 'netguru/middleware/secondcoder'
describe Netguru::Middleware::Secondcoder do
  it "should be a class" do
    Netguru::Middleware::Secondcoder.should be_a Class
  end
end
