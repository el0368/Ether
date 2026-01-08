<script>
    import { onMount } from "svelte";
    import katex from "katex";
    import "katex/dist/katex.min.css";

    let { content = "" } = $props();

    let displayElement;

    $effect(() => {
        if (displayElement && content) {
            try {
                // Find all LaTeX patterns: $...$ or $$...$$
                // This is a simple implementation that renders the whole string as markdown-like with math support
                // For a true "Math Studio", we want to detect formulas and render them
                
                let html = content
                    .replace(/\$\$([\s\S]+?)\$\$/g, (match, formula) => {
                        return katex.renderToString(formula, { displayMode: true, throwOnError: false });
                    })
                    .replace(/\$([\s\S]+?)\$/g, (match, formula) => {
                        return katex.renderToString(formula, { displayMode: false, throwOnError: false });
                    });

                displayElement.innerHTML = html;
            } catch (e) {
                console.error("KaTeX Error:", e);
                displayElement.textContent = content;
            }
        } else if (displayElement) {
            displayElement.textContent = "";
        }
    });
</script>

<div class="math-preview-container bg-[var(--vscode-editor-background)] text-[var(--vscode-editor-foreground)] overflow-auto p-8 selection:bg-[var(--vscode-selection-background)]">
    <div bind:this={displayElement} class="prose prose-invert max-w-none"></div>
</div>

<style>
    .math-preview-container {
        width: 100%;
        height: 100%;
        font-family: var(--font-sans);
        line-height: 1.6;
    }

    :global(.prose) {
        font-size: 15px;
    }

    :global(.prose h1) {
        border-bottom: 1px solid var(--vscode-sideBar-border);
        padding-bottom: 0.3em;
        margin-top: 0;
    }

    :global(.prose p) {
        margin-top: 1em;
        margin-bottom: 1em;
    }
</style>
