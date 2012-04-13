require 'spec_helper'


describe Netguru::Capistrano do

  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExt)
    @configuration.set :current_path, "/test"
    Netguru::Capistrano.load_into(@configuration)
  end

  it "define write_timestamp task" do
    @configuration.find_task('netguru:write_timestamp').should_not be_nil
  end

  it "write timestamp without format" do
    @configuration.find_and_execute_task('netguru:write_timestamp')
    @configuration.runs.has_key?("date > /test/app/views/layouts/_timestamp.html.haml").should be_true
  end

  it "write timestamp with format" do
    @configuration.set :date_format, "+'%d-%m-%y %R'"
    @configuration.find_and_execute_task('netguru:write_timestamp')
    @configuration.runs.has_key?("date +'%d-%m-%y %R' > /test/app/views/layouts/_timestamp.html.haml").should be_true
  end

end
