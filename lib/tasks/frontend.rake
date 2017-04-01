desc 'webpackでweb_modulesをビルドしてbundle.jsを作成する'
task :frontend do
  sh 'npm run build'
end
