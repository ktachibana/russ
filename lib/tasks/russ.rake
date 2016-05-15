namespace :russ do
  desc 'Dockerイメージをビルドする'
  task build: %w(assets:clobber assets:precompile) do
    system 'docker-compose build'
  end

  desc 'webpackでweb_modulesをビルドしてbundle.jsを作成する'
  task build_frontend: 'russ:routesjs' do
    system 'npm run build'
  end

  desc 'genrate routes.js'
  task routesjs: :environment do
    content = <<-EOS
(function() {
#{JsRoutes.generate.indent(2)}
}).call(module.exports);
    EOS
    Rails.root.join('web_modules', 'app').tap(&:mkpath).join('routes.js').write(content)
  end

  desc 'デプロイする'
  task deploy: 'russ:build' do
    host = ENV['DEPLOY_HOST'] || abort('$DEPLOY_HOST required.')
    path = ENV['DEPLOY_PATH'] || abort('$DEPLOY_PATH required.')

    system "scp ./docker-compose.yml #{host}:#{path}/"
    system "DOCKER_HOST=tcp://#{host}:2375 rake russ:build"
    system "ssh #{host} 'cd #{path}; docker-compose up -d'"
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

namespace :assets do
  task precompile: 'russ:build_frontend'
end
