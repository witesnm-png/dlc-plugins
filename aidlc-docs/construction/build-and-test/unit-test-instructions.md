# Unit Test Instructions — dbp-visitor Plugin

## Overview
The dbp-visitor plugin is a lightweight WordPress plugin with frontend JavaScript logic.
Unit testing focuses on the JS logic functions which are testable in isolation.

## JavaScript Unit Tests (Manual Verification)

Since the plugin uses vanilla JS without a build system, unit testing is performed through:
1. **Node.js syntax validation** (automated)
2. **Browser console verification** (manual, during integration tests)

### Testable JS Functions

| Function | Test Case | Expected Result |
|---|---|---|
| `getVisitCount()` | First visit (no localStorage) | Returns 1, stores "1" |
| `getVisitCount()` | Second visit (localStorage has "1") | Returns 2, stores "2" |
| `parseReferrer("https://google.com/search", "https://mysite.com")` | Known referrer | Returns "Google" |
| `parseReferrer("https://unknown.org", "https://mysite.com")` | Unknown referrer | Returns "unknown.org" |
| `parseReferrer("", "https://mysite.com")` | Empty referrer | Returns "" |
| `parseReferrer("https://mysite.com/page1", "https://mysite.com")` | Internal referrer | Returns "" |
| `composeMessage(1, "", null)` | First visit, no referrer, no geo | "Welcome, first-time visitor!" |
| `composeMessage(5, "Google", {city:"NYC",country:"US"})` | Returning, referrer, geo | "Welcome back for visit #5! You came from Google. Visiting from NYC, US." |
| `escapeHtml("<script>alert(1)</script>")` | XSS attempt | Returns escaped HTML entities |

### Automated Syntax Validation
```bash
node --check plugins/dbp-visitor/assets/js/dbp-visitor.js
```

## PHP Unit Tests (Manual Verification)

### Testable PHP Functions

| Function | Test Case | Expected Result |
|---|---|---|
| `dbp_visitor_sanitize_enabled('1')` | Valid enabled value | Returns '1' |
| `dbp_visitor_sanitize_enabled('0')` | Valid disabled value | Returns '0' |
| `dbp_visitor_sanitize_enabled('malicious')` | Invalid value | Returns '0' |
| `dbp_visitor_sanitize_enabled('')` | Empty value | Returns '0' |

### PHP Lint
```bash
php -l plugins/dbp-visitor/dbp-visitor.php
```

## Test Status
- **JS Syntax Check**: PASS (validated via `node --check`)
- **PHP Lint**: Pending PHP CLI availability (validated in Docker during Stage 3)
- **Function Logic**: Verified through code review and integration testing
