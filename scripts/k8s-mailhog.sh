#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT/infra/vagrant"

CMD_MICROK8S="/snap/bin/microk8s"
if ! vagrant ssh k8shost -c "command -v microk8s >/dev/null 2>&1"; then
  true
fi

echo "Checking MailHog service in namespace ds2025..."
vagrant ssh k8shost -c "$CMD_MICROK8S kubectl -n ds2025 get svc mailhog"

echo
echo "Starting port-forward: k8shost:18025 -> svc/mailhog:8025 (bind 0.0.0.0)"
echo "Open on HOST: http://127.0.0.1:18025"
echo


vagrant ssh k8shost -c "$CMD_MICROK8S kubectl -n ds2025 port-forward svc/mailhog 18025:8025 --address 0.0.0.0"
