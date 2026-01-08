// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde::Serialize;
use std::fs;
use std::path::Path;

/// File entry for the explorer
#[derive(Serialize)]
pub struct FileEntry {
    name: String,
    path: String,
    #[serde(rename = "type")]
    entry_type: String, // "file" or "directory"
    size: u64,
}

/// List files in a directory
#[tauri::command]
fn list_directory(path: String) -> Result<Vec<FileEntry>, String> {
    let dir_path = Path::new(&path);
    
    if !dir_path.exists() {
        return Err(format!("Directory does not exist: {}", path));
    }
    
    if !dir_path.is_dir() {
        return Err(format!("Path is not a directory: {}", path));
    }
    
    let mut entries = Vec::new();
    
    match fs::read_dir(dir_path) {
        Ok(read_dir) => {
            for entry in read_dir.flatten() {
                let file_name = entry.file_name().to_string_lossy().to_string();
                let file_path = entry.path();
                let full_path = file_path.to_string_lossy().to_string();
                
                // Skip hidden files/folders (starting with .)
                if file_name.starts_with('.') {
                    continue;
                }
                
                // Skip common ignored directories
                if file_name == "node_modules" || file_name == "target" || file_name == "_build" || file_name == "deps" {
                    continue;
                }
                
                let metadata = entry.metadata().ok();
                let is_dir = file_path.is_dir();
                let size = metadata.map(|m| m.len()).unwrap_or(0);
                
                entries.push(FileEntry {
                    name: file_name,
                    path: full_path,
                    entry_type: if is_dir { "directory".to_string() } else { "file".to_string() },
                    size,
                });
            }
        }
        Err(e) => return Err(format!("Failed to read directory: {}", e)),
    }
    
    // Sort: directories first, then files, alphabetically
    entries.sort_by(|a, b| {
        match (&a.entry_type[..], &b.entry_type[..]) {
            ("directory", "file") => std::cmp::Ordering::Less,
            ("file", "directory") => std::cmp::Ordering::Greater,
            _ => a.name.to_lowercase().cmp(&b.name.to_lowercase()),
        }
    });
    
    Ok(entries)
}

/// Read file contents
#[tauri::command]
fn read_file(path: String) -> Result<String, String> {
    fs::read_to_string(&path).map_err(|e| format!("Failed to read file {}: {}", path, e))
}

/// Save file contents
#[tauri::command]
fn save_file(path: String, content: String) -> Result<(), String> {
    fs::write(&path, content).map_err(|e| format!("Failed to save file {}: {}", path, e))
}

// Window controls
#[tauri::command]
fn close_window(window: tauri::Window) {
    window.close().unwrap();
}

#[tauri::command]
fn minimize_window(window: tauri::Window) {
    window.minimize().unwrap();
}

#[tauri::command]
fn maximize_window(window: tauri::Window) {
    if window.is_maximized().unwrap() {
        window.unmaximize().unwrap();
    } else {
        window.maximize().unwrap();
    }
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .invoke_handler(tauri::generate_handler![
            close_window, 
            minimize_window, 
            maximize_window,
            list_directory,
            read_file,
            save_file
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
