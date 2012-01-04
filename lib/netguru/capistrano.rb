# Defines netguru custom task to deploy project.

require 'capistrano'

module Netguru
  module Capistrano
    def self.load_into(configuration)
      configuration.load do

        set(:ng_conf) { fetch(:ng_use, [:secondcoder, :airbrake]) }  

        set :rvm_ruby_string, "1.9.3"
        set :rvm_type, :system
        set :user, application
        set :user, "#{application}_beta" if stage == 'beta'
        set :rails_env, stage
        set :scm, :git
        set :repository,  "git@github.com:netguru/#{application}.git"
        set :remote, "origin"
        set :deploy_to, "/home/#{user}/app"
        server webserver, :app, :web, :db, :primary => true

        branches = {:production => :beta, :beta => :staging, :staging => :master}
        set(:branch) { branches[fetch(:stage).to_sym].to_s }
        

        set(:latest_release)  { fetch(:current_path) }
        set(:release_path)    { fetch(:current_path) }
        set(:current_release) { fetch(:current_path) }

        set(:current_revision)  { capture("cd #{current_path}; git rev-parse HEAD").strip }

        
        before "deploy:update_code" do
          run("cd #{current_path} && astrails-safe -v config/safe.rb --local") if stage == 'production' or stage == 'beta'
        end


        #check secondcoder
        before "deploy:update_code" do
          if ng_conf.include?(:secondcoder)
            standup_response = open("http://secondcoder.com/api/netguru/#{application}/check").read
            raise "Computer says no!\n#{standup_response}" unless standup_response == "OK"
          end
        end


        after "deploy:restart" do
          if ng_conf.include?(:airbrake)
            run "cd #{current_path} && #{runner} rake airbrake:deploy TO=#{stage} REVISION=#{current_revision} REPO=#{repository}"
          end
        end
      
      end
    end
  end
end


if Capistrano::Configuration.instance
  Netguru::Capistrano.load_into(Capistrano::Configuration.instance)
end
