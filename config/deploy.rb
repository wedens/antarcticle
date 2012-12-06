require 'bundler/capistrano'
require 'rvm/capistrano'
load 'deploy/assets'

set :rvm_type, :system

set :application, "antarcticle"
set :repository,  "git@jtalks.org:antarcticle"
set :branch, "develop"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, "antarcticle"
set :deploy_to, "/home/antarcticle/apps/#{application}"
set :use_sudo, false
set :keep_releases, 3

role :web, "jtalks.org"                          # Your HTTP server, Apache/etc
role :app, "jtalks.org"                          # This may be the same as your `Web` server
role :db,  "jtalks.org", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}" # Using unicorn as the app server
    end
  end
end

task :symlink_configs do
  # database
  run "rm #{release_path}/config/database.yml"
  run "ln -sfn #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  # application
  run "ln -sfn #{shared_path}/config/application.yml #{release_path}/config/application.yml"
end
after "bundle:install", "symlink_configs"

namespace :rake_ do
  desc "Run a task on a remote server."
  # run like: cap rake_:invoke task=a_certain_task
  task :invoke do
    run("cd #{deploy_to}/current; /usr/bin/env rake #{ENV['task']} RAILS_ENV=#{rails_env}")
  end
end
