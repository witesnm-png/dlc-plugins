# Code Summary — dbp-visitor Plugin

## File Structure

```
plugins/dbp-visitor/
├── dbp-visitor.php              # Main plugin file (bootstrap, admin, frontend)
├── assets/
│   ├── css/
│   │   └── dbp-visitor.css      # Floating bar styles (responsive, accessible)
│   └── js/
│       └── dbp-visitor.js       # Frontend logic (tracking, geolocation, dismiss)
```

## Architecture Overview

### Data Flow

```
1. Page Load (PHP)
   └── Server detects HTTP_REFERER
   └── Passes referrer + siteUrl to JS via wp_localize_script()

2. DOM Ready (JS)
   └── Check sessionStorage for dismiss state → exit if dismissed
   └── Read/increment visit count (localStorage)
   └── Parse referrer into friendly name
   └── Compose initial message (visit count + referrer)
   └── Show bar immediately
   └── Async fetch geolocation (ip-api.com)
       └── Cache in sessionStorage
       └── Update message with location

3. Dismiss (JS)
   └── Click X button or press Esc
   └── Hide bar (CSS class toggle)
   └── Set sessionStorage flag
   └── Bar stays hidden until browser session ends
```

### Key Functions (PHP)

| Function | Purpose |
|---|---|
| `dbp_visitor_activate()` | Set default option on activation |
| `dbp_visitor_deactivate()` | Clean up option on deactivation |
| `dbp_visitor_register_settings()` | Register enable/disable toggle via Settings API |
| `dbp_visitor_sanitize_enabled()` | Sanitize checkbox value to '1' or '0' |
| `dbp_visitor_enqueue_frontend_assets()` | Enqueue CSS/JS on frontend only when enabled |
| `dbp_visitor_render_bar()` | Output bar HTML in wp_footer |

### Key Functions (JS)

| Function | Purpose |
|---|---|
| `getVisitCount()` | Read/increment localStorage counter |
| `parseReferrer()` | Map referrer URL to friendly name |
| `getGeolocation()` | Fetch/cache IP geolocation from API |
| `composeMessage()` | Build welcome string from all data parts |
| `escapeHtml()` | Prevent XSS from external data |
| `dismissBar()` | Hide bar + persist dismiss in sessionStorage |
| `init()` | Main entry point, orchestrates all logic |

## Geolocation API

- **Service**: ip-api.com (free tier, no API key required)
- **Endpoint**: `https://ip-api.com/json/?fields=status,city,country`
- **Rate Limit**: 45 requests/minute (free tier)
- **Fallback**: If API fails or is blocked, message displays without location
- **Caching**: Result cached in sessionStorage (per browser session)
- **CSP Note**: Requires `connect-src` to include `https://ip-api.com` in CSP policy

## Security Measures

- ABSPATH check prevents direct file access
- Admin settings protected by `manage_options` capability
- Nonce verification via `settings_fields()` (WP Settings API handles this)
- All PHP output escaped (`esc_html`, `esc_attr`, `esc_url_raw`)
- Input sanitized (`dbp_visitor_sanitize_enabled`)
- Geolocation API response treated as untrusted (truncated to 100 chars, escaped before display)
- No inline styles or scripts (strict CSP compliance)
- `data-testid` attributes for automation testing

## CSP Requirements

For the plugin to work under strict CSP, the server must allow:
```
Content-Security-Policy: default-src 'self'; connect-src 'self' https://ip-api.com;
```
