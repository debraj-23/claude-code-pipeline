import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { colors, typography } from '../styles/theme'

// Temporary scaffold page used by routes that are not yet migrated.
// Renders the shared top bar so the authenticated shell + logout flow work,
// then a clear "coming soon" notice. Replaced as each page is built out.
export default function PagePlaceholder({ title }) {
  const { username, fullName, logout } = useAuth()
  const navigate = useNavigate()

  function handleLogout() {
    logout()
    navigate('/', { replace: true })
  }

  return (
    <div style={{ minHeight: '100vh', background: '#ffffff', fontFamily: typography.fontFamily, fontSize: typography.baseFontSize }}>
      {/* Top bar — username + logout at extreme right (specs.md §7.2) */}
      <div style={{ display: 'flex', alignItems: 'center', padding: '6px 12px', background: colors.topBarBackground }}>
        <span style={{ marginLeft: 'auto', marginRight: '14px' }}>
          Username: {fullName || username}
        </span>
        <a
          href="#logout"
          onClick={(e) => { e.preventDefault(); handleLogout() }}
          style={{ color: colors.primaryGreen, textDecoration: 'none', fontWeight: 'bold' }}
        >
          Logout
        </a>
      </div>

      {/* Green separator line */}
      <div style={{ height: '3px', background: colors.primaryGreen }} />

      <div style={{ padding: '40px', textAlign: 'center', color: '#555555' }}>
        <h2 style={{ color: colors.primaryGreen, fontSize: typography.pageTitleSize, marginBottom: '8px' }}>
          {title}
        </h2>
        <p>This screen is part of a later migration step.</p>
      </div>
    </div>
  )
}
