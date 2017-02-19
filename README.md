# ops-tools-jurassic

伝統的なサーバーへのファイル操作やサービスの落とし上げなどを手元の環境から操作するためのコマンドラインツール群を提供します。

- sudo ではなく su 使用前提
- 一々 tty を求めてくる
- パスワード認証 + 踏み台サーバー

## 必要条件

ローカル環境には以下が必要です。

- bash (表示が崩れるかもなので、4.x 以上推奨)
- sshpass
- expect

Ubuntu
```
apt-get install sshpass expect
```

MacOS X
```
brew install sshpass
```

リモート環境には以下が必要です。

- sshd
- bash (ファイル送受信利用時。ログインシェルでなくて良い)

本プロダクトは ssh + root 化してコマンドを実行する物であるため、   
ssh, scp, rsync が使える環境で root 化可能であることが前提となります。   
※root 化してのコマンド実行は大変危険ですので、本プロダクトのご利用は自己責任となります。

`copy` アクションや `fetch` アクションなどファイルのやりとりをする機能を使用する場合は、`bash` も必要となります。

## インストール

```
git clone https://github.com/orangesignal/ops-tools-jurassic.git
chmod +x ops-tools-jurassic/ops
```

## 設定

### ssh_config

`ssh` や `scp`、`rsync` などセキュアコマンド操作時にリモートサーバーの接続情報として使用します。
踏み台サーバーを使用する場合、`ssh_config` にプロキシ設定の記載をする必要があります。
本プロジェクトに付属のサンプルをご覧下さい。   
尚、`ssh_config` ファイルの書きっぷりについては、`ssh_config` の公式ページなどをご覧下さい。

### passlist

サーバー毎のユーザー名やパスワード、root 化コマンド、root 化パスワードなどを定義します。
1サーバーで複数ユーザーを使い分けている場合は、`passlist` ファイルを複数作成して使い分けて下さい。   

```:passlist
# hostname username password root_cmd root_password
w01	devops	123456	sudo su -	
w02	devops2	234567	su -	
*	devops	123456	sudo su -	
```

## 使い方

### fetch (リモートからローカルへのコピー)

```
# fetch は root で実行されます。
# ディレクトリコピー
./ops fetch w01 /root/foobar /var/tmp/foobar

# ワイルドカード使用
./ops fetch w01 /root/foobar/*.txt /var/tmp

# ファイルコピー
./ops fetch w01 /root/foobar.txt /var/tmp

# ファイルコピー (ファイル名指定)
./ops fetch w01 /root/foobar.txt /var/tmp/baz.txt
```

### copy (ローカルからリモートへのコピー)

```
# copy は root で実行されます。
# ディレクトリコピー
./ops copy w01 /var/tmp /root/foobar
# または
./ops copy w01 /var/tmp/foobar/ /root/foobar/

# ワイルドカード使 (本プロダクトは bash ベースなので、* を \ でエスケープするか ' で囲んで下さい)
./ops copy w01 /var/tmp/\*.txt /root/foobar
./ops copy w01 '/var/tmp/*.txt' /root/foobar

# ファイルコピー
./ops copy w01 /var/tmp/foobar.txt /root
# ファイルコピー (ファイル名指定)
./ops copy w01 /var/tmp/foobar.txt /root/baz.txt
```

### cmd

以下は、指定したホストへ SSH 接続 + root 化してコマンドを実行する例です。

```
./ops cmd hostname ls -la

root 化する必要ない場合は、ssh アクションを使用します。
./ops ssh hostname env
```

passlist ファイルが指定されていない場合は、カレントディレクトリの `passlist` を順番に検索し一致するファイルを使用します。   
ssh_config ファイルが指定されていない場合は、ssh の仕様と同様です。   

以下は、指定したホストへ SSH 接続 + root 化してサービスコマンドを実行する例です。
```
./ops cmd hostname service jenkins stop

プロセス確認したい場合は service アクションを使用します。
./ops service hostname jenkins stop
```

コマンド全般の使い方はヘルプオプションで確認して下さい。
```
./ops -h
./ops [ssh|cmd|service|fetch|copy] -h
```

## 使い方2

以下はローカル環境の bash スクリプトをリモート環境で実行させる場合の例です。
```
cat example.bash | ./ops ssh hostname bash
# root で実行するには cmd アクションを使用して下さい。
cat example.bash | ./ops cmd hostname bash
```

以下はローカル環境のファイルをリモート環境へ簡易コピーする例です。
```
cat example.txt | ./ops ssh hostname "cat >/var/tmp/example.txt"
# root で実行するには cmd アクションを使用して下さい。
cat example.txt | ./ops cmd hostname "cat >/var/tmp/example.txt"
```

尚、以下の制限があります。

- 今のところ `ssh` と `cmd` アクションのみ対応
- bash の while ループ中などから呼び出すと、標準入力が切り替わる問題の影響からループ処理が期待通りに動かないかもしれません。   
(FYI - http://www.m-bsys.com/error/whileread-ssh)

## License

* Licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
