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

    channel.push("refactor:rename", {
      code: code,
      old_name: oldName,
      new_name: newName
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
  <div class="modal modal-open">
    <div class="modal-box">
      <h3 class="font-bold text-lg">Sidebar Refactor</h3>
      <p class="py-4">Rename <code class="badge badge-neutral">{oldName}</code> to:</p>
      
      <div class="form-control w-full">
        <input 
          type="text" 
          bind:value={newName} 
          class="input input-bordered w-full" 
          placeholder="New variable name"
          disabled={loading}
        />
      </div>

      {#if error}
        <div class="alert alert-error mt-4 shadow-lg">
          <span>{error}</span>
        </div>
      {/if}

      <div class="modal-action">
        <button class="btn" onclick={onClose} disabled={loading}>Cancel</button>
        <button class="btn btn-primary" onclick={handleRename} disabled={loading}>
          {#if loading}
            <span class="loading loading-spinner"></span>
          {/if}
          Rename
        </button>
      </div>
    </div>
  </div>
{/if}
