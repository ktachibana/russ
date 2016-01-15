namespace :russ do
  desc 'genrate routes.js'
  task routesjs: :environment do
    content = <<-EOS
(function() {
#{JsRoutes.generate.indent(2)}
}).call(module.exports);
    EOS
    Rails.root.join('frontend', 'assets', 'javascripts', 'app').tap(&:mkpath).join('routes.js').write(content)
  end
end
