desc 'webpackでweb_modulesをビルドしてbundle.jsを作成する'
task frontend: 'frontend:routesjs' do
  sh 'npm run build'
end

namespace :assets do
  task precompile: 'frontend'
end

Rake::Task['assets:precompile'].enhance do
  %w(html html.gz).each do |suffix|
    html = Pathname.glob(Rails.public_path.join('assets', "application-*.#{suffix}")).first || next
    mv html, Rails.public_path + "index.#{suffix}"
  end
end

namespace :frontend do
  desc 'RailsのルーティングをJSにexportするためのroutes.jsを生成する'
  task routesjs: :environment do
    content = <<~EOS
      (function() {
      #{JsRoutes.generate.indent(2)}
      }).call(module.exports);
    EOS
    Rails.root.join('frontend', 'web_modules', 'app').tap(&:mkpath).join('ApiRoutes.js').write(content)
  end
end
