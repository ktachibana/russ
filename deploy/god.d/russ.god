app_root = "/u/apps/russ/current"

God.watch do |w|
  w.name = "russ"
  w.env = { 'RBENV_ROOT' => '/usr/local/rbenv', 'RBENV_VERSION' => '2.1.2', 'RAILS_ENV' => 'production' }
  w.dir = app_root
  w.log = app_root + '/log/unicorn.log'
  w.start = "/usr/local/rbenv/shims/bundle exec unicorn_rails -c config/unicorn.rb"
  w.uid = "russ"
  w.gid = "russ"
  w.keepalive
end
