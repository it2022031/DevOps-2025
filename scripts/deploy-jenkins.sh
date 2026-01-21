#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/vagrant_local.ini"
SSHCFG="$ROOT/infra/ssh/ssh.config"

JENKINS_INSTALL="$ROOT/ansible/jenkins/playbooks/jenkins_install.yml"
JENKINS_SSH_SETUP="$ROOT/ansible/jenkins/playbooks/jenkins_ssh_setup.yml"
ADD_JENKINS_KEY="$ROOT/ansible/jenkins/playbooks/add_jenkins_key.yml"

export ANSIBLE_CONFIG="$ROOT/infra/ansible/ansible-local.cfg"
export ANSIBLE_REMOTE_TEMP="/tmp/.ansible-local/tmp"
export ANSIBLE_HOST_KEY_CHECKING="False"

mkdir -p "$ROOT/infra/ssh"

cd "$VAGRANT_DIR"

echo "🔧 Ensuring VMs are up: jenkins backend db front dockerhost k8shost (if defined)"
vagrant up jenkins backend db front dockerhost k8shost >/dev/null || true

echo "⏳ Waiting for SSH on jenkins..."
vagrant ssh jenkins -c "echo SSH_READY" >/dev/null

# Generate ssh config for all running machines (never breaks other scripts)
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

echo "🧪 Ansible ping (jenkins)..."
ansible -i "$INV" jenkins -m ping

# Check if Jenkins is already running (skip install if yes)
echo "🔎 Checking if Jenkins is already up on jenkins VM..."
if vagrant ssh jenkins -c "curl -fsS http://127.0.0.1:8080/login >/dev/null" >/dev/null 2>&1; then
  echo "✅ Jenkins already running — skipping jenkins_install.yml"
else
  echo "🚀 Jenkins not responding — running jenkins_install.yml"
  ansible-playbook -i "$INV" "$JENKINS_INSTALL" --limit jenkins
fi

echo "🧩 Configure Jenkins SSH user + keypair (idempotent)..."
ansible-playbook -i "$INV" "$JENKINS_SSH_SETUP" --limit jenkins

echo "🔑 Authorize Jenkins key on target VMs (idempotent)..."
ansible-playbook -i "$INV" "$ADD_JENKINS_KEY"

echo "✅ Jenkins setup done."
