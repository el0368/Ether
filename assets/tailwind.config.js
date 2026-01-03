/** @type {import('tailwindcss').Config} */
export default {
    content: ['./src/**/*.{html,js,svelte,ts}'],
    darkMode: 'class', // Enable class-based dark mode
    theme: {
        extend: {
            colors: {
                // Semantic colors that map to CSS variables
                bg: {
                    base: 'var(--color-bg-base)',
                    surface: 'var(--color-bg-surface)',
                    highlight: 'var(--color-bg-highlight)',
                },
                text: {
                    base: 'var(--color-text-base)',
                    muted: 'var(--color-text-muted)',
                    inverted: 'var(--color-text-inverted)',
                },
                border: {
                    base: 'var(--color-border-base)',
                }
            }
        },
    },
    plugins: [],
}
