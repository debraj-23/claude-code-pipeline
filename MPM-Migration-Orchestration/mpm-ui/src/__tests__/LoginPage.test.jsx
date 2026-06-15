import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from '../context/AuthContext'
import LoginPage from '../pages/LoginPage'

// Mock the centralised axios instance.
vi.mock('../api/axios', () => ({
  default: { post: vi.fn(), get: vi.fn(), put: vi.fn() },
}))
import api from '../api/axios'

const STORAGE_KEY = 'mpm_auth'

function renderLogin() {
  return render(
    <AuthProvider>
      <MemoryRouter initialEntries={['/']}>
        <Routes>
          <Route path="/" element={<LoginPage />} />
          <Route path="/home" element={<div>HOME PAGE</div>} />
        </Routes>
      </MemoryRouter>
    </AuthProvider>,
  )
}

describe('LoginPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorage.clear()
  })

  it('logs in successfully, stores auth and redirects to /home', async () => {
    const user = userEvent.setup()
    const authData = { token: 'jwt-123', username: 'admin', role: 'ADMIN', fullName: 'Admin User' }
    api.post.mockResolvedValueOnce({ data: authData })

    const { container } = renderLogin()

    const loginId = screen.getByRole('textbox')
    const password = container.querySelector('input[type="password"]')
    await user.type(loginId, 'admin')
    await user.type(password, 'secret')
    await user.click(screen.getByRole('button', { name: 'Login' }))

    // Posts to the auth endpoint with the credentials.
    expect(api.post).toHaveBeenCalledWith('/auth/login', {
      username: 'admin',
      password: 'secret',
    })

    // Redirects to /home on success.
    expect(await screen.findByText('HOME PAGE')).toBeInTheDocument()

    // Auth payload persisted to localStorage.
    expect(JSON.parse(localStorage.getItem(STORAGE_KEY))).toEqual(authData)
  })

  it('shows "Invalid username or password." when the API rejects', async () => {
    const user = userEvent.setup()
    api.post.mockRejectedValueOnce({ response: { status: 401 } })

    const { container } = renderLogin()

    await user.type(screen.getByRole('textbox'), 'admin')
    await user.type(container.querySelector('input[type="password"]'), 'wrong')
    await user.click(screen.getByRole('button', { name: 'Login' }))

    expect(await screen.findByText('Invalid username or password.')).toBeInTheDocument()
    // Did not navigate away / store auth.
    expect(screen.queryByText('HOME PAGE')).not.toBeInTheDocument()
    expect(localStorage.getItem(STORAGE_KEY)).toBeNull()
  })

  it('validates empty credentials without calling the API', async () => {
    const user = userEvent.setup()
    renderLogin()

    await user.click(screen.getByRole('button', { name: 'Login' }))

    expect(api.post).not.toHaveBeenCalled()
    await waitFor(() =>
      expect(screen.getByText('Invalid username or password.')).toBeInTheDocument(),
    )
  })
})
