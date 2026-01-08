import { describe, it, expect, beforeEach } from 'vitest';
import { UIState } from '../ui.svelte.js';

describe('UIState', () => {
    let ui;

    beforeEach(() => {
        ui = new UIState();
    });

    it('should initialize with default values', () => {
        expect(ui.sidebarVisible).toBe(true);
        expect(ui.terminalVisible).toBe(true);
        expect(ui.activeSidebar).toBe('files');
        expect(ui.showPalette).toBe(false);
    });

    it('should toggle sidebar correctly', () => {
        ui.toggleSidebar('search');
        expect(ui.activeSidebar).toBe('search');
        expect(ui.sidebarVisible).toBe(true);

        ui.toggleSidebar('search');
        expect(ui.sidebarVisible).toBe(false);

        ui.toggleSidebar('git');
        expect(ui.activeSidebar).toBe('git');
        expect(ui.sidebarVisible).toBe(true);
    });

    it('should toggle terminal correctly', () => {
        ui.toggleTerminal();
        expect(ui.terminalVisible).toBe(false);
        ui.toggleTerminal();
        expect(ui.terminalVisible).toBe(true);
    });

    it('should manage palette state', () => {
        ui.openPalette('symbols');
        expect(ui.showPalette).toBe(true);
        expect(ui.paletteMode).toBe('symbols');

        ui.closePalette();
        expect(ui.showPalette).toBe(false);
    });
});
