import { test, expect } from '@playwright/test';

/**
 * File Explorer Interaction Tests
 * Verifies tree navigation, file selection, and context menus
 */

test.describe('File Explorer', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should show empty state when no folder is open', async ({ page }) => {
    const emptyMessage = page.getByText('You have not yet opened a folder');
    await expect(emptyMessage).toBeVisible();
    
    const openFolderButton = page.getByRole('button', { name: 'Open Folder' });
    await expect(openFolderButton).toBeVisible();
  });

  test('should expand and collapse tree nodes', async ({ page }) => {
    // Assuming a folder is already open for this test
    // You may need to mock or set up test data
    
    const folderNode = page.locator('.tree-node').filter({ hasText: 'src' }).first();
    const twistie = folderNode.locator('.node-twistie').first();
    
    // Click to expand
    await twistie.click();
    
    // Check if children are visible
    const childNode = page.locator('.tree-node').filter({ hasText: 'App.svelte' });
    await expect(childNode).toBeVisible();
    
    // Click to collapse
    await twistie.click();
    await expect(childNode).toBeHidden();
  });

  test('should select file on click', async ({ page }) => {
    const fileNode = page.locator('.tree-node').filter({ hasText: 'README.md' }).first();
    await fileNode.click();
    
    // File should have selected class
    await expect(fileNode).toHaveClass(/selected/);
  });

  test('should show context menu on right click', async ({ page }) => {
    const fileNode = page.locator('.tree-node').first();
    await fileNode.click({ button: 'right' });
    
    // Context menu should appear
    const contextMenu = page.locator('.context-menu');
    await expect(contextMenu).toBeVisible();
    
    // Should have menu items
    const newFileItem = page.getByText('New File');
    await expect(newFileItem).toBeVisible();
  });

  test('should handle drag and drop', async ({ page }) => {
    const sourceFile = page.locator('.tree-node').filter({ hasText: 'test.txt' }).first();
    const targetFolder = page.locator('.tree-node').filter({ hasText: 'docs' }).first();
    
    // Drag file to folder
    await sourceFile.dragTo(targetFolder);
    
    // Folder should show drop target styling during drag
    await expect(targetFolder).toHaveClass(/drop-target/);
  });
});

test.describe('File Explorer Toolbar', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should show refresh button', async ({ page }) => {
    const refreshButton = page.locator('button[title="Refresh"]');
    await expect(refreshButton).toBeVisible();
  });

  test('should show new file button', async ({ page }) => {
    const newFileButton = page.locator('button[title="New File"]');
    await expect(newFileButton).toBeVisible();
  });

  test('should show loading spinner when loading', async ({ page }) => {
    // Trigger a refresh to show loading state
    const refreshButton = page.locator('button[title="Refresh"]');
    await refreshButton.click();
    
    const spinner = page.locator('.animate-spin');
    await expect(spinner).toBeVisible();
  });
});
