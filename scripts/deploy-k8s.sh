#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/hosts.ini"
PLAYBOOK="$ROOT/ansible/k8s/playbooks/k8s_full_pipeline.yml"
SSHCFG="$ROOT/infra/ssh/ssh.config"

mkdir -p "$ROOT/infra/ssh"

# 1) Vagrant actions
cd "$VAGRANT_DIR"

state="$(vagrant status k8shost --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo "🔧 Bringing up: k8shost"
  vagrant up k8shost
else
  echo "✅ VM already running: k8shost"
fi

echo "🔁 Generating $SSHCFG from vagrant for: k8shost"
vagrant ssh-config k8shost > "$SSHCFG"

# 2) Ansible from repo root
cd "$ROOT"

echo "🧪 Ansible ping (k8s_nodes)..."
ansible -i "$INV" k8s_nodes -m ping

echo "🚀 Deploy k8s pipeline..."
ansible-playbook -i "$INV" "$PLAYBOOK" --limit k8s_nodes
