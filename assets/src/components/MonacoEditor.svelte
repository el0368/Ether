<script>
    import { onMount, onDestroy } from "svelte";
    import * as monaco from "monaco-editor";

    let { value, language, theme, channel, path, onChange } = $props();

    let editorContainer;
    let editor;
    let model;

    // Initialize Monaco
    onMount(() => {
        if (editorContainer) {
            editor = monaco.editor.create(editorContainer, {
                value: value || "",
                language: language || "elixir",
                theme: theme || "vs-dark",
                automaticLayout: true,
                minimap: { enabled: false },
                fontSize: 14,
                fontFamily:
                    "'JetBrains Mono', 'Fira Code', Consolas, monospace",
                scrollBeyondLastLine: false,
            });

            model = editor.getModel();

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
                                // Transform backend items to Monaco format if needed
                                // Backend sends: {label, kind, detail, documentation}
                                // Monaco expects similar structure
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
    });

    // Listen for diagnostics from backend
    $effect(() => {
        if (channel && editor) {
            const ref = channel.on("lsp:diagnostics", (payload) => {
                if (payload.path === path) {
                    const markers = payload.diagnostics.map((diag) => ({
                        startLineNumber: diag.from.line,
                        startColumn: diag.from.col,
                        endLineNumber: diag.to.line,
                        endColumn: diag.to.col,
                        message: diag.message,
                        severity: monaco.MarkerSeverity.Error,
                    }));
                    monaco.editor.setModelMarkers(
                        editor.getModel(),
                        "owner",
                        markers,
                    );
                }
            });

            return () => {
                // channel.off("lsp:diagnostics", ref) // handling off might differ in Phoenix
            };
        }
    });

    // Watch for external value changes
    $effect(() => {
        if (editor && value !== editor.getValue()) {
            // Avoid loop if we just typed it
            // Simple check: if cursor is at end, maybe push?
            // Better: complete replace only if significantly different or forced update
            // For now, simple replace for file switching
            editor.setValue(value || "");
        }
    });

    function mapKind(kindAtom) {
        // Map ElixirSense kinds/atoms to monaco.languages.CompletionItemKind
        // Keyword = 14, Function = 2, Module = 9
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

<div class="w-full h-full overflow-hidden" bind:this={editorContainer}></div>
