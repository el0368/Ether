export class UIState {
    sidebarVisible = $state(true);
    terminalVisible = $state(true);
    activeSidebar = $state("files");
    showPalette = $state(false);
    paletteMode = $state("files");
    isLoading = $state(false);

    toggleSidebar(section) {
        if (this.activeSidebar === section && this.sidebarVisible) {
            this.sidebarVisible = false;
        } else {
            this.activeSidebar = section;
            this.sidebarVisible = true;
        }
    }

    toggleTerminal() {
        this.terminalVisible = !this.terminalVisible;
    }

    openPalette(mode = "files") {
        this.paletteMode = mode;
        this.showPalette = true;
    }

    closePalette() {
        this.showPalette = false;
    }
}

export const ui = new UIState();
