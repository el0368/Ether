import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import path from 'path'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
    plugins: [
        tailwindcss(),
        svelte()
    ],
    build: {
        outDir: '../priv/static',
        emptyOutDir: true,
        manifest: false,
        rollupOptions: {
            input: {
                app: path.resolve(__dirname, 'src/main.js')
            },
            output: {
                entryFileNames: 'js/[name].js',
                chunkFileNames: 'js/[name]-[hash].js',
                assetFileNames: (assetInfo) => {
                    if (assetInfo.name.endsWith('.css')) {
                        return 'css/[name][extname]'
                    }
                    return 'assets/[name]-[hash][extname]'
                }
            }
        }
    },
    resolve: {
        alias: {
            '@': path.resolve(__dirname, 'src')
        }
    }
})
