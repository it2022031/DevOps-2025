#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
cd "$VAGRANT_DIR"

export ANSIBLE_CONFIG="$VAGRANT_DIR/ansible-host.cfg"

ansible-playbook k8s/ansible/vms/playbooks/k8s_seed_db.yml --limit k8s_nodes
ansible-playbook k8s/ansible/vms/playbooks/k8s_load_photos.yml --limit k8s_nodes
