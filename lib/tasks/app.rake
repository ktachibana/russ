namespace :app do
  desc 'Webアプリケーションを起動する'
  task :server do
    sh 'rails server'
  end

  desc 'クローラーを定期実行する'
  task :crawler do
    require 'bundler'
    Bundler.require ENV['RAILS_ENV'] || 'development'
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new
    scheduler.every '30m' do
      sh 'rails crawl'
    end
    scheduler.join
  end

  desc 'クローラーを１回実行する'
  task crawl: :environment do
    Feed.load_all!
  end
end
