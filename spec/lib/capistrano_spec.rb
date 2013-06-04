require 'spec_helper'

describe Netguru::Capistrano do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExt)
    @configuration.set :current_path, "/test"
    Netguru::Capistrano.load_into(@configuration)
  end

  describe "check Rollbar" do
    it "initialize Rollbar with variable from config" do
       Netguru.stub(:config).and_return(Konf.new({"rollbar" => { "token" => 'secret' }}))
      @configuration.set :stage, "production"
      rollbar = stub "Rollbar", exec_capistrano_task: true
      ::Netguru::Rollbar.should_receive(:new).with("secret").and_return rollbar
      @configuration.find_and_execute_task('netguru:check_rollbar')
    end

    it "doesn't check rollbar during deployment to staging" do
      @configuration.set :stage, "staging"
      ::Netguru::Rollbar.should_not_receive(:new)
      @configuration.find_and_execute_task('netguru:check_rollbar')
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
