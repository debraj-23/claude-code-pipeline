import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Generated frontend runs on 5174 (5173 belongs to the reference merchant-ui).
// /api is proxied to the generated backend on 8082.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5174,
    proxy: {
      '/api': {
        target: 'http://localhost:8082',
        changeOrigin: true,
      },
    },
  },
})
