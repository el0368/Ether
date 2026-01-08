export class CommsState {
    channel = $state(null);
    connected = $state(false);

    setChannel(ch) {
        this.channel = ch;
        this.connected = true;
    }

    clearChannel() {
        this.channel = null;
        this.connected = false;
    }
}

export const comms = new CommsState();
