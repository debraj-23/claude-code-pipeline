import { useState, useEffect, useMemo } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import TopBarNav from '../components/TopBarNav'
import ErrorBanner from '../components/ErrorBanner'
import api from '../api/axios'
import { useAuth } from '../context/AuthContext'
import { colors, typography, inputStyle, buttonStyle } from '../styles/theme'

// ─── Edit Basic Details Form (specs.md §7.4, §8, §9) ─────────────────────────
// Reached at the protected /organisations/:id/edit route.
//  - Shared top bar with NO nav tabs (activeTab={null}) per §7.4
//  - Green separator (rendered by TopBarNav)
//  - White page-title bar: "{fullName} ({orgId}): Organization Basic Details"
//  - Gray page body (#e0e0e0) with a two-column <table> form (all 37 fields)
//  - Button row: [Check Multi-Site Compatible] [Cancel] [Save]
//
// Role-based behaviour (§2 / §8.1): admin-only fields are disabled / grayed out
// for the USER role and decorated with an orange "(Admin only)" note. They are
// editable for ADMIN. Field filtering on save is also enforced server-side.
//
// orgId is immutable (§8.2): rendered as plain read-only text, never an input.

// ─── Dropdown option sets (specs.md §4) ──────────────────────────────────────
const TYPE_OPTIONS = ['Merchant', 'ISO', 'Acquirer', 'Processor']
const SUBTYPE_OPTIONS = ['Retail', 'Ecommerce', 'Hotel', 'Wholesale']
const ACQUIRING_CONTRACT_OWNER_OPTIONS = [
  'Acquirer A',
  'Chase Paymentech',
  'Wells Fargo',
  'Bank of America',
  'Citi',
  'US Bank',
]
const FEE_ROUNDING_OPTIONS = [
  'bankers_agg',
  'ROUND_UP',
  'ROUND_DOWN',
  'ROUND_HALF',
  'NONE',
]
const SLA_REPORT_FREQUENCY_OPTIONS = ['None', 'Daily', 'Weekly', 'Monthly']
const ACQUIRER_FEE_LEVEL_OPTIONS = ['Default', 'Level1', 'Level2', 'Level3']

// Country / State are not enumerated in the spec — provide sensible option
// sets that include the seed-data values (USA / CA / WA).
const COUNTRY_OPTIONS = [
  'USA',
  'Canada',
  'United Kingdom',
  'Australia',
  'Germany',
  'France',
  'India',
  'Japan',
]
const STATE_OPTIONS = [
  'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
  'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
  'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
  'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
  'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
]

