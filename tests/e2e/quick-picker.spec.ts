import { test, expect } from '@playwright/test';

/**
 * QuickPicker Component E2E Tests
 * Verifies keyboard shortcuts, fuzzy search, and navigation
 */

test.describe('QuickPicker', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should open with Ctrl+P', async ({ page }) => {
    // QuickPicker should not be visible initially
    const quickPicker = page.locator('.quick-input-overlay');
    await expect(quickPicker).toBeHidden();
    
    // Press Ctrl+P
    await page.keyboard.press('Control+p');
    
    // QuickPicker should now be visible
    await expect(quickPicker).toBeVisible();
    
    // Input should be focused
    const input = page.locator('.quick-input-input');
    await expect(input).toBeFocused();
  });

  test('should filter items based on query', async ({ page }) => {
    await page.keyboard.press('Control+p');
    
    const input = page.locator('.quick-input-input');
    await input.fill('App');
    
    // Should show filtered results
    const appItem = page.locator('.quick-input-item').filter({ hasText: 'App.svelte' });
    await expect(appItem).toBeVisible();
    
    // Should not show unrelated files
    const otherItem = page.locator('.quick-input-item').filter({ hasText: 'package.json' });
    await expect(otherItem).toBeHidden();
  });

  test('should navigate with arrow keys', async ({ page }) => {
    await page.keyboard.press('Control+p');
    
    // First item should be active
    const firstItem = page.locator('.quick-input-item.active').first();
    await expect(firstItem).toBeVisible();
    
    // Press down arrow
    await page.keyboard.press('ArrowDown');
    
    // Second item should now be active
    const items = page.locator('.quick-input-item');
    const secondItem = items.nth(1);
    await expect(secondItem).toHaveClass(/active/);
  });

  test('should select item with Enter', async ({ page }) => {
    await page.keyboard.press('Control+p');
    
    const input = page.locator('.quick-input-input');
    await input.fill('README');
    
    // Press Enter to select
    await page.keyboard.press('Enter');
    
    // QuickPicker should close
    const quickPicker = page.locator('.quick-input-overlay');
    await expect(quickPicker).toBeHidden();
    
    // File should be opened in editor
    const editorContent = page.locator('.monaco-editor');
    await expect(editorContent).toBeVisible();
  });

  test('should close with Escape', async ({ page }) => {
    await page.keyboard.press('Control+p');
    
    const quickPicker = page.locator('.quick-input-overlay');
    await expect(quickPicker).toBeVisible();
    
    // Press Escape
    await page.keyboard.press('Escape');
    
    // QuickPicker should close
    await expect(quickPicker).toBeHidden();
  });

  test('should close when clicking overlay', async ({ page }) => {
    await page.keyboard.press('Control+p');
    
    const overlay = page.locator('.quick-input-overlay');
    await expect(overlay).toBeVisible();
    
    // Click outside the widget (on the overlay)
    await overlay.click({ position: { x: 10, y: 10 } });
    
    // QuickPicker should close
    await expect(overlay).toBeHidden();
  });

  test('should show recent files when empty', async ({ page }) => {
    await page.keyboard.press('Control+p');
    
    const input = page.locator('.quick-input-input');
    await expect(input).toHaveValue('');
    
    // Should show recent files with history icon
    const recentItem = page.locator('.quick-input-item').filter({ has: page.locator('[data-icon="history"]') });
    await expect(recentItem).toBeVisible();
  });
});

test.describe('Symbol Search', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should open symbol search with Ctrl+Shift+O', async ({ page }) => {
    await page.keyboard.press('Control+Shift+o');
    
    const quickPicker = page.locator('.quick-input-overlay');
    await expect(quickPicker).toBeVisible();
    
    // Should show symbols instead of files
    const symbolItem = page.locator('.quick-input-item').filter({ has: page.locator('[data-icon="symbol-method"]') });
    await expect(symbolItem).toBeVisible();
  });
});
