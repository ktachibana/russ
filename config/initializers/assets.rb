# Be sure to restart your server when you modify this file.

Rails.application.config.assets.tap do |assets|
  # Version of your assets, change this if you want to expire all your assets.
  assets.version = '1.0'

  # Add additional assets to the asset load path
  # Rails.application.config.assets.paths << Emoji.images_path
  assets.paths << Rails.root + 'node_modules' # webpack化していないbootstrapなどのため
  assets.paths << Rails.root + 'frontend' + 'dist'

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # Rails.application.config.assets.precompile += %w( search.js )

  Sprockets.register_engine '.haml', Tilt::HamlTemplate
end
