#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/vagrant_local.ini"
SSHCFG="$ROOT/infra/ssh/ssh.config"

export ANSIBLE_CONFIG="$ROOT/infra/ansible/ansible-local.cfg"
export ANSIBLE_HOST_KEY_CHECKING="False"
export ANSIBLE_REMOTE_TEMP="/tmp/.ansible-local/tmp"

cd "$VAGRANT_DIR"

state="$(vagrant status k8shost --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo " Bringing up: k8shost"
  vagrant up k8shost
else
  echo " VM already running: k8shost"
fi

mkdir -p "$ROOT/infra/ssh"
echo " Generating $SSHCFG from vagrant for: k8shost"
vagrant ssh-config k8shost > "$SSHCFG"

export ANSIBLE_SSH_ARGS="-F $SSHCFG -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

cd "$ROOT"

echo " Ansible ping (k8s_nodes)..."
ansible -i "$INV" k8s_nodes -m ping

echo " Deploy k8s pipeline..."
ansible-playbook -i "$INV" ansible/k8s/playbooks/microk8s_install.yml --limit k8s_nodes
ansible-playbook -i "$INV" ansible/k8s/playbooks/k8s_apply_core.yml --limit k8s_nodes
