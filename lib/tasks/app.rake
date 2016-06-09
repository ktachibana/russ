namespace :app do
  desc 'クローラーを定期実行する'
  task :crawler do
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new
    scheduler.every '30m' do
      sh 'bundle', 'exec', 'rails', 'runner' 'Feed.load_all!'
    end
    scheduler.join
  end

  desc 'config/vars/SECRET_KEY_BASEを生成する'
  task :write_secret, :overwrite do |_t, args|
    file = Pathname.pwd + 'config' + 'vars' + 'SECRET_KEY_BASE'
    exists = file.exist?

    if exists && !args[:overwrite]
      puts "#{file} exists."
      next
    end

    require 'securerandom'
    file.parent.mkpath
    file.write SecureRandom.hex(64)

    puts "#{file} #{exists ? 'changed' : 'created'}."
  end
end
