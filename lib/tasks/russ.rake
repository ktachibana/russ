namespace :russ do
  desc 'プロジェクトをtar.gzにアーカイブする'
  task :archive do
    `tar -c -z -f tmp/russ.tar.gz --exclude 'vendor/bundle' --exclude .git --exclude 'tmp' --exclude log .`
  end
end
