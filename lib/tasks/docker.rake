namespace :docker do
  desc 'メインとなるappのDockerイメージをビルドする'
  task build: :write_version do
    sh 'docker build -t ktachiv/russ .'
  end

  desc 'public/VERSIONを更新する'
  task :write_version do
    sh 'git rev-parse HEAD > public/VERSION'
  end

  desc 'Dockerイメージをpushする'
  task :push do
    sh 'docker push ktachiv/russ'
  end
end
