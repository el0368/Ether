/**
 * tauri_fs.ts - Tauri Native File System API
 * 
 * This module provides a direct bridge to Tauri's Rust backend for file operations.
 * It bypasses the Phoenix channel entirely, making the IDE work standalone.
 */

import { invoke } from '@tauri-apps/api/core';
import { open } from '@tauri-apps/plugin-dialog';

export interface FileEntry {
    name: string;
    path: string;
    type: 'file' | 'directory';
    size: number;
}

/**
 * Open a native folder picker dialog
 * @returns The selected folder path, or null if cancelled
 */
export async function pickFolder(): Promise<string | null> {
    try {
        const result = await open({
            directory: true,
            multiple: false,
            title: 'Open Folder',
        });
        return result as string | null;
    } catch (e) {
        console.error('Folder picker error:', e);
        return null;
    }
}

/**
 * List files in a directory using Tauri's native API
 * @param path - The directory path to list
 * @returns Array of file entries
 */
export async function listDirectory(path: string): Promise<FileEntry[]> {
    try {
        return await invoke<FileEntry[]>('list_directory', { path });
    } catch (e) {
        console.error('List directory error:', e);
        return [];
    }
}

/**
 * Read file contents using Tauri's native API
 * @param path - The file path to read
 * @returns File contents as string
 */
export async function readFile(path: string): Promise<string> {
    try {
        return await invoke<string>('read_file', { path });
    } catch (e) {
        console.error('Read file error:', e);
        throw e;
    }
}

/**
 * Save file contents using Tauri's native API
 * @param path - The file path to save
 * @param content - The content to write
 */
export async function saveFile(path: string, content: string): Promise<void> {
    try {
        await invoke('save_file', { path, content });
    } catch (e) {
        console.error('Save file error:', e);
        throw e;
    }
}

/**
 * Check if we're running in Tauri environment
 */
export function isTauri(): boolean {
    return typeof window !== 'undefined' && '__TAURI__' in window;
}
