#!/usr/bin/env python


import argparse
import json
import re
import shutil
import subprocess
from os import getenv
from sys import exit
from sys import stderr
from sys import stdout

import jinja2


FILTERING_TAG = "@sshconfig"

SSH_USER_TAG = "@ssh_user"
SSH_PORT_TAG = "@ssh_port"
SSH_BASTION_SERVER_TAG = "@ssh_bastion_server"  # 踏み台サーバ
SSH_BASTION_GROUP_TAG = "@ssh_bastion_group"  # 踏み台経由でログインされる側

# ssh_hostsで使うdictのkey
HOSTS_KEY_NAME = "Hosts"
HOSTNAME_KEY_NAME = "Hostname"
USER_KEY_NAME = "User"
PORT_KEY_NAME = "Port"
IDENTITY_FILE_KEY_NAME = "IdentityFile"
BASTION_SERVER_KEY_NAME = "BastionServer"
BASTION_GROUP_KEY_NAME = "BastionGroup"


SSH_CONFIG_TEMPLATE = """
{% for host in hosts %}\
{% if host[HOSTNAME_KEY_NAME] is not none %}\
Host {{ host[HOSTS_KEY_NAME] | join(' ') }} {{ host[BASTION_SERVER_KEY_NAME] }}
    Hostname {{ host[HOSTNAME_KEY_NAME] }}
{% if host[USER_KEY_NAME] is defined %}\
    User {{ host[USER_KEY_NAME] }}
{% endif %}\
{% if host[PORT_KEY_NAME] is defined %}\
    Port {{ host[PORT_KEY_NAME] }}
{% endif %}\
{% if host[BASTION_GROUP_KEY_NAME] is defined and host[BASTION_SERVER_KEY_NAME] is not defined %}\
    ProxyCommand ssh -W %h:%p {{ host[BASTION_GROUP_KEY_NAME] }}
{% endif %}\
    IdentityFile {{ host[IDENTITY_FILE_KEY_NAME] }}
{% endif %}\
{% endfor %}
"""


def get_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--ssh-host-prefix", default="" + getenv("USACLOUD_PROFILE", "")
    )

    parser.add_argument("--default-ssh-user", default="root")

    parser.add_argument("--ssh-identity-file", default="~/.ssh/id_rsa")

    return parser.parse_args()


def fetch_servers_from_sacloud() -> dict:
    res: subprocess.CompletedProcess = subprocess.run(
        "usacloud server list --out json --max=1000".split(),
        stdout=subprocess.PIPE,
        text=True,
    )

    def __convert_json_to_dict(_json) -> dict:
        try:
            return json.loads(_json)
        except json.decoder.JSONDecodeError:
            return {}

    return __convert_json_to_dict(res.stdout)


def add_ssh_parameter_from_tags(hosts: dict) -> dict:
    """
    `@ssh_user=` などのタグからsshconfigで使用するパラメータを追加する
    """
    _ssh_hosts = []

    # '^@ssh_user=.*' の形になる
    user_regex = re.compile("^" + SSH_USER_TAG + "=.*")
    port_regex = re.compile("^" + SSH_PORT_TAG + "=.*")
    bastion_server_regex = re.compile("^" + SSH_BASTION_SERVER_TAG + "=.*")
    bastion_group_regex = re.compile("^" + SSH_BASTION_GROUP_TAG + "=.*")

    for host in hosts:

        _extended_object = {}

        # server['Tags'] から上の正規表現にマッチするものをfilterして取得する
        _user_tag = list(filter(user_regex.match, host["Tags"]))
        if len(_user_tag) >= 1:
            # タグの '@ssh_user=' 部分を消して server.NAME.USER_KEY_NAME に保存する
            # ex) `@ssh_user=ubuntu` -> `ubuntu`
            _extended_object.update(
                {USER_KEY_NAME: _user_tag[0].replace(SSH_USER_TAG + "=", "")}
            )

        _port_tag = list(filter(port_regex.match, host["Tags"]))
        if len(_port_tag) >= 1:
            _extended_object.update(
                {PORT_KEY_NAME: _port_tag[0].replace(SSH_PORT_TAG + "=", "")}
            )

        _bastion_server_tag = list(filter(bastion_server_regex.match, host["Tags"]))
        if len(_bastion_server_tag) >= 1:
            _extended_object.update(
                {
                    BASTION_SERVER_KEY_NAME: _bastion_server_tag[0].replace(
                        SSH_BASTION_SERVER_TAG + "=", ""
                    )
                }
            )

        _bastion_group_tag = list(filter(bastion_group_regex.match, host["Tags"]))
        if len(_bastion_group_tag) >= 1:
            _extended_object.update(
                {
                    BASTION_GROUP_KEY_NAME: _bastion_group_tag[0].replace(
                        SSH_BASTION_GROUP_TAG + "=", ""
                    )
                }
            )

        host.update(_extended_object)

        _ssh_hosts.append(host)

    return _ssh_hosts


