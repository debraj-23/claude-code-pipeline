import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './context/AuthContext'
import ProtectedRoute from './components/ProtectedRoute'
import LoginPage from './pages/LoginPage'
import MerchantPage from './pages/MerchantPage'
import OrganisationSearchPage from './pages/OrganisationSearchPage'
import EditBasicDetailsPage from './pages/EditBasicDetailsPage'

export default function App() {
  const { isAuthenticated } = useAuth()

  return (
    <Routes>
      {/* Public — login. If already authenticated, go straight to /home. */}
      <Route
        path="/"
        element={isAuthenticated ? <Navigate to="/home" replace /> : <LoginPage />}
      />

      {/* Protected — every authenticated route is wrapped by ProtectedRoute. */}
      <Route
        path="/home"
        element={<ProtectedRoute><MerchantPage /></ProtectedRoute>}
      />
      <Route
        path="/organisations"
        element={<ProtectedRoute><OrganisationSearchPage /></ProtectedRoute>}
      />
      <Route
        path="/organisations/:id/edit"
        element={<ProtectedRoute><EditBasicDetailsPage /></ProtectedRoute>}
      />

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
