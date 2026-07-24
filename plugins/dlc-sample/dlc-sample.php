<?php
/**
 * Plugin Name: DLC Sample - Hello Bar
 * Description: Displays a dismissible hello bar with a call-to-action on all pages.
 * Version: 1.1.0
 * Author: DLC
 * License: GPL-2.0-or-later
 * Text Domain: dlc-sample
 * Requires at least: 6.0
 * Requires PHP: 8.0
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( 'DLC_HELLO_BAR_VERSION', '1.1.0' );

/**
 * Set default options on plugin activation.
 */
function dlc_hello_bar_activate() {
	if ( false === get_option( 'dlc_hello_bar_message' ) ) {
		add_option( 'dlc_hello_bar_message', __( 'Welcome! Check out our latest updates.', 'dlc-sample' ) );
	}
	if ( false === get_option( 'dlc_hello_bar_enabled' ) ) {
		add_option( 'dlc_hello_bar_enabled', '1' );
	}
	if ( false === get_option( 'dlc_hello_bar_cta_text' ) ) {
		add_option( 'dlc_hello_bar_cta_text', __( 'Learn More', 'dlc-sample' ) );
	}
	if ( false === get_option( 'dlc_hello_bar_cta_url' ) ) {
		add_option( 'dlc_hello_bar_cta_url', '' );
	}
	if ( false === get_option( 'dlc_hello_bar_theme' ) ) {
		add_option( 'dlc_hello_bar_theme', 'blue' );
	}
}
register_activation_hook( __FILE__, 'dlc_hello_bar_activate' );

/**
 * Clean up options on plugin deactivation.
 */
function dlc_hello_bar_deactivate() {
	delete_option( 'dlc_hello_bar_message' );
	delete_option( 'dlc_hello_bar_enabled' );
	delete_option( 'dlc_hello_bar_cta_text' );
	delete_option( 'dlc_hello_bar_cta_url' );
	delete_option( 'dlc_hello_bar_theme' );
}
register_deactivation_hook( __FILE__, 'dlc_hello_bar_deactivate' );

/**
 * Register plugin settings.
 */
function dlc_hello_bar_register_settings() {
	register_setting(
		'dlc_hello_bar_options',
		'dlc_hello_bar_message',
		array(
			'type'              => 'string',
			'sanitize_callback' => 'sanitize_text_field',
			'default'           => __( 'Welcome! Check out our latest updates.', 'dlc-sample' ),
		)
	);

	register_setting(
		'dlc_hello_bar_options',
		'dlc_hello_bar_enabled',
		array(
			'type'              => 'string',
			'sanitize_callback' => 'dlc_hello_bar_sanitize_checkbox',
			'default'           => '1',
		)
	);

	register_setting(
		'dlc_hello_bar_options',
		'dlc_hello_bar_cta_text',
		array(
			'type'              => 'string',
			'sanitize_callback' => 'sanitize_text_field',
			'default'           => __( 'Learn More', 'dlc-sample' ),
		)
	);

	register_setting(
		'dlc_hello_bar_options',
		'dlc_hello_bar_cta_url',
		array(
			'type'              => 'string',
			'sanitize_callback' => 'esc_url_raw',
			'default'           => '',
		)
	);

	register_setting(
		'dlc_hello_bar_options',
		'dlc_hello_bar_theme',
		array(
			'type'              => 'string',
			'sanitize_callback' => 'dlc_hello_bar_sanitize_theme',
			'default'           => 'blue',
		)
	);
}
add_action( 'admin_init', 'dlc_hello_bar_register_settings' );

/**
 * Sanitize checkbox value.
 *
 * @param mixed $value The checkbox value.
 * @return string '1' if checked, '0' if not.
 */
function dlc_hello_bar_sanitize_checkbox( $value ) {
	return ( '1' === $value || 1 === $value || true === $value ) ? '1' : '0';
}

/**
 * Sanitize theme selection.
 *
 * @param mixed $value The theme value.
 * @return string A valid theme slug.
 */
function dlc_hello_bar_sanitize_theme( $value ) {
	$valid_themes = array( 'blue', 'dark', 'green', 'red', 'purple', 'orange' );
	return in_array( $value, $valid_themes, true ) ? $value : 'blue';
}

/**
 * Add admin menu page under Settings.
 */
function dlc_hello_bar_admin_menu() {
	add_options_page(
		esc_html__( 'Hello Bar Settings', 'dlc-sample' ),
		esc_html__( 'Hello Bar', 'dlc-sample' ),
		'manage_options',
		'dlc-hello-bar',
		'dlc_hello_bar_settings_page'
	);
}
add_action( 'admin_menu', 'dlc_hello_bar_admin_menu' );

