#!/bin/bash
set -e

# Prepare .ssh
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh

# Generate key once
if [ ! -f "/home/vagrant/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -b 4096 -N "" -f /home/vagrant/.ssh/id_rsa
fi

# Export public key to shared folder
cp /home/vagrant/.ssh/id_rsa.pub /vagrant/control.pub
chmod 644 /vagrant/control.pub

# SSH client config (lab convenience)
cat <<'SSHEOF' > /home/vagrant/.ssh/config
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
SSHEOF

chmod 600 /home/vagrant/.ssh/config
chown -R vagrant:vagrant /home/vagrant/.ssh
