desc 'デプロイする'
task deploy: 'deploy:build_app' do
  sh "docker-compose up -d --build"
end

namespace :deploy do
  desc 'メインとなるappのDockerイメージをビルドする'
  task build_app: :frontend do
    sh 'docker build -t ktachiv/russ .'
  end

  namespace :to do
    desc '本番環境にデプロイする'
    task :production do
      abort('assets:precompileをproductionで行うため RAILS_ENV=production を指定してください') if ENV['RAILS_ENV'] != 'production'

      ENV['DOCKER_HOST'] = 'tcp://192.168.0.6:2375'
      ENV['VIRTUAL_HOST'] = 'russ.deadzone.mydns.jp'
      Rake::Task['deploy'].invoke
    end

    desc 'localhostにデプロイする（動作確認用）'
    task :local do
      ENV['DOCKER_HOST'] = ''
      ENV['VIRTUAL_HOST'] = 'localhost'
      Rake::Task['deploy'].invoke
    end
  end
end
