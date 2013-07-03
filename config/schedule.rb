# Learn more: http://github.com/javan/whenever

set :output, path + '/log/cron_log.log'

every 30.minutes do
  runner 'Feed.load_all!'
end
