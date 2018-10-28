namespace :deploy do
  desc 'メインとなるappのDockerイメージをビルドする'
  task :build_app do
    sh 'docker build -t ktachiv/russ .'
  end

  desc 'Dockerイメージをpushする'
  task :push do
    sh 'docker push ktachiv/russ'
  end
end
