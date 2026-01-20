#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/vm/vagrant"
cd "$VAGRANT_DIR"
export ANSIBLE_CONFIG="$VAGRANT_DIR/ansible-host.cfg"

TARGETS=(k8shost)
TARGET_PATTERN="k8s_nodes"

state="$(vagrant status k8shost --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo "🔧 Bringing up: k8shost"
  vagrant up k8shost
else
  echo "✅ VM already running: k8shost"
fi

echo "🔁 Generating ssh.config from vagrant for: k8shost"
for i in 1 2 3; do
  if vagrant ssh-config k8shost > ssh.config; then
    break
  fi
  echo "⏳ ssh-config not ready yet, retry $i/3..."
  sleep 2
done

echo "🧪 Ansible ping (k8s)..."
ansible -i hosts.ini "$TARGET_PATTERN" -m ping

echo "🚀 Deploy k8s pipeline..."
ansible-playbook -i hosts.ini k8s/playbooks/k8s_full_pipeline.yml --limit "$TARGET_PATTERN"
