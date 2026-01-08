import { describe, it, expect, beforeEach } from 'vitest';
import { EditorState } from '../editor.svelte.js';

describe('EditorState', () => {
    let editor;

    beforeEach(() => {
        editor = new EditorState();
    });

    it('should initialize with a default group', () => {
        expect(editor.groups.length).toBe(1);
        expect(editor.activeGroup.file).toBe(null);
    });

    it('should split editor correctly', () => {
        editor.groups[0].file = { name: 'test.js', path: 'test.js' };
        editor.groups[0].content = 'test content';
        
        editor.splitEditor();
        expect(editor.groups.length).toBe(2);
        expect(editor.activeIndex).toBe(1);
        expect(editor.activeGroup.file.name).toBe('test.js');
        expect(editor.activeGroup.content).toBe('test content');
    });

    it('should create new untitled file', () => {
        editor.newUntitled();
        expect(editor.activeGroup.file.name).toBe('Untitled');
        expect(editor.activeGroup.content).toBe('');
    });

    it('should toggle autoSave', () => {
        expect(editor.autoSave).toBe(false);
        editor.toggleAutoSave();
        expect(editor.autoSave).toBe(true);
    });

    it('should close editor correctly', () => {
        editor.newUntitled();
        editor.splitEditor();
        expect(editor.groups.length).toBe(2);

        editor.closeEditor(1);
        expect(editor.groups.length).toBe(1);
        expect(editor.activeIndex).toBe(0);
    });
});
