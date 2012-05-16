# Defines netguru custom task to deploy project.
require 'open-uri'
require 'capistrano'

module Netguru
  module Capistrano
    def self.load_into(configuration)
      configuration.load do

        require 'rvm/capistrano'
        require 'bundler/capistrano'
        require 'hipchat/capistrano' if exists?(:hipchat_token)
        require 'open-uri'

        set :repository,  "git@github.com:netguru/#{application}.git"

        set :stage, 'staging' unless exists?(:stage)
        set(:rails_env) { fetch(:stage) }
        set :user, application
        set(:deploy_to) { "/home/#{fetch(:user)}/app" }
        set :rvm_type, :system

        branches = {:production => :beta, :beta => :staging, :staging => :master}
        set(:branch) { branches[fetch(:stage).to_sym].to_s } unless exists?(:branch)

        role(:db, :primary => true) { fetch(:webserver) }
        role(:app) { fetch(:webserver) }
        role(:web) { fetch(:webserver) }

        set :remote, "origin"
        set(:current_revision)  { capture("cd #{current_path}; git rev-parse HEAD").strip }

        set :scm, :git

        set(:latest_release)  { fetch(:current_path) }
        set(:release_path)    { fetch(:current_path) }
        set(:current_release) { fetch(:current_path) }

        set(:runner) { "RAILS_ENV=#{fetch(:stage)} bundle exec" }

        set :run_migrations, ENV['MIGRATIONS']
        set(:run_migrate) { fetch(:stage) == 'staging' ? true : (fetch(:run_migrations) == 'true' rescue false) }

        set :date_format, ''

        #basic 'github' style definition
        namespace :deploy do
          desc "Setup a GitHub-style deployment."
          task :setup, :except => { :no_release => true } do
            dirs = [deploy_to, shared_path]
            dirs += shared_children.map { |d| File.join(shared_path, d) }
            run "mkdir -p #{dirs.join(' ')} && chmod g+w #{dirs.join(' ')}"
            run "ssh-keyscan github.com >> /home/#{user}/.ssh/known_hosts"
            run "git clone #{repository} #{current_path}"
            run "cd #{current_path} && git checkout -b #{stage} ; git merge #{remote}/#{branch}; git push #{remote} #{stage}"
          end

          task :default do
            update
            migrate unless fetch(:skip_migrations, false)
            restart
          end

          task :symlink do
          end

          task :update do
            transaction do
              update_code
            end
          end

          task :quickfix do
            run "cd #{current_path} && git pull #{remote} #{stage} && touch tmp/restart.txt"
          end

          desc "revert your stage branch to specified timestamp and restart app (cap stage deploy:revert -s to=201205121417)"
          task :revert do
            raise "specify the revision you want to rollback to - cap stage deploy:revert -s to=201205121417" unless defined?(to)
            run "cd #{current_path} && get fetch --tags #{remote} && git checkout #{stage} -f && git reset --hard #{to}-#{stage} && git push #{remote} #{stage}"
          end

          task :migrate do
            run "cd #{current_path} && #{runner} rake db:migrate"
          end

          desc "Update the deployed code"
          task :update_code, :except => { :no_release => true } do
            run "cd #{current_path} && git fetch #{remote} && git checkout #{stage} -f && git merge #{remote}/#{branch} && git push #{remote} #{stage}"
          end

          desc "Restarts app"
          task :restart, :except => { :no_release => true } do
            run "touch #{current_path}/tmp/restart.txt"
          end
        end

        #common tasks
        before "deploy:update_code", "netguru:secondcoder"
        after "deploy:update_code", "bundle:install"
        after "deploy:update_code", "netguru:write_release"
        after "deploy:revert", "deploy:restart"

        namespace :netguru do
          #migrate data (for data-enabled projects)
          task :migrate_data do
            run("cd #{current_path} && #{runner} rake db:migrate:data")
          end
          #cleanup compiled assets (jammit setup)
          task :cleanup_compiled do
            run("rm -rf #{current_path}/public/javascripts/compiled/*")
          end
          #abort on pending migrations (you need to do them by hand)
          task :check_migrations do
            run("cd #{current_path} && #{runner} rake db:abort_if_pending_migrations")
          end
          #symlink solr solr dirs after setup
          task :symlink_solr do
            run("mkdir #{shared_path}/solr")
            run("ln -s #{shared_path}/solr #{current_path}/solr")
          end
          #write current release
          task :write_release do
            run("echo #{current_revision} > #{current_path}/RELEASE")
          end

          # write timestamp partial
          # override date_format variable to get different date format
          #
          # e.g.
          # set :date_format, "+'%d-%m-%y %R'"
          #
          task :write_timestamp do
            run "touch #{current_path}/app/views/layouts/_timestamp.html.haml"
            run "date #{date_format} > #{current_path}/app/views/layouts/_timestamp.html.haml".split.join(' ')
          end

          #finish code update
          task :finish_update do
            run("cd #{current_path} && #{runner} rake deploy:after_update_code")
          end
          #restart solr server
          task :start_solr do
            run("cd #{current_path} && #{runner} rake sunspot:solr:start ;true")
          end
          #rebuild sphinx server
          task :rebuild_sphinx do
            run("cd #{current_path} && #{runner} rake ts:config && #{runner} rake ts:rebuild")
          end
          #update whenever
          task :update_crontab do
            run "cd #{current_path} && #{runner} whenever --update-crontab #{application} --set environment=#{fetch(:stage)}"
          end
          #restart DJ
          task :restart_dj do
            run "cd #{current_path}; #{runner} script/delayed_job restart"
          end
          #precompile assets
          task :precompile do
            run "cd #{current_path} && #{runner} rake assets:precompile"
          end
          #backup db
          task :backup do
            run("cd #{current_path} && astrails-safe -v config/safe.rb --local") if stage == 'production' or stage == 'beta'
          end
          #notify ab
          task :notify_airbrake do
            run "cd #{current_path} && #{runner} rake airbrake:deploy TO=#{stage} REVISION=#{current_revision} REPO=#{repository}"
          end

          #ask sc
          task :secondcoder do
            standup_response = open("http://secondcoder.com/api/netguru/#{application}/check").read
            raise "Computer says no!\n#{standup_response}" unless standup_response == "OK"
          end

          #tag release with timestamp, e.g. 201206161435-production
          task :tag_release do
            run "cd #{current_path} && git tag #{Time.now.utc.strftime("%Y%m%d%H%M%S")}-#{stage} && git push --tags"
          end
        end

        namespace :log do
          task :default do
            run "tail -f #{current_path}/log/#{stage}.log"
          end
        end

      end
    end
  end
end


if Capistrano::Configuration.instance
  Netguru::Capistrano.load_into(Capistrano::Configuration.instance)
end
