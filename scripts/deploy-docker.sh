#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/vagrant_local.ini"
PLAYBOOK="$ROOT/ansible/docker/playbooks/docker_site.yml"
SSHCFG="$ROOT/infra/ssh/ssh.config"

export ANSIBLE_CONFIG="$ROOT/infra/ansible/ansible-local.cfg"
export ANSIBLE_REMOTE_TEMP="/tmp/.ansible-local/tmp"
export ANSIBLE_HOST_KEY_CHECKING="False"

mkdir -p "$ROOT/infra/ssh"

cd "$VAGRANT_DIR"

echo "🔧 Ensuring VM is up: dockerhost"
vagrant up dockerhost >/dev/null

echo "⏳ Waiting for SSH on dockerhost..."
vagrant ssh dockerhost -c "echo SSH_READY" >/dev/null

# Generate ssh config for all running machines (so it never breaks other scripts)
machines=()
for m in backend db front dockerhost k8shost jenkins; do
  st="$(vagrant status "$m" --machine-readable 2>/dev/null | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
  if [ "$st" = "running" ]; then
    machines+=("$m")
  fi
done

echo "🔁 Generating $SSHCFG from vagrant for: ${machines[*]}"
vagrant ssh-config "${machines[@]}" > "$SSHCFG"

cd "$ROOT"

echo "🧪 Ansible ping (docker)..."
ansible -i "$INV" docker_nodes -m ping

echo "🚀 Deploy docker stack..."
ansible-playbook -i "$INV" "$PLAYBOOK" --limit docker_nodes
