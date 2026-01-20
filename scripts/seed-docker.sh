#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/hosts.ini"
SSHCFG="$ROOT/infra/ssh/ssh.config"

SEED="$ROOT/ansible/docker/playbooks/docker_seed_like_k8s.yml"
LOAD="$ROOT/ansible/docker/playbooks/docker_load_photos_like_k8s.yml"

mkdir -p "$ROOT/infra/ssh"

cd "$VAGRANT_DIR"

# Ensure dockerhost up
vagrant up dockerhost >/dev/null

# Generate SSH config
vagrant ssh-config dockerhost > "$SSHCFG"

cd "$ROOT"

ansible -i "$INV" docker_nodes -m ping
ansible-playbook -i "$INV" "$SEED" --limit docker_nodes
ansible-playbook -i "$INV" "$LOAD" --limit docker_nodes
