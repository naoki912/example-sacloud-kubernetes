# kubespray

TODO: あとでかく

```sh
USACLOUD_PROFILE=dev \
  CLUSTER=@cluster=example \
  ansible-playbook \
  -i inventory/inventory.py \
  -i inventory/dev.ini \ 
  -e '@extra_vars_all.yml' \
  --become --ask-pass --ask-become-pass \
  kubespray/cluster.yml
```

