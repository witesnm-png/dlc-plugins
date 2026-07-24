(function () {
	"use strict";

	var STORAGE_KEY = "dlc_hello_bar_dismissed";
	var DISMISS_DAYS = 7;

	function isDismissed() {
		try {
			var timestamp = localStorage.getItem( STORAGE_KEY );
			if ( ! timestamp ) {
				return false;
			}
			var dismissedAt = parseInt( timestamp, 10 );
			var now = Date.now();
			var diffDays = ( now - dismissedAt ) / ( 1000 * 60 * 60 * 24 );
			return diffDays < DISMISS_DAYS;
		} catch ( e ) {
			return false;
		}
	}

	function dismiss() {
		var bar = document.getElementById( "dlc-hello-bar" );
		if ( bar ) {
			bar.classList.add( "dlc-hello-bar--hidden" );
			try {
				localStorage.setItem( STORAGE_KEY, Date.now().toString() );
			} catch ( e ) {
				// localStorage unavailable, bar hidden for session only.
			}
		}
	}

	function init() {
		var bar = document.getElementById( "dlc-hello-bar" );
		if ( ! bar ) {
			return;
		}

		if ( isDismissed() ) {
			bar.style.display = "none";
			return;
		}

		var btn = bar.querySelector( ".dlc-hello-bar__dismiss" );
		if ( btn ) {
			btn.addEventListener( "click", dismiss );
		}
	}

	if ( document.readyState === "loading" ) {
		document.addEventListener( "DOMContentLoaded", init );
	} else {
		init();
	}
})();
