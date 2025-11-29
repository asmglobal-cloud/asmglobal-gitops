# ASMGlobal GitOps Applications

This folder contains all ArgoCD-managed applications for ASMGlobal.

Structure:
- infra-traefik/       → Traefik ingress routes, middleware, TLS config
- infra-certmanager/   → Let's Encrypt automatic SSL (added later)
- asm-backend/         → ASMGlobal backend API
- asm-frontend/        → ASMGlobal frontend
- flowcash-backend/    → Flowcash API
- flowcash-frontend/   → Flowcash UI
- chat-backend/        → Chat API
- chat-frontend/       → Chat UI
- spiritlynk-backend/  → SpiritLynk API
- spiritlynk-frontend/ → SpiritLynk UI

ArgoCD Root (`argocd-root.yaml`) will point to this folder.
