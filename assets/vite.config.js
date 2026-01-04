import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import path from 'path'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
    plugins: [
        tailwindcss(),
        svelte()
    ],
    server: {
        port: 5173,
        strictPort: true,
        watch: {
            ignored: ['**/_build/**', '**/deps/**', '**/node_modules/**', '**/.git/**']
        }
    },
    optimizeDeps: {
        include: ['phoenix', 'phoenix_live_view', 'phoenix_html'],
        exclude: ['@tauri-apps/api']
    },
    build: {
        target: 'esnext',
        minify: false,
        sourcemap: true,
        outDir: '../priv/static',
        emptyOutDir: true,
        manifest: false,
        rollupOptions: {
            input: {
                // Point to index.html so it includes the dark mode script & loader
                app: path.resolve(__dirname, 'index.html')
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
        },
        resolve: {
            alias: {
                '@': path.resolve(__dirname, 'src')
            }
        }
    }
});
