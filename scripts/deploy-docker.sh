#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/vm/vagrant"
cd "$VAGRANT_DIR"

TARGETS=(dockerhost)
TARGET_PATTERN="dockerhost"

state="$(vagrant status dockerhost --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo "🔧 Bringing up: dockerhost"
  vagrant up dockerhost
else
  echo "✅ VM already running: dockerhost"
fi

echo "🔁 Generating ssh.config from vagrant for: dockerhost"
for i in 1 2 3; do
  if vagrant ssh-config dockerhost > ssh.config; then
    break
  fi
  echo "⏳ ssh-config not ready yet, retry $i/3..."
  sleep 2
done

echo "🧪 Ansible ping (dockerhost)..."
ansible -i hosts.ini "$TARGET_PATTERN" -m ping

echo "🚀 Deploy docker stack..."
ansible-playbook -i hosts.ini docker/playbooks/docker_site.yml --limit "$TARGET_PATTERN"
