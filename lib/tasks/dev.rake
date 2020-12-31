namespace :dev do
  desc '開発環境のセットアップを行う'
  task setup: %w(db:create db:migrate frontend)

  desc '自己証明書を利用してSSLを有効にしたnginx-proxyを起動する'
  task :nginxproxy do
    sh 'docker run -ti -p 80:80 --net front -p 443:443 -v /var/run/docker.sock:/tmp/docker.sock:ro -v $PWD/tmp/dev_cert:/etc/nginx/certs jwilder/nginx-proxy'
  end
end
