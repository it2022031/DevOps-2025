#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
INV="$ROOT/infra/inventories/cloud_k8s.ini"
PB="$ROOT/ansible/online/k8s/playbooks/site_k8s_online_nginx.yml"

export ANSIBLE_HOST_KEY_CHECKING="False"

echo "== Ping k8s nodes =="
ansible -i "$INV" k8s_nodes -m ping

echo "== Deploy K8s Online (Nginx) =="
ansible-playbook -i "$INV" "$PB" -v
