import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

// Vitest config for the generated frontend unit tests.
// jsdom environment + React Testing Library, mirroring merchant-ui conventions.
export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.js',
    css: false,
    include: ['src/**/*.test.{js,jsx}'],
  },
})
