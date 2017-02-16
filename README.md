# ops-tools-jurassic

伝統的なサーバーへのファイル操作やサービスの落とし上げなどを手元の環境から操作するためのコマンドラインツール群を提供します。

- sudo ではなく su 使用前提
- 一々 tty を求めてくる
- パスワード認証 + 踏み台サーバー

# 必要条件

以下が必要です。

- bash (表示が崩れるかもなので、4.x 以上推奨)
- sshpass
- expect

```
apt-get install sshpass expect
```

# インストール

```
git clone https://github.com/orangesignal/ops-tools-jurassic.git
chmod +x ops-tools-jurassic/ops
```

# 設定

## ssh_config

`ssh` や `scp`、`rsync` などセキュアコマンド操作時にリモートサーバーの接続情報として使用します。
踏み台サーバーを使用する場合、`ssh_config` にプロキシ設定の記載をする必要があります。
本プロジェクトに付属のサンプルをご覧下さい。   
尚、`ssh_config` ファイルの書きっぷりについては、`ssh_config` の公式ページなどをご覧下さい。

## passlist

サーバー毎のユーザー名やパスワード、root 化コマンド、root 化パスワードなどを定義します。
1サーバーで複数ユーザーを使い分けている場合は、passlist ファイルを複数作成して使い分けて下さい。

# 使い方

指定したホストへ SSH 接続 + root 化してコマンドを実行する例
```
./ops cmd hostname 'ls -la'

root 化する必要ない場合は、ssh アクションを使用します。
./ops ssh hostname env
```

指定したホストへ SSH 接続 + root 化してサービスコマンドを実行する例
```
./ops cmd hostname 'service jenkins stop'

プロセス確認したい場合は service アクションを使用します。
./ops service hostname jenkins stop
```

コマンド全般の使い方はヘルプオプションで確認して下さい。
```
./ops -h
./ops [test|ssh|cmd|service|fetch|copy] -h
```

# ライセンス

Apache ライセンス
