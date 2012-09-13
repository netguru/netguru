require 'spec_helper'

describe Netguru::Capistrano do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExt)
    @configuration.set :current_path, "/test"
    Netguru::Capistrano.load_into(@configuration)
  end

  describe "check Airbrake" do
    it "initialize Airbrake with variable from ENV" do
      ENV['AIRBRAKE_API_KEY'] = "secret"
      @configuration.set :stage, "production"
      airbrake = stub "Airbrake", exec_capistrano_task: true
      Netguru::Airbrake.should_receive(:new).with("secret").and_return airbrake
      @configuration.find_and_execute_task('netguru:check_airbrake')
    end

    it "doesn't check airbrake during deployment to staging" do
      @configuration.set :stage, "staging"
      Netguru::Airbrake.should_not_receive(:new)
      @configuration.find_and_execute_task('netguru:check_airbrake')
    end
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

  it "should tag with timestamp and stage" do
    @configuration.set :stage, 'production'
    time = Time.now.utc.strftime("%Y%m%d%H%M%S")
    @configuration.find_and_execute_task('netguru:tag_release')
    @configuration.runs.has_key?("cd /test && git tag #{time}-production && git push --tags").should be_true
  end
end
