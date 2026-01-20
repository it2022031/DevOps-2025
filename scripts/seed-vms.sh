#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/hosts.ini"
SSHCFG="$ROOT/infra/ssh/ssh.config"

SEED="$ROOT/ansible/vms/playbooks/vm_seed_like_k8s.yml"
LOAD="$ROOT/ansible/vms/playbooks/vm_load_photos_like_k8s.yml"

mkdir -p "$ROOT/infra/ssh"

# Vagrant must run in Vagrantfile dir
cd "$VAGRANT_DIR"

# Ensure VMs exist/up (optional but helpful)
vagrant up backend db front >/dev/null

# Generate SSH config
vagrant ssh-config backend db front > "$SSHCFG"

# Run Ansible from repo root (portable paths)
cd "$ROOT"

ansible -i "$INV" "backend:db:front" -m ping
ansible-playbook -i "$INV" "$SEED" --limit "backend_nodes:db_nodes"
ansible-playbook -i "$INV" "$LOAD" --limit "db_nodes"
