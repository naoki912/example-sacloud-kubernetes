# utils

## sshconfig_generator.py

さくらのクラウドのサーバ一覧からsshconfigを生成するスクリプト

server_tagsに `@sshconfig` が設定されているサーバが対象になる。

1つ目のNICのIPアドレスをHostnameに設定している。  
Switchに繋がっているインスタンスは `UserIPAddress` の値がHostnameに設定される。

踏み台にも対応している。  
踏み台サーバには `@ssh_bastion_server=group1` を指定し、その踏み台を経由するサーバには `@ssh_bastion_group=group1` を指定する。  
ここで指定したgroup名によってどの踏み台を使用するかを判断している。

現在の実装では「 `@ssh_bastion_server` で指定されたgroup名」をaliasとして踏み台サーバのホスト名に登録し、それをProxyCommandに指定している。

`@ssh_bastion_server=group1` `@ssh_bastion_group=group1` のように指定すると、Hostにaliasとして追加される
```
Host bastion 192.168.0.1 group1
    Hostname 192.168.0.1
    User ubuntu
...
Host myserver 10.0.0.1
    Hostname 10.0.0.1
    User ubuntu
    ProxyCommand ssh -W %h:%p group1
```

### 使い方

```sh
./sshconfig_generator.py > sakura.sshconfig

# usacloudのprofileを指定する場合
USACLOUD_PROFILE=dev ./sshconfig_generator.py > sakura-dev.sshconfig
```

#### タグ

サーバのタグに設定するもの

##### `@sshconfig`

このスクリプトの対象にしたいサーバに設定する。  
他の `@ssh_` タグを設定しても、このタグが設定されていなければ対象から外れる。

##### `@ssh_user=`

sshconfigのUserに設定するログインユーザ

`@ssh_user=hogehoge`
```
Host example 10.0.0.1
    Hostname 10.0.0.1
    User hogehoge        <- この値
    IdentityFile ~/.ssh/id_rsa
```

##### `@ssh_port=`

sshconfigのPortに設定するSSHの待受ポート

`@ssh_port=22222`
```
Host example 10.0.0.1
    Hostname 10.0.0.1
    User ubuntu
    Port 22222            <- この値
    IdentityFile ~/.ssh/id_rsa
```

##### `@ssh_bastion_server=`

踏み台サーバに設定する

`@ssh_bastion_server=group1`
```
Host example 10.0.0.1 group1 <- ここに追加される
    Hostname 10.0.0.1
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
```

##### `@ssh_bastion_group=`

踏み台経由でログインされる側

`@ssh_bastion_group=group1`
```
Host example 10.0.0.1 group1
    Hostname 10.0.0.1
    User ubuntu
    ProxyCommand ssh -W %h:%p group1  <- ProxyCommandが設定される
    IdentityFile ~/.ssh/id_rsa
```

#### オプション

```sh
./sshconfig_generator.py -h
<<STDOUT
usage: sshconfig_generator.py [-h] [--ssh-host-prefix SSH_HOST_PREFIX]
                              [--default-ssh-user DEFAULT_SSH_USER]
                              [--ssh-identity-file SSH_IDENTITY_FILE]

optional arguments:
  -h, --help            show this help message and exit
  --ssh-host-prefix SSH_HOST_PREFIX
  --default-ssh-user DEFAULT_SSH_USER
  --ssh-identity-file SSH_IDENTITY_FILE
STDOUT
```

##### --ssh-host-prefix SSH_HOST_PREFIX

ホスト名にprefixを設定する

`--ssh-host-prefix=hoge`
```
Host hoge-example 192.168.0.1
    Hostname 192.168.0.1
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
```

##### --default-ssh-user DEFAULT_SSH_USER

`@ssh_user` が指定されていない場合に設定するユーザ名

`--default-ssh-user=hogehoge`
```
Host example 192.168.0.1
    Hostname 192.168.0.1
    User hogehoge
    IdentityFile ~/.ssh/id_rsa
```

##### --ssh-identity-file SSH_IDENTITY_FILE

`--ssh-identity-file=~/.ssh/sakura`

```
Host example 192.168.0.1
    Hostname 192.168.0.1
    User ubuntu
    IdentityFile ~/.ssh/sakura
```

### Require

- python 3.7以上
- usacloud
  - https://github.com/sacloud/usacloud

