namespace :docker do
  desc 'Dockerコンテナをすべてビルドする'
  task :build do
    system('docker build -t russ/base .') || fail
    system('docker-compose build') || fail
  end
end
