import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import TopBarNav from '../components/TopBarNav'
import ErrorBanner from '../components/ErrorBanner'
import api from '../api/axios'
import { colors, typography, inputStyle, buttonStyle } from '../styles/theme'

// ─── Organisation Search Page (specs.md §7.3 / §9) ───────────────────────────
// Reached at the protected /organisations route.
//  - Shared top bar + Merchant/Organization tab strip (Organization active)
//  - Toolbar: [Org ID / Full Name ▼][text input][Search] | Edit Basic Details
//  - Results grid (rendered only after an explicit Search)
//  - Single-row selection (highlighted green); Edit navigates to the edit form
//
// Search is EXPLICIT only (specs.md §8.5): nothing happens on keystroke — the
// backend GET /api/organisations endpoint is called only when the Search button
// (or Enter in the query field) is used. Matching is partial / case-insensitive
// and handled entirely server-side.

// Search field options (specs.md §7.3)
//   orgId    → backend matches orgId OR shortName
//   fullName → backend matches fullName
const SEARCH_FIELDS = [
  { value: 'orgId', label: 'Org ID' },
  { value: 'fullName', label: 'Full Name' },
]

// Results grid columns (specs.md §7.3)
const GRID_COLUMNS = [
  { key: 'orgId', label: 'Org ID' },
  { key: 'shortName', label: 'Short Name' },
  { key: 'fullName', label: 'Full Name' },
  { key: 'type', label: 'Type' },
  { key: 'subType', label: 'Sub Type' },
  { key: 'feeRounding', label: 'Fee Rounding' },
  { key: 'active', label: 'Active' },
]

const styles = {
  page: {
    minHeight: '100vh',
    display: 'flex',
    flexDirection: 'column',
    background: '#ffffff',
    fontFamily: typography.fontFamily,
    fontSize: typography.baseFontSize,
  },

  // Toolbar — search group on the left, actions on the right
  toolbar: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    flexWrap: 'wrap',
    gap: '6px',
    padding: '8px 12px',
    background: colors.topBarBackground,
  },
  searchGroup: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
  },
  searchSelect: {
    ...inputStyle,
    padding: '3px 4px',
    background: '#ffffff',
  },
  searchInput: {
    ...inputStyle,
    width: '200px',
  },
  toolbarSeparator: {
    width: '1px',
    alignSelf: 'stretch',
    background: colors.separatorLine,
    margin: '0 8px',
  },

  // Feedback area (loading / error)
  feedback: {
    padding: '0 12px',
  },
  loading: {
    padding: '8px 0',
    color: '#555555',
  },

  // Grid
  gridWrapper: {
    padding: '0 12px',
  },
  table: {
    width: '100%',
    borderCollapse: 'collapse',
    tableLayout: 'auto',
  },
  th: {
    background: colors.navTabBackground,
    border: '1px solid #cccccc',
    padding: '5px 8px',
    textAlign: 'left',
    fontWeight: 'bold',
    color: '#333333',
    whiteSpace: 'nowrap',
  },
  td: {
    border: '1px solid #cccccc',
    padding: '5px 8px',
    color: '#333333',
    whiteSpace: 'nowrap',
  },
  rowSelected: {
    background: colors.primaryGreen,
    color: '#ffffff',
  },
  tdSelected: {
    border: '1px solid #cccccc',
    padding: '5px 8px',
    color: '#ffffff',
    whiteSpace: 'nowrap',
  },
  emptyCell: {
    border: '1px solid #cccccc',
    padding: '24px 8px',
    textAlign: 'center',
    color: '#777777',
  },
}

export default function OrganisationSearchPage() {
  const navigate = useNavigate()

  // Controlled toolbar inputs (do NOT trigger a search on change).
  const [searchField, setSearchField] = useState('orgId')
  const [query, setQuery] = useState('')

  // Search results & request state.
  const [results, setResults] = useState([])
  const [searched, setSearched] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // Currently selected row (organisation id) for the Edit action.
  const [selectedId, setSelectedId] = useState(null)

  // Explicit search — only ever called from the Search button / Enter key.
  async function handleSearch() {
    setLoading(true)
    setError('')
    setSelectedId(null)
    try {
      const { data } = await api.get('/organisations', {
        params: { query, searchField },
      })
      setResults(Array.isArray(data) ? data : [])
      setSearched(true)
    } catch (err) {
      const message =
        err.response?.data?.message ||
        'Unable to load organisations. Please try again.'
      setError(message)
      setResults([])
      setSearched(true)
    } finally {
      setLoading(false)
    }
  }

  // Submit on Enter inside the query field (still an explicit user action).
  function handleQueryKeyDown(e) {
    if (e.key === 'Enter') {
      e.preventDefault()
      handleSearch()
    }
  }

  // Edit Basic Details — requires a selected row (specs.md §7.3 step 6).
  function handleEdit() {
    if (selectedId == null) {
      alert('Please select an organisation first.')
      return
    }
    navigate(`/organisations/${selectedId}/edit`)
  }

  function renderCell(org, columnKey) {
    const value = org[columnKey]
    if (columnKey === 'active') {
      return value ? 'Yes' : 'No'
    }
    return value == null || value === '' ? '—' : String(value)
  }

  return (
    <div style={styles.page}>
      {/* Shared top bar + Merchant/Organization tab strip (Organization active) */}
      <TopBarNav activeTab="organization" />

      {/* Toolbar — explicit search on the left, Edit action on the right */}
      <div style={styles.toolbar}>
        <div style={styles.searchGroup}>
          <select
            style={styles.searchSelect}
            value={searchField}
            onChange={(e) => setSearchField(e.target.value)}
            aria-label="Search field"
          >
            {SEARCH_FIELDS.map((field) => (
              <option key={field.value} value={field.value}>
                {field.label}
              </option>
            ))}
          </select>
          <input
            type="text"
            style={styles.searchInput}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onKeyDown={handleQueryKeyDown}
            aria-label="Search query"
          />
          <button
            type="button"
            style={
              loading
                ? { ...buttonStyle, cursor: 'not-allowed', color: '#999999' }
                : buttonStyle
            }
            onClick={handleSearch}
            disabled={loading}
          >
            Search
          </button>
        </div>

        <div style={styles.toolbarSeparator} />

        <button type="button" style={buttonStyle} onClick={handleEdit}>
          Edit Basic Details
        </button>
      </div>

      {/* Loading / error feedback */}
      <div style={styles.feedback}>
        <ErrorBanner message={error} />
        {loading && <div style={styles.loading}>Searching…</div>}
      </div>

      {/* Results grid — only rendered after an explicit search */}
      {searched && !loading && (
        <div style={styles.gridWrapper}>
          <table style={styles.table}>
            <thead>
              <tr>
                {GRID_COLUMNS.map((col) => (
                  <th key={col.key} style={styles.th}>{col.label}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {results.length === 0 ? (
                <tr>
                  <td style={styles.emptyCell} colSpan={GRID_COLUMNS.length}>
                    No data to display
                  </td>
                </tr>
              ) : (
                results.map((org) => {
                  const isSelected = org.id === selectedId
                  return (
                    <tr
                      key={org.id}
                      onClick={() => setSelectedId(org.id)}
                      style={isSelected ? styles.rowSelected : { cursor: 'pointer' }}
                    >
                      {GRID_COLUMNS.map((col) => (
                        <td
                          key={col.key}
                          style={isSelected ? styles.tdSelected : styles.td}
                        >
                          {renderCell(org, col.key)}
                        </td>
                      ))}
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
