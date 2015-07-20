namespace :docker do
  desc 'Dockerコンテナをすべてビルドする. no_cache=yで--no-cache'
  task :build do
    no_cache = ('--no-cache' if ENV['no_cache'])
    system("docker build -t russ/base #{no_cache} .") || fail
    system("docker-compose build #{no_cache}") || fail
  end
end
