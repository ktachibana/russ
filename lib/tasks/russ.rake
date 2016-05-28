namespace :russ do
  desc 'デプロイする'
  task :deploy do
    host = ENV['DEPLOY_HOST']
    docker_host = ENV['DOCKER_HOST'] || "tcp://#{host}:2375" # $DOCKER_HOSTが空白なら空白を使う

    system "DOCKER_HOST=#{docker_host} rake russ:build"
    system "DOCKER_HOST=#{docker_host} docker-compose up -d --build"
  end

  desc 'webpackでweb_modulesをビルドしてbundle.jsを作成する'
  task build_frontend: 'russ:routesjs' do
    chdir 'frontend' do
      sh 'npm run build'
    end
  end

  desc 'Dockerイメージをビルドする'
  task build: %w(assets:clobber assets:precompile) do
    sh 'docker build -t ktachiv/russ .'
  end

  desc 'RailsのルーティングをJSにexportするためのroutes.jsを生成する'
  task routesjs: :environment do
    content = <<~EOS
      (function() {
      #{JsRoutes.generate.indent(2)}
      }).call(module.exports);
    EOS
    Rails.root.join('frontend', 'web_modules', 'app').tap(&:mkpath).join('routes.js').write(content)
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

  desc 'config/vars/SECRET_KEY_BASEを生成する'
  task :write_secret, :overwrite do |_t, args|
    file = Pathname.pwd + 'config' + 'vars' + 'SECRET_KEY_BASE'
    exists = file.exist?

    if exists && !args[:overwrite]
      puts "#{file} exists."
      next
    end

    require 'securerandom'
    file.parent.mkpath
    file.write SecureRandom.hex(64)

    puts "#{file} #{exists ? 'changed' : 'created'}."
  end

  namespace :dev do
    desc '開発環境のセットアップを行う'
    task setup: %w(db:setup russ:build_frontend russ:dev:cert)

    desc '開発用に自己証明書を生成する'
    task :cert do
      mkpath 'tmp/dev_cert'
      chdir 'tmp/dev_cert' do
        sh 'openssl genrsa 2048 > localhost.key'
        sh 'openssl req -new -key localhost.key > server.csr'
        sh 'openssl x509 -days 3650 -req -signkey localhost.key < server.csr > localhost.crt'
        sh 'openssl dhparam 2048 -out localhost.dhparam.pem'
      end
    end
  end
end

namespace :assets do
  task precompile: 'russ:build_frontend'
end
