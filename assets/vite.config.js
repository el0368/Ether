import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import path from 'path'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
    plugins: [
        tailwindcss(),
        svelte({
            onwarn: (warning, handler) => {
                // Suppress a11y warnings that cause Vite to crash (handles Svelte 4/5 variations)
                if (warning.code && warning.code.includes('a11y')) return;
                handler(warning);
            }
        })
    ],
    server: {
        port: 5173,
        strictPort: true,
        watch: {
            ignored: ['**/_build/**', '**/deps/**', '**/node_modules/**', '**/.git/**']
        },
        proxy: {
            '/socket': {
                target: 'http://127.0.0.1:4000',
                ws: true
            }
        }
    },
    optimizeDeps: {
        include: ['phoenix', 'phoenix_live_view', 'phoenix_html'],
        exclude: ['@tauri-apps/api']
    },
    resolve: {
        alias: {
            '@': path.resolve(__dirname, './src'),
            '$lib': path.resolve(__dirname, './src/lib')
        }
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
        }
    }
});
