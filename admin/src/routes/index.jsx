import { createBrowserRouter, Navigate } from 'react-router-dom'
import LoginView from '../views/LoginView'
import DashboardView from '../views/DashboardView'
import { useAuth } from '../context/AuthContext'

function ProtectedRoute({ children }) {
  const { isAuthenticated, isLoading } = useAuth()

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#F8FAFC]">
        <div className="w-6 h-6 border-2 border-[#8B53FE] border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }

  return children
}

function PublicRoute({ children }) {
  const { isAuthenticated, isLoading } = useAuth()

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#F8FAFC]">
        <div className="w-6 h-6 border-2 border-[#8B53FE] border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }

  if (isAuthenticated) {
    const saved = localStorage.getItem('qareeb_admin_active_tab')
    const dest = saved && saved !== 'dashboard' ? `/dashboard/${saved}` : '/dashboard'
    return <Navigate to={dest} replace />
  }

  return children
}

export const router = createBrowserRouter([
  {
    path: '/',
    element: (
      <ProtectedRoute>
        <DashboardView />
      </ProtectedRoute>
    ),
  },
  {
    path: '/login',
    element: (
      <PublicRoute>
        <LoginView />
      </PublicRoute>
    ),
  },
  {
    path: '/dashboard',
    element: (
      <ProtectedRoute>
        <DashboardView />
      </ProtectedRoute>
    ),
  },
  {
    path: '/dashboard/:tab',
    element: (
      <ProtectedRoute>
        <DashboardView />
      </ProtectedRoute>
    ),
  },
  {
    path: '/:tab',
    element: (
      <ProtectedRoute>
        <DashboardView />
      </ProtectedRoute>
    ),
  },
  {
    path: '*',
    element: (
      <ProtectedRoute>
        <DashboardView />
      </ProtectedRoute>
    ),
  },
])
