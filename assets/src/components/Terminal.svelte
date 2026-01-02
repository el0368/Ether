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
    history = [...history, { type: 'in', text: "> " + cmdLine }];
    input = "";

    // Platform specific adjustment for tests but in UI we assume simple commands
    // We should probably route this through a smarter parser, but for now:
    let finalCmd = cmd;
    let finalArgs = args;

    // Windows hack for basic commands if needed, but CommandAgent is raw system
    // Let's just send it raw and let the user type `cmd /c dir` if they want.
    
    channel.push("cmd:exec", {cmd: finalCmd, args: finalArgs})
      .receive("ok", resp => {
        history = [...history, { type: 'out', text: resp.output }];
        scrollToBottom();
      })
      .receive("error", resp => {
        history = [...history, { type: 'err', text: "Error: " + (resp.reason || "Unknown") }];
        scrollToBottom();
      });
  }

  function scrollToBottom() {
    setTimeout(() => {
      if(container) container.scrollTop = container.scrollHeight;
    }, 10);
  }
</script>

<div class="flex flex-col h-48 border-t border-base-300 bg-black font-mono text-sm text-gray-300">
  <div bind:this={container} class="flex-1 overflow-auto p-2 scrollbar-thin">
    {#each history as line}
      <div class:text-red-400={line.type === 'err'} class:text-yellow-400={line.type === 'in'} class="whitespace-pre-wrap mb-1">{line.text}</div>
    {/each}
  </div>
  <div class="flex p-2 bg-gray-900">
    <span class="mr-2 text-green-500">$</span>
    <input 
      type="text" 
      class="flex-1 bg-transparent outline-none text-white border-none p-0 focus:ring-0"
      bind:value={input}
      onkeydown={handleKeydown}
      placeholder="Try 'echo hello'..."
    />
  </div>
</div>
