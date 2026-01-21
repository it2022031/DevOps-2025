#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

VAGRANT_DIR="$ROOT/infra/vagrant"
INV="$ROOT/infra/inventories/vagrant_local.ini"
SSHCFG="$ROOT/infra/ssh/ssh.config"

JENKINS_INSTALL="$ROOT/ansible/jenkins/playbooks/jenkins_install.yml"
JENKINS_SSH_SETUP="$ROOT/ansible/jenkins/playbooks/jenkins_ssh_setup.yml"
ADD_JENKINS_KEY="$ROOT/ansible/jenkins/playbooks/add_jenkins_key.yml"

mkdir -p "$ROOT/infra/ssh"

cd "$VAGRANT_DIR"

# Ensure Jenkins VM is up (and targets exist if you want to authorize them)
vagrant up backend db front dockerhost k8shost >/dev/null || true

state="$(vagrant status jenkins --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo "🔧 Bringing up: jenkins"
  vagrant up jenkins
else
  echo "✅ VM already running: jenkins"
fi

# IMPORTANT: ssh config must include ALL machines, not just jenkins
echo "🔁 Generating $SSHCFG from vagrant (all machines)"
vagrant ssh-config backend db front dockerhost k8shost jenkins > "$SSHCFG"

cd "$ROOT"

echo "🧪 Ansible ping (jenkins_nodes)..."
ansible -i "$INV" jenkins_nodes -m ping

echo "🚀 Install Jenkins..."
ansible-playbook -i "$INV" "$JENKINS_INSTALL" --limit jenkins_nodes

echo "🧩 Configure Jenkins SSH user + keypair..."
ansible-playbook -i "$INV" "$JENKINS_SSH_SETUP" --limit jenkins_nodes

echo "🔑 Authorize Jenkins key on target VMs..."
ansible-playbook -i "$INV" "$ADD_JENKINS_KEY"

echo "✅ Jenkins base setup complete (jobs are seeded manually via UI + JobDSL)."
