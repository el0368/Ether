import * as monaco from "monaco-editor";

const MonacoEditor = {
  mounted() {
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

    this.editor.onDidChangeModelContent(() => {
      const text = this.editor.getValue();
      this.pushEvent("editor_change", { text });
    });

    this.handleEvent("load_file", ({ text, language, path }) => {
      const model = monaco.editor.createModel(text, language, monaco.Uri.parse(`file://${path}`));
      this.editor.setModel(model);
    });
  },

  destroyed() {
    if (this.editor) {
      this.editor.dispose();
    }
  }
};

export default MonacoEditor;
