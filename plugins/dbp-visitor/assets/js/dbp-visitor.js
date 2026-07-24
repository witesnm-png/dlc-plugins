/**
 * DBP Visitor Welcome Bar — Frontend Logic
 *
 * Handles visit count tracking, referrer parsing, geolocation,
 * message composition, and dismiss behavior.
 *
 * @package DBP_Visitor
 */

(function () {
	'use strict';

	var STORAGE_KEY_DISMISS = 'dbp_visitor_dismissed';
	var STORAGE_KEY_COUNT = 'dbp_visitor_count';
	var STORAGE_KEY_GEO = 'dbp_visitor_geo';
	var GEO_API_URL = 'https://ip-api.com/json/?fields=status,city,country';

	/**
	 * Known referrer domain to friendly name mapping.
	 */
	var KNOWN_REFERRERS = {
		'google.com': 'Google',
		'google.co.uk': 'Google',
		'google.ca': 'Google',
		'google.com.au': 'Google',
		'bing.com': 'Bing',
		'yahoo.com': 'Yahoo',
		'duckduckgo.com': 'DuckDuckGo',
		'facebook.com': 'Facebook',
		'instagram.com': 'Instagram',
		'twitter.com': 'Twitter',
		'x.com': 'X',
		'linkedin.com': 'LinkedIn',
		'reddit.com': 'Reddit',
		'youtube.com': 'YouTube',
		'pinterest.com': 'Pinterest',
		'tiktok.com': 'TikTok',
		't.co': 'Twitter'
	};

	/**
	 * Get the visit count, increment, and store.
	 *
	 * @return {number} The current visit count (after increment).
	 */
	function getVisitCount() {
		var count = 1;
		try {
			var stored = localStorage.getItem(STORAGE_KEY_COUNT);
			if (stored) {
				count = parseInt(stored, 10) + 1;
			}
			localStorage.setItem(STORAGE_KEY_COUNT, String(count));
		} catch (e) {
			// localStorage unavailable — default to 1.
		}
		return count;
	}

	/**
	 * Parse referrer and return a friendly name.
	 *
	 * @param {string} referrer The raw referrer URL.
	 * @param {string} siteUrl  The current site URL.
	 * @return {string} Friendly referrer description or empty string for internal/direct.
	 */
	function parseReferrer(referrer, siteUrl) {
		if (!referrer) {
			return '';
		}

		// Skip internal referrers.
		try {
			var refHost = new URL(referrer).hostname.toLowerCase();
			var siteHost = new URL(siteUrl).hostname.toLowerCase();
			if (refHost === siteHost) {
				return '';
			}

			// Check known referrers (match with and without www).
			var cleanHost = refHost.replace(/^www\./, '');
			if (KNOWN_REFERRERS[cleanHost]) {
				return KNOWN_REFERRERS[cleanHost];
			}

			// Return the domain for unknown referrers.
			return cleanHost;
		} catch (e) {
			return '';
		}
	}

	/**
	 * Fetch geolocation from API or sessionStorage cache.
	 *
	 * @param {function} callback Called with {city, country} or null.
	 */
	function getGeolocation(callback) {
		// Check cache first.
		try {
			var cached = sessionStorage.getItem(STORAGE_KEY_GEO);
			if (cached) {
				callback(JSON.parse(cached));
				return;
			}
		} catch (e) {
			// sessionStorage unavailable — proceed with API call.
		}

		// Fetch from API.
		fetch(GEO_API_URL)
			.then(function (response) {
				if (!response.ok) {
					throw new Error('Geolocation API error');
				}
				return response.json();
			})
			.then(function (data) {
				if (data && data.status === 'success' && data.city && data.country) {
					var geo = {
						city: String(data.city).substring(0, 100),
						country: String(data.country).substring(0, 100)
					};
					// Cache in sessionStorage.
					try {
						sessionStorage.setItem(STORAGE_KEY_GEO, JSON.stringify(geo));
					} catch (e) {
						// Storage unavailable — continue without cache.
					}
					callback(geo);
				} else {
					callback(null);
				}
			})
			.catch(function () {
				callback(null);
			});
	}

	/**
	 * Compose the welcome message from all parts.
	 *
	 * @param {number}      visitCount  The visit count.
	 * @param {string}      referrer    Friendly referrer name (or empty).
	 * @param {object|null} geo         Geolocation object {city, country} or null.
	 * @return {string} The composed welcome message.
	 */
	function composeMessage(visitCount, referrer, geo) {
		var parts = [];

		// Visit greeting.
		if (visitCount <= 1) {
			parts.push('Welcome, first-time visitor!');
		} else {
			parts.push('Welcome back for visit #' + visitCount + '!');
		}

		// Referrer.
		if (referrer) {
			parts.push('You came from ' + escapeHtml(referrer) + '.');
		}

		// Geolocation.
		if (geo && geo.city && geo.country) {
			parts.push('Visiting from ' + escapeHtml(geo.city) + ', ' + escapeHtml(geo.country) + '.');
		}

		return parts.join(' ');
	}

	/**
	 * Escape HTML entities to prevent XSS from API/referrer data.
	 *
	 * @param {string} str The raw string.
	 * @return {string} The escaped string.
	 */
	function escapeHtml(str) {
		var div = document.createElement('div');
		div.appendChild(document.createTextNode(str));
		return div.innerHTML;
	}

	/**
	 * Dismiss the bar and persist dismiss state for the session.
	 *
	 * @param {HTMLElement} bar The bar element.
	 */
	function dismissBar(bar) {
		bar.classList.add('dbp-visitor-bar--hidden');
		try {
			sessionStorage.setItem(STORAGE_KEY_DISMISS, '1');
		} catch (e) {
			// sessionStorage unavailable — bar hidden for current view only.
		}
	}

	/**
	 * Show the bar with a slide-up animation.
	 *
	 * @param {HTMLElement} bar The bar element.
	 */
	function showBar(bar) {
		bar.classList.remove('dbp-visitor-bar--hidden');
	}

	/**
	 * Initialize the visitor welcome bar.
	 */
	function init() {
		// Check if already dismissed this session.
		try {
			if (sessionStorage.getItem(STORAGE_KEY_DISMISS) === '1') {
				return;
			}
		} catch (e) {
			// sessionStorage unavailable — proceed (show bar).
		}

		// Ensure localized data is available.
		if (typeof dbpVisitorData === 'undefined') {
			return;
		}

		var bar = document.querySelector('[data-testid="dbp-visitor-bar"]');
		var closeBtn = document.querySelector('[data-testid="dbp-visitor-bar-close"]');
		var messageEl = document.querySelector('[data-testid="dbp-visitor-bar-message"]');

		if (!bar || !closeBtn || !messageEl) {
			return;
		}

		var visitCount = getVisitCount();
		var referrer = parseReferrer(dbpVisitorData.referrer, dbpVisitorData.siteUrl);

		// Start with a message without geo, then update when geo arrives.
		var initialMessage = composeMessage(visitCount, referrer, null);
		messageEl.textContent = initialMessage;
		showBar(bar);

		// Fetch geolocation async and update message.
		getGeolocation(function (geo) {
			if (geo) {
				var fullMessage = composeMessage(visitCount, referrer, geo);
				messageEl.textContent = fullMessage;
			}
		});

		// Close button handler.
		closeBtn.addEventListener('click', function () {
			dismissBar(bar);
		});

		// Escape key handler.
		document.addEventListener('keydown', function (event) {
			if (event.key === 'Escape' && !bar.classList.contains('dbp-visitor-bar--hidden')) {
				dismissBar(bar);
			}
		});
	}

	// Initialize when DOM is ready.
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', init);
	} else {
		init();
	}
})();
