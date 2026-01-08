import { defineConfig, mergeConfig } from 'vitest/config'
import viteConfig from './vite.config.js'

export default mergeConfig(
  viteConfig,
  defineConfig({
    test: {
      globals: true,
      // Switching to 'node' environment for pure logic tests
      // This is faster and avoids JSDOM-specific startup errors
      environment: 'jsdom',
      include: ['src/**/*.{test,spec}.{js,ts}'],
      setupFiles: ['./vitest-setup.js'],
    },
  })
)
