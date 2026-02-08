#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/vagrant_local.ini"
SSHCFG="$ROOT/infra/ssh/ssh.config"

SEED="$ROOT/ansible/vms/playbooks/vm_seed_like_k8s.yml"
LOAD="$ROOT/ansible/vms/playbooks/vm_load_photos_like_k8s.yml"

export ANSIBLE_CONFIG="$ROOT/infra/ansible/ansible-local.cfg"
export ANSIBLE_REMOTE_TEMP="/tmp/.ansible-local/tmp"
export ANSIBLE_HOST_KEY_CHECKING="False"

mkdir -p "$ROOT/infra/ssh"

TARGETS=(backend db front)
TARGET_PATTERN="backend:db:front"

cd "$VAGRANT_DIR"

# Βεβαιώνουμε ότι οι VMs είναι up
echo " Ensuring VMs are up: ${TARGETS[*]}"
vagrant up "${TARGETS[@]}" >/dev/null

# Περιμένουμε να είναι έτοιμο το SSH
for m in "${TARGETS[@]}"; do
  echo " Waiting for SSH on $m..."
  vagrant ssh "$m" -c "echo SSH_READY" >/dev/null
done

# Δημιουργία ssh config για τις 3 VMs
echo " Generating $SSHCFG from vagrant for: ${TARGETS[*]}"
vagrant ssh-config "${TARGETS[@]}" > "$SSHCFG"

cd "$ROOT"

echo " Ansible ping..."
ansible -i "$INV" "$TARGET_PATTERN" -m ping

# Αν υπάρχουν groups backend_nodes/db_nodes, τα χρησιμοποιούμε· αλλιώς fallback σε hostnames
use_backend_nodes=0
use_db_nodes=0
ansible-inventory -i "$INV" --graph 2>/dev/null | grep -q "@backend_nodes" && use_backend_nodes=1
ansible-inventory -i "$INV" --graph 2>/dev/null | grep -q "@db_nodes" && use_db_nodes=1

seed_limit="$TARGET_PATTERN"
load_limit="db"

if [ "$use_backend_nodes" -eq 1 ] || [ "$use_db_nodes" -eq 1 ]; then
  seed_limit=""
  [ "$use_backend_nodes" -eq 1 ] && seed_limit="backend_nodes"
  [ "$use_db_nodes" -eq 1 ] && seed_limit="${seed_limit:+$seed_limit:}db_nodes"
  load_limit=$([ "$use_db_nodes" -eq 1 ] && echo "db_nodes" || echo "db")
fi

echo " Seeding DB (limit: $seed_limit)"
ansible-playbook -i "$INV" "$SEED" --limit "$seed_limit"

echo " Loading photos (limit: $load_limit)"
ansible-playbook -i "$INV" "$LOAD" --limit "$load_limit"

echo " Seed VMs done."
