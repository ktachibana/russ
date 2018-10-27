namespace :app do
  desc 'Webアプリケーションを起動する'
  task :server do
    sh 'rails server'
  end

  desc 'クローラーを定期実行する'
  task :crawler do
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new
    scheduler.every '30m' do
      sh 'rails', 'runner', 'Feed.load_all!'
    end
    scheduler.join
  end

  desc 'クローラーを１回実行する'
  task crawl: :environment do
    Feed.load_all!
  end
end
