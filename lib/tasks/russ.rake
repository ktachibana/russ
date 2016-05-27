namespace :russ do
  desc 'デプロイする'
  task :deploy do
    host = ENV['DEPLOY_HOST']
    docker_host = ENV['DOCKER_HOST'] || "tcp://#{host}:2375" # $DOCKER_HOSTが空白なら空白を使う

    system "DOCKER_HOST=#{docker_host} rake russ:build"
    system "DOCKER_HOST=#{docker_host} docker-compose up -d --build"
  end

  desc '開発用に自己証明書を生成する'
  task :dev_cert do
    FileUtils.mkpath 'tmp/dev_cert'
    FileUtils.chdir 'tmp/dev_cert' do
      system 'openssl genrsa 2048 > localhost.key'
      system 'openssl req -new -key localhost.key > server.csr'
      system 'openssl x509 -days 3650 -req -signkey localhost.key < server.csr > localhost.crt'
      system 'openssl dhparam 2048 -out localhost.dhparam.pem'
    end
  end

  desc 'Dockerイメージをビルドする'
  task build: %w(assets:clobber assets:precompile) do
    system 'docker build -t ktachiv/russ'
  end

  desc 'クローラーを定期実行する'
  task crawler: :environment do
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new
    scheduler.every '30m' do
      Feed.load_all!
    end
    scheduler.join
  end
end
