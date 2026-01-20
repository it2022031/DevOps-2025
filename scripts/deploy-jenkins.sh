#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
VAGRANT_DIR="$ROOT/infra/vagrant"
cd "$VAGRANT_DIR"
export ANSIBLE_CONFIG="$VAGRANT_DIR/ansible-host.cfg"

TARGET_PATTERN="jenkins_nodes"

state="$(vagrant status jenkins --machine-readable | awk -F, '$3=="state" {print $4}' | tail -n1 || true)"
if [ "$state" != "running" ]; then
  echo "🔧 Bringing up: jenkins"
  vagrant up jenkins
else
  echo "✅ VM already running: jenkins"
fi

echo "🔁 Generating infra/ssh/ssh.config from vagrant for: jenkins"
for i in 1 2 3; do
  if vagrant ssh-config jenkins > infra/ssh/ssh.config; then
    break
  fi
  sleep 2
done

echo "🧪 Ansible ping (jenkins)..."
ansible -i infra/inventories/hosts.ini "$TARGET_PATTERN" -m ping

echo "🚀 Install Jenkins..."
ansible-playbook -i infra/inventories/hosts.ini jenkins/ansible/vms/playbooks/jenkins_install.yml --limit "$TARGET_PATTERN"

echo "🧩 Configure Jenkins SSH + prerequisites..."
ansible-playbook -i infra/inventories/hosts.ini jenkins/ansible/vms/playbooks/jenkins_ssh_setup.yml --limit "$TARGET_PATTERN"
ansible-playbook -i infra/inventories/hosts.ini jenkins/ansible/vms/playbooks/jenkins_docker_prereqs.yml --limit "$TARGET_PATTERN"

echo "📦 Create/Update Jenkins job(s)..."
#ansible-playbook -i infra/inventories/hosts.ini jenkins/ansible/vms/playbooks/jenkins_create_job.yml --limit "$TARGET_PATTERN" || true


