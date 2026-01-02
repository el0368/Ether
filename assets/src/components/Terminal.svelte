<script>
  let { channel } = $props();

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

  function scrollToBottom() {
    setTimeout(() => {
      if (container) container.scrollTop = container.scrollHeight;
    }, 10);
  }
</script>

<div
  class="flex flex-col h-56 border-t border-white/5 bg-[#0d0f14] font-mono text-[11px] text-slate-400"
>
  <div
    class="flex items-center px-4 py-1.5 bg-[#12151c] border-b border-white/5"
  >
    <span class="text-[9px] font-black uppercase tracking-[0.2em] opacity-40"
      >Integrated Terminal</span
    >
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
  <div class="flex p-3 bg-[#12151c]/50 items-center gap-3">
    <span class="text-blue-500 font-bold opacity-60">❯</span>
    <input
      type="text"
      class="flex-1 bg-transparent outline-none text-slate-200 border-none p-0 focus:ring-0 placeholder:opacity-20"
      bind:value={input}
      onkeydown={handleKeydown}
      placeholder="Execute system command..."
    />
  </div>
</div>
