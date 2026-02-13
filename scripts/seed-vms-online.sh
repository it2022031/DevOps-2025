#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
INV="$ROOT/infra/inventories/cloud_vms.ini"

PB_SEED="$ROOT/ansible/online/vms/playbooks/online_seed_db.yml"
PB_PHOTOS="$ROOT/ansible/online/vms/playbooks/online_load_photos.yml"

export ANSIBLE_HOST_KEY_CHECKING="False"

echo "== Ping all (cloud_vms) =="
ansible -i "$INV" all -m ping

echo "== Seed DB (demo data) =="
ansible-playbook -i "$INV" "$PB_SEED" -v

echo "== Load photos (demo photos) =="
ansible-playbook -i "$INV" "$PB_PHOTOS" -v
