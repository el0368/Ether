<script>
  import VscodeIcon from '../../ui/VscodeIcon.svelte';
</script>

<div class="activitybar-container">
  <div class="top-items">
    <div class="item active">
      <VscodeIcon name="files" size={24} />
    </div>
    <div class="item">
      <VscodeIcon name="search" size={24} />
    </div>
    <div class="item">
      <VscodeIcon name="source-control" size={24} />
    </div>
    <div class="item">
      <VscodeIcon name="extensions" size={24} />
    </div>
  </div>
  <div class="bottom-items">
    <div class="item">
      <VscodeIcon name="account" size={24} />
    </div>
    <div class="item">
      <VscodeIcon name="settings-gear" size={24} />
    </div>
  </div>
</div>

<style>
  .activitybar-container {
    height: 100%;
    width: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    background-color: var(--vscode-activityBar-background);
    padding: 10px 0;
  }

  .item {
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0.6;
    cursor: pointer;
    border-left: 2px solid transparent;
  }

  .item:hover { opacity: 1; }
  .item.active { opacity: 1; border-left-color: var(--vscode-activityBar-foreground); }
</style>
