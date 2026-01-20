#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT/vm/vagrant"
ansible-playbook -i hosts.ini k8s/playbooks/k8s_seed_db.yml --limit k8s_nodes
ansible-playbook -i hosts.ini k8s/playbooks/k8s_load_photos.yml --limit k8s_nodes