/**
 * Enqueue admin assets on the plugin settings page only.
 *
 * @param string $hook_suffix The current admin page hook suffix.
 */
function dlc_hello_bar_admin_enqueue( $hook_suffix ) {
	if ( 'settings_page_dlc-hello-bar' !== $hook_suffix ) {
		return;
	}

	wp_enqueue_style(
		'dlc-hello-bar-admin',
		plugin_dir_url( __FILE__ ) . 'assets/css/hello-bar-admin.css',
		array(),
		DLC_HELLO_BAR_VERSION
	);

	wp_enqueue_script(
		'dlc-hello-bar-admin',
		plugin_dir_url( __FILE__ ) . 'assets/js/hello-bar-admin.js',
		array(),
		DLC_HELLO_BAR_VERSION,
		true
	);
}
add_action( 'admin_enqueue_scripts', 'dlc_hello_bar_admin_enqueue' );

/**
 * Render the admin settings page.
 */
function dlc_hello_bar_settings_page() {
	if ( ! current_user_can( 'manage_options' ) ) {
		return;
	}

	$message  = get_option( 'dlc_hello_bar_message', __( 'Welcome! Check out our latest updates.', 'dlc-sample' ) );
	$enabled  = get_option( 'dlc_hello_bar_enabled', '1' );
	$cta_text = get_option( 'dlc_hello_bar_cta_text', __( 'Learn More', 'dlc-sample' ) );
	$cta_url  = get_option( 'dlc_hello_bar_cta_url', '' );
	$theme    = get_option( 'dlc_hello_bar_theme', 'blue' );
	?>
	<div class="wrap">
		<h1><?php echo esc_html__( 'Hello Bar Settings', 'dlc-sample' ); ?></h1>
		<form method="post" action="options.php">
			<?php settings_fields( 'dlc_hello_bar_options' ); ?>
			<table class="form-table" role="presentation">
				<tr>
					<th scope="row">
						<label for="dlc_hello_bar_enabled"><?php echo esc_html__( 'Enable Hello Bar', 'dlc-sample' ); ?></label>
					</th>
					<td>
						<input
							type="checkbox"
							id="dlc_hello_bar_enabled"
							name="dlc_hello_bar_enabled"
							value="1"
							<?php checked( '1', $enabled ); ?>
						/>
						<p class="description"><?php echo esc_html__( 'Show the hello bar on all pages.', 'dlc-sample' ); ?></p>
					</td>
				</tr>
				<tr>
					<th scope="row">
						<label for="dlc_hello_bar_message"><?php echo esc_html__( 'Message', 'dlc-sample' ); ?></label>
					</th>
					<td>
						<input
							type="text"
							id="dlc_hello_bar_message"
							name="dlc_hello_bar_message"
							value="<?php echo esc_attr( $message ); ?>"
							class="regular-text"
						/>
						<p class="description"><?php echo esc_html__( 'The message displayed in the hello bar.', 'dlc-sample' ); ?></p>
					</td>
				</tr>
				<tr>
					<th scope="row">
						<label for="dlc_hello_bar_cta_text"><?php echo esc_html__( 'CTA Link Text', 'dlc-sample' ); ?></label>
					</th>
					<td>
						<input
							type="text"
							id="dlc_hello_bar_cta_text"
							name="dlc_hello_bar_cta_text"
							value="<?php echo esc_attr( $cta_text ); ?>"
							class="regular-text"
						/>
						<p class="description"><?php echo esc_html__( 'Text for the call-to-action link. Leave empty to hide the link.', 'dlc-sample' ); ?></p>
					</td>
				</tr>
				<tr>
					<th scope="row">
						<label for="dlc_hello_bar_cta_url"><?php echo esc_html__( 'CTA Link URL', 'dlc-sample' ); ?></label>
					</th>
					<td>
						<input
							type="url"
							id="dlc_hello_bar_cta_url"
							name="dlc_hello_bar_cta_url"
							value="<?php echo esc_attr( $cta_url ); ?>"
							class="regular-text"
						/>
						<p class="description"><?php echo esc_html__( 'URL for the call-to-action link.', 'dlc-sample' ); ?></p>
					</td>
				</tr>
				<tr>
					<th scope="row">
						<label for="dlc_hello_bar_theme"><?php echo esc_html__( 'Color Theme', 'dlc-sample' ); ?></label>
					</th>
					<td>
						<select id="dlc_hello_bar_theme" name="dlc_hello_bar_theme">
							<option value="blue" <?php selected( $theme, 'blue' ); ?>><?php echo esc_html__( 'Blue (Default)', 'dlc-sample' ); ?></option>
							<option value="dark" <?php selected( $theme, 'dark' ); ?>><?php echo esc_html__( 'Dark', 'dlc-sample' ); ?></option>
							<option value="green" <?php selected( $theme, 'green' ); ?>><?php echo esc_html__( 'Green', 'dlc-sample' ); ?></option>
							<option value="red" <?php selected( $theme, 'red' ); ?>><?php echo esc_html__( 'Red', 'dlc-sample' ); ?></option>
							<option value="purple" <?php selected( $theme, 'purple' ); ?>><?php echo esc_html__( 'Purple', 'dlc-sample' ); ?></option>
							<option value="orange" <?php selected( $theme, 'orange' ); ?>><?php echo esc_html__( 'Orange', 'dlc-sample' ); ?></option>
						</select>
						<p class="description"><?php echo esc_html__( 'Choose a color theme for the hello bar.', 'dlc-sample' ); ?></p>
					</td>
				</tr>
			</table>
			<?php submit_button(); ?>
		</form>

		<div class="dlc-hello-bar-preview-wrap">
			<h2><?php echo esc_html__( 'Preview', 'dlc-sample' ); ?></h2>
			<div
				id="dlc-hello-bar-preview"
				class="dlc-hello-bar-preview"
				data-theme="<?php echo esc_attr( $theme ); ?>"
			>
				<span class="dlc-hello-bar-preview__message"><?php echo esc_html( $message ); ?></span>
				<a
					href="<?php echo esc_url( $cta_url ); ?>"
					class="dlc-hello-bar-preview__cta"
					<?php echo ( empty( $cta_text ) || empty( $cta_url ) ) ? 'style="display:none"' : ''; ?>
				><?php echo esc_html( $cta_text ); ?></a>
				<span class="dlc-hello-bar__dismiss" aria-hidden="true">&#10005;</span>
			</div>
		</div>
	</div>
	<?php
}

