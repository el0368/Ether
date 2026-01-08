export class UIState {
    activeSidebar = $state("files");
    showPalette = $state(false);
    paletteMode = $state("files");
    isLoading = $state(false);


    openPalette(mode = "files") {
        this.paletteMode = mode;
        this.showPalette = true;
    }

    closePalette() {
        this.showPalette = false;
    }
}

export const ui = new UIState();
