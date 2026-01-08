<script>
  let { orientation = 'vertical', onResize } = $props();
  
  let dragging = $state(false);
  let startX = $state(0);
  let startY = $state(0);

  function handlePointerDown(e) {
    dragging = true;
    startX = e.clientX;
    startY = e.clientY;
    document.body.style.cursor = orientation === 'vertical' ? 'col-resize' : 'row-resize';
    window.addEventListener('pointermove', handlePointerMove);
    window.addEventListener('pointerup', handlePointerUp);
  }

  function handlePointerMove(e) {
    if (!dragging) return;
    const deltaX = e.clientX - startX;
    const deltaY = e.clientY - startY;
    onResize?.(deltaX, deltaY);
    startX = e.clientX;
    startY = e.clientY;
  }

  function handlePointerUp() {
    dragging = false;
    document.body.style.cursor = 'default';
    window.removeEventListener('pointermove', handlePointerMove);
    window.removeEventListener('pointerup', handlePointerUp);
  }
</script>

<!-- svelte-ignore a11y_no_static_element_interactions -->
<div 
  class="sash {orientation}" 
  class:active={dragging}
  onpointerdown={handlePointerDown}
></div>

<style>
  .sash {
    position: absolute;
    z-index: 100;
    transition: background-color 0.2s;
  }

  .sash.vertical {
    top: 0;
    bottom: 0;
    width: 4px;
    cursor: col-resize;
    right: -2px;
  }

  .sash.horizontal {
    left: 0;
    right: 0;
    height: 4px;
    cursor: row-resize;
    top: -2px;
  }

  .sash:hover, .sash.active {
    background-color: var(--vscode-sash-hoverBorder, #007fd4);
  }
</style>
