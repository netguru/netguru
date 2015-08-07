# Defines netguru custom task to deploy project.
require 'open-uri'
require 'capistrano'
require 'json'
require 'netguru'

module Netguru
  module Capistrano
    def self.load_into(configuration)
      configuration.load do

        require 'rvm/capistrano'
        require 'bundler/capistrano'
        require 'open-uri'

        set :repository,  "git@github.com:netguru/#{application}.git"

        set :stage, 'staging' unless exists?(:stage)
        set(:rails_env) { fetch(:stage) }
        set :user, application
        set(:deploy_to) { "/home/#{fetch(:user)}/app" }
        set :rvm_type, :system
        set :rvm_path, "/usr/local/rvm"

        branches = {:production => :production, :beta => :beta, :staging => :master}
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
            run "cd #{current_path} && git branch --track #{branch} #{remote}/#{branch}; git checkout #{branch}"
          end

          task :default do
            transaction do
              update
              migrate unless fetch(:skip_migrations, false)
              restart
            end
          end

          task :symlink do
          end

          task :update do
            transaction do
              update_code
            end
          end

          task :quickfix do
            run "cd #{current_path} && git pull #{remote} #{branch} && touch tmp/restart.txt"
          end

          desc "revert your stage branch to specified timestamp and restart app (cap stage deploy:revert -s to=201205121417)"
          task :revert do
            raise "specify the revision you want to rollback to - cap stage deploy:revert -s to=201205121417" unless exists?(:to)
            run "cd #{current_path} && git fetch --tags #{remote} && git checkout #{branch} -f && git reset --hard #{to}-#{branch} git push --force #{branch} #{stage}"
          end

          task :migrate do
            run "cd #{current_path} && #{runner} rake db:migrate"
          end

          desc "Update the deployed code"
          task :update_code, :except => { :no_release => true } do
              run "cd #{current_path} && git checkout #{branch} && git pull origin #{branch}"
          end

          desc "Restarts app"
          task :restart, :except => { :no_release => true } do
            run "touch #{current_path}/tmp/restart.txt"
          end

        end

        #common tasks

        if fetch(:hipchat_token, false)
          before "deploy:update_code", "netguru:set_hipchat"
          after "deploy", "netguru:notify_hipchat"
        end

        after "deploy:update_code", "bundle:install"
        after "deploy:update_code", "netguru:write_release"
        after "deploy:update_code", "netguru:update_crontab"
        after "deploy:revert", "deploy:restart"
        after "deploy:restart", "netguru:notify_rollbar"


        # tag production releases by default
        after "production", "netguru:set_tagging"

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
            if fetch(:stage, 'staging') == 'production'
              run "cd #{current_path} && #{runner} whenever --update-crontab #{application} --set environment=#{fetch(:stage)}"
            end
          end
          #restart DJ
          task :restart_dj do
            set :workers, fetch(:dj_workers, 1)
            run "cd #{current_path}; #{runner} script/delayed_job restart -n #{workers}"
          end
          #precompile assets
          task :precompile do
            run "cd #{current_path} && #{runner} rake assets:precompile --trace"
          end
          #backup db
          task :backup do
            if fetch(:stage, 'staging') == 'production' or fetch(:stage, 'staging') == 'beta'
              run("cd #{current_path} && #{runner} rake netguru:backup[local]")
            end
          end
          #notify rb
          task :notify_rollbar, :roles => :app do
            set :revision, `git log -n 1 --pretty=format:"%H"`
            set :local_user, `whoami`
            set :rollbar_token, Netguru.config.rollbar.post_server_item_token
            rails_env = fetch(:rails_env, 'production')
            run "curl https://api.rollbar.com/api/1/deploy/ -F access_token=#{rollbar_token} -F environment=#{rails_env} -F revision=#{revision} -F local_username=#{local_user} >/dev/null 2>&1", :once => true
          end

          task :check_rollbar do
            #no-op
          end

          # tag release with timestamp, e.g. 201206161435-production
          # roles are not accepted in callbacks in capistrano
          task :tag_release do
            tag_release_web
          end
          task :tag_release_web, :roles => :web do
            run "cd #{current_path} && git tag #{Time.now.utc.strftime("%Y%m%d%H%M%S")}-#{stage} && git push --tags"
          end

          task :set_tagging do
            after "deploy:update_code", "netguru:tag_release"
          end

          # tasks for start/stop faye server
          task :start_faye do
            run "bundle exec rackup private_pub.ru -s thin -E production --pid #{current_path}/tmp/pids/faye.pid"
          end

          task :stop_faye do
            run 'kill -9 `cat #{current_path}/tmp/pids/faye.pid`'
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
