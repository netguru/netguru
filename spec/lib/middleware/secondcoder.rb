require 'spec_helper'
require 'netguru'
require 'netguru/middleware/review'
describe Netguru::Middleware::Review do
  it "should be a class" do
    Netguru::Middleware::Review.should be_a Class
  end
end
