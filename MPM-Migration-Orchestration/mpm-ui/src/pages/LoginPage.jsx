import { useState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import ErrorBanner from '../components/ErrorBanner'
import api from '../api/axios'
import { colors, typography } from '../styles/theme'

// ─── Styles (login layout from specs.md §7.1, colours from §9) ───────────────

const styles = {
  page: {
    minHeight: '100vh',
    background: '#ffffff',
    fontFamily: typography.fontFamily,
    fontSize: typography.baseFontSize,
    display: 'flex',
    flexDirection: 'column',
  },

  // Top title bar — "Login to Merchant Profile Manager" + gray separator
  topBar: {
    padding: '6px 10px',
    fontSize: '12px',
    color: '#555555',
    borderBottom: '1px solid #cccccc',
    background: '#ffffff',
  },

  // Wrapper to horizontally center the card
  cardWrapper: {
    display: 'flex',
    justifyContent: 'center',
    paddingTop: '80px',
  },

  // Card: white background with green border (specs.md §7.1)
  card: {
    width: '480px',
    background: '#ffffff',
    border: `1px solid ${colors.primaryGreen}`,
    padding: '28px 36px 32px',
  },

  // "Merchant Profile Manager" title inside card — green, centered
  title: {
    color: colors.primaryGreen,
    fontSize: '16px',
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: '22px',
    fontFamily: typography.fontFamily,
  },

  // Form table — label col + input col, no cell borders
  formTable: {
    width: '100%',
    borderCollapse: 'collapse',
    marginBottom: '18px',
  },

  labelCell: {
    width: '110px',
    paddingRight: '10px',
    paddingBottom: '12px',
    fontWeight: 'bold',
    textAlign: 'right',
    verticalAlign: 'middle',
    color: '#333333',
    whiteSpace: 'nowrap',
  },

  inputCell: {
    paddingBottom: '12px',
    verticalAlign: 'middle',
  },

  input: {
    width: '240px',
    padding: '4px 6px',
    border: `1px solid ${colors.inputBorderNormal}`,
    fontFamily: typography.fontFamily,
    fontSize: typography.baseFontSize,
    background: '#ffffff',
    outline: 'none',
  },

  // Button row — centered
  buttonRow: {
    display: 'flex',
    justifyContent: 'center',
  },

  // Login button — green background, white text (specs.md §7.1)
  loginButton: {
    background: colors.primaryGreen,
    color: '#ffffff',
    border: `1px solid ${colors.primaryGreen}`,
    fontFamily: typography.fontFamily,
    fontSize: typography.baseFontSize,
    fontWeight: 'bold',
    padding: '5px 28px',
    cursor: 'pointer',
  },

  loginButtonDisabled: {
    background: '#aaaaaa',
    color: '#ffffff',
    border: '1px solid #aaaaaa',
    fontFamily: typography.fontFamily,
    fontSize: typography.baseFontSize,
    fontWeight: 'bold',
    padding: '5px 28px',
    cursor: 'not-allowed',
  },
}

// ─── Component ────────────────────────────────────────────────────────────────

export default function LoginPage() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError]       = useState('')
  const [loading, setLoading]   = useState(false)

  const { login } = useAuth()
  const navigate  = useNavigate()
  const location  = useLocation()

  // If redirected here by ProtectedRoute, return the user to their target page.
  const from = location.state?.from?.pathname || '/home'

  async function handleSubmit(e) {
    e.preventDefault()
    setError('')
    if (!username.trim() || !password.trim()) {
      setError('Invalid username or password.')
      return
    }
    setLoading(true)
    try {
      const { data } = await api.post('/auth/login', { username, password })
      login(data)                          // store token + role in AuthContext
      navigate(from, { replace: true })    // §7.1: on success → redirect to /home
    } catch {
      setError('Invalid username or password.') // §7.1: exact failure message
    } finally {
      setLoading(false)
    }
  }

  function handleInputFocus(e) {
    e.target.style.borderColor = colors.inputBorderFocused
  }

  function handleInputBlur(e) {
    e.target.style.borderColor = colors.inputBorderNormal
  }

  return (
    <div style={styles.page}>

      {/* Top title bar */}
      <div style={styles.topBar}>
        Login to Merchant Profile Manager
      </div>

      {/* Centered card */}
      <div style={styles.cardWrapper}>
        <div style={styles.card}>

          {/* Card title */}
          <h1 style={styles.title}>Merchant Profile Manager</h1>

          {/* Error message — shown only on failed login */}
          <ErrorBanner message={error} style={{ marginBottom: '14px' }} />

          <form onSubmit={handleSubmit} noValidate>
            <table style={styles.formTable}>
              <tbody>
                <tr>
                  <td style={styles.labelCell}>Login ID</td>
                  <td style={styles.inputCell}>
                    <input
                      type="text"
                      value={username}
                      onChange={e => setUsername(e.target.value)}
                      onFocus={handleInputFocus}
                      onBlur={handleInputBlur}
                      style={styles.input}
                      autoComplete="username"
                      required
                    />
                  </td>
                </tr>
                <tr>
                  <td style={styles.labelCell}>Password</td>
                  <td style={styles.inputCell}>
                    <input
                      type="password"
                      value={password}
                      onChange={e => setPassword(e.target.value)}
                      onFocus={handleInputFocus}
                      onBlur={handleInputBlur}
                      style={styles.input}
                      autoComplete="current-password"
                      required
                    />
                  </td>
                </tr>
              </tbody>
            </table>

            <div style={styles.buttonRow}>
              <button
                type="submit"
                disabled={loading}
                style={loading ? styles.loginButtonDisabled : styles.loginButton}
              >
                {loading ? 'Logging in…' : 'Login'}
              </button>
            </div>
          </form>

        </div>
      </div>
    </div>
  )
}
