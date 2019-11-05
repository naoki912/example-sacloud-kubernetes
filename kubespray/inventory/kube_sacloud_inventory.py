#!/usr/bin/env python

"""
filtering_tag と filtering_cluster_tag(CLUSTER_NUMBER 環境変数) を使用して、
あるzoneの指定したクラスタのinventoryを生成するDynamic Inventory.

`CLUSTER_NUMBER` 環境変数の指定が必須。
この環境変数は同じzoneに複数クラスタが存在する場合に、それらを識別するために使用される。

事実上2番目のfiltering_tagとしても機能する。


Example:
```
# sob-dev クラウドアカウントかつ、VMに `@cluster=sob-i1b-d01` タグが設定されているサーバ
USACLOUD_PROFILE=sob-dev CLUSTER_TAG=@cluster=sob-i1b-d01 ./inventory.py
```
"""

import argparse
import json
import shutil
import subprocess
import sys
from os import environ


# for exclude hosts, check tags
filtering_tag = "@with_kubespray_inventory"
# multi cluster構成でclusterと識別するためのタグ
filtering_cluster_tag = environ.get("CLUSTER_TAG", None)

if filtering_cluster_tag is None:
    sys.stderr("CLUSTER_TAG environment variable not found.")
    sys.exit(1)

# usacloud installed check
if shutil.which("usacloud") is None:
    sys.stderr("usacloud not found")
    sys.exit(1)

parser = argparse.ArgumentParser(
    description="Produce an Ansible Inventory file based on DigitalOcean credentials"
)

parser.add_argument(
    "--list",
    action="store_true",
    default=True,
    help="List all active Droplets as Ansible inventory (default: True)",
)
parser.add_argument(
    "--host",
    action="store",
    help="Get all Ansible inventory variables about a specific Droplet",
)

args = parser.parse_args()

if args.list:
    s = subprocess.check_output(
        "usacloud server list --out json --max=1000", shell=True
    )
    j = json.loads(s.decode("utf-8"))

    inventory = {}
    hostvars = {}
    for i in j:
        # filtering_tag と filtering_cluster_tag(特定のクラスタ) でhostをfilterする
        if not (filtering_tag in i["Tags"] and filtering_cluster_tag in i["Tags"]):
            continue

        zone = i["Zone"]["Name"]
        host = i["Name"]
        interfaces = i["Interfaces"]
        ahost = i["Name"]
        if zone not in inventory.keys():
            inventory[zone] = []
        inventory[zone].append(host)

        for tag in i["Tags"]:
            if tag not in inventory.keys():
                inventory[tag] = []
            inventory[tag].append(host)

        # etcd member には etcd_member_name を設定する必要があるため処理を分けている
        if "etcd" in i["Tags"]:
            hostvars[host] = {
                "etcd_member_name": host,
                "ansible_host": ahost,
                "name": host,
                "sacloud_id": i["ID"],
                "sacloud_tags": i["Tags"],
                "sacloud_interfaces": [ifc for ifc in i["Interfaces"]],
                "sacloud_disks": [d for d in i["Disks"]],
            }
        else:
            hostvars[host] = {
                "ansible_host": ahost,
                "name": host,
                "sacloud_id": i["ID"],
                "sacloud_tags": i["Tags"],
                "sacloud_interfaces": [ifc for ifc in i["Interfaces"]],
                "sacloud_disks": [d for d in i["Disks"]],
            }

    for k, v in inventory.items():
        v.sort()

    inventory["_meta"] = {"hostvars": hostvars}

    print(json.dumps(inventory, sort_keys=True, indent=2, separators=(",", ": ")))

elif args.host is not None or args.host == "":
    s = subprocess.check_output(
        "usacloud server read --out json {}".format(args.host), shell=True
    )
    j = json.loads(s.decode("utf-8"))[0]
    interfaces = j["Interfaces"]
    ahost = j["Name"]
    i = {
        "ansible_host": ahost,
        "name": j["Name"],
        "sacloud_id": j["ID"],
        "sacloud_tags": j["Tags"],
        "sacloud_interfaces": [ifc for ifc in interfaces],
        "sacloud_disks": [d for d in j["Disks"]],
    }
    print(json.dumps(i, sort_keys=True, indent=2, separators=(",", ": ")))
