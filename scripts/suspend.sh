#!/bin/bash

set -e

OS=$1
TENANT=$2
ENVIRONMENT=${3:-dev}

if [ -z "$OS" ] || [ -z "$TENANT" ]; then
  echo "Usage:"
  echo "./suspend.sh <os> <tenant> [environment]"
  exit 1
fi

ROOT="/root/asmglobal-platform-os/apps/asm-gitops-os"

MANIFEST="$ROOT/tenants/$ENVIRONMENT/$OS/$TENANT/all.yaml"

REGISTRY="$ROOT/registry/tenants.json"

if [ ! -f "$MANIFEST" ]; then
  echo ""
  echo "Tenant manifest not found."
  echo ""
  exit 1
fi

echo ""

echo "Suspending tenant workloads..."
echo ""

sed -i 's/replicas: 1/replicas: 0/g' "$MANIFEST"

TMP=$(mktemp)

jq --arg tenant "$TENANT" \
   --arg env "$ENVIRONMENT" \
   'map(
      if .tenant == $tenant and .environment == $env
      then .status = "SUSPENDED"
      else .
      end
   )' "$REGISTRY" > "$TMP"

mv "$TMP" "$REGISTRY"

echo ""

echo "Registry updated:"
echo "$REGISTRY"

echo ""

cd "$ROOT"

git add .

git commit -m "suspend: $OS/$TENANT ($ENVIRONMENT)"

echo ""

echo "Pushing sovereign governance update..."
echo ""

git push

echo ""

echo "Triggering ArgoCD reconciliation..."
echo ""

kubectl annotate application asmglobal-gitops-root \
  -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite

kubectl annotate application asmglobal-gitops-prod \
  -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite

echo ""

echo "======================================"
echo "TENANT SUSPENDED"
echo "======================================"
echo ""

echo "Tenant:"
echo "$TENANT"

echo ""

echo "Environment:"
echo "$ENVIRONMENT"

echo ""
