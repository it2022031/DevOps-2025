#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/vagrant_local.ini"
PLAYBOOK="$ROOT/ansible/vms/playbooks/site.yml"
SSHCFG="$ROOT/infra/ssh/ssh.config"

export ANSIBLE_CONFIG="$ROOT/infra/ansible/ansible-local.cfg"
export ANSIBLE_REMOTE_TEMP="/tmp/.ansible-local/tmp"
export ANSIBLE_HOST_KEY_CHECKING="False"

mkdir -p "$ROOT/infra/ssh"

TARGETS=(backend db front)
TARGET_PATTERN="backend:db:front"

cd "$VAGRANT_DIR"

#  Επιβεβαίωση ότι τα target VMs είναι ενεργά
need_up=0
for m in "${TARGETS[@]}"; do
  state="$(vagrant status "$m" --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
  if [ "$state" != "running" ]; then
    need_up=1
  fi
done

if [ "$need_up" -eq 1 ]; then
  echo " Bringing up: ${TARGETS[*]}"
  vagrant up "${TARGETS[@]}"
else
  echo " VMs already running: ${TARGETS[*]}"
fi

# Αναμονή μέχρι να είναι έτοιμο το SSH
for m in "${TARGETS[@]}"; do
  echo "⏳ Waiting for SSH on $m..."
  # μπλοκάρει μέχρι να δουλέψει το ssh (ή αποτυγχάνει αν υπάρχει θέμα στο VM)
  vagrant ssh "$m" -c "echo SSH_READY" >/dev/null
done

# Δημιουργία ssh config μόνο για vms που υπάρχουν και τρέχουν
machines=()
for m in backend db front dockerhost k8shost jenkins; do
  st="$(vagrant status "$m" --machine-readable 2>/dev/null | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
  if [ "$st" = "running" ]; then
    machines+=("$m")
  fi
done

echo " Generating $SSHCFG from vagrant for: ${machines[*]}"
vagrant ssh-config "${machines[@]}" > "$SSHCFG"

cd "$ROOT"

echo " Using ANSIBLE_CONFIG=$ANSIBLE_CONFIG"
ansible --version | head -n 5

echo " Ansible ping (targets only)..."
ansible -i "$INV" "$TARGET_PATTERN" -m ping

echo " Ensure remote tmp exists on targets..."
ansible -i "$INV" "$TARGET_PATTERN" -b -m file -a "path=$ANSIBLE_REMOTE_TEMP state=directory mode=1777"

echo " Deploy (targets only)..."
ansible-playbook -i "$INV" "$PLAYBOOK" --limit "$TARGET_PATTERN"
