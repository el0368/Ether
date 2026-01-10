const ActivityBarSort = {
    mounted() {
        this.el.addEventListener("dragstart", (e) => {
            const icon = e.target.closest(".activity-icon");
            if (icon) {
                e.dataTransfer.setData("text/plain", icon.dataset.panel);
                icon.classList.add("dragging");
            }
        });

        this.el.addEventListener("dragend", (e) => {
            const icon = e.target.closest(".activity-icon");
            if (icon) {
                icon.classList.remove("dragging");
            }
            this.el.querySelectorAll(".activity-icon").forEach(el => {
                el.classList.remove("drag-over-top", "drag-over-bottom");
            });
        });

        this.el.addEventListener("dragover", (e) => {
            e.preventDefault();
            const icon = e.target.closest(".activity-icon");
            if (icon && !icon.classList.contains("dragging")) {
                const rect = icon.getBoundingClientRect();
                const mid = rect.top + rect.height / 2;
                if (e.clientY < mid) {
                    icon.classList.add("drag-over-top");
                    icon.classList.remove("drag-over-bottom");
                } else {
                    icon.classList.add("drag-over-bottom");
                    icon.classList.remove("drag-over-top");
                }
            }
        });

        this.el.addEventListener("dragleave", (e) => {
            const icon = e.target.closest(".activity-icon");
            if (icon) {
                icon.classList.remove("drag-over-top", "drag-over-bottom");
            }
        });

        this.el.addEventListener("drop", (e) => {
            e.preventDefault();
            const dragPanel = e.dataTransfer.getData("text/plain");
            const targetIcon = e.target.closest(".activity-icon");
            
            if (targetIcon && dragPanel) {
                const targetPanel = targetIcon.dataset.panel;
                if (dragPanel === targetPanel) return;

                const icons = Array.from(this.el.querySelectorAll(".activity-icon"));
                const targetIndex = icons.indexOf(targetIcon);
                
                const rect = targetIcon.getBoundingClientRect();
                const mid = rect.top + rect.height / 2;
                const finalIndex = e.clientY < mid ? targetIndex : targetIndex + 1;

                this.pushEvent("reorder_icons", { panel: dragPanel, to_index: finalIndex });
            }
        });

        // Consolidate SidebarControl logic here for ActivityBar items
        this.el.addEventListener("contextmenu", (e) => {
            e.preventDefault();
            const icon = e.target.closest(".activity-icon");
            if (icon) {
                this.pushEvent("show_context_menu", { 
                    panel: icon.dataset.panel, 
                    x: e.clientX, 
                    y: e.clientY 
                });
            }
        });

        this.el.addEventListener("click", (e) => {
            const icon = e.target.closest(".activity-icon");
            if (icon) {
                this.pushEvent("set_sidebar", { panel: icon.dataset.panel });
            }
        });
    }
}

export default ActivityBarSort;
