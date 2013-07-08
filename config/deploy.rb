require 'bundler/capistrano'
require 'capistrano-rbenv'
set :application, 'russ'
set :repository, 'https://github.com/ktachibana/russ.git'
set :deploy_via, :copy
set :scm, :git
set :user, 'tachibana'

set :rbenv_path, '/usr/local/rbenv'
set :rbenv_ruby_version, File.read('.ruby-version').strip

default_run_options[:pty] = true

server "192.168.0.6", :web, :app, :db, primary: true

require 'whenever/capistrano'
set :whenever_command, 'bundle exec whenever'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
