import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen, within } from '@testing-library/react'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from '../context/AuthContext'
import EditBasicDetailsPage from '../pages/EditBasicDetailsPage'

vi.mock('../api/axios', () => ({
  default: { post: vi.fn(), get: vi.fn(), put: vi.fn() },
}))
import api from '../api/axios'

const ORG = {
  id: 3,
  orgId: 'ORG3',
  shortName: 'Acme',
  fullName: 'Acme Incorporated',
  city: 'Boston',
  country: 'USA',
  state: 'MA',
  type: 'Merchant',
  subType: 'Retail',
  feeRounding: 'NONE',
}

function mockApiForLoad() {
  // First call: GET /organisations/3 ; second call: GET /organisations (parent list)
  api.get.mockImplementation((url) => {
    if (url === '/organisations/3') return Promise.resolve({ data: ORG })
    if (url === '/organisations') return Promise.resolve({ data: [ORG] })
    return Promise.reject(new Error(`unexpected url ${url}`))
  })
}

function renderEdit(role) {
  localStorage.setItem('mpm_auth', JSON.stringify({ token: 't', role, username: 'u' }))
  return render(
    <AuthProvider>
      <MemoryRouter initialEntries={['/organisations/3/edit']}>
        <Routes>
          <Route path="/organisations/:id/edit" element={<EditBasicDetailsPage />} />
          <Route path="/organisations" element={<div>SEARCH PAGE</div>} />
        </Routes>
      </MemoryRouter>
    </AuthProvider>,
  )
}

// Helper: get the control inside the table row whose label matches `label`.
function controlInRow(label, role) {
  const row = screen.getByText(label, { selector: 'td' }).closest('tr')
  return within(row).getByRole(role)
}

describe('EditBasicDetailsPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorage.clear()
    mockApiForLoad()
  })

  it('renders orgId as read-only text (no editable input)', async () => {
    renderEdit('ADMIN')
    // Title bar reflects the loaded org.
    expect(
      await screen.findByText('Acme Incorporated (ORG3): Organization Basic Details'),
    ).toBeInTheDocument()

    const row = screen.getByText('Organization ID', { selector: 'td' }).closest('tr')
    // No input/select/textbox for the org id — just plain text.
    expect(within(row).queryByRole('textbox')).toBeNull()
    expect(within(row).queryByRole('combobox')).toBeNull()
    expect(within(row).getByText('ORG3')).toBeInTheDocument()
  })

  it('disables admin-only fields for the USER role', async () => {
    renderEdit('USER')
    await screen.findByText('Acme Incorporated (ORG3): Organization Basic Details')

    // Admin-only text field (Short Name) is read-only for USER.
    const shortName = controlInRow('Short Name', 'textbox')
    expect(shortName).toHaveAttribute('readonly')

    // Admin-only select field (Fee Rounding) is disabled for USER.
    const feeRounding = controlInRow('Fee Rounding', 'combobox')
    expect(feeRounding).toBeDisabled()

    // The "(Admin only)" note is shown next to a locked field.
    expect(screen.getAllByText('(Admin only)').length).toBeGreaterThan(0)

    // A non-admin field (Corporate City) remains editable for USER.
    const city = controlInRow('Corporate City', 'textbox')
    expect(city).not.toHaveAttribute('readonly')
  })

  it('keeps admin-only fields editable for the ADMIN role', async () => {
    renderEdit('ADMIN')
    await screen.findByText('Acme Incorporated (ORG3): Organization Basic Details')

    const shortName = controlInRow('Short Name', 'textbox')
    expect(shortName).not.toHaveAttribute('readonly')

    const feeRounding = controlInRow('Fee Rounding', 'combobox')
    expect(feeRounding).not.toBeDisabled()

    // No "(Admin only)" notes for an admin.
    expect(screen.queryByText('(Admin only)')).toBeNull()
  })
})
