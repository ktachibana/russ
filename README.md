# RuSS

Ruby RSS Reader.

## 自分でインストールする必要のある開発ツール

### direnv

.envrcに色々設定あり

### docker & docker-compose

開発用ミドルウェアも本番実行環境もdocker-compose

### node & yarn

フロントエンドは本番ではnodeのdockerイメージでビルドする。
ただしローカルでは直接yarn buildでビルドしている。
メジャーバージョンくらいは合わせたものをインストールする。

### ChromeDriver

Chromeを用いたsystem testあり。

https://sites.google.com/chromium.org/driver/
から、Chromeのバージョンに合わせたものをDLしてパスに置く。

### その他なるべく自動化されたセットアップ

```bash
./bin/setup
```

## リリース(update)

* Dockerイメージをビルドしてpush

```
rails docker:build
rails docker:push
```

* Lightsailにログイン

```
docker-compose pull
docker-compose up -d
```

(まずpullしないとなんかエラーが出た)
