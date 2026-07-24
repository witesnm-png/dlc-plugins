# Build Instructions — dbp-visitor Plugin

## Prerequisites
- **Build Tool**: None required (standard WordPress plugin, no compilation step)
- **Dependencies**: None (vanilla JS, no npm packages)
- **Validation Tools**: Node.js (for JS syntax check), PHP CLI (for PHP lint — optional)
- **System Requirements**: Any OS with Node.js installed

## Build Steps

### 1. Validate JavaScript Syntax
```bash
node --check plugins/dbp-visitor/assets/js/dbp-visitor.js
```
**Expected**: Exit code 0, no output (success)

### 2. Validate PHP Syntax (requires PHP CLI)
```bash
php -l plugins/dbp-visitor/dbp-visitor.php
```
**Expected**: "No syntax errors detected in plugins/dbp-visitor/dbp-visitor.php"

### 3. Verify Plugin Header
```bash
grep "Plugin Name:" plugins/dbp-visitor/dbp-visitor.php
```
**Expected**: "Plugin Name: DBP Visitor Welcome Bar"

### 4. Verify ABSPATH Security Check
```bash
grep "defined.*ABSPATH" plugins/dbp-visitor/dbp-visitor.php
```
**Expected**: Line containing `if ( ! defined( 'ABSPATH' ) )`

### 5. Verify CSP Compliance (No Inline Code)
```bash
# Should return NO results (no inline styles or scripts)
grep -n "wp_add_inline_style\|wp_add_inline_script\|<style>\|<script>" plugins/dbp-visitor/dbp-visitor.php
```
**Expected**: No matches found

## Build Artifacts
- `plugins/dbp-visitor/dbp-visitor.php` — Main plugin file (ready to deploy)
- `plugins/dbp-visitor/assets/css/dbp-visitor.css` — Frontend styles
- `plugins/dbp-visitor/assets/js/dbp-visitor.js` — Frontend logic

## Troubleshooting

### JS Syntax Error
- **Cause**: Typo or malformed JS in dbp-visitor.js
- **Solution**: Run `node --check` and fix the reported line

### PHP Syntax Error
- **Cause**: Unclosed bracket, missing semicolon, or PHP parse error
- **Solution**: Run `php -l` and fix the reported line