def generate_hosts_from_sacloud_servers(
    servers: dict, host_prefix="", user="", identity_file=""
) -> dict:
    """
    使用する属性のみのリストを生成する

    [
      {
        "Hosts": [
          "myserver"
          "192.168.0.1",
        ],
        "Hostname": "192.168.0.1",
        "User": "admin",
        "IdentityFile": "~/.ssh/id_rsa",
        "Tags": [
          "@ssh_user=ubuntu",
          "@ssh_port=2222",
        ],
      }
    ]
    """

    ssh_hosts = []

    for server in servers:

        # Host
        _hosts = []

        # server.Name に None が入ることはない
        _hosts.append(
            server.get("Name")
            if host_prefix == ""
            else host_prefix + "-" + server.get("Name")
        )
        _hosts.append(server.get("Interfaces", [{}])[0].get("UserIPAddress", None))
        _hosts.append(server.get("Interfaces", [{}])[0].get("IPAddress", None))
        # TODO: bastion server
        # _hosts.append(bastion_server)

        # not None で filter
        _hosts = [host for host in _hosts if host is not None]

        # Hostname
        hostnames = []
        hostnames.append(server.get("Interfaces", [{}])[0].get("UserIPAddress", None))
        hostnames.append(server.get("Interfaces", [{}])[0].get("IPAddress", None))
        # FIXME: UserIPAddressとIPAddressの両方が設定されていない時にクラッシュする
        #        IndexErrorを握りつぶす
        hostname = [i for i in hostnames if i is not None][0]

        ssh_hosts.append(
            {
                HOSTS_KEY_NAME: _hosts,
                HOSTNAME_KEY_NAME: hostname,
                USER_KEY_NAME: user,
                IDENTITY_FILE_KEY_NAME: identity_file,
                "Tags": server.get("Tags", {}),
            }
        )

    return ssh_hosts


def main():
    if shutil.which("usacloud") is None:
        stderr.write("usacloud not found")
        exit(1)

    args = get_args()

    sacloud_servers: dict = fetch_servers_from_sacloud()

    # server['Tags'] に FILTERING_TAG が含まれているものだけをfilterする
    filtered_sacloud_servers: dict = list(
        filter(lambda server: FILTERING_TAG in server["Tags"], sacloud_servers)
    )

    # おそらくリソースIDでソートされているのでNameでsortし直す
    sorted_sacloud_servers: dict = sorted(
        filtered_sacloud_servers, key=lambda x: x["Name"]
    )

    # sacloud_servers から jinja2 に渡す ssh_hosts を生成する
    ssh_hosts: dict = add_ssh_parameter_from_tags(
        generate_hosts_from_sacloud_servers(
            servers=sorted_sacloud_servers,
            host_prefix=args.ssh_host_prefix,
            user=args.default_ssh_user,
            identity_file=args.ssh_identity_file,
        )
    )

    # debug
    # stderr.write(json.dumps(ssh_hosts))

    tmpl = jinja2.Template(SSH_CONFIG_TEMPLATE)
    stdout.write(
        tmpl.render(
            hosts=ssh_hosts,
            HOSTS_KEY_NAME=HOSTS_KEY_NAME,
            HOSTNAME_KEY_NAME=HOSTNAME_KEY_NAME,
            USER_KEY_NAME=USER_KEY_NAME,
            PORT_KEY_NAME=PORT_KEY_NAME,
            IDENTITY_FILE_KEY_NAME=IDENTITY_FILE_KEY_NAME,
            BASTION_SERVER_KEY_NAME=BASTION_SERVER_KEY_NAME,
            BASTION_GROUP_KEY_NAME=BASTION_GROUP_KEY_NAME,
        )
    )


if __name__ == "__main__":
    main()
