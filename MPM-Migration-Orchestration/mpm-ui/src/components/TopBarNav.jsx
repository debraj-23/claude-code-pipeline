import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { colors, typography } from '../styles/theme'

// ─── Shared application shell (specs.md §7.2 / §9) ───────────────────────────
// Renders the white top bar ("Username: {name}" + Logout at the extreme right),
// the 3px green separator line, and the Merchant | Organization tab strip.
//
// Reused by MerchantPage, OrganisationSearchPage and EditBasicDetailsPage.
//
// Props:
//   activeTab  — 'merchant' | 'organization' | null
//                Highlights the matching tab. Pass null to hide the tab strip
//                entirely (e.g. the Edit Basic Details form has no nav tabs).

const styles = {
  topBar: {
    display: 'flex',
    alignItems: 'center',
    padding: '6px 12px',
    background: colors.topBarBackground,
  },
  topBarRightText: {
    marginLeft: 'auto',
    marginRight: '14px',
    color: '#333333',
  },
  logoutLink: {
    color: colors.primaryGreen,
    textDecoration: 'none',
    fontWeight: 'bold',
  },
  separator: {
    height: '3px',
    background: colors.primaryGreen,
  },
  tabStrip: {
    display: 'flex',
    flexDirection: 'row',
    flexWrap: 'nowrap',
    background: colors.navTabBackground,
  },
  tabBase: {
    padding: '6px 22px',
    fontFamily: typography.fontFamily,
    fontSize: typography.baseFontSize,
    cursor: 'pointer',
    border: 'none',
    borderRight: '1px solid #cccccc',
    background: colors.navTabBackground,
    color: '#333333',
  },
  tabActive: {
    background: colors.activeTabBackground,
    borderBottom: `2px solid ${colors.primaryGreen}`,
    fontWeight: 'bold',
    color: colors.primaryGreen,
  },
}

export default function TopBarNav({ activeTab = null }) {
  const { username, fullName, logout } = useAuth()
  const navigate = useNavigate()

  function handleLogout() {
    logout()
    navigate('/', { replace: true })
  }

  function tabStyle(tab) {
    return activeTab === tab
      ? { ...styles.tabBase, ...styles.tabActive }
      : styles.tabBase
  }

  return (
    <>
      {/* Top bar — username + logout at extreme right (specs.md §7.2) */}
      <div style={styles.topBar}>
        <span style={styles.topBarRightText}>
          Username: {fullName || username}
        </span>
        <a
          href="#logout"
          onClick={(e) => { e.preventDefault(); handleLogout() }}
          style={styles.logoutLink}
        >
          Logout
        </a>
      </div>

      {/* Green separator line (3px, #5a9e32) */}
      <div style={styles.separator} />

      {/* Navigation tabs — hidden when activeTab is null */}
      {activeTab !== null && (
        <div style={styles.tabStrip}>
          <button
            type="button"
            style={tabStyle('merchant')}
            onClick={() => navigate('/home')}
          >
            Merchant
          </button>
          <button
            type="button"
            style={tabStyle('organization')}
            onClick={() => navigate('/organisations')}
          >
            Organization
          </button>
        </div>
      )}
    </>
  )
}
