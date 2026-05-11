#!/bin/bash

set -e

OS=$1
TENANT=$2
ENVIRONMENT=${3:-dev}

if [ -z "$OS" ] || [ -z "$TENANT" ]; then
  echo "Usage:"
  echo "./provision.sh <os> <tenant-slug> [environment]"
  exit 1
fi

ROOT="/root/asmglobal-platform-os/apps/asm-gitops-os"

TEMPLATE="$ROOT/templates/base-tenant.yaml"

TARGET_DIR="$ROOT/tenants/$ENVIRONMENT/$OS/$TENANT"

mkdir -p "$TARGET_DIR"

TENANT_NAMESPACE="${OS}-${TENANT}-${ENVIRONMENT}"

TENANT_IMAGE="knnrsolomon/${OS}-os:release"

TENANT_HOST="${TENANT}.${OS}.asmglobal.cloud"

TENANT_TLS_SECRET="${TENANT}-${OS}-tls"

TARGET_FILE="$TARGET_DIR/all.yaml"
REGISTRY="$ROOT/registry/tenants.json"

CREATED_AT=$(date +"%Y-%m-%d %H:%M:%S")

cp "$TEMPLATE" "$TARGET_FILE"

sed -i "s|{{TENANT_NAMESPACE}}|$TENANT_NAMESPACE|g" "$TARGET_FILE"

sed -i "s|{{TENANT_NAME}}|$TENANT|g" "$TARGET_FILE"

sed -i "s|{{TENANT_IMAGE}}|$TENANT_IMAGE|g" "$TARGET_FILE"

sed -i "s|{{TENANT_OS}}|$OS|g" "$TARGET_FILE"

sed -i "s|{{TENANT_ENV}}|$ENVIRONMENT|g" "$TARGET_FILE"

sed -i "s|{{TENANT_HOST}}|$TENANT_HOST|g" "$TARGET_FILE"

sed -i "s|{{TENANT_TLS_SECRET}}|$TENANT_TLS_SECRET|g" "$TARGET_FILE"

echo ""

echo "Updating sovereign registry..."
echo ""

TMP=$(mktemp)

jq --arg os "$OS" \
   --arg tenant "$TENANT" \
   --arg env "$ENVIRONMENT" \
   --arg namespace "$TENANT_NAMESPACE" \
   --arg host "$TENANT_HOST" \
   --arg image "$TENANT_IMAGE" \
   --arg created "$CREATED_AT" \
   '. += [{
      os: $os,
      tenant: $tenant,
      environment: $env,
      namespace: $namespace,
      host: $host,
      image: $image,
      status: "ACTIVE",
      created_at: $created
   }]' "$REGISTRY" > "$TMP"

mv "$TMP" "$REGISTRY"

echo ""

echo "Updating GitOps repository..."
echo ""

cd "$ROOT"

git add .

git commit -m "provision: $OS/$TENANT ($ENVIRONMENT)"

echo ""

echo "GitOps state committed successfully."
echo ""

echo "======================================"
echo "DEPLOYMENT COMPLETE"
echo "======================================"
echo ""

echo "Tenant is now live at:"
echo "https://$TENANT_HOST"

echo ""

echo "Registry updated:"
echo "$REGISTRY"

echo ""
