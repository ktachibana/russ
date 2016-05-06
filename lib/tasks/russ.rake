namespace :russ do
  desc 'プロジェクトをtar.gzにアーカイブする'
  task :archive do
    `tar -c -z -f tmp/russ.tar.gz --exclude 'vendor/bundle' --exclude .git --exclude 'tmp' --exclude log .`
  end

  desc 'クローラーを定期実行する'
  task crawler: :environment do
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new
    scheduler.every '30m' do
      Feed.load_all!
    end
    scheduler.join
  end
end
