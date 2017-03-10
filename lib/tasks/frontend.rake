desc 'webpackでweb_modulesをビルドしてbundle.jsを作成する'
task frontend: %w(frontend:clean) do
  sh 'npm run build'
  chdir 'public/assets' do
    sh 'gzip -k *'
  end
end

namespace :frontend do
  task :clean do
    rm_rf 'public/assets'
  end
end
