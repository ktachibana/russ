namespace :dev do
  desc '開発環境のセットアップを行う'
  task setup: %w(app:write_secret db:create db:migrate frontend cert)

  desc '開発用に自己証明書を生成する'
  task :cert do
    mkpath 'tmp/dev_cert'
    chdir 'tmp/dev_cert' do
      sh 'openssl genrsa 2048 > localhost.key'
      sh 'openssl req -new -key localhost.key > server.csr'
      sh 'openssl x509 -days 3650 -req -signkey localhost.key < server.csr > localhost.crt'
      sh 'openssl dhparam 2048 -out localhost.dhparam.pem'
    end
  end

  desc '自己証明書を利用してSSLを有効にしたnginx-proxyを起動する'
  task :nginxproxy do
    sh 'docker run -ti -p 80:80 --net front -p 443:443 -v /var/run/docker.sock:/tmp/docker.sock:ro -v $PWD/tmp/dev_cert:/etc/nginx/certs jwilder/nginx-proxy'
  end
end
