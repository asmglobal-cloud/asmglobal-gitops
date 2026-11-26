# Private Cloudflare Tunnel for Commander reports

This workload provides an outbound-only Cloudflare Tunnel connector for the read-only Commander report gateway. It does not create a Kubernetes Ingress or expose the gateway through a public load balancer.

## Required prerequisites

1. Create a remotely managed Cloudflare Tunnel in the Cloudflare dashboard and configure a connector token.
2. Store the tunnel token in the existing `asmglobal-observability` namespace as a Kubernetes Secret named `cloudflared-tunnel-token`, with key `TUNNEL_TOKEN`. Use the cluster's approved secret-management process. **Never commit the token to this repository.**
3. In the tunnel's public-hostname configuration, route `reports-gateway.asmglobal.cloud` to:
   `http://asmglobal-telegram.asmglobal-observability.svc.cluster.local:8080`
4. Protect that hostname with Cloudflare Access. Create a service-auth policy for the AppDeploy Cloudflare Access service token; do not allow public or unauthenticated access.
5. Ensure the gateway's own bearer token remains stored separately in its existing dedicated Kubernetes Secret. Cloudflare Access credentials and the gateway bearer token are distinct secrets.

## Argo CD

The Argo CD Application in `apps/infra-cloudflared-app.yaml` targets this Kustomize directory. Review and manually sync it only after the tunnel token Secret exists and the Cloudflare hostname and Access policy are configured.

The Deployment uses two connector replicas and a pinned cloudflared release. No credential values are stored in Git.
