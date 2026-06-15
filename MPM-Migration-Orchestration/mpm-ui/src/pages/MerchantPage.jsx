import TopBarNav from '../components/TopBarNav'
import { colors, typography, inputStyle, buttonStyle } from '../styles/theme'

// ─── Merchant tab landing page (specs.md §7.2) ───────────────────────────────
// Static placeholder page reached at the protected /home route.
//  - Top bar + Merchant/Organization tab strip (shared TopBarNav)
//  - Toolbar: [Merchant ID/Org ID ▼][text input][Search] | Edit Basic Details
//  - Always-empty data grid ("No data to display")
//  - Pagination row beneath the grid
// Per §7.2 / §8.8 this page has NO search wired up — it is a static landing
// page only, so the toolbar controls are inert.

// Grid columns (specs.md §7.2)
const GRID_COLUMNS = [
  'Merchant ID',
  'Merchant Name',
  'External MID',
  'Status',
  'Processing Group ID',
  'Organization ID',
  'Organization Name',
  'Organization Type',
  'Customer Experience Manager',
  'Payment Service Provider ID',
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
  emptyCell: {
    border: '1px solid #cccccc',
    padding: '24px 8px',
    textAlign: 'center',
    color: '#777777',
  },

  // Pagination row
  pagination: {
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
    padding: '8px 12px',
    background: colors.topBarBackground,
  },
  pageButton: {
    ...buttonStyle,
    padding: '2px 8px',
    cursor: 'not-allowed',
    color: '#999999',
  },
  pageInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
    margin: '0 6px',
    color: '#333333',
  },
  pageNumberBox: {
    ...inputStyle,
    width: '36px',
    textAlign: 'center',
    background: colors.adminFieldBackground,
    color: colors.adminFieldText,
  },
  paginationMessage: {
    marginLeft: 'auto',
    color: '#777777',
  },
}

// Static, empty data grid — always renders "No data to display".
function EmptyDataGrid() {
  // rows is intentionally empty on the Merchant landing page.
  const rows = []

  return (
    <div style={styles.gridWrapper}>
      <table style={styles.table}>
        <thead>
          <tr>
            {GRID_COLUMNS.map((col) => (
              <th key={col} style={styles.th}>{col}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr>
              <td style={styles.emptyCell} colSpan={GRID_COLUMNS.length}>
                No data to display
              </td>
            </tr>
          ) : null /* rows would be rendered here if there were any */}
        </tbody>
      </table>
    </div>
  )
}

// Pagination row beneath the grid: |< < Page [0] of 0 > >| + "No data to display"
function PaginationRow() {
  return (
    <div style={styles.pagination}>
      <button type="button" style={styles.pageButton} disabled aria-label="First page">|&lt;</button>
      <button type="button" style={styles.pageButton} disabled aria-label="Previous page">&lt;</button>
      <span style={styles.pageInfo}>
        Page
        <input type="text" value="0" readOnly style={styles.pageNumberBox} aria-label="Current page" />
        of 0
      </span>
      <button type="button" style={styles.pageButton} disabled aria-label="Next page">&gt;</button>
      <button type="button" style={styles.pageButton} disabled aria-label="Last page">&gt;|</button>
      <span style={styles.paginationMessage}>No data to display</span>
    </div>
  )
}

export default function MerchantPage() {
  return (
    <div style={styles.page}>
      {/* Shared top bar + Merchant/Organization tab strip (Merchant active) */}
      <TopBarNav activeTab="merchant" />

      {/* Toolbar — inert on this static landing page (no search wired, §7.2) */}
      <div style={styles.toolbar}>
        <div style={styles.searchGroup}>
          <select style={styles.searchSelect} defaultValue="merchantId" disabled>
            <option value="merchantId">Merchant ID</option>
            <option value="orgId">Org ID</option>
          </select>
          <input
            type="text"
            style={styles.searchInput}
            placeholder=""
            disabled
            aria-label="Search query"
          />
          <button type="button" style={{ ...buttonStyle, cursor: 'not-allowed', color: '#999999' }} disabled>
            Search
          </button>
        </div>

        <div style={styles.toolbarSeparator} />

        <button type="button" style={{ ...buttonStyle, cursor: 'not-allowed', color: '#999999' }} disabled>
          Edit Basic Details
        </button>
      </div>

      {/* Always-empty data grid */}
      <EmptyDataGrid />

      {/* Pagination row */}
      <PaginationRow />
    </div>
  )
}
