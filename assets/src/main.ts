import { mount } from 'svelte'
import './app.css'
import App from './App.svelte'
import { Socket } from 'phoenix'
import './lib/performance_monitor'
import './lib/interaction_monitor'

// Monaco Worker Configuration
import editorWorker from 'monaco-editor/esm/vs/editor/editor.worker?worker'
import jsonWorker from 'monaco-editor/esm/vs/language/json/json.worker?worker'
import cssWorker from 'monaco-editor/esm/vs/language/css/css.worker?worker'
import htmlWorker from 'monaco-editor/esm/vs/language/html/html.worker?worker'
import tsWorker from 'monaco-editor/esm/vs/language/typescript/ts.worker?worker'

self.MonacoEnvironment = {
    getWorker(_, label) {
        if (label === 'json') {
            return new jsonWorker()
        }
        if (label === 'css' || label === 'scss' || label === 'less') {
            return new cssWorker()
        }
        if (label === 'html' || label === 'handlebars' || label === 'razor') {
            return new htmlWorker()
        }
        if (label === 'typescript' || label === 'javascript') {
            return new tsWorker()
        }
        return new editorWorker()
    }
}

// Establish shared socket connection
const socket = new Socket("ws://localhost:4000/socket", {
    params: { token: window.userToken || "dev_token" }
})
socket.connect()

const app = mount(App, {
    target: document.getElementById('app'),
    props: {
        socket: socket
    }
})

// Remove Loader
const loader = document.getElementById('app-loader');
if (loader) {
    loader.style.opacity = '0';
    setTimeout(() => loader.remove(), 300);
}

export default app