/**
 * Enqueue frontend styles for the hello bar.
 */
function dlc_hello_bar_enqueue_styles() {
	if ( '1' !== get_option( 'dlc_hello_bar_enabled', '1' ) ) {
		return;
	}

	wp_enqueue_style(
		'dlc-hello-bar',
		plugin_dir_url( __FILE__ ) . 'assets/css/hello-bar.css',
		array(),
		DLC_HELLO_BAR_VERSION
	);
}
add_action( 'wp_enqueue_scripts', 'dlc_hello_bar_enqueue_styles' );

/**
 * Enqueue frontend script for dismiss functionality.
 */
function dlc_hello_bar_enqueue_scripts() {
	if ( '1' !== get_option( 'dlc_hello_bar_enabled', '1' ) ) {
		return;
	}

	wp_enqueue_script(
		'dlc-hello-bar',
		plugin_dir_url( __FILE__ ) . 'assets/js/hello-bar.js',
		array(),
		DLC_HELLO_BAR_VERSION,
		true
	);
}
add_action( 'wp_enqueue_scripts', 'dlc_hello_bar_enqueue_scripts' );

/**
 * Render the hello bar HTML after the opening body tag.
 */
function dlc_hello_bar_render() {
	if ( '1' !== get_option( 'dlc_hello_bar_enabled', '1' ) ) {
		return;
	}

	$message = get_option( 'dlc_hello_bar_message', __( 'Welcome! Check out our latest updates.', 'dlc-sample' ) );

	if ( empty( $message ) ) {
		return;
	}

	// CTA link configuration (from admin settings).
	$cta_url  = get_option( 'dlc_hello_bar_cta_url', '' );
	$cta_text = get_option( 'dlc_hello_bar_cta_text', __( 'Learn More', 'dlc-sample' ) );
	$theme    = get_option( 'dlc_hello_bar_theme', 'blue' );

	?>
	<div
		id="dlc-hello-bar"
		role="banner"
		aria-label="<?php echo esc_attr__( 'Site announcement', 'dlc-sample' ); ?>"
		data-testid="hello-bar"
		data-theme="<?php echo esc_attr( $theme ); ?>"
	>
		<span class="dlc-hello-bar__message" data-testid="hello-bar-message">
			<?php echo esc_html( $message ); ?>
		</span>
		<?php if ( ! empty( $cta_url ) && ! empty( $cta_text ) ) : ?>
			<a
				href="<?php echo esc_url( $cta_url ); ?>"
				class="dlc-hello-bar__cta"
				data-testid="hello-bar-cta"
			>
				<?php echo esc_html( $cta_text ); ?>
			</a>
		<?php endif; ?>
		<button
			type="button"
			class="dlc-hello-bar__dismiss"
			aria-label="<?php echo esc_attr__( 'Dismiss announcement', 'dlc-sample' ); ?>"
			data-testid="hello-bar-dismiss"
		>
			&#10005;
		</button>
	</div>
	<?php
}
add_action( 'wp_body_open', 'dlc_hello_bar_render' );
