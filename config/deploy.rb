require 'bundler/capistrano'
require 'capistrano-rbenv'
require 'dotenv/capistrano'
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

namespace :deploy do
  [:start, :stop, :restart].each do |action|
    desc "#{action} application server."
    task action, roles: :app do
      sudo "god #{action} #{application}"
    end
  end
end

%w[deploy:start deploy:restart].each do |task|
  after task do
    sleep 10
    run 'curl -s http://localhost:8088/users/sign_in > /dev/null 2>&1'
  end
end
