<?php
/**
 * Plugin Name: DBP Visitor Welcome Bar
 * Plugin URI:  https://github.com/your-org/dbp-visitor
 * Description: Displays a floating welcome bar showing visitor origin, geolocation, and visit count.
 * Version:     1.0.0
 * Author:      DLC Team
 * Author URI:  https://example.com
 * License:     GPL-2.0-or-later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: dbp-visitor
 * Domain Path: /languages
 *
 * @package DBP_Visitor
 */

// Prevent direct access.
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Plugin constants.
 */
define( 'DBP_VISITOR_VERSION', '1.0.0' );
define( 'DBP_VISITOR_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
define( 'DBP_VISITOR_PLUGIN_URL', plugin_dir_url( __FILE__ ) );

/**
 * Activation hook — set default options.
 *
 * @return void
 */
function dbp_visitor_activate() {
	if ( false === get_option( 'dbp_visitor_enabled' ) ) {
		add_option( 'dbp_visitor_enabled', '1' );
	}
}
register_activation_hook( __FILE__, 'dbp_visitor_activate' );

/**
 * Deactivation hook — clean up options.
 *
 * @return void
 */
function dbp_visitor_deactivate() {
	delete_option( 'dbp_visitor_enabled' );
}
register_deactivation_hook( __FILE__, 'dbp_visitor_deactivate' );

// ─── Admin Settings ───────────────────────────────────────────────────────────

/**
 * Register admin settings.
 *
 * @return void
 */
function dbp_visitor_register_settings() {
	register_setting(
		'dbp_visitor_settings_group',
		'dbp_visitor_enabled',
		array(
			'type'              => 'string',
			'sanitize_callback' => 'dbp_visitor_sanitize_enabled',
			'default'           => '1',
		)
	);

	add_settings_section(
		'dbp_visitor_main_section',
		__( 'Visitor Welcome Bar Settings', 'dbp-visitor' ),
		'__return_null',
		'dbp-visitor-settings'
	);

	add_settings_field(
		'dbp_visitor_enabled_field',
		__( 'Enable Welcome Bar', 'dbp-visitor' ),
		'dbp_visitor_render_enabled_field',
		'dbp-visitor-settings',
		'dbp_visitor_main_section'
	);
}
add_action( 'admin_init', 'dbp_visitor_register_settings' );

/**
 * Sanitize the enabled setting value.
 *
 * @param mixed $value The raw input value.
 * @return string Sanitized value ('1' or '0').
 */
function dbp_visitor_sanitize_enabled( $value ) {
	return ( '1' === $value ) ? '1' : '0';
}

/**
 * Render the enable/disable checkbox field.
 *
 * @return void
 */
function dbp_visitor_render_enabled_field() {
	$enabled = get_option( 'dbp_visitor_enabled', '1' );
	?>
	<label for="dbp-visitor-enabled">
		<input
			type="checkbox"
			id="dbp-visitor-enabled"
			name="dbp_visitor_enabled"
			value="1"
			<?php checked( '1', $enabled ); ?>
			data-testid="dbp-visitor-enabled-checkbox"
		/>
		<?php esc_html_e( 'Show the visitor welcome bar on the frontend', 'dbp-visitor' ); ?>
	</label>
	<?php
}

/**
 * Add settings page under the Settings menu.
 *
 * @return void
 */
function dbp_visitor_add_settings_page() {
	add_options_page(
		__( 'DBP Visitor Settings', 'dbp-visitor' ),
		__( 'DBP Visitor', 'dbp-visitor' ),
		'manage_options',
		'dbp-visitor-settings',
		'dbp_visitor_render_settings_page'
	);
}
add_action( 'admin_menu', 'dbp_visitor_add_settings_page' );

/**
 * Render the admin settings page.
 *
 * @return void
 */
function dbp_visitor_render_settings_page() {
	if ( ! current_user_can( 'manage_options' ) ) {
		return;
	}
	?>
	<div class="wrap">
		<h1><?php esc_html_e( 'DBP Visitor Welcome Bar', 'dbp-visitor' ); ?></h1>
		<form method="post" action="options.php" data-testid="dbp-visitor-settings-form">
			<?php
			settings_fields( 'dbp_visitor_settings_group' );
			do_settings_sections( 'dbp-visitor-settings' );
			submit_button();
			?>
		</form>
	</div>
	<?php
}

// ─── Frontend Output ──────────────────────────────────────────────────────────

/**
 * Enqueue frontend assets when plugin is enabled and not in admin.
 *
 * @return void
 */
function dbp_visitor_enqueue_frontend_assets() {
	// Do not load in admin area.
	if ( is_admin() ) {
		return;
	}

	// Check if plugin is enabled.
	if ( '1' !== get_option( 'dbp_visitor_enabled', '1' ) ) {
		return;
	}

	wp_enqueue_style(
		'dbp-visitor-style',
		DBP_VISITOR_PLUGIN_URL . 'assets/css/dbp-visitor.css',
		array(),
		DBP_VISITOR_VERSION
	);

	wp_enqueue_script(
		'dbp-visitor-script',
		DBP_VISITOR_PLUGIN_URL . 'assets/js/dbp-visitor.js',
		array(),
		DBP_VISITOR_VERSION,
		true
	);

	// Detect referrer server-side and pass to JS (CSP-safe).
	$referrer = '';
	if ( isset( $_SERVER['HTTP_REFERER'] ) ) {
		$referrer = esc_url_raw( wp_unslash( $_SERVER['HTTP_REFERER'] ) );
	}

	wp_localize_script(
		'dbp-visitor-script',
		'dbpVisitorData',
		array(
			'referrer' => $referrer,
			'siteUrl'  => home_url(),
		)
	);
}
add_action( 'wp_enqueue_scripts', 'dbp_visitor_enqueue_frontend_assets' );

/**
 * Render the floating welcome bar HTML in the footer.
 *
 * @return void
 */
function dbp_visitor_render_bar() {
	// Do not render in admin area.
	if ( is_admin() ) {
		return;
	}

	// Check if plugin is enabled.
	if ( '1' !== get_option( 'dbp_visitor_enabled', '1' ) ) {
		return;
	}
	?>
	<div
		id="dbp-visitor-bar"
		class="dbp-visitor-bar dbp-visitor-bar--hidden"
		role="complementary"
		aria-label="<?php esc_attr_e( 'Visitor welcome message', 'dbp-visitor' ); ?>"
		data-testid="dbp-visitor-bar"
	>
		<span
			class="dbp-visitor-bar__message"
			data-testid="dbp-visitor-bar-message"
			aria-live="polite"
		></span>
		<button
			type="button"
			class="dbp-visitor-bar__close"
			aria-label="<?php esc_attr_e( 'Close welcome bar', 'dbp-visitor' ); ?>"
			data-testid="dbp-visitor-bar-close"
		>
			<span aria-hidden="true">&times;</span>
		</button>
	</div>
	<?php
}
add_action( 'wp_footer', 'dbp_visitor_render_bar' );
