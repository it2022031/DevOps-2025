#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT/vm/vagrant"
ansible-playbook -i hosts.ini docker/playbooks/docker_seed_like_k8s.yml --limit docker_nodes
ansible-playbook -i hosts.ini docker/playbooks/docker_load_photos_like_k8s.yml --limit docker_nodes
