import { createContext, useContext, useState, useCallback } from 'react'

const AuthContext = createContext(null)

const STORAGE_KEY = 'mpm_auth'

function loadFromStorage() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export function AuthProvider({ children }) {
  const [auth, setAuth] = useState(() => loadFromStorage())

  // Called after a successful POST /api/auth/login.
  // data: { token, username, role, fullName }
  const login = useCallback((data) => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
    setAuth(data)
  }, [])

  const logout = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY)
    setAuth(null)
  }, [])

  const value = {
    token:    auth?.token    ?? null,
    username: auth?.username ?? null,
    role:     auth?.role     ?? null,     // 'ADMIN' | 'USER'
    fullName: auth?.fullName ?? null,
    isAdmin:  auth?.role === 'ADMIN',
    isAuthenticated: !!auth?.token,
    login,
    logout,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>')
  return ctx
}
