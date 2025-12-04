# asmglobal-gitops

This repository will contain Kubernetes manifests and ArgoCD "App of Apps" to deploy ASMGlobal, Flowcash, Chat, and SpiritLynk services.

Default domains (change if needed):
- argocd.asmglobal.cloud
- traefik.asmglobal.cloud
- api.asmglobal.cloud
- app.asmglobal.cloud
- flowcash.asmglobal.cloud
- api.flowcash.asmglobal.cloud
- chat.asmglobal.cloud
- api.chat.asmglobal.cloud
- spiritlynk.asmglobal.cloud
- api.spiritlynk.asmglobal.cloud

Instructions:
1. Add Kubernetes manifests in the `apps/` and `infra/` folders.
2. Push this repo to GitHub and note the Git URL.
3. Update ArgoCD root application to point at the Git URL (we will do this later).
# Trigger CI
