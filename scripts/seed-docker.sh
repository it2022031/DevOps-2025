#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/vm/vagrant"
cd "$VAGRANT_DIR"

export ANSIBLE_CONFIG="$VAGRANT_DIR/ansible-host.cfg"

# Ensure dockerhost VM is up
state="$(vagrant status dockerhost --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo "🔧 Bringing up: dockerhost"
  vagrant up dockerhost
fi

# Refresh ssh.config so Ansible can reach dockerhost
vagrant ssh-config dockerhost > ssh.config

# Seed + load photos (k8s-like) on dockerhost
ansible -i hosts.ini docker_nodes -m ping
ansible-playbook docker/playbooks/docker_seed_like_k8s.yml --limit docker_nodes
ansible-playbook docker/playbooks/docker_load_photos_like_k8s.yml --limit docker_nodes
