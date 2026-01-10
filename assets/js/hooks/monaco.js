const MonacoEditor = {
  async mounted() {
    this.el.innerHTML = '<div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #858585;">Loading Editor...</div>';
    
    try {
      // Dynamic import to unblock Main Thread on boot
      const monaco = await import("monaco-editor");
      
      // Clear loading state
      this.el.innerHTML = '';
      
      this.editor = monaco.editor.create(this.el, {
        value: this.el.dataset.value || "",
        language: this.el.dataset.language || "elixir",
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

      this.debounceTimer = null;
      this.editor.onDidChangeModelContent(() => {
        if (this.debounceTimer) clearTimeout(this.debounceTimer);
        this.debounceTimer = setTimeout(() => {
          const text = this.editor.getValue();
          this.pushEvent("editor_change", { text });
        }, 1000);
      });

      this.handleEvent("load_file", ({ text, language, path }) => {
        const model = monaco.editor.createModel(text, language, monaco.Uri.parse(`file://${path}`));
        this.editor.setModel(model);
      });
      
    } catch (err) {
      console.error("Failed to load Monaco Editor:", err);
      this.el.innerHTML = '<div style="color: #f87171; padding: 1rem;">Error loading editor. Check console.</div>';
    }
  },

  destroyed() {
    if (this.editor) {
      this.editor.dispose();
    }
  }
};

export default MonacoEditor;
