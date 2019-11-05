# example-sacloud-kubernetes

`さくらの夕べDocker/Kubernetesナイト #2` で紹介したサンプルprojectです。

このリポジトリに含まれるもの

- さくらのクラウド用のDynamic Inventory
  - [sacloud_inventory.py](./ansible/sacloud_inventory.py)
  - [kube_sacloud_inventory.py](./kubespray/inventory/kube_sacloud_inventory.py)
- [nodeをデプロイするterraformのサンプルプロジェクト](./terraform)
- [node初期化用のansibleのサンプルプロジェクト](./ansible)
- [kubesprayで使用するinventoryのサンプル](./kubespray)
- [utils](./utils)

## 手順

TODO: あとで書く

### Step 0. 事前準備

#### Step 0-1. リポジトリのclone

このリポジトリをcloneします

```sh
git clone https://github.com/naoki912/example-sakura-kubernetes

cd example-sakura-kubernetes
```

#### Step 0-2. usacloud のインストール

Windows, Linux:  
https://github.com/sacloud/usacloud#%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E3%83%9E%E3%82%B7%E3%83%B3%E3%81%AB%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB

archlinux:  
install aur/usacloud-bin
```sh
wget https://aur.archlinux.org/cgit/aur.git/snapshot/usacloud-bin.tar.gz
tar fvxz usacloud-bin.tar.gz
cd usacloud-bin
makepkg -s
sudo pacman -U usacloud-bin-*.pkg.tar.xz
```

asdf-vm:
```sh
asdf plugin-add usacloud https://github.com/naoki912/asdf-usacloud.git
asdf install usacloud 0.29.0
```

#### Step 0-3. terraformとproviderのインストール

Windows, Linux:  
https://learn.hashicorp.com/terraform/getting-started/install.html

asdf-vm:
```sh
asdf plugin-add terraform
asdf install terraform 0.12.13
```

##### terraform-provider-sakuracloud

https://github.com/sacloud/terraform-provider-sakuracloud

archlinux:  
( :warning: ${HOME} にインストールされます)
```sh
git clone https://github.com/naoki912/pkgbuild-terraform-provider-sakuracloud-bin.git
cd pkgbuild-terraform-provider-sakuracloud-bin
makepkg -s
sudo pacman -U *.pkg.tar.zx
```

### Step 1. VM作成

[terraform/README.md](./terraform/README.md)

sshconfig:  
[utils/README.md](./utils/README.md)

### Step 2. Ansibleの実行

[ansible/README.md](./ansible/README.md)

### Step 3. kubesprayの実行

[kubespray/README.md](./kubespray/README.md)

