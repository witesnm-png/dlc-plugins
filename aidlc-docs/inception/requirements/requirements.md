# Requirements Document — dbp-visitor Plugin

## Intent Analysis

| Attribute | Value |
|---|---|
| **User Request** | Create a new WordPress plugin named `dbp-visitor` that adds a floating bar at the bottom of the page showing a welcome message indicating where the visitor came from and how they've been, with close (X) button and Esc key support |
| **Request Type** | New Feature (new plugin) |
| **Scope Estimate** | Single Component (new plugin in `plugins/dbp-visitor/`) |
| **Complexity Estimate** | Simple — clear implementation path, standard WordPress plugin patterns |

---

## Functional Requirements

### FR-01: Floating Welcome Bar
- Display a fixed-position bar at the bottom of the viewport on all frontend pages (excluding admin area)
- Bar must float above page content and remain visible during scroll
- Bar must not obstruct primary page content (appropriate z-index management)

### FR-02: Visitor Origin Detection (HTTP Referer)
- Read the HTTP Referer header to determine which site/page the visitor came from
- Display a human-readable referrer source (e.g., "You came from Google", "You came from Facebook", "You came from example.com")
- Handle common referrers with friendly names (Google, Facebook, Twitter/X, LinkedIn, etc.)
- For unknown referrers, display the domain name
- For direct visits (no referrer), display "Welcome, direct visitor!" or similar

### FR-03: Visitor Geolocation
- Determine the visitor's geographic location via IP-based geolocation
- Use a free/lightweight geolocation API or WordPress-compatible service
- Display location in the welcome message (e.g., "visiting from New York, US")
- Handle gracefully when geolocation is unavailable or blocked (fallback to generic greeting)

### FR-04: Visit Count Tracking
- Track the number of times a visitor has visited the site using localStorage
- Display visit count in the welcome message (e.g., "Welcome back for your 5th visit!")
- For first-time visitors, display appropriate first-visit greeting
- Increment count on each new page load (or session start)

### FR-05: Dismiss Functionality
- Provide a visible close button (X) in the bar
- Support Esc key to dismiss the bar
- Once dismissed, bar remains hidden for the entire browser session (sessionStorage)
- Bar reappears on next browser session (after browser close/reopen)

### FR-06: Admin Settings (Minimal)
- Provide an enable/disable toggle in WordPress admin (Settings menu)
- When disabled, the bar does not render on any page
- Default state: enabled

---

## Non-Functional Requirements

### NFR-01: CSP Compliance (Strict)
- No inline styles (`style=""` attributes or `<style>` blocks)
- No inline scripts (`onclick=""` attributes or `<script>` blocks)
- All CSS in external `.css` files enqueued via `wp_enqueue_style()`
- All JS in external `.js` files enqueued via `wp_enqueue_script()`
- Plugin must function under `Content-Security-Policy: default-src 'self'`
- **Exception**: Geolocation API call requires `connect-src` directive for the external API domain

### NFR-02: WordPress Coding Standards
- Follow WordPress PHP Coding Standards (WPCS)
- Use WordPress APIs (Settings API, Options API, wp_enqueue_*)
- Proper text domain for internationalization (`dbp-visitor`)
- Use `wp_localize_script()` or `wp_add_inline_script()` with `data` type for passing server-side data to JS (CSP-safe approach via `<script id="...">` JSON data blocks)

### NFR-03: Security
- ABSPATH check at top of all PHP files
- Nonce verification for admin settings save
- Sanitize all inputs, escape all outputs
- No direct database queries (use Options API)
- Capability checks for admin operations (`manage_options`)

### NFR-04: Performance
- Lightweight — minimal impact on page load
- Geolocation request should be async (non-blocking)
- Cache geolocation result in sessionStorage to avoid repeated API calls
- Enqueue assets only on frontend (not admin pages)

### NFR-05: Accessibility
- Close button has `aria-label="Close welcome bar"`
- Bar has `role="complementary"` or appropriate landmark role
- Keyboard accessible (Esc key, Tab to close button)
- Sufficient color contrast (WCAG 2.1 AA minimum)
- Screen reader announcement when bar appears

### NFR-06: Browser Compatibility
- Support modern browsers (Chrome, Firefox, Safari, Edge — last 2 versions)
- Graceful degradation if localStorage/sessionStorage unavailable

---

## Technical Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Geolocation method | Free IP geolocation API (e.g., ip-api.com or similar) | No server-side dependencies, lightweight |
| Visit tracking storage | localStorage (count) + sessionStorage (dismiss state) | Client-side, no database overhead |
| Referrer detection | PHP `$_SERVER['HTTP_REFERER']` passed to JS via wp_localize_script | Server-side detection, CSP-safe data passing |
| Admin settings | WordPress Settings API with single option | Minimal complexity per user preference |

---

## File Structure

```
plugins/dbp-visitor/
├── dbp-visitor.php          # Main plugin file (bootstrap, admin settings, frontend output)
├── assets/
│   ├── css/
│   │   └── dbp-visitor.css  # Frontend floating bar styles
│   └── js/
│       └── dbp-visitor.js   # Frontend logic (geolocation, visit count, dismiss)
└── readme.txt               # WordPress plugin readme (optional)
```

---

## Security Compliance Notes

- **SECURITY-01**: N/A — no data persistence stores (uses client-side localStorage only)
- **SECURITY-02**: N/A — no network intermediaries defined by plugin
- **SECURITY-03**: N/A — WordPress core handles logging; plugin is frontend-only
- **SECURITY-04**: Applicable — CSP compliance required (strict, NFR-01)
- **SECURITY-05**: Applicable — admin settings input validation required
- **SECURITY-06**: N/A — no IAM policies (WordPress capability system used)
- **SECURITY-07**: N/A — no network configuration
- **SECURITY-08**: Applicable — admin settings require `manage_options` capability check
- **SECURITY-09**: Applicable — no default credentials, no debug info in production output
- **SECURITY-10**: Applicable — dependency pinning (minimal dependencies)
- **SECURITY-11**: Applicable — rate limiting N/A for client-side plugin; misuse considered (bar cannot be used for XSS)
- **SECURITY-12**: N/A — no authentication system in plugin
- **SECURITY-13**: Applicable — no unsafe deserialization; external API data treated as untrusted
- **SECURITY-14**: N/A — WordPress core handles monitoring/alerting
- **SECURITY-15**: Applicable — graceful error handling for geolocation API failures
