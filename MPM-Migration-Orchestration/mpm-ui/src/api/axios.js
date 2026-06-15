import axios from 'axios'

const STORAGE_KEY = 'mpm_auth'

// Centralised axios instance. baseURL is /api so the Vite dev proxy
// (vite.config.js) forwards requests to the backend on :8082.
const api = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json' },
})

// Attach JWT Bearer token from localStorage on every request.
api.interceptors.request.use((config) => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    const auth = raw ? JSON.parse(raw) : null
    if (auth?.token) {
      config.headers.Authorization = `Bearer ${auth.token}`
    }
  } catch {
    // storage parse error — proceed without token
  }
  return config
})

// Redirect to login on 401 (but not for the login request itself).
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const isLoginRequest = error.config?.url?.includes('/auth/login')
    if (error.response?.status === 401 && !isLoginRequest) {
      localStorage.removeItem(STORAGE_KEY)
      window.location.href = '/'
    }
    return Promise.reject(error)
  }
)

export default api
