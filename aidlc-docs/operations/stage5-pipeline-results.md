# Stage 5: CI/CD Pipeline — Results (dbp-visitor)

## Pipeline Architecture

### Automatic Triggers (Push-to-Deploy)
| Workflow | Trigger | Branch | Target |
|---|---|---|---|
| `deploy-dbp-visitor-staging.yml` | Push to `develop` (paths: `plugins/dbp-visitor/**`) | develop | Staging (32.196.224.204) |
| `deploy-dbp-visitor-production.yml` | Push to `main` (paths: `plugins/dbp-visitor/**`) | main | Production (3.230.145.236) |

### Manual Triggers (Existing — works for any plugin)
| Workflow | Trigger | Target |
|---|---|---|
| `deploy-staging.yml` | workflow_dispatch (plugin name input) | Staging |
| `deploy-production.yml` | workflow_dispatch (plugin name input) | Production |

## Pipeline Steps (Both Environments)

```
validate → build → deploy → validate
```

1. **Validate**: PHP lint + JS syntax check
2. **Build**: `scripts/build.sh dbp-visitor` → `dist/dbp-visitor.zip`
3. **Deploy**: SCP zip to server → WP-CLI install + activate
4. **Validate**: curl check for `dbp-visitor-bar` in page HTML

## Approval Gate
- **Staging**: No approval required (auto-deploy on push)
- **Production**: GitHub Environment protection rules — requires manual approval via `environment: production` setting

## Required GitHub Secrets/Variables
| Name | Type | Value |
|---|---|---|
| `STAGING_SSH_KEY` | Secret | SSH private key for staging server |
| `STAGING_HOST` | Secret | 32.196.224.204 |
| `STAGING_USER` | Secret | bitnami |
| `PRODUCTION_SSH_KEY` | Secret | SSH private key for production server |
| `PRODUCTION_HOST` | Secret | 3.230.145.236 |
| `PRODUCTION_USER` | Secret | bitnami |
| `STAGING_URL` | Variable | http://32.196.224.204 |
| `PRODUCTION_URL` | Variable | http://3.230.145.236 |
| `WP_PATH` | Variable | /opt/bitnami/wordpress |

## Path Filtering
Workflows only trigger when files in `plugins/dbp-visitor/**` or `scripts/**` change — changes to `dlc-sample` or docs won't trigger dbp-visitor deploys.

## Gate Status: COMPLETE ✅
- Workflows created for both staging and production
- Automatic triggers on branch push with path filtering
- Production has approval gate via GitHub Environments
- Existing manual dispatch workflows also work for dbp-visitor
