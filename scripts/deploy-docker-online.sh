#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
INV="$ROOT/infra/inventories/cloud_docker.ini"
PB="$ROOT/ansible/online/docker/playbooks/site_docker_online_nginx.yml"

export ANSIBLE_HOST_KEY_CHECKING="False"

echo "== Ping docker nodes =="
ansible -i "$INV" docker_nodes -m ping

echo "== Deploy Docker Online (Nginx) =="
ansible-playbook -i "$INV" "$PB" -v
