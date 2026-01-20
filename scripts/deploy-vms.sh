#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/hosts.ini"
PLAYBOOK="$ROOT/ansible/vms/playbooks/site.yml"
SSHCFG="$ROOT/infra/ssh/ssh.config"

mkdir -p "$ROOT/infra/ssh"

TARGETS=(backend db front)
TARGET_PATTERN="backend:db:front"

# 1) Vagrant operations must run in the Vagrantfile directory
cd "$VAGRANT_DIR"

need_up=0
for m in "${TARGETS[@]}"; do
  state="$(vagrant status "$m" --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
  if [ "$state" != "running" ]; then need_up=1; fi
done

if [ "$need_up" -eq 1 ]; then
  echo "🔧 Bringing up: ${TARGETS[*]}"
  vagrant up "${TARGETS[@]}"
else
  echo "✅ VMs already running: ${TARGETS[*]}"
fi

echo "🔁 Generating $SSHCFG from vagrant for: ${TARGETS[*]}"
vagrant ssh-config "${TARGETS[@]}" > "$SSHCFG"

# 2) Ansible should run from repo root so relative paths in inventory work
cd "$ROOT"

echo "🧪 Ansible ping (targets only)..."
ansible -i "$INV" "$TARGET_PATTERN" -m ping

echo "🚀 Deploy (targets only)..."
ansible-playbook -i "$INV" "$PLAYBOOK" --limit "$TARGET_PATTERN"
