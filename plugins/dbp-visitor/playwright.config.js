// @ts-check
const { defineConfig } = require('@playwright/test');

/**
 * Playwright configuration for DBP Visitor plugin tests.
 * Requires WordPress running at http://localhost:8080 (via docker-compose).
 */
module.exports = defineConfig({
	testDir: './tests',
	timeout: 30000,
	expect: {
		timeout: 5000,
	},
	fullyParallel: false,
	forbidOnly: !!process.env.CI,
	retries: process.env.CI ? 1 : 0,
	workers: 1,
	reporter: 'list',
	use: {
		baseURL: 'http://localhost:8080',
		trace: 'on-first-retry',
		screenshot: 'only-on-failure',
	},
	projects: [
		{
			name: 'chromium',
			use: { browserName: 'chromium' },
		},
	],
});
