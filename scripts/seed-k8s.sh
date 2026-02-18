#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/vagrant_local.ini"
SSHCFG="$ROOT/infra/ssh/ssh.config"

SEED="$ROOT/ansible/k8s/playbooks/k8s_seed_db.yml"
LOAD="$ROOT/ansible/k8s/playbooks/k8s_load_photos.yml"

export ANSIBLE_CONFIG="$ROOT/infra/ansible/ansible-local.cfg"
export ANSIBLE_REMOTE_TEMP="/tmp/.ansible-local/tmp"
export ANSIBLE_HOST_KEY_CHECKING="False"

mkdir -p "$ROOT/infra/ssh"

cd "$VAGRANT_DIR"

echo " Ensuring VM is up: k8shost"
vagrant up k8shost >/dev/null

echo " Waiting for SSH on k8shost..."
vagrant ssh k8shost -c "echo SSH_READY" >/dev/null

# Δημιουργία ssh config για όλα τα VMs που τρέχουν
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

echo " Ansible ping (k8s)..."
ansible -i "$INV" k8s_nodes -m ping

echo " Seed k8s DB..."
ansible-playbook -i "$INV" "$SEED" --limit k8s_nodes

echo " Load k8s photos..."
ansible-playbook -i "$INV" "$LOAD" --limit k8s_nodes

echo " Seed k8s done."
