#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
cd "$VAGRANT_DIR"
export ANSIBLE_CONFIG="$VAGRANT_DIR/ansible-host.cfg"

TARGETS=(backend db front)

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

# Refresh infra/ssh/ssh.config for these VMs
echo "🔁 Generating infra/ssh/ssh.config for: ${TARGETS[*]}"
vagrant ssh-config "${TARGETS[@]}" > infra/ssh/ssh.config

echo "🧪 Ping..."
ansible -i infra/inventories/hosts.ini "backend:db:front" -m ping

echo "🌱 Seed DB (VMs, k8s-like)..."
ansible-playbook -i infra/inventories/hosts.ini ansible/vms/playbooks/vm_seed_like_k8s.yml --limit "backend_nodes:db_nodes"

echo "🖼️ Load photos (DB VM, k8s-like)..."
ansible-playbook -i infra/inventories/hosts.ini ansible/vms/playbooks/vm_load_photos_like_k8s.yml --limit "db_nodes"
