# ansible example project

## 実行方法

```sh
ansible-playbook -i ./sacloud_inventory.py kubespray_pre.yml

# usacloudのprofileを指定する場合
USACLOUD_PROFILE=dev ansible-playbook -i ./sacloud_inventory.py kubespray_pre.yml

```

inventoryの中身を確認する:
```sh
ansible-inventory -i ./sacloud_inventory.py --list
```

## サーバに設定するタグ

対象にしたいサーバサーバのタグに `@with_sacloud_inventory` を必ず設定する

`kubespray_pre.yml`:
```yaml
---
- name: kubespray-pre
  hosts:
    - "@cluster=example"  # ここに設定した値をサーバのタグにも設定する
  become: true
  roles:
    - kubespray-pre
```

## Dynamic Inventory ( `sacloud_inventory.py` )

### 対象

server_tags に `@with_sacloud_inventory` が設定されているサーバのみを対象にしている。  
設定されていないサーバは無視される。

### なにでグループを作成しているか

server_tags に設定されているタグでグループを作成する。

### example

例えば以下のような3台のサーバとタグが設定されていた場合は、
```
server-01
  -> `@with_sacloud_inventory`, `@cluster=example`, `kube-master`, `etcd`
server-02
  -> `@with_sacloud_inventory`, `@cluster=example`, `kube-master`, `kube-node`
server-03
  -> `@with_sacloud_inventory`, `@cluster=example`, `kube-node`
```

設定されているタグごとにgroupが作成される

```sh
ansible-inventory -i ./sacloud_inventory --list
<<STDOUT
{
    "_meta": {
        "hostvars": {...}
    },
    "@with_sacloud_inventory": {
        "hosts": [
            "server-01",
            "server-02",
            "server-03"
        ]
    },
    "@cluster=example": {
        "hosts": [
            "server-01",
            "server-02",
            "server-03"
        ]
    },
    "kube-master": {
        "hosts": [
            "server-01",
            "server-02"
        ]
    },
    "etcd": {
        "hosts": [
            "server-01"
        ]
    },
    "kube-node": {
        "hosts": [
            "server-02",
            "server-03"
        ]
    }
}
STDOUT
```

