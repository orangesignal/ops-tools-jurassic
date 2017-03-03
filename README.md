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
本プロジェクトに付属の[サンプル](https://github.com/orangesignal/ops-tools-jurassic/blob/master/test/ssh_config)をご覧下さい。   
尚、`ssh_config` ファイルの書きっぷりについては、`ssh_config` の公式ページなどをご覧下さい。

`ops` コマンドで、`ssh_config` ファイルが指定されていない場合の検索方法は ssh の仕様と同様です。   

### passlist

サーバー毎のユーザー名やパスワード、`root` 化コマンド、`root` 化パスワードなどを定義します。
1サーバーで複数ユーザーを使い分けている場合は、`passlist` ファイルを複数作成して使い分けて下さい。   

```:passlist
# hostname username password root_cmd root_password
w01	devops	123456	sudo su -	
w02	devops2	234567	su -	
*	devops	123456	sudo su -	
```

`ops` コマンドで、`passlist` ファイルが指定されていない場合は、
カレントディレクトリの `passlist` が検索され使用されます。

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

# ワイルドカード使用
./ops copy w01 /var/tmp/*.txt /root/foobar

# ファイルコピー
./ops copy w01 /var/tmp/foobar.txt /root
# ファイルコピー (ファイル名指定)
./ops copy w01 /var/tmp/foobar.txt /root/baz.txt

# ファイルの所有者やアクセス権限を指定する場合
./ops copy w01 /var/tmp/foobar.txt /root/baz.txt -owner devops -mode +rw

# 既存のディレクトリやファイルをバックアップ移動してからコピー
./ops copy w01 /var/tmp/foobar.txt /root/baz.txt -backup yes
# デフォルトのサフィックスである ~ をやめて別のものを指定する場合
./ops copy w01 /var/tmp/foobar.txt /root/baz.txt -backup yes -suffix ".$(date +%Y%m%d%H%M)"
# バックアップ先を指定する場合
./ops copy w01 /var/tmp/foobar /root/baz -backup /root/backups -suffix ".$(date +%Y%m%d%H%M)"

```

`-backup` に `yes` を指定するとコピー先と同じ場所にバックアップが作成されます。   
システム系ディレクトリへのコピー時に `-backup yes` とすると、
ディレクトリ毎バックアップ移動されてシステムが壊れるなど大変危険な事態となるのでご注意下さい。

### cmd (root でのコマンド実行)

```
# root のホームディレクトリのファイル一覧を取得する例
./ops cmd hostname "ls -la"
# - で始まる文字を ops のオプションとして解釈させたくない場合は、-- を使用することで、それ以降のパラメーターの解析を無効化できます。
./ops cmd hostname -- ls -la

# Jenkins を停止させる例
./ops cmd hostname service jenkins stop
```

### ssh (一般ユーザでのコマンド実行)

root 化する必要ない操作は通常の ssh や scp で十分ですが、
ops を使用すると(良いか悪いかは別として)パスワードを覚えておく手間を減らせます。

```
./ops ssh hostname env
```

### その他

帯域制限したい場合は、`-l` オプションを使用します。単位は `rsync` と同じ kB/sec です。
`ssh` アクションでは `-l `オプションを指定しても無視されます。

```
./ops -l 1024 fetch w01 /root/foobar /var/tmp/foobar
```

コマンド全般の使い方はヘルプオプションで確認して下さい。
```
./ops -h
./ops [ssh|cmd|fetch|copy] -h
```

## 使い方2

以下はローカル環境の bash スクリプトをリモート環境で実行させる場合の例です。   
```
cat example.bash | ./ops ssh hostname bash
# root で実行するには cmd アクションを使用して下さい。
cat example.bash | ./ops cmd hostname bash

# 以下はヒアドキュメント形式での例
./ops cmd hostname bash <<'END'
# command...
END
```

以下はローカル環境のファイルをリモート環境へ簡易コピーする例です。
```
cat example.txt | ./ops ssh hostname "cat >/var/tmp/example.txt"
# root で実行するには cmd アクションを使用して下さい。
cat example.txt | ./ops cmd hostname "cat >/var/tmp/example.txt"
```

尚、以下の制限があります。

- 今のところ `ssh` と `cmd` アクションのみ対応
- `ssh` と同じくデフォルトでは標準入力があると読み込もうとしますので、バッチ処理や、`bash` の `while read` ループ中から呼び出すなど問題が起こる場合は、標準入力を読み込まないよう `-n` オプションを使用して下さい。   
尚、標準入力からの読み込みを禁止した場合は、「使い方2」の使用方法はできなくなります。

## License

* Licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
