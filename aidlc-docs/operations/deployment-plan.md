# Deployment Plan — dbp-visitor Plugin

## Deployment Targets
- **Staging**: AWS Lightsail (32.196.224.204) — same instance as dlc-sample
- **Production**: AWS Lightsail (3.230.145.236) — same instance as dlc-sample
- **Local**: Docker Compose (WordPress 6.7 + MariaDB 11.4)

## Environments

| Environment | Branch | Purpose | Trigger | Approval |
|---|---|---|---|---|
| Local | Any | Development & testing | Manual (docker compose) | None |
| Staging | develop | Integration testing, QA | Auto on push to develop | None |
| Production | main | Live traffic | Auto on push to main | Approval gate required |

## Branch → Environment Mapping (GitFlow)

| Branch | Environment | Trigger | Action |
|---|---|---|---|
| `develop` | Staging | Push/merge to develop | Auto-deploy via GitHub Actions |
| `main` | Production | Push/merge to main | Deploy after approval gate |
| `feature/*` | Local only | Manual | Docker compose for local testing |

## Deployment Path

```
Local (Docker) → Staging (Lightsail) → Production (Lightsail)
     Stage 2-3         Stage 4              Stage 6
```

### Stage 2: Local Scripts
- Build validation (JS syntax, PHP lint via Docker)
- Plugin structure verification
- Script creation (adapted from dlc-sample)

### Stage 3: Local Simulation (Docker)
- Full Docker environment (WordPress + MariaDB)
- Plugin activation via WP-CLI
- Playwright E2E tests (12 scenarios)
- First-try success required

### Stage 4: Staging Cloud Deployment
- SSH/SCP to 32.196.224.204
- Backup existing plugin folder
- Deploy new plugin files
- Activate via WP-CLI
- Validate (curl checks + manual verify)

### Stage 5: CI/CD Pipeline
- GitHub Actions workflow for dbp-visitor
- Push to `develop` → auto-deploy to staging
- Push to `main` → deploy to production (with approval)
- Reuse existing SSH key (`lightsail-key.pem`) and GitHub Secrets

### Stage 6: Multi-Environment
- Staging auto-deploy on develop branch
- Production deploy with approval gate on main branch
- Same validation checks on both environments

## Database
- **None** — plugin uses WP Options API (single toggle) + client-side storage
- No migrations, no seed data beyond activation hook

## Configuration
- **Plugin settings**: WP admin UI per environment (enable/disable toggle)
- **Deploy credentials**: Existing GitHub Secrets (SSH key, server IPs)
- **No .env files needed** for the plugin itself

## Rollback Strategy
1. Deploy script creates backup: `dbp-visitor-backup-{timestamp}/`
2. If health check fails: restore backup folder
3. Rollback script: `scripts/deploy/rollback.sh` (adapted for dbp-visitor)
4. WP-CLI deactivate as immediate mitigation if needed

## Security Requirements
- No 0.0.0.0/0 in security groups (existing Lightsail config)
- SSH access via key pair only (existing `lightsail-key.pem`)
- Plugin folder permissions: 755 (dirs), 644 (files)
- No secrets in plugin code (no API keys needed — ip-api.com is keyless)

## Automation Level Summary
- **Staging**: Full auto (push to develop → deploy)
- **Production**: Auto with approval gate (push to main → approval → deploy)
- **Rollback**: Script-based (manual trigger or pipeline step)

## Stages to Execute
- [x] Stage 0: Prerequisites (COMPLETE)
- [x] Stage 1: Environment Strategy (COMPLETE)
- [ ] Stage 2: Local Scripts & Validation
- [ ] Stage 3: Staging Simulation (Docker + Playwright)
- [ ] Stage 4: Staging Cloud Deployment
- [ ] Stage 5: CI/CD Pipeline (GitHub Actions)
- [ ] Stage 6: Multi-Environment (staging + production)
- [ ] Stage 7: Operational Readiness — SKIP (not production-critical, simple plugin)
