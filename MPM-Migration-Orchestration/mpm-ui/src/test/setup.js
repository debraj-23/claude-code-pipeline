import '@testing-library/jest-dom/vitest'
import { afterEach } from 'vitest'
import { cleanup } from '@testing-library/react'

// Some Node runtimes expose an experimental global `localStorage` that lacks the
// full Web Storage API (e.g. `clear`). Install a clean, spec-compliant in-memory
// implementation so the AuthContext storage logic behaves deterministically.
class MemoryStorage {
  constructor() {
    this.store = new Map()
  }
  getItem(key) {
    return this.store.has(key) ? this.store.get(key) : null
  }
  setItem(key, value) {
    this.store.set(key, String(value))
  }
  removeItem(key) {
    this.store.delete(key)
  }
  clear() {
    this.store.clear()
  }
  key(i) {
    return Array.from(this.store.keys())[i] ?? null
  }
  get length() {
    return this.store.size
  }
}

const memoryStorage = new MemoryStorage()
Object.defineProperty(globalThis, 'localStorage', {
  configurable: true,
  value: memoryStorage,
})
if (typeof window !== 'undefined') {
  Object.defineProperty(window, 'localStorage', {
    configurable: true,
    value: memoryStorage,
  })
}

// Ensure the DOM and storage are reset between tests.
afterEach(() => {
  cleanup()
  localStorage.clear()
})
