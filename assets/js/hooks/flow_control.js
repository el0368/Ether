const FlowControl = {
  mounted() {
    this.handleEvent("flow_sync", () => {
      // "Frame-Awareness": Wait for the browser to paint the current frame
      requestAnimationFrame(() => {
        // Double RAF ensuring layout + paint are complete
        requestAnimationFrame(() => {
          this.pushEvent("flow_ack", {});
        });
      });
    });
  }
};

export default FlowControl;
