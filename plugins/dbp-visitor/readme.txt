=== DBP Visitor Welcome Bar ===
Contributors: dlcteam
Tags: welcome bar, visitor tracking, geolocation, floating bar
Requires at least: 6.0
Tested up to: 6.7
Stable tag: 1.0.0
Requires PHP: 7.4
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Displays a floating welcome bar at the bottom of the page showing visitor origin, geolocation, and visit count.

== Description ==

DBP Visitor Welcome Bar adds a non-intrusive floating bar at the bottom of your website that greets visitors with personalized information:

* **Where they came from** — detects the referring site (Google, Facebook, etc.) or shows a direct visit message
* **Their location** — uses IP-based geolocation to display the visitor's city and country
* **Visit count** — tracks how many times the visitor has been to your site

The bar can be dismissed with the × button or by pressing Escape. Once dismissed, it stays hidden for the browser session.

= Features =

* Floating bottom bar on all frontend pages
* HTTP Referer detection with friendly names for known sites
* IP geolocation via free API (ip-api.com)
* Visit count tracking (localStorage)
* Session-based dismiss (X button or Escape key)
* Strict CSP compliant (no inline styles or scripts)
* Accessible (WCAG 2.1 AA, keyboard navigation, screen reader support)
* Minimal admin settings (enable/disable toggle)
* Responsive design

== Installation ==

1. Upload the `dbp-visitor` folder to `/wp-content/plugins/`
2. Activate the plugin through the 'Plugins' menu in WordPress
3. (Optional) Go to Settings → DBP Visitor to enable/disable the bar

== Frequently Asked Questions ==

= How do I disable the welcome bar? =

Go to Settings → DBP Visitor in your WordPress admin and uncheck "Enable Welcome Bar".

= Does this plugin use cookies? =

No. It uses localStorage (visit count) and sessionStorage (dismiss state, geolocation cache). No cookies are set.

= What geolocation service is used? =

The plugin uses ip-api.com (free tier, no API key required). The request is made client-side and cached for the session.

= Is this plugin GDPR compliant? =

The plugin stores data only in the visitor's browser (localStorage/sessionStorage). No personal data is sent to your server or stored in your database. The geolocation API call is made directly from the visitor's browser to ip-api.com.

== Changelog ==

= 1.0.0 =
* Initial release
* Floating welcome bar with referrer detection
* IP geolocation display
* Visit count tracking
* Dismiss via X button or Escape key
* Admin enable/disable toggle
* Strict CSP compliance
