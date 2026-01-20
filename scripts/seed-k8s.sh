#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/hosts.ini"
SSHCFG="$ROOT/infra/ssh/ssh.config"

SEED="$ROOT/ansible/k8s/playbooks/k8s_seed_db.yml"
LOAD="$ROOT/ansible/k8s/playbooks/k8s_load_photos.yml"

mkdir -p "$ROOT/infra/ssh"

cd "$VAGRANT_DIR"

# Ensure k8shost up
vagrant up k8shost >/dev/null

# Generate SSH config
vagrant ssh-config k8shost > "$SSHCFG"

cd "$ROOT"

ansible -i "$INV" k8s_nodes -m ping
ansible-playbook -i "$INV" "$SEED" --limit k8s_nodes
ansible-playbook -i "$INV" "$LOAD" --limit k8s_nodes
