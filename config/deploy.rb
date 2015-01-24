# config valid only for Capistrano 3.1
lock '3.3.5'

set :application, 'russ'
set :repo_url, 'https://github.com/ktachibana/russ.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '~/russ'

set :rbenv_type, :system # or :system, depends on your rbenv setup
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  before 'deploy:check:linked_files', :create_env do
    on roles(:app) do
      execute :touch, shared_path + '.env'
    end
  end

  task :published do
    invoke 'deploy:restart'
  end

  task :enable_god do
    on roles(:app) do
      upload! 'deploy/god.d/russ.god', '/etc/god.d/russ.god'
      execute :sudo, '/usr/local/rbenv/shims/god', 'load', '/etc/god.d/russ.god'
    end
  end

  %i[start stop restart].each do |action|
    desc 'Restart application'
    task action do
      on roles(:app), in: :sequence, wait: 5 do
        execute :sudo, action, 'russ'
      end
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
        execute :rake, 'tmp:cache:clear'
      end
    end
  end

  %w[start restart].each do |task|
    after task, :warmup_app do
      on roles(:app), in: :sequence do
        sleep 10
        execute 'curl -s http://localhost:8088/users/sign_in > /dev/null 2>&1'
      end
    end
  end
end
