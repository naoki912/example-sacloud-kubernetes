#!/usr/bin/env python

import argparse
import json
import shutil
import subprocess
import sys


# for exclude hosts, check tags
filtering_tag = "@with_sacloud_inventory"

# usacloud installed check
if shutil.which("usacloud") is None:
    sys.stderr("usacloud not found")
    sys.exit(1)

parser = argparse.ArgumentParser(
    description="Produce an Ansible" "Inventory file based on DigitalOcean credentials"
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
        # filter hosts by tags
        if filtering_tag not in i["Tags"]:
            continue

        zone = i["Zone"]["Name"]
        host = i["Name"]
        interfaces = i["Interfaces"]
        #  ahost = interfaces[0]["UserIPAddress"],
        ahost = i["Name"]
        if zone not in inventory.keys():
            inventory[zone] = []
        inventory[zone].append(host)

        for tag in i["Tags"]:
            if tag not in inventory.keys():
                inventory[tag] = []
            inventory[tag].append(host)

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
