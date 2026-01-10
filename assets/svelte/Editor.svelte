<script>
  import { onMount, onDestroy } from 'svelte';
  import * as monaco from 'monaco-editor';

  let { active_file = null, content = "", language = "elixir", live } = $props();
  let container;
  let editor;
  let debounceTimer;

  $effect(() => {
    if (editor && active_file) {
      const model = monaco.editor.createModel(content, language, monaco.Uri.parse(`file://${active_file.path}`));
      editor.setModel(model);
    }
  });

  onMount(async () => {
    editor = monaco.editor.create(container, {
      value: content,
      language: language,
      theme: "vs-dark",
      automaticLayout: true,
      minimap: { enabled: false },
      fontSize: 13,
      lineHeight: 20,
      fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
      fontLigatures: true,
      scrollBeyondLastLine: false,
      renderLineHighlight: "all"
    });

    editor.onDidChangeModelContent(() => {
      if (debounceTimer) clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => {
        const text = editor.getValue();
        live.pushEvent("editor_change", { text });
      }, 500); // Faster debounce for Svelte
    });
  });

  onDestroy(() => {
    if (editor) editor.dispose();
  });
</script>

<div class="flex-1 flex flex-col min-w-0 bg-[#1e1e1e]">
  <div class="flex-1 relative">
    {#if !active_file}
      <div class="h-full flex flex-col items-center justify-center gap-8 opacity-40 select-none pointer-events-none absolute inset-0 z-10">
        <img src="/images/logo.png" class="w-32 h-32" alt="Ether Logo" />
        <div class="flex flex-col items-center gap-2 text-[#cccccc] text-sm italic font-light tracking-widest text-center">
          <span>ctrl + p to search files</span> 
          <span>ctrl + shift + f to search text</span>
          <span>ctrl + \ to split editor</span>
        </div>
      </div>
    {/if}
    <div bind:this={container} class="h-full w-full"></div>
  </div>
</div>
