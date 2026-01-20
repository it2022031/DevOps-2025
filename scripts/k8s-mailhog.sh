#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)/infra/vagrant"
vagrant ssh k8shost -c "microk8s kubectl -n ds2025 port-forward svc/mailhog 18025:8025 --address 0.0.0.0"
