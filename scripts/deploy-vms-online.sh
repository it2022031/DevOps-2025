#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
INV="$ROOT/infra/inventories/cloud_vms.ini"
PB="$ROOT/ansible/online/vms/playbooks/site_vms_online_nginx.yml"

export ANSIBLE_HOST_KEY_CHECKING="False"

echo "== Ping all (cloud_vms) =="
ansible -i "$INV" all -m ping

echo "== Deploy VMs Online (Nginx) =="
ansible-playbook -i "$INV" "$PB" -v
