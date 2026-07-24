# Stage 6: Multi-Environment — Results (dbp-visitor)

## Environment Configuration

| Environment | Server | Branch | Trigger | Approval |
|---|---|---|---|---|
| Local | Docker (localhost:8080) | Any | Manual | None |
| Staging | 32.196.224.204 | develop | Auto on push | None |
| Production | 3.230.145.236 | main | Auto on push | Required |

## Branch → Environment Mapping (GitFlow)

```
feature/* → (local dev only)
    ↓ (merge)
develop → Staging (auto-deploy)
    ↓ (merge/release)
main → Production (approval gate)
```

## Environment Isolation
- Each environment has its own WordPress instance on separate Lightsail servers
- Plugin settings (enable/disable) are managed independently per environment via WP admin
- No shared state between environments (client-side storage is per-browser)
- GitHub Environments provide environment-specific secrets and approval rules

## Deployment Flow
1. Developer works on `feature/*` branch, tests locally with Docker
2. Merge to `develop` → automatic deploy to staging
3. Validate on staging (manual or automated checks)
4. Merge to `main` → triggers production workflow, requires approval
5. After approval → deploys to production with backup

## Rollback
- **Automatic backup**: Production workflow creates `.bak` folder before deploy
- **Manual rollback**: `scripts/deploy/rollback.sh dbp-visitor /opt/bitnami/wordpress`
- **Pipeline rollback**: Re-run workflow with previous commit SHA

## Current Status
- [x] Staging: dbp-visitor deployed and active (verified)
- [ ] Production: Ready for deployment (pending first merge to main)
- [x] Workflows: Created for both environments
- [x] Path filtering: Only dbp-visitor changes trigger dbp-visitor workflows
- [x] Approval gate: Production environment requires manual approval

## Gate Status: COMPLETE ✅
