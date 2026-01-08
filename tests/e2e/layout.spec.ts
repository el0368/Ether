import { test, expect } from '@playwright/test';

/**
 * Layout & Grid Verification Tests
 * Ensures the Workbench grid layout renders correctly with proper dimensions
 */

test.describe('Workbench Layout', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the Ether IDE (adjust URL based on your setup)
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should render title bar with correct height', async ({ page }) => {
    const titleBar = page.locator('.part-titlebar');
    await expect(titleBar).toBeVisible();
    
    const box = await titleBar.boundingBox();
    expect(box?.height).toBe(35);
  });

  test('should render activity bar with correct width', async ({ page }) => {
    const activityBar = page.locator('.part-activitybar');
    await expect(activityBar).toBeVisible();
    
    const box = await activityBar.boundingBox();
    expect(box?.width).toBe(48);
  });

  test('should toggle sidebar visibility', async ({ page }) => {
    const sidebar = page.locator('.part-sidebar');
    
    // Sidebar should be visible initially
    await expect(sidebar).toBeVisible();
    
    // Click explorer icon to toggle
    const explorerIcon = page.locator('[data-testid="activity-explorer"]').first();
    await explorerIcon.click();
    
    // Sidebar should be hidden
    await expect(sidebar).toBeHidden();
    
    // Click again to show
    await explorerIcon.click();
    await expect(sidebar).toBeVisible();
  });

  test('should have correct z-index stacking', async ({ page }) => {
    const titleBar = page.locator('.part-titlebar');
    const editor = page.locator('.part-editor');
    
    const titleBarZ = await titleBar.evaluate(el => 
      window.getComputedStyle(el).zIndex
    );
    const editorZ = await editor.evaluate(el => 
      window.getComputedStyle(el).zIndex
    );
    
    // Title bar should be above editor
    expect(parseInt(titleBarZ)).toBeGreaterThan(parseInt(editorZ));
  });

  test('should render status bar at bottom', async ({ page }) => {
    const statusBar = page.locator('.part-statusbar');
    await expect(statusBar).toBeVisible();
    
    const box = await statusBar.boundingBox();
    const viewportHeight = page.viewportSize()?.height || 0;
    
    // Status bar should be at the bottom
    expect(box?.y).toBeGreaterThan(viewportHeight - 50);
  });
});

test.describe('Responsive Layout', () => {
  test('should handle sidebar resize', async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
    
    const sidebar = page.locator('.part-sidebar');
    const initialBox = await sidebar.boundingBox();
    
    // Find and drag the sash (resize handle)
    const sash = page.locator('.sash-vertical').first();
    await sash.hover();
    
    // Drag to resize
    await page.mouse.down();
    await page.mouse.move((initialBox?.x || 0) + 100, initialBox?.y || 0);
    await page.mouse.up();
    
    // Sidebar width should have changed
    const newBox = await sidebar.boundingBox();
    expect(newBox?.width).not.toBe(initialBox?.width);
  });
});
