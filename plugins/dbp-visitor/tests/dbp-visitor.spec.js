// @ts-check
const { test, expect } = require('@playwright/test');

/**
 * DBP Visitor Welcome Bar — Automated Browser Tests
 *
 * Prerequisites:
 * - WordPress running at http://localhost:8080 (docker-compose up)
 * - dbp-visitor plugin activated
 * - Plugin enabled in Settings → DBP Visitor
 */

test.describe('DBP Visitor Welcome Bar', () => {

	test.beforeEach(async ({ page }) => {
		// Clear storage to start fresh each test.
		await page.goto('/');
		await page.evaluate(() => {
			localStorage.clear();
			sessionStorage.clear();
		});
	});

	test('Scenario 1: Bar renders on frontend', async ({ page }) => {
		await page.goto('/');
		const bar = page.locator('[data-testid="dbp-visitor-bar"]');
		await expect(bar).toBeVisible();
		await expect(bar).toHaveClass(/dbp-visitor-bar/);

		// Message should have content.
		const message = page.locator('[data-testid="dbp-visitor-bar-message"]');
		await expect(message).not.toBeEmpty();

		// Close button should be visible.
		const closeBtn = page.locator('[data-testid="dbp-visitor-bar-close"]');
		await expect(closeBtn).toBeVisible();
	});

	test('Scenario 2: First visit shows welcome message', async ({ page }) => {
		await page.goto('/');
		const message = page.locator('[data-testid="dbp-visitor-bar-message"]');
		await expect(message).toContainText('Welcome, first-time visitor!');
	});

	test('Scenario 3: Visit count increments on reload', async ({ page }) => {
		// First visit.
		await page.goto('/');
		await expect(page.locator('[data-testid="dbp-visitor-bar-message"]')).toContainText('first-time visitor');

		// Clear dismiss state but keep count, then reload.
		await page.evaluate(() => {
			sessionStorage.removeItem('dbp_visitor_dismissed');
		});
		await page.reload();

		const message = page.locator('[data-testid="dbp-visitor-bar-message"]');
		await expect(message).toContainText('Welcome back for visit #2');
	});

	test('Scenario 4: Dismiss with X button', async ({ page }) => {
		await page.goto('/');
		const bar = page.locator('[data-testid="dbp-visitor-bar"]');
		await expect(bar).toBeVisible();

		// Click close.
		await page.locator('[data-testid="dbp-visitor-bar-close"]').click();

		// Bar should be hidden.
		await expect(bar).toHaveClass(/dbp-visitor-bar--hidden/);

		// SessionStorage should have dismiss flag.
		const dismissed = await page.evaluate(() => sessionStorage.getItem('dbp_visitor_dismissed'));
		expect(dismissed).toBe('1');
	});

	test('Scenario 5: Dismiss with Escape key', async ({ page }) => {
		await page.goto('/');
		const bar = page.locator('[data-testid="dbp-visitor-bar"]');
		await expect(bar).toBeVisible();

		// Press Escape.
		await page.keyboard.press('Escape');

		// Bar should be hidden.
		await expect(bar).toHaveClass(/dbp-visitor-bar--hidden/);

		// SessionStorage should have dismiss flag.
		const dismissed = await page.evaluate(() => sessionStorage.getItem('dbp_visitor_dismissed'));
		expect(dismissed).toBe('1');
	});

	test('Scenario 6: Dismiss persists across page navigation', async ({ page }) => {
		await page.goto('/');
		const bar = page.locator('[data-testid="dbp-visitor-bar"]');
		await expect(bar).toBeVisible();

		// Dismiss.
		await page.locator('[data-testid="dbp-visitor-bar-close"]').click();
		await expect(bar).toHaveClass(/dbp-visitor-bar--hidden/);

		// Navigate to another page.
		await page.reload();

		// Bar should still be hidden (session dismiss).
		await expect(bar).toHaveClass(/dbp-visitor-bar--hidden/);
	});

	test('Scenario 7: Bar does not appear in admin area', async ({ page }) => {
		// Login to WP admin.
		await page.goto('/wp-login.php');
		await page.fill('#user_login', 'admin');
		await page.fill('#user_pass', 'admin');
		await page.click('#wp-submit');
		await page.waitForURL(/wp-admin/);

		// Check bar is not present in admin.
		const bar = page.locator('[data-testid="dbp-visitor-bar"]');
		await expect(bar).toHaveCount(0);
	});

	test('Scenario 8: Close button is keyboard accessible', async ({ page }) => {
		await page.goto('/');
		const closeBtn = page.locator('[data-testid="dbp-visitor-bar-close"]');

		// Tab to close button and verify it can receive focus.
		await closeBtn.focus();
		await expect(closeBtn).toBeFocused();

		// Verify aria-label.
		await expect(closeBtn).toHaveAttribute('aria-label', /[Cc]lose/);
	});

	test('Scenario 9: Accessibility attributes present', async ({ page }) => {
		await page.goto('/');
		const bar = page.locator('[data-testid="dbp-visitor-bar"]');

		// role="complementary".
		await expect(bar).toHaveAttribute('role', 'complementary');

		// aria-label on bar.
		await expect(bar).toHaveAttribute('aria-label');

		// aria-live on message.
		const message = page.locator('[data-testid="dbp-visitor-bar-message"]');
		await expect(message).toHaveAttribute('aria-live', 'polite');
	});

	test('Scenario 10: No CSP violations (no inline styles/scripts)', async ({ page }) => {
		const cspViolations = [];
		page.on('console', (msg) => {
			if (msg.text().includes('Content Security Policy') ||
				msg.text().includes('refused to')) {
				cspViolations.push(msg.text());
			}
		});

		await page.goto('/');
		// Wait for bar to render and geolocation to attempt.
		await page.waitForTimeout(2000);

		// Filter out connect-src violations (expected for ip-api.com if CSP is strict).
		const nonConnectViolations = cspViolations.filter(
			(v) => !v.includes('connect-src') && !v.includes('ip-api.com')
		);
		expect(nonConnectViolations).toHaveLength(0);
	});

	test('Scenario 11: Geolocation updates message', async ({ page }) => {
		// Mock the geolocation API to avoid rate limits in testing.
		await page.route('**/ip-api.com/**', async (route) => {
			await route.fulfill({
				status: 200,
				contentType: 'application/json',
				body: JSON.stringify({
					status: 'success',
					city: 'TestCity',
					country: 'TestCountry',
				}),
			});
		});

		await page.goto('/');
		const message = page.locator('[data-testid="dbp-visitor-bar-message"]');

		// Wait for geolocation to update message.
		await expect(message).toContainText('Visiting from TestCity, TestCountry', { timeout: 5000 });
	});

	test('Scenario 12: Responsive — bar visible on mobile viewport', async ({ page }) => {
		await page.setViewportSize({ width: 375, height: 667 });
		await page.goto('/');

		const bar = page.locator('[data-testid="dbp-visitor-bar"]');
		await expect(bar).toBeVisible();

		// Close button still accessible.
		const closeBtn = page.locator('[data-testid="dbp-visitor-bar-close"]');
		await expect(closeBtn).toBeVisible();
	});

});
