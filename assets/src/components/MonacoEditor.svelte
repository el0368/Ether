<script>
    import { onMount, onDestroy } from "svelte";
    import * as monaco from "monaco-editor";
    import MathPreview from "./MathPreview.svelte";

    let { value, language, theme, channel, path, onChange } = $props();

    let editorContainer;
    let editor;
    let model;
    let showPreview = $state(false);

    // Create or retrieve model for a specific path
    function getOrCreateModel(path, value, language) {
        let existingModel = monaco.editor
            .getModels()
            .find((m) => m.uri.toString() === `file://${path}`);
        if (existingModel) {
            if (value !== undefined && value !== existingModel.getValue()) {
                existingModel.setValue(value);
            }
            return existingModel;
        }
        return monaco.editor.createModel(
            value || "",
            language || "elixir",
            monaco.Uri.parse(`file://${path}`),
        );
    }

    // Initialize Monaco
    onMount(() => {
        const mountStart = performance.now();
        if (editorContainer) {
            editor = monaco.editor.create(editorContainer, {
                theme:
                    theme ||
                    (document.documentElement.getAttribute("data-theme") ===
                    "light"
                        ? "vs"
                        : "vs-dark"),
                automaticLayout: true,
                minimap: { enabled: false },
                fontSize: 13,
                lineHeight: 20,
                fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
                fontLigatures: true,
                padding: { top: 10, bottom: 10 },
                scrollBeyondLastLine: false,
                renderLineHighlight: "all",
                scrollbar: {
                    vertical: "visible",
                    horizontal: "visible",
                    useShadows: false,
                    verticalScrollbarSize: 10,
                    horizontalScrollbarSize: 10,
                },
            });

            const mountEnd = performance.now();
            import("$lib/benchmarks").then(({ FrontendBenchmarks }) => {
                new FrontendBenchmarks().recordMonacoMount(mountEnd - mountStart);
            });

            // Initial model
            if (path) {
                const newModel = getOrCreateModel(path, value, language);
                editor.setModel(newModel);
            }

            // Handle content changes
            editor.onDidChangeModelContent(() => {
                const text = editor.getValue();
                if (onChange) onChange(text);

                // Notify backend LSP
                if (channel && path) {
                    channel.push("lsp:did_change", { path: path, text: text });
                }
            });

            // Register Completion Provider for Elixir
            monaco.languages.registerCompletionItemProvider("elixir", {
                provideCompletionItems: (model, position) => {
                    if (!channel) return { suggestions: [] };

                    return new Promise((resolve) => {
                        channel
                            .push("lsp:completion", {
                                path: path,
                                line: position.lineNumber,
                                column: position.column,
                            })
                            .receive("ok", (resp) => {
                                const suggestions = resp.items.map((item) => ({
                                    label: item.label,
                                    kind: mapKind(item.kind),
                                    detail: item.detail,
                                    documentation: item.documentation,
                                    insertText: item.label,
                                }));
                                resolve({ suggestions: suggestions });
                            })
                            .receive("error", () =>
                                resolve({ suggestions: [] }),
                            );
                    });
                },
            });
        }
    });

    onDestroy(() => {
        if (editor) {
            editor.dispose();
        }
        // Dispose all models to prevent memory leaks
        monaco.editor.getModels().forEach((m) => m.dispose());
    });

    // Listen for diagnostics from backend
    $effect(() => {
        if (channel && editor) {
            const ref = channel.on("lsp:diagnostics", (payload) => {
                const currentModel = editor.getModel();
                if (payload.path === path && currentModel) {
                    const markers = payload.diagnostics.map((diag) => ({
                        startLineNumber: diag.from.line,
                        startColumn: diag.from.col,
                        endLineNumber: diag.to.line,
                        endColumn: diag.to.col,
                        message: diag.message,
                        severity: monaco.MarkerSeverity.Error,
                    }));
                    monaco.editor.setModelMarkers(currentModel, "owner", markers);
                }
            });

            return () => {
                // cleanup diagnostics listeners if needed
            };
        }
    });

    // Watch for file/path changes (Switching Files)
    $effect(() => {
        if (editor && path) {
            const currentModel = editor.getModel();
            if (!currentModel || currentModel.uri.toString() !== `file://${path}`) {
                const newModel = getOrCreateModel(path, value, language);
                editor.setModel(newModel);
            } else if (value !== undefined && value !== editor.getValue()) {
                // If it's the same file but value changed externally (e.g. undo/redo from parent)
                editor.setValue(value);
            }
        }
    });

    // Listen for goto-line events from Go to Symbol feature
    $effect(() => {
        if (editor) {
            const handleGotoLine = (e) => {
                const line = e.detail?.line;
                if (line) {
                    editor.revealLineInCenter(line);
                    editor.setPosition({ lineNumber: line, column: 1 });
                    editor.focus();
                }
            };
            window.addEventListener("goto-line", handleGotoLine);

            const handleThemeChange = (e) => {
                const newTheme = e.detail === "light" ? "vs" : "vs-dark";
                monaco.editor.setTheme(newTheme);
            };
            window.addEventListener("theme-changed", handleThemeChange);

            return () => {
                window.removeEventListener("goto-line", handleGotoLine);
                window.removeEventListener("theme-changed", handleThemeChange);
            };
        }
    });

    function mapKind(kindAtom) {
        switch (kindAtom) {
            case "keyword":
                return monaco.languages.CompletionItemKind.Keyword;
            case "function":
                return monaco.languages.CompletionItemKind.Function;
            case "module":
                return monaco.languages.CompletionItemKind.Module;
            default:
                return monaco.languages.CompletionItemKind.Text;
        }
    }
</script>

<div class="editor-shell flex flex-col h-full w-full overflow-hidden">
    <div
        class="editor-toolbar flex items-center justify-end px-4 py-1 gap-2 bg-[var(--vscode-editorGroupHeader-tabsBackground)] border-b border-[var(--vscode-sideBar-border)]"
    >
        <button
            class="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded transition-colors {showPreview
                ? 'bg-[var(--vscode-button-background)] text-white'
                : 'bg-white/5 opacity-40 hover:opacity-100'}"
            onclick={() => (showPreview = !showPreview)}
        >
            {showPreview ? "Hide Preview" : "Math Preview"}
        </button>
    </div>

    <div class="flex-1 flex overflow-hidden">
        <div
            class="editor-container h-full {showPreview ? 'w-1/2' : 'w-full'}"
            bind:this={editorContainer}
        ></div>
        {#if showPreview}
            <div
                class="preview-container w-1/2 h-full border-l border-[var(--vscode-editorGroup-border)] bg-[var(--vscode-editor-background)] text-[var(--vscode-editor-foreground)] overflow-y-auto"
            >
                <MathPreview content={value} />
            </div>
        {/if}
    </div>
</div>

<style>
    .editor-container {
        width: 100%;
        height: 100%;
    }
</style>
