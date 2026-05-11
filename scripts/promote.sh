#!/bin/bash

set -e

OS=$1
TENANT=$2

if [ -z "$OS" ] || [ -z "$TENANT" ]; then
  echo "Usage:"
  echo "./promote.sh <os> <tenant>"
  exit 1
fi

ROOT="/root/asmglobal-platform-os/apps/asm-gitops-os"

SOURCE_DIR="$ROOT/tenants/dev/$OS/$TENANT"

TARGET_DIR="$ROOT/tenants/prod/$OS/$TENANT"

ARGO_SOURCE="$ROOT/argocd/dev/${TENANT}.yaml"

ARGO_TARGET="$ROOT/argocd/prod/${TENANT}.yaml"

if [ ! -d "$SOURCE_DIR" ]; then
  echo ""
  echo "Dev tenant does not exist."
  echo ""
  exit 1
fi

mkdir -p "$TARGET_DIR"

cp "$SOURCE_DIR/all.yaml" "$TARGET_DIR/all.yaml"

cp "$ARGO_SOURCE" "$ARGO_TARGET"

sed -i "s|-dev|-prod|g" "$TARGET_DIR/all.yaml"

sed -i "s|environment: \"dev\"|environment: \"prod\"|g" "$TARGET_DIR/all.yaml"

sed -i "s|argocd/dev|argocd/prod|g" "$ARGO_TARGET"

sed -i "s|tenants/dev|tenants/prod|g" "$ARGO_TARGET"

sed -i "s|-dev|-prod|g" "$ARGO_TARGET"

echo ""

echo "Production manifests generated."
echo ""

cd "$ROOT"

git add .

git commit -m "promote: $OS/$TENANT (prod)"

echo ""

echo "Pushing sovereign promotion..."
echo ""

git push

echo ""

echo "Triggering ArgoCD reconciliation..."
echo ""

kubectl annotate application asmglobal-gitops-root \
  -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite

echo ""

echo "======================================"
echo "PROMOTION COMPLETE"
echo "======================================"
echo ""

echo "Production tenant:"
echo "https://$TENANT.$OS.asmglobal.cloud"

echo ""
