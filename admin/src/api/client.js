import axios from 'axios'

/**
 * Qareeb Admin API Client
 * Configured with base URL and automatic Authorization Bearer token header.
 */
export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 15000,
})

// Request Interceptor: Attach Admin JWT Token if available
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('qareeb_admin_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error),
)

// Response Interceptor: Handle 401 Unauthorized / Expired sessions
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('qareeb_admin_token')
      localStorage.removeItem('qareeb_admin_user')
      // Redirect or emit event when auth route is active
    }
    return Promise.reject(error)
  },
)

export default apiClient

