#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/hosts.ini"

# Τοπικό ansible cfg (χρησιμοποιεί το infra/ssh/ssh.config)
export ANSIBLE_CONFIG="$ROOT/infra/ansible/ansible-local.cfg"
export ANSIBLE_HOST_KEY_CHECKING="False"
export ANSIBLE_REMOTE_TEMP="/tmp/.ansible-local/tmp"

cd "$VAGRANT_DIR"

# Επιβεβαίωση ότι το VM k8shost είναι ενεργό
state="$(vagrant status k8shost --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo " Bringing up: k8shost"
  vagrant up k8shost
else
  echo " VM already running: k8shost"
fi

# Δημιουργία ssh config για το k8shost
mkdir -p "$ROOT/infra/ssh"
echo " Generating $ROOT/infra/ssh/ssh.config from vagrant for: k8shost"
vagrant ssh-config k8shost > "$ROOT/infra/ssh/ssh.config"

cd "$ROOT"

echo " Ansible ping (k8s)..."
ansible -i "$INV" k8s -m ping

echo " Deploy k8s pipeline..."
ansible-playbook -i "$INV" ansible/k8s/playbooks/microk8s_install.yml --limit k8s
ansible-playbook -i "$INV" ansible/k8s/playbooks/k8s_apply_core.yml --limit k8s
