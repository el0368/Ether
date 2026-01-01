# Project FAQ & Architecture Decisions

This document records key architectural questions and answers discussed during development.

## 🏗️ Architecture

### Q: What makes Aether a Desktop App?
**A:** The magic is the **`desktop` library** (wxWidgets).
1.  **Backend**: Phoenix runs as usual (`localhost:4000`).
2.  **Shell**: A Native Window (Elixir + wxWidgets) launches.
3.  **UI**: An embedded **WebView** (Edge/WebKit) inside the window loads the Phoenix app.
*Result*: A standalone app feel with web technologies.

### Q: Is it Cross-Platform?
**A:** **Yes.**
-   The Code (`Desktop.Window`) is 100% agnostic.
-   **Windows**: Uses Edge (WebView2).
-   **macOS**: Uses WKWebView.
-   **Linux**: Uses WebKitGTK.
*Note*: You need to run the build command on the target OS (or properly cross-compile) to get the final executable.

### Q: Can it run on Mobile?
**A:**
-   **Native App**: No (`desktop` lib is PC-only).
-   **Web Interface**: **Yes**. You can access the server from a mobile browser on the same Wi-Fi (e.g., `http://192.168.x.x:4000`).
-   *Future*: Could use "LiveView Native" or "Capacitor" to wrap the exact same backend for iOS/Android.

## 🤖 Agents & Workflows

### Q: What is a "Workflow Agent"?
**A:** A `.md` file in `.agent/workflows/` acts as a programmable persona for the AI (Antigravity).
-   It is a **specific job description** (e.g., "QA Auditor").
-   When providing this file to the AI, it switches mode to execute those specific steps strictly.

### Q: Global Rules vs. Agents?
-   **Global Rules** (`GLOBAL_RULES.md`): The **Constitution**. Unbreakable laws that apply to *everything* (e.g., "No NIFs").
-   **Agents**: Specific tasks.
*Hierarchy*: Global Rules > Agent Instructions > Ad-hoc Commands.
