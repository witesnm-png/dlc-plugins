# Stage 0: Prerequisites — Validated (dbp-visitor)

## Test Suite
- **Framework**: Playwright (automated browser testing)
- **Total Tests**: 12 scenarios
- **Breakdown**: Integration/E2E (12 — bar rendering, dismiss, visit count, referrer, geolocation, accessibility, CSP, responsive)
- **Additional**: JS syntax validation (`node --check`), PHP lint (`php -l`)
- **Pass Rate**: Pending execution (requires Docker environment running)
- **Config**: `plugins/dbp-visitor/playwright.config.js`
- **Test File**: `plugins/dbp-visitor/tests/dbp-visitor.spec.js`

## Project Structure
```
plugins/dbp-visitor/
├── dbp-visitor.php            # Main plugin file
├── assets/
│   ├── css/dbp-visitor.css    # Frontend styles
│   └── js/dbp-visitor.js      # Frontend logic
├── tests/
│   └── dbp-visitor.spec.js    # Playwright E2E tests
├── composer.json              # PHPCS/linting tooling
├── package.json               # Playwright dev dependency
├── playwright.config.js       # Test configuration
└── readme.txt                 # WordPress plugin readme
```
- **Decision**: Structure updated with readme.txt, tests, and tooling config

## Database Strategy
- **Dev**: No database (WP Options API, client-side storage)
- **Staging/Prod**: No database (same)
- **Migration**: None needed

## Seed Data
- **Strategy**: Plugin activation hook sets default option (`dbp_visitor_enabled = '1'`)
- **No external seed data required**

## Build System
- **PHP Linting**: Composer + PHPCS (WordPress standard)
- **JS Validation**: `node --check`
- **Test Execution**: `npx playwright test` (after `npm install`)
- **Deployment**: File copy (no compilation)

## Containerization
- **Reusing**: Existing workspace `docker-compose.yml` (WordPress 6.7 + MariaDB 11.4)
- **Plugin Mount**: `./plugins` → `/var/www/html/wp-content/plugins`
- **No changes needed** to Docker configuration

## Gate Status
- [x] Automated test suite exists (Playwright, 12 scenarios)
- [ ] All tests pass (execution pending — requires Docker + npm install)
- [x] Project structure documented
- [x] Seed data strategy defined (activation hook)
- [x] Build system works (JS syntax validated)