// ─── Field metadata (the exact 37 fields, in §8 order) ───────────────────────
// kind:     'text' | 'number' | 'decimal' | 'select' | 'checkbox' | 'money'
// adminOnly: grayed/disabled for USER role
// info:      render the ⓘ tooltip icon after the control
const FIELDS = [
  { key: 'shortName', label: 'Short Name', kind: 'text', width: 160, adminOnly: true },
  { key: 'fullName', label: 'Full Name', kind: 'text', width: 370, adminOnly: true },
  { key: 'corporateAddress', label: 'Corporate Street Address', kind: 'text', width: 370 },
  { key: 'corporateAddress2', label: 'Corporate Street Address 2', kind: 'text', width: 370 },
  { key: 'city', label: 'Corporate City', kind: 'text', width: 160 },
  { key: 'country', label: 'Corporate Country', kind: 'select', width: 200, options: COUNTRY_OPTIONS },
  { key: 'state', label: 'Corporate State', kind: 'select', width: 120, options: STATE_OPTIONS },
  { key: 'postalCode', label: 'Corporate Postal Code', kind: 'text', width: 80 },
  { key: 'type', label: 'Type', kind: 'select', width: 200, options: TYPE_OPTIONS },
  { key: 'subType', label: 'Sub Type', kind: 'select', width: 200, options: SUBTYPE_OPTIONS },
  { key: 'amexPaymentServiceProvider', label: 'Amex Payment Service Provider', kind: 'checkbox' },
  { key: 'amexMarketingIndicator', label: 'Amex Marketing Indicator', kind: 'checkbox' },
  { key: 'acquiringContractOwner', label: 'Acquiring Contract Owner', kind: 'select', width: 200, options: ACQUIRING_CONTRACT_OWNER_OPTIONS },
  { key: 'parentOrgId', label: 'Parent Organization ID', kind: 'parentOrg', width: 200, adminOnly: true },
  { key: 'feeRounding', label: 'Fee Rounding', kind: 'select', width: 370, options: FEE_ROUNDING_OPTIONS, adminOnly: true },
  { key: 'depositCreditLimit', label: 'Deposit Credit Limit (in USD including foreign currency)', kind: 'money', width: 140, adminOnly: true },
  { key: 'refundCreditLimit', label: 'Refund Credit Limit (in USD including foreign currency)', kind: 'money', width: 140, adminOnly: true },
  { key: 'orphanRefundCreditLimit', label: 'Orphan Refund Credit Limit (in USD including foreign currency)', kind: 'money', width: 140, adminOnly: true },
  { key: 'supportMastercardInterchange', label: 'Support MasterCard Business Service Arrangement Interchange Rates', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'supportQueryTransactions', label: 'Support Query Transactions', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'salesforceId', label: 'Salesforce Id', kind: 'text', width: 260 },
  { key: 'enableLogicalBackEndTying', label: 'Enable Logical Back End Tying', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'startMultiSiteDay', label: 'Start Multi Site Day', kind: 'number', width: 80, info: true },
  { key: 'maxCategoryNodes', label: 'Maximum No. of Category Nodes', kind: 'number', width: 80 },
  { key: 'slaReportFrequency', label: 'SLA Report Frequency', kind: 'select', width: 120, options: SLA_REPORT_FREQUENCY_OPTIONS },
  { key: 'enableEarlyReportGeneration', label: 'Enable Early Report Generation', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'acquirerFeeLevel', label: 'Acquirer Fee Level', kind: 'select', width: 120, options: ACQUIRER_FEE_LEVEL_OPTIONS, adminOnly: true },
  { key: 'pazienEnableIndicator', label: 'Pazien Enable Indicator', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'ssoPazien', label: 'SSO Pazien', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'eightDigitBinSSR', label: '8 Digit Bin SSR', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'netSettledSalesReportRemoveComma', label: 'Net Settled Sales Report Remove Comma', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'dailyECheckSalesVolumeLimit', label: 'Daily eCheck Sales Volume Limit', kind: 'money', width: 140, adminOnly: true, info: true },
  { key: 'dailyECheckCreditVolumeLimit', label: 'Daily eCheck Credit Volume Limit', kind: 'money', width: 140, adminOnly: true, info: true },
  { key: 'preferredCustomerReportIndicator', label: 'Preferred Customer Report Indicator', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'embeddedFinanceEnabled', label: 'Embedded Finance Enabled', kind: 'checkbox', adminOnly: true, info: true },
  { key: 'saferPaymentEnabled', label: 'SaferPayment Enabled', kind: 'checkbox', adminOnly: true, info: true },
]

// Keys grouped by data type — used to coerce the payload sent to PUT.
const BOOLEAN_KEYS = FIELDS.filter((f) => f.kind === 'checkbox').map((f) => f.key)
const NUMBER_KEYS = FIELDS.filter((f) => f.kind === 'number').map((f) => f.key)
const DECIMAL_KEYS = FIELDS.filter((f) => f.kind === 'money').map((f) => f.key)

const styles = {
  page: {
    minHeight: '100vh',
    display: 'flex',
    flexDirection: 'column',
    background: '#ffffff',
    fontFamily: typography.fontFamily,
    fontSize: typography.baseFontSize,
  },
  titleBar: {
    background: colors.topBarBackground,
    padding: '8px 12px',
    fontSize: typography.pageTitleSize,
    fontWeight: 'bold',
    color: '#333333',
  },
  body: {
    flex: 1,
    background: colors.pageBackground,
    padding: '12px',
  },
  feedback: {
    padding: '0 12px',
  },
  loading: {
    padding: '12px',
    color: '#555555',
  },
  table: {
    borderCollapse: 'collapse',
  },
  labelCell: {
    width: '310px',
    verticalAlign: 'top',
    padding: '4px 10px 4px 0',
    fontWeight: 'bold',
    color: '#333333',
  },
  controlCell: {
    padding: '4px 0',
    verticalAlign: 'top',
  },
  adminNote: {
    color: colors.adminLabelNote,
    fontStyle: 'italic',
    fontSize: '11px',
    marginLeft: '6px',
    fontWeight: 'normal',
  },
  readonlyText: {
    color: '#333333',
    padding: '2px 0',
  },
  moneyWrap: {
    display: 'inline-flex',
    alignItems: 'stretch',
    border: `1px solid ${colors.inputBorderNormal}`,
  },
  moneyPrefix: {
    padding: '2px 6px',
    background: '#f0f0f0',
    borderRight: `1px solid ${colors.inputBorderNormal}`,
    color: '#333333',
  },
  moneyInput: {
    border: 'none',
    outline: 'none',
    fontFamily: typography.fontFamily,
    fontSize: typography.baseFontSize,
    padding: '2px 4px',
  },
  infoIcon: {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '14px',
    height: '14px',
    borderRadius: '50%',
    background: colors.infoIconBackground,
    color: colors.infoIconText,
    fontSize: '10px',
    fontStyle: 'italic',
    fontWeight: 'bold',
    marginLeft: '6px',
    cursor: 'help',
    verticalAlign: 'middle',
  },
  buttonRow: {
    display: 'flex',
    gap: '8px',
    marginTop: '16px',
  },
}

