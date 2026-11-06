import apiClient from './client'

/**
 * Admin Panel Backend APIs
 */

export async function fetchProviders(params = {}) {
  const query = new URLSearchParams()
  if (params.status) query.append('status', params.status)
  if (params.search) query.append('search', params.search)
  if (params.page) query.append('page', params.page)
  if (params.limit) query.append('limit', params.limit)

  const url = `/admin/providers${query.toString() ? `?${query.toString()}` : ''}`
  const response = await apiClient.get(url)
  return response.data
}

export async function fetchOnlineProviders(params = {}) {
  const response = await apiClient.get('/admin/providers/online', { params })
  return response.data
}

export async function fetchAdminMapProviders(params = {}) {
  const query = new URLSearchParams()
  if (params.status) query.append('status', params.status)
  if (params.categoryId) query.append('categoryId', params.categoryId)
  const url = `/admin/providers/map${query.toString() ? `?${query.toString()}` : ''}`
  const response = await apiClient.get(url)
  return response.data
}

export async function lookupProvider(q) {
  const response = await apiClient.get('/admin/providers/lookup', {
    params: { q },
  })
  return response.data
}

export async function fetchProviderDetails(id) {
  const response = await apiClient.get(`/admin/providers/${id}`)
  return response.data
}

export async function approveProviderApi(id, reason = 'Approved by admin') {
  const response = await apiClient.post(`/admin/providers/${id}/approve`, {
    reason,
  })
  return response.data
}

export async function rejectProviderApi(id, reason) {
  const response = await apiClient.post(`/admin/providers/${id}/reject`, {
    reason,
  })
  return response.data
}

export async function suspendProviderApi(id, reason) {
  const response = await apiClient.post(`/admin/providers/${id}/suspend`, {
    reason,
  })
  return response.data
}

export async function reinstateProviderApi(id, reason = 'Reinstated by admin') {
  const response = await apiClient.post(`/admin/providers/${id}/reinstate`, {
    reason,
  })
  return response.data
}

export async function fetchPlatformAnalytics(days = 30) {
  const response = await apiClient.get('/admin/analytics/funnel', {
    params: { days },
  })
  return response.data
}

export async function fetchCallLogs(params = {}) {
  const response = await apiClient.get('/admin/call-logs', { params })
  return response.data
}

export async function fetchCategories() {
  const response = await apiClient.get('/admin/categories')
  return response.data
}

export async function createCategoryApi(name) {
  const response = await apiClient.post('/admin/categories', { name })
  return response.data
}

export async function toggleCategoryApi(id, isEnabled) {
  const response = await apiClient.patch(`/admin/categories/${id}`, {
    is_enabled: isEnabled,
  })
  return response.data
}

export async function patchCategoryApi(id, data = {}) {
  const response = await apiClient.patch(`/admin/categories/${id}`, data)
  return response.data
}

export async function deleteCategoryApi(id) {
  const response = await apiClient.delete(`/admin/categories/${id}`)
  return response.data
}

