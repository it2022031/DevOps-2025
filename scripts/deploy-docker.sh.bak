#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/hosts.ini"
PLAYBOOK="$ROOT/ansible/docker/playbooks/docker_site.yml"
SSHCFG="$ROOT/infra/ssh/ssh.config"

mkdir -p "$ROOT/infra/ssh"

# 1) Vagrant actions
cd "$VAGRANT_DIR"

state="$(vagrant status dockerhost --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo "🔧 Bringing up: dockerhost"
  vagrant up dockerhost
else
  echo "✅ VM already running: dockerhost"
fi

echo "🔁 Generating $SSHCFG from vagrant for: dockerhost"
vagrant ssh-config dockerhost > "$SSHCFG"

# 2) Ansible from repo root (so inventory relative ssh_args works)
cd "$ROOT"

echo "🧪 Ansible ping (docker_nodes)..."
ansible -i "$INV" docker_nodes -m ping

echo "🚀 Deploy docker stack..."
ansible-playbook -i "$INV" "$PLAYBOOK" --limit docker_nodes
