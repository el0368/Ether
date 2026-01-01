// Aether IDE - Main Entry Point
import { mount } from 'svelte'
import App from './App.svelte'
import { Socket } from 'phoenix'

// Connect to Phoenix socket
const socket = new Socket("/socket", {
    params: { token: window.userToken || "dev_token" }
})
socket.connect()

// Export socket for use in components
window.aetherSocket = socket

// Mount Svelte app
const app = mount(App, {
    target: document.getElementById('app'),
    props: {
        socket: socket
    }
})

export default app
