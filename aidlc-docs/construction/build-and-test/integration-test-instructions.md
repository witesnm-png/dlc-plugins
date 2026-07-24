# Integration Test Instructions — dbp-visitor Plugin

## Purpose
Test the plugin within a live WordPress environment to verify all components work together:
PHP output, CSS rendering, JS behavior, geolocation API, and dismiss persistence.

## Setup Integration Test Environment

### 1. Start Docker WordPress Environment
```bash
docker compose up -d
```
Wait for WordPress to be ready (health check or manual verification at http://localhost:8080).

### 2. Install WordPress (if fresh)
```bash
docker compose exec wordpress wp core install \
  --url="http://localhost:8080" \
  --title="Test Site" \
  --admin_user="admin" \
  --admin_password="admin" \
  --admin_email="admin@test.com" \
  --skip-email
```

### 3. Activate Plugin
```bash
docker compose exec wordpress wp plugin activate dbp-visitor
```

## Test Scenarios

### Scenario 1: Bar Renders on Frontend
- **Steps**: Visit http://localhost:8080 in browser
- **Expected**: Floating bar appears at bottom with welcome message
- **Verify**:
  - [ ] Bar is visible at bottom of viewport
  - [ ] Bar has dark background (#1e293b)
  - [ ] Message text is readable (light color on dark)
  - [ ] Close (×) button is visible on the right

### Scenario 2: Visit Count Tracking
- **Steps**: 
  1. Open browser DevTools → Application → Local Storage
  2. Check `dbp_visitor_count` key
  3. Refresh page
  4. Check count incremented
- **Expected**: 
  - First visit: Message says "Welcome, first-time visitor!"
  - Second visit: Message says "Welcome back for visit #2!"

### Scenario 3: Referrer Detection
- **Steps**: 
  1. Navigate to frontend from a link on another page (or set Referer header manually)
  2. Check bar message
- **Expected**: 
  - From Google: "You came from Google."
  - Direct visit: No referrer mentioned in message

### Scenario 4: Geolocation Display
- **Steps**: Visit frontend and wait ~1 second for API call
- **Expected**: 
  - Message updates to include "Visiting from [City], [Country]."
  - Check DevTools Network tab for ip-api.com request
  - Check sessionStorage for cached geo data (`dbp_visitor_geo`)

### Scenario 5: Dismiss with X Button
- **Steps**: Click the × button
- **Expected**:
  - [ ] Bar slides down and disappears
  - [ ] `sessionStorage.dbp_visitor_dismissed` is set to "1"
  - [ ] Refreshing page keeps bar hidden

### Scenario 6: Dismiss with Escape Key
- **Steps**: Press Escape key while bar is visible
- **Expected**:
  - [ ] Bar slides down and disappears
  - [ ] Same sessionStorage behavior as X button

### Scenario 7: Session Persistence
- **Steps**: 
  1. Dismiss bar
  2. Refresh page — bar should stay hidden
  3. Close browser completely, reopen
  4. Visit site again
- **Expected**: Bar reappears after browser restart (sessionStorage cleared)

### Scenario 8: Admin Settings Toggle
- **Steps**: 
  1. Go to Settings → DBP Visitor in WP Admin
  2. Uncheck "Enable Welcome Bar"
  3. Save
  4. Visit frontend
- **Expected**: Bar does NOT appear when disabled

### Scenario 9: Admin Area Exclusion
- **Steps**: Navigate through WP Admin pages
- **Expected**: Bar never appears in admin area (no CSS/JS loaded)

### Scenario 10: Accessibility
- **Steps**: Tab through the page with keyboard
- **Expected**:
  - [ ] Close button is focusable with Tab key
  - [ ] Close button has visible focus indicator (blue outline)
  - [ ] Pressing Enter on close button dismisses bar
  - [ ] `aria-label` is present on bar and close button
  - [ ] `aria-live="polite"` on message element

### Scenario 11: CSP Compliance
- **Steps**: Check browser DevTools Console for CSP violations
- **Expected**: 
  - [ ] No "refused to execute inline script" errors
  - [ ] No "refused to apply inline style" errors
  - [ ] Only potential issue: `connect-src` for ip-api.com (expected, documented)

### Scenario 12: Responsive Design
- **Steps**: Resize browser to mobile width (<600px)
- **Expected**:
  - [ ] Bar adapts to smaller screen
  - [ ] Text remains readable
  - [ ] Close button still accessible

## Cleanup
```bash
docker compose down -v
```

## Test Matrix Summary

| # | Scenario | Priority | Status |
|---|---|---|---|
| 1 | Bar renders | Critical | Pending |
| 2 | Visit count | High | Pending |
| 3 | Referrer detection | High | Pending |
| 4 | Geolocation | Medium | Pending |
| 5 | Dismiss X button | Critical | Pending |
| 6 | Dismiss Esc key | Critical | Pending |
| 7 | Session persistence | High | Pending |
| 8 | Admin toggle | High | Pending |
| 9 | Admin exclusion | Medium | Pending |
| 10 | Accessibility | High | Pending |
| 11 | CSP compliance | High | Pending |
| 12 | Responsive | Medium | Pending |
