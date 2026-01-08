import { test, expect } from '@playwright/test';

/**
 * Editor Functionality Tests
 * Verifies Monaco editor initialization, file loading, and tab management
 */

test.describe('Monaco Editor', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should show welcome page when no file is open', async ({ page }) => {
    const welcomePage = page.getByText('Welcome to Ether IDE');
    await expect(welcomePage).toBeVisible();
  });

  test('should initialize Monaco editor when file is opened', async ({ page }) => {
    // Open a file (assuming README.md exists)
    const fileNode = page.locator('.tree-node').filter({ hasText: 'README.md' }).first();
    await fileNode.click();
    
    // Monaco editor should be visible
    const editor = page.locator('.monaco-editor');
    await expect(editor).toBeVisible();
    
    // Editor should have content
    const editorContent = page.locator('.view-lines');
    await expect(editorContent).toBeVisible();
  });

  test('should load file content correctly', async ({ page }) => {
    const fileNode = page.locator('.tree-node').filter({ hasText: 'README.md' }).first();
    await fileNode.click();
    
    // Wait for content to load
    await page.waitForTimeout(500);
    
    // Check if content is displayed
    const lines = page.locator('.view-line');
    const count = await lines.count();
    expect(count).toBeGreaterThan(0);
  });

  test('should show file name in tab', async ({ page }) => {
    const fileNode = page.locator('.tree-node').filter({ hasText: 'README.md' }).first();
    await fileNode.click();
    
    // Tab should show file name
    const tab = page.locator('.editor-tab').filter({ hasText: 'README.md' });
    await expect(tab).toBeVisible();
  });

  test('should highlight active tab', async ({ page }) => {
    const fileNode = page.locator('.tree-node').filter({ hasText: 'README.md' }).first();
    await fileNode.click();
    
    const tab = page.locator('.editor-tab').filter({ hasText: 'README.md' });
    await expect(tab).toHaveClass(/active/);
  });
});

test.describe('Split Editor', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should split editor with Ctrl+\\', async ({ page }) => {
    // Open a file first
    const fileNode = page.locator('.tree-node').first();
    await fileNode.click();
    
    // Split editor
    await page.keyboard.press('Control+\\');
    
    // Should have two editor groups
    const editorGroups = page.locator('.editor-group');
    await expect(editorGroups).toHaveCount(2);
  });

  test('should show same file in both panes after split', async ({ page }) => {
    const fileNode = page.locator('.tree-node').filter({ hasText: 'README.md' }).first();
    await fileNode.click();
    
    await page.keyboard.press('Control+\\');
    
    // Both panes should show README.md
    const tabs = page.locator('.editor-tab').filter({ hasText: 'README.md' });
    await expect(tabs).toHaveCount(2);
  });
});

test.describe('Tab Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should close tab with close button', async ({ page }) => {
    const fileNode = page.locator('.tree-node').first();
    await fileNode.click();
    
    const closeButton = page.locator('.tab-close').first();
    await closeButton.click();
    
    // Tab should be removed
    const tabs = page.locator('.editor-tab');
    await expect(tabs).toHaveCount(0);
  });

  test('should switch between tabs', async ({ page }) => {
    // Open two files
    const file1 = page.locator('.tree-node').filter({ hasText: 'README.md' }).first();
    await file1.click();
    
    const file2 = page.locator('.tree-node').filter({ hasText: 'package.json' }).first();
    await file2.click();
    
    // Click on first tab
    const tab1 = page.locator('.editor-tab').filter({ hasText: 'README.md' });
    await tab1.click();
    
    // First tab should be active
    await expect(tab1).toHaveClass(/active/);
  });
});

test.describe('Syntax Highlighting', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
  });

  test('should apply syntax highlighting to code', async ({ page }) => {
    // Open a JavaScript file
    const jsFile = page.locator('.tree-node').filter({ hasText: '.js' }).first();
    await jsFile.click();
    
    // Wait for Monaco to apply syntax highlighting
    await page.waitForTimeout(1000);
    
    // Check for syntax tokens (Monaco adds specific classes)
    const tokens = page.locator('.mtk1, .mtk2, .mtk3, .mtk4, .mtk5');
    const count = await tokens.count();
    expect(count).toBeGreaterThan(0);
  });
});
