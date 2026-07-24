---
inclusion: auto
---

# WordPress Development Standards

This steering file establishes coding and security standards for all WordPress plugin development in this workspace.

## WordPress Coding Standards (WPCS)

### PHP Formatting
- Use tabs for indentation (not spaces)
- Opening braces on the same line for functions, classes, and control structures
- Space after control structure keywords: `if ( $condition )` not `if($condition)`
- Space inside parentheses: `function_name( $arg )` not `function_name($arg)`
- Yoda conditions: `if ( true === $value )` not `if ( $value === true )`
- Single quotes for strings unless interpolation needed
- Trailing commas in multi-line arrays

### Naming Conventions
- Functions: lowercase with underscores, prefixed: `dlc_hello_bar_function_name()`
- Classes: capitalized words, prefixed: `DLC_Hello_Bar_Class_Name`
- Constants: uppercase with underscores: `DLC_HELLO_BAR_VERSION`
- Hooks: lowercase with underscores, prefixed: `dlc_hello_bar_hook_name`
- Options: lowercase with underscores, prefixed: `dlc_hello_bar_option_name`
- File naming: lowercase with hyphens: `class-hello-bar-admin.php`

### Plugin Structure
- Always check `defined( 'ABSPATH' )` at the top of every PHP file
- Use proper plugin headers (Plugin Name, Description, Version, Author, License, Text Domain)
- Prefix all global functions, classes, constants, and hooks with `dlc_` to avoid conflicts
- Use text domain `dlc-sample` for all translatable strings

## WordPress Security Standards

### Input Sanitization (on save/receive)
- `sanitize_text_field()` — plain text inputs
- `sanitize_textarea_field()` — multiline text
- `sanitize_hex_color()` — color values
- `sanitize_email()` — email addresses
- `absint()` — positive integers
- `esc_url_raw()` — URLs being saved to database
- `wp_kses_post()` — rich HTML content (allows safe HTML subset)

### Output Escaping (on render)
- `esc_html()` — text content in HTML
- `esc_attr()` — attribute values
- `esc_url()` — URLs in href/src attributes
- `esc_js()` — inline JavaScript strings
- `wp_kses_post()` — trusted HTML from database
- Never output raw `$_GET`, `$_POST`, `$_REQUEST` values

### Form Security
- Always use `wp_nonce_field()` in forms
- Always verify with `wp_verify_nonce()` or `check_admin_referer()` on submission
- Always check `current_user_can( 'manage_options' )` before processing admin actions
- Use `settings_fields()` and `register_setting()` for Settings API forms (handles nonces automatically)

### Database Security
- Use WordPress Options API (`get_option`, `update_option`) instead of direct DB queries when possible
- When direct queries are needed, always use `$wpdb->prepare()` with placeholders
- Never concatenate user input into SQL queries

### General Security
- No direct file access: check `ABSPATH` at top of every file
- Avoid `eval()`, `extract()`, `$GLOBALS` manipulation
- Validate and sanitize ALL input regardless of source
- Escape ALL output regardless of trust level
- Use `wp_enqueue_script()` / `wp_enqueue_style()` for assets (never echo script tags)

## WordPress Plugin Best Practices

### Hooks & Filters
- Use `add_action()` and `add_filter()` — never modify core files
- Register hooks at appropriate priority (default 10)
- Always unhook in deactivation if registering persistent hooks
- Use `wp_body_open` for front-end content injection at body start

### Settings API
- Register settings with `register_setting()` providing sanitize callbacks
- Use `add_options_page()` for plugins that only have settings
- Group related settings under one option group

### Enqueuing Assets
- Use `wp_enqueue_script()` and `wp_enqueue_style()` with proper dependencies
- Use `wp_add_inline_style()` or `wp_add_inline_script()` for dynamic/small assets
- Version assets for cache-busting: use plugin version constant
- Load admin assets only on plugin pages using `admin_enqueue_scripts` with page hook check
- Load frontend assets conditionally when needed

### Internationalization
- Wrap all user-facing strings in `__()` or `_e()`
- Use `esc_html__()` / `esc_html_e()` / `esc_attr__()` / `esc_attr_e()` for escaped translations
- Always specify text domain: `__( 'text', 'dlc-sample' )`

## Environment Strategy

### Local/Test Environment
- **WordPress Playground**: https://playground.wordpress.net/ (site slug: generous-busy-city)
- Synced locally at: `E:\wordpress-playg\aidlc\wp-content\`
- Used for development and testing

### Production Environment
- To be provisioned (details determined in Operations phase)
- Plugin must work on any standard WordPress 6.x+ installation
