<script>
  export let name = "";
  export let size = 16;
  export let color = "currentColor";
</script>

<i 
  class="codicon codicon-{name}" 
  style="font-size: {size}px; color: {color};"
></i>

<style>
  @font-face {
    font-family: 'codicon';
    src: url('/fonts/codicon.ttf') format('truetype');
  }

  .codicon {
    font-family: 'codicon';
    display: inline-block;
    font-style: normal;
    font-weight: normal;
    font-variant: normal;
    text-transform: none;
    line-height: 1;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }
</style>
