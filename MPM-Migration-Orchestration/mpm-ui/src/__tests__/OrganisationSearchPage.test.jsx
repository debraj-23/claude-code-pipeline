import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Routes, Route, useParams } from 'react-router-dom'
import { AuthProvider } from '../context/AuthContext'
import OrganisationSearchPage from '../pages/OrganisationSearchPage'

vi.mock('../api/axios', () => ({
  default: { post: vi.fn(), get: vi.fn(), put: vi.fn() },
}))
import api from '../api/axios'

const ORG = {
  id: 7,
  orgId: 'ORG7',
  shortName: 'Acme',
  fullName: 'Acme Incorporated',
  type: 'Merchant',
  subType: 'Retail',
  feeRounding: 'NONE',
  active: true,
}

function EditStub() {
  const { id } = useParams()
  return <div>EDIT PAGE {id}</div>
}

function renderSearch() {
  // Seed an authenticated user so TopBarNav renders cleanly.
  localStorage.setItem('mpm_auth', JSON.stringify({ token: 't', role: 'USER', username: 'u' }))
  return render(
    <AuthProvider>
      <MemoryRouter initialEntries={['/organisations']}>
        <Routes>
          <Route path="/organisations" element={<OrganisationSearchPage />} />
          <Route path="/organisations/:id/edit" element={<EditStub />} />
        </Routes>
      </MemoryRouter>
    </AuthProvider>,
  )
}

describe('OrganisationSearchPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorage.clear()
  })

  it('does not call the API or render the grid before an explicit Search', () => {
    renderSearch()
    expect(api.get).not.toHaveBeenCalled()
    expect(screen.queryByText('Acme Incorporated')).not.toBeInTheDocument()
  })

  it('triggers the API call on Search and renders the results', async () => {
    const user = userEvent.setup()
    api.get.mockResolvedValueOnce({ data: [ORG] })
    renderSearch()

    await user.type(screen.getByLabelText('Search query'), 'Acme')
    await user.click(screen.getByRole('button', { name: 'Search' }))

    expect(api.get).toHaveBeenCalledWith('/organisations', {
      params: { query: 'Acme', searchField: 'orgId' },
    })

    expect(await screen.findByText('Acme Incorporated')).toBeInTheDocument()
    expect(screen.getByText('ORG7')).toBeInTheDocument()
    // boolean active rendered as Yes
    expect(screen.getByText('Yes')).toBeInTheDocument()
  })

  it('selects a row and navigates to the edit page via Edit Basic Details', async () => {
    const user = userEvent.setup()
    api.get.mockResolvedValueOnce({ data: [ORG] })
    renderSearch()

    await user.click(screen.getByRole('button', { name: 'Search' }))
    await screen.findByText('Acme Incorporated')

    // Select the row, then click Edit.
    await user.click(screen.getByText('Acme Incorporated'))
    await user.click(screen.getByRole('button', { name: 'Edit Basic Details' }))

    expect(await screen.findByText('EDIT PAGE 7')).toBeInTheDocument()
  })

  it('alerts when Edit is clicked with no row selected', async () => {
    const user = userEvent.setup()
    const alertSpy = vi.spyOn(window, 'alert').mockImplementation(() => {})
    api.get.mockResolvedValueOnce({ data: [ORG] })
    renderSearch()

    // Search (which clears any selection) but do NOT select a row.
    await user.click(screen.getByRole('button', { name: 'Search' }))
    await screen.findByText('Acme Incorporated')

    await user.click(screen.getByRole('button', { name: 'Edit Basic Details' }))

    expect(alertSpy).toHaveBeenCalledWith('Please select an organisation first.')
    expect(screen.queryByText(/EDIT PAGE/)).not.toBeInTheDocument()
    alertSpy.mockRestore()
  })

  it('shows an empty-grid message when search returns no rows', async () => {
    const user = userEvent.setup()
    api.get.mockResolvedValueOnce({ data: [] })
    renderSearch()

    await user.click(screen.getByRole('button', { name: 'Search' }))

    expect(await screen.findByText('No data to display')).toBeInTheDocument()
  })
})
