namespace :dev do
  desc '開発環境のセットアップを行う'
  task setup: %w(db:create db:migrate frontend)
end
