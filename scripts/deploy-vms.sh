#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/vm/vagrant"
cd "$VAGRANT_DIR"
export ANSIBLE_CONFIG="$VAGRANT_DIR/ansible-host.cfg"

TARGETS=(backend db front)
TARGET_PATTERN="backend:db:front"

# Ensure required VMs are up
need_up=0
for m in "${TARGETS[@]}"; do
  state="$(vagrant status "$m" --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
  if [ "$state" != "running" ]; then
    need_up=1
  fi
done

if [ "$need_up" -eq 1 ]; then
  echo "🔧 Bringing up: ${TARGETS[*]}"
  vagrant up "${TARGETS[@]}"
else
  echo "✅ VMs already running: ${TARGETS[*]}"
fi

# Refresh ssh.config ONLY for these machines (more stable)
echo "🔁 Generating ssh.config from vagrant for: ${TARGETS[*]}"
for i in 1 2 3; do
  if vagrant ssh-config "${TARGETS[@]}" > ssh.config; then
    break
  fi
  echo "⏳ ssh-config not ready yet, retry $i/3..."
  sleep 2
done

echo "🧪 Ansible ping (targets only)..."
ansible -i hosts.ini "$TARGET_PATTERN" -m ping

echo "🚀 Deploy (targets only)..."
ansible-playbook -i hosts.ini playbooks/site.yml --limit "$TARGET_PATTERN"
