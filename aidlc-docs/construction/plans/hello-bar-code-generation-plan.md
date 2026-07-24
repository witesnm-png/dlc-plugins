# Code Generation Plan — Hello Bar Plugin

## Unit Context
- **Unit Name**: hello-bar
- **Location**: `plugins/dlc-sample/dlc-sample.php`
- **Type**: Single-file WordPress plugin (brownfield — file already exists with initial implementation)
- **Dependencies**: None (self-contained WordPress plugin)
- **Workspace Root**: `E:\wordpress-playg\aidlc\wp-content\`

## Requirements Covered
- FR-01: Hello bar with message + CTA link + dismiss button
- FR-02: Fixed position at top of viewport
- FR-03: Displays on all pages site-wide
- FR-04: Dismiss persisted via localStorage (7 days)
- FR-05: Minimal admin settings (message + enable/disable)
- FR-06: CTA link defined in plugin code
- NFR-01: WordPress coding standards (WPCS)
- NFR-02: Performance (no external requests, inline assets)
- NFR-03: Accessibility (ARIA roles, keyboard support)
- NFR-05: Security (sanitization, escaping, nonces, capability checks)

## Approach
- **Modify** existing `dlc-sample.php` (it already has a working implementation from initial coding)
- Rewrite to fully comply with:
  - WPCS formatting (tabs, Yoda conditions, spacing)
  - Requirements (all pages, localStorage persistence, minimal admin settings)
  - Security baseline (proper sanitization, escaping, capability checks)
  - Accessibility (ARIA, keyboard navigation)

---

## Generation Steps

### Step 1: Plugin Header & Bootstrap
- [x] Rewrite plugin file header with proper metadata
- [x] Add `ABSPATH` check
- [x] Define plugin constants (`DLC_HELLO_BAR_VERSION`)
- [x] Add plugin activation/deactivation hooks for option defaults and cleanup

### Step 2: Admin Settings Registration
- [x] Register settings using WordPress Settings API
- [x] Register only: `dlc_hello_bar_message` (text) and `dlc_hello_bar_enabled` (boolean)
- [x] Add proper sanitize callbacks (`sanitize_text_field`, `rest_sanitize_boolean`)
- [x] Add settings page under Settings menu via `add_options_page()`
- [x] Implement capability check (`manage_options`) in settings page renderer

### Step 3: Admin Settings Page Render
- [x] Create settings page HTML with proper escaping
- [x] Use `settings_fields()` for nonce handling (Settings API handles this)
- [x] Add message text input field
- [x] Add enable/disable checkbox
- [x] Follow WPCS formatting throughout
- [x] Use `esc_html__()` for all labels, `esc_attr()` for values

### Step 4: Frontend Hello Bar Output
- [x] Hook into `wp_body_open` to render the hello bar
- [x] Remove the homepage-only restriction (show on all pages per FR-03)
- [x] Check `dlc_hello_bar_enabled` option before rendering
- [x] Output bar HTML with:
  - Fixed position styling (top of viewport)
  - Message from options (escaped with `wp_kses_post()`)
  - CTA link (hardcoded URL/text in plugin, escaped with `esc_url()` and `esc_html()`)
  - Dismiss button with aria-label
  - `role="banner"` and `aria-label` for accessibility
  - `data-testid` attributes for automation

### Step 5: Frontend JavaScript (Dismiss Logic)
- [x] Enqueue inline JavaScript via `wp_add_inline_script()` or output in footer
- [x] On dismiss click: hide bar + store timestamp in localStorage
- [x] On page load: check localStorage, hide bar if dismissed within 7 days
- [x] Graceful degradation: if JS disabled, bar always shows (no dismiss button hidden by default)

### Step 6: Frontend CSS (Inline Styles)
- [x] Use `wp_add_inline_style()` or output in `<style>` block via `wp_head`
- [x] Fixed positioning at top with high z-index
- [x] Responsive design (mobile-friendly)
- [x] Default colors: blue background (#0073aa), white text
- [x] Smooth dismiss animation (optional)

### Step 7: Security Compliance Verification
- [x] Verify all output is escaped (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`)
- [x] Verify admin page has capability check
- [x] Verify Settings API handles nonces (no manual nonce needed with `register_setting`)
- [x] Verify no direct `$_GET`/`$_POST` access without sanitization
- [x] Verify no `eval()`, `extract()`, or unsafe functions

### Step 8: Code Documentation Summary
- [x] Create `aidlc-docs/construction/hello-bar/code/code-summary.md` documenting:
  - File structure
  - Functions and their purposes
  - Hooks used
  - Options registered
  - Security measures applied

---

## Total Steps: 8
## Estimated Scope: Single PHP file (~150-200 lines) + documentation