// Disabled / grayed styling for admin-only fields locked to a USER (§9).
const lockedFieldStyle = {
  background: colors.adminFieldBackground,
  color: colors.adminFieldText,
  cursor: 'not-allowed',
}

function InfoIcon() {
  return (
    <span style={styles.infoIcon} title="More information">
      i
    </span>
  )
}

export default function EditBasicDetailsPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { isAdmin } = useAuth()

  const [org, setOrg] = useState(null)
  const [form, setForm] = useState(null)
  const [allOrgs, setAllOrgs] = useState([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  // ── Load the organisation (and the org list for the Parent Org dropdown) ──
  useEffect(() => {
    let cancelled = false

    async function load() {
      setLoading(true)
      setError('')
      try {
        const { data } = await api.get(`/organisations/${id}`)
        if (cancelled) return
        setOrg(data)
        // Seed the editable form state from every known field.
        const next = {}
        FIELDS.forEach((f) => {
          const value = data[f.key]
          if (f.kind === 'checkbox') next[f.key] = !!value
          else next[f.key] = value == null ? '' : String(value)
        })
        setForm(next)

        // Parent Org dropdown lists every other organisation (§8.3).
        try {
          const list = await api.get('/organisations', {
            params: { query: '', searchField: 'orgId' },
          })
          if (!cancelled) setAllOrgs(Array.isArray(list.data) ? list.data : [])
        } catch {
          if (!cancelled) setAllOrgs([])
        }
      } catch (err) {
        if (cancelled) return
        const message =
          err.response?.data?.message ||
          'Unable to load the organisation. Please try again.'
        setError(message)
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    load()
    return () => {
      cancelled = true
    }
  }, [id])

  // Parent Org options exclude the org currently being edited (§8.3).
  const parentOrgOptions = useMemo(
    () => allOrgs.filter((o) => String(o.id) !== String(id)),
    [allOrgs, id],
  )

  function updateField(key, value) {
    setForm((prev) => ({ ...prev, [key]: value }))
  }

  function isLocked(field) {
    // Admin-only fields are locked for non-admin (USER) role.
    return field.adminOnly && !isAdmin
  }

  // ── Save (PUT /api/organisations/{id}) ──
  async function handleSave() {
    setSaving(true)
    setError('')
    const payload = {}
    FIELDS.forEach((f) => {
      const raw = form[f.key]
      if (BOOLEAN_KEYS.includes(f.key)) {
        payload[f.key] = !!raw
      } else if (NUMBER_KEYS.includes(f.key)) {
        payload[f.key] = raw === '' || raw == null ? null : parseInt(raw, 10)
      } else if (DECIMAL_KEYS.includes(f.key)) {
        payload[f.key] = raw === '' || raw == null ? null : Number(raw)
      } else {
        payload[f.key] = raw === '' ? null : raw
      }
    })

    try {
      await api.put(`/organisations/${id}`, payload)
      // Success: no flash message — silently return to the search page (§8.6).
      navigate('/organisations')
    } catch (err) {
      const message =
        err.response?.data?.message ||
        'Unable to save changes. Please review the form and try again.'
      setError(message)
      setSaving(false)
    }
  }

  // Cancel returns to search without saving (§7.4).
  function handleCancel() {
    navigate('/organisations')
  }

  function handleCheckMultiSite() {
    alert('Multi-Site compatibility check is not available in this environment.')
  }

  // ── Render a single field control ──
  function renderControl(field) {
    const locked = isLocked(field)
    const value = form[field.key]

    if (field.kind === 'checkbox') {
      return (
        <input
          type="checkbox"
          checked={!!value}
          disabled={locked}
          onChange={(e) => updateField(field.key, e.target.checked)}
          style={locked ? { cursor: 'not-allowed' } : undefined}
        />
      )
    }

    if (field.kind === 'select') {
      const selectStyle = {
        ...inputStyle,
        width: field.width,
        background: '#ffffff',
        ...(locked ? lockedFieldStyle : {}),
      }
      return (
        <select
          value={value}
          disabled={locked}
          onChange={(e) => updateField(field.key, e.target.value)}
          style={selectStyle}
        >
          <option value="">-- Select --</option>
          {field.options.map((opt) => (
            <option key={opt} value={opt}>
              {opt}
            </option>
          ))}
        </select>
      )
    }

    if (field.kind === 'parentOrg') {
      const selectStyle = {
        ...inputStyle,
        width: field.width,
        background: '#ffffff',
        ...(locked ? lockedFieldStyle : {}),
      }
      return (
        <select
          value={value}
          disabled={locked}
          onChange={(e) => updateField(field.key, e.target.value)}
          style={selectStyle}
        >
          <option value="">-- None --</option>
          {parentOrgOptions.map((o) => (
            <option key={o.id} value={o.orgId}>
              {o.orgId} — {o.shortName}
            </option>
          ))}
        </select>
      )
    }

    if (field.kind === 'money') {
      const wrapStyle = {
        ...styles.moneyWrap,
        ...(locked ? { background: colors.adminFieldBackground } : {}),
      }
      const moneyInputStyle = {
        ...styles.moneyInput,
        width: field.width,
        ...(locked ? lockedFieldStyle : {}),
      }
      return (
        <span style={wrapStyle}>
          <span style={styles.moneyPrefix}>$</span>
          <input
            type="text"
            value={value}
            readOnly={locked}
            onChange={(e) => updateField(field.key, e.target.value)}
            style={moneyInputStyle}
          />
        </span>
      )
    }

    // text / number
    const textStyle = {
      ...inputStyle,
      width: field.width,
      ...(locked ? lockedFieldStyle : {}),
    }
    return (
      <input
        type="text"
        value={value}
        readOnly={locked}
        onChange={(e) => updateField(field.key, e.target.value)}
        style={textStyle}
      />
    )
  }

  return (
    <div style={styles.page}>
      {/* Shared top bar with NO nav tabs (specs.md §7.4). */}
      <TopBarNav activeTab={null} />

      {/* Page title bar: "{fullName} ({orgId}): Organization Basic Details" */}
      <div style={styles.titleBar}>
        {org
          ? `${org.fullName} (${org.orgId}): Organization Basic Details`
          : 'Organization Basic Details'}
      </div>

      <div style={styles.body}>
        <div style={styles.feedback}>
          <ErrorBanner message={error} />
        </div>

        {loading && <div style={styles.loading}>Loading…</div>}

        {!loading && org && form && (
          <>
            <table style={styles.table}>
              <tbody>
                {/* Field 1: Organization ID — read-only plain text (§8.2). */}
                <tr>
                  <td style={styles.labelCell}>Organization ID</td>
                  <td style={styles.controlCell}>
                    <span style={styles.readonlyText}>{org.orgId}</span>
                  </td>
                </tr>

                {/* Fields 2–37 */}
                {FIELDS.map((field) => {
                  const locked = isLocked(field)
                  return (
                    <tr key={field.key}>
                      <td style={styles.labelCell}>
                        {field.label}
                        {locked && <span style={styles.adminNote}>(Admin only)</span>}
                      </td>
                      <td style={styles.controlCell}>
                        {renderControl(field)}
                        {field.info && <InfoIcon />}
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>

            {/* Button row (§7.4) */}
            <div style={styles.buttonRow}>
              <button
                type="button"
                style={buttonStyle}
                onClick={handleCheckMultiSite}
              >
                Check Multi-Site Compatible
              </button>
              <button
                type="button"
                style={buttonStyle}
                onClick={handleCancel}
                disabled={saving}
              >
                Cancel
              </button>
              <button
                type="button"
                style={
                  saving
                    ? { ...buttonStyle, cursor: 'not-allowed', color: '#999999' }
                    : buttonStyle
                }
                onClick={handleSave}
                disabled={saving}
              >
                {saving ? 'Saving…' : 'Save'}
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
