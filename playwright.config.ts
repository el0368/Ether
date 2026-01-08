import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright configuration for Ether IDE E2E testing
 * Tests the actual Tauri desktop application
 */
export default defineConfig({
  testDir: './tests/e2e',
  
  // Test timeout for desktop app operations
  timeout: 10000,
  
  // Fail fast on first failure during development
  fullyParallel: false,
  
  // Retry failed tests once
  retries: 1,
  
  // Reporter configuration
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['list']
  ],
  
  use: {
    // Base URL for the Tauri app (if using webview testing)
    // baseURL: 'http://localhost:5173',
    
    // Capture screenshot on failure
    screenshot: 'only-on-failure',
    
    // Capture video on failure
    video: 'retain-on-failure',
    
    // Trace on first retry
    trace: 'on-first-retry',
  },

  // Configure projects for different scenarios
  projects: [
    {
      name: 'desktop',
      use: { 
        ...devices['Desktop Chrome'],
        // Tauri-specific configuration will go here
      },
    },
  ],
});
