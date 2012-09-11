require 'spec_helper'

module Netguru
  module Middleware
    describe Block do
      it "should be a class" do
        Netguru::Middleware::Block.should be_a Class
      end

      describe "success rack response" do
        let(:block){ Block.new("app") }

        it "return 200 status code" do
          expect(block.success_rack_response[0]).to eq 200
        end

        it "return html" do
          expect(block.success_rack_response[2][0]).to include("password")
        end
      end
    end
  end
end
