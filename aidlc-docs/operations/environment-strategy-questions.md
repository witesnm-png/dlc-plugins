# Environment Strategy Questions — dbp-visitor

The workspace already has deployment infrastructure from the dlc-sample plugin (AWS Lightsail, GitHub Actions, staging+production). These questions determine the strategy for the dbp-visitor plugin.

## Question 1: Deployment Targets
What are the deployment targets for this plugin?

A) Same AWS Lightsail instances as dlc-sample (staging: 32.196.224.204, prod: 3.230.145.236)
B) Different cloud VM (new Lightsail/EC2 instances)
C) WordPress Playground only (no cloud deployment)
D) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 2: Environment Strategy
How many environments do you need?

A) 2 environments (local Docker + production)
B) 3 environments (local Docker + staging + production) — same as dlc-sample
C) 4+ environments (local + staging + UAT + production)
D) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 3: Branch Strategy
How should branches map to environments?

A) GitFlow (main=prod, develop=staging) — same as dlc-sample
B) Trunk-based (main=prod, feature branches → staging on merge)
C) Branch-per-environment (staging branch, main branch)
D) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 4: Deployment Automation
What level of CI/CD automation is needed?

A) Full automation (push-to-deploy for staging, approval gate for production)
B) Semi-automated (manual trigger GitHub Action, automated execution) — same as dlc-sample
C) Manual with scripts (SSH + SCP deploy scripts only)
D) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 5: Database Strategy
How should data be managed across environments?

A) No database — client-side storage only (localStorage/sessionStorage), WP Options API for settings
B) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 6: Configuration Strategy
Where should configuration and secrets be stored?

A) WordPress admin settings only (single enable/disable toggle, managed per-environment via WP admin UI)
B) Environment files (.env) per server
C) CI/CD pipeline secrets (GitHub Secrets) for deploy credentials + WP admin for plugin settings
D) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 7: Rollback Strategy
How should a failed deployment be rolled back?

A) Backup previous plugin folder, restore if needed (file-based rollback) — same as dlc-sample
B) Redeploy previous git commit through pipeline
C) WP-CLI plugin deactivate + restore from backup
D) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 8: Stage 3 Simulation Scope
What should Stage 3 (local staging simulation) include?

A) Full Docker simulation matching production (WordPress + MariaDB + plugin activation + Playwright tests)
B) Docker for WordPress only, skip full E2E
C) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 9: Reuse Existing Infrastructure
Since dlc-sample already has deploy scripts, GitHub Actions, and server access configured, should dbp-visitor reuse or create independent infrastructure?

A) Reuse — deploy to same servers, adapt existing scripts/workflows for dbp-visitor
B) Independent — create separate scripts and workflows specific to dbp-visitor
C) Shared pipeline — single workflow deploys both plugins together
D) Other (please describe after [Answer]: tag below)

[Answer]: A
