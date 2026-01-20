#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/vm/vagrant"
cd "$VAGRANT_DIR"

TARGETS=(backend db front)
TARGET_PATTERN="backend:db:front"

# Ensure VMs up
need_up=0
for m in "${TARGETS[@]}"; do
  state="$(vagrant status "$m" --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
  if [ "$state" != "running" ]; then need_up=1; fi
done
if [ "$need_up" -eq 1 ]; then
  echo "🔧 Bringing up: ${TARGETS[*]}"
  vagrant up "${TARGETS[@]}"
fi

# Refresh ssh.config for these VMs
echo "🔁 Generating ssh.config for: ${TARGETS[*]}"
vagrant ssh-config "${TARGETS[@]}" > ssh.config

echo "🧪 Ping..."
ansible -i hosts.ini "$TARGET_PATTERN" -m ping

echo "🌱 Seed DB..."
ansible-playbook -i hosts.ini playbooks/vm_seed_like_k8s.yml --limit "$TARGET_PATTERN"

echo "🖼️ Load photos..."
ansible-playbook -i hosts.ini playbooks/vm_load_photos_like_k8s.yml --limit "$TARGET_PATTERN"
