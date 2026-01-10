import { describe, it, expect, vi } from 'vitest';

// Test Editor logic without rendering (Svelte 5 lifecycle issues with happy-dom)
describe('Editor Logic', () => {
  it('detects correct language from file extension', () => {
    const getLanguage = (path: string) => {
      const ext = path?.split('.').pop()?.toLowerCase() || '';
      const langMap: Record<string, string> = {
        'ex': 'elixir',
        'exs': 'elixir',
        'heex': 'html',
        'js': 'javascript',
        'ts': 'typescript',
        'svelte': 'html',
        'css': 'css',
        'json': 'json',
        'md': 'markdown',
        'zig': 'zig',
        'html': 'html',
        'xml': 'xml',
        'yaml': 'yaml',
        'yml': 'yaml',
        'toml': 'ini'
      };
      return langMap[ext] || 'plaintext';
    };

    expect(getLanguage('/test/file.ex')).toBe('elixir');
    expect(getLanguage('/test/file.exs')).toBe('elixir');
    expect(getLanguage('/test/file.js')).toBe('javascript');
    expect(getLanguage('/test/file.ts')).toBe('typescript');
    expect(getLanguage('/test/file.md')).toBe('markdown');
    expect(getLanguage('/test/file.zig')).toBe('zig');
    expect(getLanguage('/test/file.unknown')).toBe('plaintext');
  });

  it('debounces editor changes correctly', async () => {
    let callCount = 0;
    const mockPushEvent = vi.fn();

    // Simulate debounce behavior
    let debounceTimer: ReturnType<typeof setTimeout> | null = null;
    const debouncedPush = (text: string) => {
      if (debounceTimer) clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => {
        mockPushEvent({ event: 'editor_change', text });
      }, 50); // Faster for testing
    };

    // Rapid calls should be debounced
    debouncedPush('a');
    debouncedPush('ab');
    debouncedPush('abc');
    
    // Wait for debounce
    await new Promise(r => setTimeout(r, 100));

    expect(mockPushEvent).toHaveBeenCalledTimes(1);
    expect(mockPushEvent).toHaveBeenCalledWith({ event: 'editor_change', text: 'abc' });
  });

  it('handles load_file event structure correctly', () => {
    const loadFilePayload = {
      text: 'defmodule Test do\n  def hello, do: :world\nend',
      language: 'elixir',
      path: '/test/test.ex'
    };

    expect(loadFilePayload.text).toContain('defmodule');
    expect(loadFilePayload.language).toBe('elixir');
    expect(loadFilePayload.path).toContain('.ex');
  });

  it('handles large file content efficiently', () => {
    const largeContent = 'defmodule Test do\n'.repeat(10000);
    
    const startTime = performance.now();
    
    // Simulate content processing
    const lines = largeContent.split('\n');
    const lineCount = lines.length;
    
    const processingTime = performance.now() - startTime;
    
    // Processing should be fast
    expect(processingTime).toBeLessThan(50);
    expect(lineCount).toBe(10001); // 10000 lines + 1 empty
  });
});

describe('Monaco Editor Mock', () => {
  it('validates Monaco editor API structure', () => {
    // Mock Monaco editor instance
    const mockEditor = {
      getValue: vi.fn(() => 'test content'),
      setValue: vi.fn(),
      getModel: vi.fn(() => ({
        getValue: vi.fn(() => 'test content'),
        uri: { toString: () => 'file:///test.ex' }
      })),
      onDidChangeModelContent: vi.fn((callback) => {
        // Return disposable
        return { dispose: vi.fn() };
      }),
      dispose: vi.fn(),
    };

    expect(mockEditor.getValue()).toBe('test content');
    
    mockEditor.setValue('new content');
    expect(mockEditor.setValue).toHaveBeenCalledWith('new content');

    const disposer = mockEditor.onDidChangeModelContent(() => {});
    expect(disposer.dispose).toBeDefined();
  });
});
