<script>
  let { channel, onClear = () => {}, onClose = () => {} } = $props();

  let history = $state([]);
  let input = $state("");
  let container;

  function handleKeydown(e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      execute();
    }
  }

  function execute() {
    if (!channel || !input.trim()) return;

    const cmdLine = input.trim();
    const parts = cmdLine.split(" ");
    const cmd = parts[0];
    const args = parts.slice(1);

    // Add to history
    history = [...history, { type: "in", text: "> " + cmdLine }];
    input = "";

    // Platform specific adjustment for tests but in UI we assume simple commands
    // We should probably route this through a smarter parser, but for now:
    let finalCmd = cmd;
    let finalArgs = args;

    // Windows hack for basic commands if needed, but CommandAgent is raw system
    // Let's just send it raw and let the user type `cmd /c dir` if they want.

    channel
      .push("cmd:exec", { cmd: finalCmd, args: finalArgs })
      .receive("ok", (resp) => {
        history = [...history, { type: "out", text: resp.output }];
        scrollToBottom();
      })
      .receive("error", (resp) => {
        history = [
          ...history,
          { type: "err", text: "Error: " + (resp.reason || "Unknown") },
        ];
        scrollToBottom();
      });
  }

  function clear() {
    history = [];
    onClear();
  }

  function scrollToBottom() {
    setTimeout(() => {
      if (container) container.scrollTop = container.scrollHeight;
    }, 10);
  }
</script>

<div
  class="flex flex-col flex-1 min-h-0 bg-[var(--vscode-terminal-background)] font-mono text-[11px] text-[var(--vscode-terminal-foreground)]"
>
  <div
    class="flex items-center px-4 py-1.5 bg-[var(--vscode-panel-background)] border-b border-[var(--vscode-panel-border)] justify-between"
  >
    <div class="flex items-center gap-4 h-full">
      <span class="text-[9px] font-black uppercase tracking-[0.2em] opacity-40 border-b border-[var(--vscode-focusBorder)] h-full flex items-center"
        >Terminal</span
      >
      <span class="text-[9px] font-black uppercase tracking-[0.2em] opacity-40 hover:opacity-80 cursor-pointer h-full flex items-center">Output</span>
      <span class="text-[9px] font-black uppercase tracking-[0.2em] opacity-40 hover:opacity-80 cursor-pointer h-full flex items-center">Problems</span>
    </div>

    <div class="flex items-center gap-2">
      <button class="opacity-40 hover:opacity-100 p-1 hover:bg-white/10 rounded transition-colors" onclick={clear} title="Clear Terminal">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" x2="10" y1="11" y2="17"/><line x1="14" x2="14" y1="11" y2="17"/></svg>
      </button>
      <button class="opacity-40 hover:opacity-100 p-1 hover:bg-white/10 rounded transition-colors" onclick={onClose} title="Close Panel">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="M6 6l12 12"/></svg>
      </button>
    </div>
  </div>
  <div bind:this={container} class="flex-1 overflow-auto p-3 leading-relaxed">
    {#each history as line}
      <div
        class:text-rose-500={line.type === "err"}
        class:text-blue-400={line.type === "in"}
        class:font-bold={line.type === "in"}
        class="whitespace-pre-wrap mb-1 tracking-tight"
      >
        {line.text}
      </div>
    {/each}
  </div>
  <div class="flex p-3 bg-base-200/50 items-center gap-3">
    <span class="text-blue-500 font-bold opacity-60">❯</span>
    <input
      type="text"
      class="flex-1 bg-transparent outline-none text-base-content border-none p-0 focus:ring-0 placeholder:opacity-20"
      bind:value={input}
      onkeydown={handleKeydown}
      placeholder="Execute system command..."
    />
  </div>
</div>
