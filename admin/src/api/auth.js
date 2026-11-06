import apiClient from './client'

/**
 * Admin Authentication API services
 */
export async function loginAdmin({ email, password }) {
  const response = await apiClient.post('/admin/auth/login', {
    email: email.trim().toLowerCase(),
    password,
  })
  return response.data
}

export async function fetchCurrentAdmin() {
  const response = await apiClient.get('/admin/providers/lookup?q=test')
  return response.data
}

