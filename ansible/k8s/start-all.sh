#!/usr/bin/env bash
set -e

NS=ds2025

echo "⏳ Περιμένω να είναι έτοιμο το Kubernetes cluster..."
kubectl wait --for=condition=Ready node --all --timeout=120s

echo "⏳ Περιμένω τα pods στο namespace $NS..."
kubectl wait --for=condition=Ready pod -l app=backend  -n $NS --timeout=120s
kubectl wait --for=condition=Ready pod -l app=frontend -n $NS --timeout=120s
kubectl wait --for=condition=Ready pod -l app=mailhog  -n $NS --timeout=120s

echo "✅ Cluster & pods έτοιμα"

echo ""
echo "🚀 Άνοιγμα port-forwards:"
echo "Frontend → http://127.0.0.1:8087"
echo "Backend  → http://127.0.0.1:8086"
echo "MailHog  → http://127.0.0.1:18025"
echo ""
echo "CTRL+C για τερματισμό όλων"

kubectl -n $NS port-forward svc/frontend 8087:80 &
kubectl -n $NS port-forward svc/backend  8086:8080 &
kubectl -n $NS port-forward svc/mailhog  18025:8025 &

wait
