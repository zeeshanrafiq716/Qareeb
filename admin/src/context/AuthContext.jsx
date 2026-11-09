import { createContext, useContext, useState, useEffect } from 'react'

const AuthContext = createContext(null)

export const AuthProvider = ({ children }) => {
  const [admin, setAdmin] = useState(null)
  const [token, setToken] = useState(() => localStorage.getItem('qareeb_admin_token'))
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    try {
      const storedUser = localStorage.getItem('qareeb_admin_user')
      if (storedUser && token) {
        setAdmin(JSON.parse(storedUser))
      }
    } catch {
      // Clear corrupt state
      localStorage.removeItem('qareeb_admin_user')
      localStorage.removeItem('qareeb_admin_token')
    } finally {
      setIsLoading(false)
    }
  }, [token])

  const login = (adminData, authToken) => {
    setAdmin(adminData)
    setToken(authToken)
    localStorage.setItem('qareeb_admin_token', authToken)
    localStorage.setItem('qareeb_admin_user', JSON.stringify(adminData))
  }

  const updateAdmin = (adminData, authToken) => {
    setAdmin((prev) => {
      const merged = { ...(prev || {}), ...adminData }
      localStorage.setItem('qareeb_admin_user', JSON.stringify(merged))
      return merged
    })
    if (authToken) {
      setToken(authToken)
      localStorage.setItem('qareeb_admin_token', authToken)
    }
  }

  const logout = () => {
    setAdmin(null)
    setToken(null)
    localStorage.removeItem('qareeb_admin_token')
    localStorage.removeItem('qareeb_admin_user')
  }

  return (
    <AuthContext.Provider value={{ admin, token, isAuthenticated: !!token, isLoading, login, logout, updateAdmin }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

