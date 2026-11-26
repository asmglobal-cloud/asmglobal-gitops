# Private Cloudflare Tunnel for Commander reports

This workload provides an outbound-only Cloudflare Tunnel connector for the read-only Commander report gateway. It does not create a Kubernetes Ingress or expose the gateway through a public load balancer.

## Existing staging DNS — leave unchanged

The existing `telegram-staging.asmcloud.org` A record pointing to `5.182.18.49` is Telegram staging and is DNS-only. **Do not edit, replace, or repoint that record for Commander.**

Use a separate hostname for the private Commander report endpoint:

`commander-reports.asmcloud.org`

This hostname must be configured as a Cloudflare Tunnel public-hostname route (Cloudflare-managed CNAME to the tunnel), not as an A record to the VPS IP. Keep the Tunnel route protected by Cloudflare Access service authentication.

## Required prerequisites

1. Create a remotely managed Cloudflare Tunnel in the Cloudflare dashboard and configure a connector token.
2. Store the tunnel token in the existing `asmglobal-observability` namespace as a Kubernetes Secret named `cloudflared-tunnel-token`, with key `TUNNEL_TOKEN`. Use the cluster's approved secret-management process. **Never commit the token to this repository.**
3. Configure the Tunnel hostname `commander-reports.asmcloud.org` to route to:
   `http://asmglobal-telegram.asmglobal-observability.svc.cluster.local:8080`
4. Apply Cloudflare Access to that hostname. Create a service-auth policy for the AppDeploy Cloudflare Access service token; do not allow public or unauthenticated access.
5. Ensure the gateway's own bearer token remains stored separately in its existing dedicated Kubernetes Secret. Cloudflare Access credentials and the gateway bearer token are distinct secrets.
6. Configure AppDeploy's server-side report API base URL to the HTTPS hostname only after the tunnel and Access policy are verified.

## Argo CD

The Argo CD Application in `apps/infra-cloudflared-app.yaml` targets this Kustomize directory. Review and manually sync it only after the tunnel token Secret exists and the Cloudflare hostname and Access policy are configured.

The Deployment uses two connector replicas and a pinned cloudflared release. No credential values are stored in Git.
