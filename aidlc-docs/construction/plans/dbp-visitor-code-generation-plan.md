# Code Generation Plan — dbp-visitor Plugin

## Unit Context
- **Unit**: dbp-visitor (single unit)
- **Location**: `plugins/dbp-visitor/`
- **Type**: New WordPress plugin (greenfield within brownfield workspace)
- **Dependencies**: None (standalone plugin)
- **Stories Implemented**: FR-01 through FR-06

---

## Generation Steps

### Step 1: Create Plugin Directory Structure
- [x] Create `plugins/dbp-visitor/` directory
- [x] Create `plugins/dbp-visitor/assets/css/` directory
- [x] Create `plugins/dbp-visitor/assets/js/` directory

### Step 2: Generate Main Plugin File (`dbp-visitor.php`)
- [x] Plugin header block (Name, Description, Version, Author, Text Domain, License)
- [x] ABSPATH security check
- [x] Plugin activation/deactivation hooks
- [x] Admin settings registration (Settings API — enable/disable toggle)
- [x] Admin menu registration (under Settings)
- [x] Admin settings page render function
- [x] Frontend asset enqueue (CSS + JS) — only when enabled and not admin
- [x] Frontend HTML output via `wp_footer` hook — floating bar container with:
  - Close button with `aria-label`, `data-testid`
  - Message container with `data-testid`
  - `role="complementary"` for accessibility
- [x] Server-side referrer detection (`$_SERVER['HTTP_REFERER']`)
- [x] Pass referrer data to JS via `wp_localize_script()` (CSP-safe)
- [x] Nonce verification for admin settings save
- [x] Sanitize/escape all inputs and outputs
- [x] Capability check (`manage_options`) for admin operations

### Step 3: Generate Frontend CSS (`assets/css/dbp-visitor.css`)
- [x] Fixed-position bottom bar styling
- [x] Responsive design (mobile + desktop)
- [x] Close button styling
- [x] Typography and spacing
- [x] Z-index management (above content, below modals)
- [x] Slide-up animation on appear
- [x] Hidden state class (`.dbp-visitor-bar--hidden`)
- [x] Sufficient color contrast (WCAG AA)
- [x] Focus styles for close button (keyboard accessibility)

### Step 4: Generate Frontend JavaScript (`assets/js/dbp-visitor.js`)
- [x] Check sessionStorage for dismiss state — if dismissed, don't show bar
- [x] Check if plugin data available (passed from PHP via `wp_localize_script`)
- [x] Visit count logic:
  - Read visit count from localStorage
  - Increment and save back to localStorage
  - Generate appropriate message (first visit vs returning)
- [x] Referrer message generation:
  - Parse referrer from localized data
  - Map known domains to friendly names (Google, Facebook, Twitter/X, LinkedIn, etc.)
  - Handle direct visits (no referrer)
- [x] Geolocation logic:
  - Check sessionStorage cache first
  - If no cache, fetch from free IP geolocation API (async)
  - Cache result in sessionStorage
  - Handle API failure gracefully (omit location from message)
- [x] Compose and display welcome message combining all three parts
- [x] Close button click handler — hide bar + set sessionStorage dismiss flag
- [x] Escape key handler — same dismiss behavior
- [x] Screen reader announcement (`aria-live` region or equivalent)
- [x] All DOM queries use `data-testid` attributes

### Step 5: Generate Code Documentation
- [x] Create `aidlc-docs/construction/dbp-visitor/code/code-summary.md`
- [x] Document file structure, key functions, data flow
- [x] Document geolocation API choice and fallback strategy
- [x] Document security measures applied

### Step 6: Security Verification
- [x] Verify ABSPATH check present
- [x] Verify nonce usage in admin settings (handled by Settings API `settings_fields()`)
- [x] Verify capability checks for admin operations (`manage_options` in render + `add_options_page`)
- [x] Verify all outputs escaped (`esc_html`, `esc_attr`, `esc_url_raw`)
- [x] Verify all inputs sanitized (`dbp_visitor_sanitize_enabled`)
- [x] Verify no inline styles or scripts (CSP compliance — all external files)
- [x] Verify external geolocation API response treated as untrusted (truncated + `escapeHtml()`)
- [x] Verify no hardcoded credentials or secrets

---

## Security Compliance Checkpoints (per SECURITY rules)

| Rule | Status | Notes |
|---|---|---|
| SECURITY-04 | Must verify | CSP headers — plugin itself is CSP-safe; server config needed for headers |
| SECURITY-05 | Must verify | Admin input validation on enable/disable toggle |
| SECURITY-08 | Must verify | `manage_options` capability check on admin page |
| SECURITY-09 | Must verify | No debug info in output, no default creds |
| SECURITY-13 | Must verify | Geolocation API response treated as untrusted |
| SECURITY-15 | Must verify | Graceful error handling for geolocation failures |

---

## Total Steps: 6
## Estimated Scope: ~200-250 lines PHP, ~80 lines CSS, ~120 lines JS
