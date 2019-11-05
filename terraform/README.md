# terraform sample project

このterraform projectではkubernetesのnodeをスイッチ配下に作成する。  
ルータ＋スイッチも作成されるが現状そちらには接続していない。

## 実行方法

`terraform/providers/sakuracloud/example/terraform.tfvars` を設定する

```sh
cd providers/sakuracloud/example

terraform init
terraform apply
```

