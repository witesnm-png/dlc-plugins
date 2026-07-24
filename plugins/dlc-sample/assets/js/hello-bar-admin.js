(function () {
	"use strict";

	function updatePreview() {
		var preview = document.getElementById( "dlc-hello-bar-preview" );
		if ( ! preview ) {
			return;
		}

		var messageInput = document.getElementById( "dlc_hello_bar_message" );
		var ctaTextInput = document.getElementById( "dlc_hello_bar_cta_text" );
		var ctaUrlInput = document.getElementById( "dlc_hello_bar_cta_url" );
		var themeSelect = document.getElementById( "dlc_hello_bar_theme" );

		// Update message.
		var messageEl = preview.querySelector( ".dlc-hello-bar-preview__message" );
		if ( messageEl && messageInput ) {
			messageEl.textContent = messageInput.value || "Your message here...";
		}

		// Update CTA link.
		var ctaEl = preview.querySelector( ".dlc-hello-bar-preview__cta" );
		if ( ctaEl && ctaTextInput ) {
			if ( ctaTextInput.value && ctaUrlInput && ctaUrlInput.value ) {
				ctaEl.textContent = ctaTextInput.value;
				ctaEl.href = ctaUrlInput.value;
				ctaEl.style.display = "";
			} else {
				ctaEl.style.display = "none";
			}
		}

		// Update theme.
		if ( themeSelect ) {
			preview.setAttribute( "data-theme", themeSelect.value );
		}
	}

	function init() {
		var fields = [
			"dlc_hello_bar_message",
			"dlc_hello_bar_cta_text",
			"dlc_hello_bar_cta_url",
			"dlc_hello_bar_theme"
		];

		fields.forEach( function ( id ) {
			var el = document.getElementById( id );
			if ( el ) {
				el.addEventListener( "input", updatePreview );
				el.addEventListener( "change", updatePreview );
			}
		} );

		// Initial render.
		updatePreview();
	}

	if ( document.readyState === "loading" ) {
		document.addEventListener( "DOMContentLoaded", init );
	} else {
		init();
	}
})();
