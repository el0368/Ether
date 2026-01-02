<script>
  let { channel } = $props();

  let status = $state("Unknown");
  let output = $state("");
  let commitMsg = $state("");
  let loading = $state(false);

  function checkStatus() {
    if (!channel) return;
    loading = true;
    channel.push("git:status", {})
      .receive("ok", resp => {
        status = resp.status;
        loading = false;
      })
      .receive("error", resp => {
        output = "Error: " + (resp.reason || "Unknown");
        loading = false;
      });
  }

  function handleCommit() {
    if (!channel || !commitMsg) return;
    loading = true;
    
    // First add all
    channel.push("git:add", {path: ".", files: ["."]})
      .receive("ok", _ => {
        // Then commit
        channel.push("git:commit", {path: ".", message: commitMsg})
          .receive("ok", resp => {
            output = resp.output;
            commitMsg = "";
            loading = false;
            checkStatus(); // Refresh status
          })
          .receive("error", resp => {
             output = "Commit Error: " + (resp.reason || "Unknown");
             loading = false;
          });
      })
      .receive("error", resp => {
        output = "Add Error: " + (resp.reason || "Unknown");
        loading = false;
      });
  }

  // Check status on mount
  $effect(() => {
    if (channel) {
      checkStatus();
    }
  });
</script>

<div class="flex flex-col h-full p-4 bg-base-200 text-base-content">
  <div class="flex justify-between items-center mb-4">
    <h2 class="font-bold">Source Control</h2>
    <button class="btn btn-xs btn-ghost" onclick={checkStatus} title="Refresh">🔄</button>
  </div>

  <div class="flex-1 overflow-auto bg-base-300 rounded p-2 mb-4 font-mono text-xs whitespace-pre">
    {status}
  </div>

  <div class="form-control gap-2">
    <textarea 
      class="textarea textarea-bordered h-24" 
      placeholder="Commit message"
      bind:value={commitMsg}
    ></textarea>
    <button 
      class="btn btn-primary btn-sm" 
      disabled={loading || !commitMsg} 
      onclick={handleCommit}
    >
      {loading ? 'Processing...' : 'Commit All'}
    </button>
  </div>
  
  {#if output}
    <div class="mt-4 p-2 bg-black text-green-400 font-mono text-xs rounded overflow-auto max-h-32">
      {output}
    </div>
  {/if}
</div>
