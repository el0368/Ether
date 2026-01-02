<script>
  let { isOpen, code, oldName, channel, onClose, onSuccess } = $props();

  let newName = $state("");
  let error = $state(null);
  let loading = $state(false);

  // Reset state when modal opens
  $effect(() => {
    if (isOpen) {
      newName = oldName;
      error = null;
    }
  });

  function handleRename() {
    if (!channel) {
      error = "Not connected to server";
      return;
    }
    if (!newName) {
      error = "Name cannot be empty";
      return;
    }

    loading = true;
    error = null;

    channel
      .push("refactor:rename", {
        code: code,
        old_name: oldName,
        new_name: newName,
      })
      .receive("ok", (resp) => {
        loading = false;
        onSuccess(resp.code);
        onClose();
      })
      .receive("error", (resp) => {
        loading = false;
        error = resp.reason || "Unknown error";
      });
  }
</script>

{#if isOpen}
  <!-- Overlay -->
  <div
    class="fixed inset-0 bg-black/50 z-[60] flex justify-center pt-24"
    onclick={onClose}
  >
    <!-- Modal -->
    <div
      class="w-full max-w-md bg-[#252526] border border-white/10 shadow-2xl rounded-md flex flex-col h-fit overflow-hidden"
      onclick={(e) => e.stopPropagation()}
    >
      <div class="p-4 border-b border-white/5 bg-[#1e1e1e]/50">
        <h3 class="text-sm font-bold text-[#cccccc] flex items-center gap-2">
          <span class="text-primary">🔨</span> Rename Symbol
        </h3>
      </div>

      <div class="p-6 flex flex-col gap-4">
        <div class="text-xs text-[#cccccc]/60">
          Enter a new name for the symbol <code
            class="bg-black/20 px-1 py-0.5 rounded text-white">{oldName}</code
          >
        </div>

        <div class="flex flex-col gap-2">
          <input
            type="text"
            bind:value={newName}
            class="bg-[#3c3c3c] text-white border border-transparent focus:border-primary outline-none px-4 py-2 text-sm rounded-sm"
            placeholder="New name..."
            disabled={loading}
            id="refactor-input"
          />
        </div>

        {#if error}
          <div
            class="text-xs text-rose-500 bg-rose-500/10 p-2 border border-rose-500/20 rounded-sm"
          >
            {error}
          </div>
        {/if}
      </div>

      <div
        class="p-3 bg-[#1e1e1e]/50 border-t border-white/5 flex justify-end gap-2"
      >
        <button
          class="px-4 py-1.5 text-xs text-[#cccccc] hover:bg-white/5 rounded-sm transition-colors"
          onclick={onClose}
          disabled={loading}>Cancel</button
        >
        <button
          class="px-4 py-1.5 text-xs bg-primary text-white hover:bg-primary/80 rounded-sm transition-colors flex items-center gap-2"
          onclick={handleRename}
          disabled={loading}
        >
          {#if loading}
            <span class="loading loading-spinner loading-xs text-white"></span>
          {/if}
          Rename
        </button>
      </div>
    </div>
  </div>
{/if}
