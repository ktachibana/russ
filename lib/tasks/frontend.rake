desc 'webpackでweb_modulesをビルドしてbundle.jsを作成する'
task frontend: 'frontend:routesjs' do
  chdir 'frontend' do
    sh 'npm run build'
  end
end

namespace :assets do
  task precompile: 'frontend'
end

namespace :frontend do
  desc 'RailsのルーティングをJSにexportするためのroutes.jsを生成する'
  task routesjs: :environment do
    content = <<~EOS
      (function() {
      #{JsRoutes.generate.indent(2)}
      }).call(module.exports);
    EOS
    Rails.root.join('frontend', 'web_modules', 'app').tap(&:mkpath).join('routes.js').write(content)
  end
end
