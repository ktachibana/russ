namespace :russ do
  desc 'Dockerイメージをビルドする'
  task build: %w(assets:clobber assets:precompile) do
    sh 'docker-compose build'
  end

  desc 'webpackでweb_modulesをビルドしてbundle.jsを作成する'
  task build_frontend: 'russ:routesjs' do
    chdir 'frontend' do
      sh 'npm run build'
    end
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

  desc 'デプロイする'
  task deploy: 'russ:build' do
    host = ENV['DEPLOY_HOST'] || abort('$DEPLOY_HOST required.')
    path = ENV['DEPLOY_PATH'] || abort('$DEPLOY_PATH required.')

    sh "scp ./docker-compose.yml #{host}:#{path}/"
    sh "DOCKER_HOST=tcp://#{host}:2375 rake russ:build"
    sh "ssh #{host} 'cd #{path}; docker-compose up -d'"
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

  namespace :dev do
    desc '開発環境のセットアップを行う'
    task setup: %w(db:setup russ:build_frontend russ:dev:env_file russ:dev:cert)

    desc '開発用にdocker-compose用の.envファイルを生成する'
    task :env_file do
      env_file = Pathname.pwd.join('.env')
      unless env_file.exist?
        secret = `bundle exec rake secret`.strip
        env_file.write(<<~EOS)
          SECRET_KEY_BASE=#{secret}
          VIRTUAL_HOST=localhost
        EOS
      end
    end

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
