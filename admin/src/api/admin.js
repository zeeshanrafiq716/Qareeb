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
  const items = Array.isArray(response.data?.data)
    ? response.data.data
    : Array.isArray(response.data?.items)
    ? response.data.items
    : Array.isArray(response.data)
    ? response.data
    : []
  return {
    ...response.data,
    items,
    data: items,
    meta: response.data?.meta || { total: items.length },
  }
}

export async function fetchOnlineProviders(params = {}) {
  const response = await apiClient.get('/admin/providers/online', { params })
  const items = Array.isArray(response.data?.data)
    ? response.data.data
    : Array.isArray(response.data?.items)
    ? response.data.items
    : Array.isArray(response.data)
    ? response.data
    : []
  return {
    ...response.data,
    items,
    data: items,
    meta: response.data?.meta || { total: items.length },
  }
}

export async function fetchAdminMapProviders(params = {}) {
  const query = new URLSearchParams()
  if (params.status) query.append('status', params.status)
  if (params.categoryId) query.append('categoryId', params.categoryId)
  const url = `/admin/providers/map${query.toString() ? `?${query.toString()}` : ''}`
  const response = await apiClient.get(url)
  const items = Array.isArray(response.data?.data)
    ? response.data.data
    : Array.isArray(response.data?.items)
    ? response.data.items
    : Array.isArray(response.data)
    ? response.data
    : []
  return {
    ...response.data,
    items,
    data: items,
  }
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

export async function suspendProviderApi(id, reason = 'Suspended by admin') {
  const response = await apiClient.post(`/admin/providers/${id}/suspend`, {
    reason,
  })
  return response.data
}

export async function blockProviderApi(id, reason = 'Blocked by admin') {
  const response = await apiClient.post(`/admin/providers/${id}/block`, {
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

export async function deleteProviderApi(id) {
  const response = await apiClient.delete(`/admin/providers/${id}`)
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
  const items = Array.isArray(response.data?.data)
    ? response.data.data
    : Array.isArray(response.data?.items)
    ? response.data.items
    : Array.isArray(response.data)
    ? response.data
    : []
  return {
    ...response.data,
    data: items,
    items,
  }
}

export async function createCategoryApi(data) {
  const payload = typeof data === 'string' ? { name: data } : data
  const response = await apiClient.post('/admin/categories', payload)
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

export async function reorderCategoriesApi(payload) {
  // payload can be { items: [{ id, sortOrder }] } or { categoryIds: [id1, id2, ...] }
  const body = Array.isArray(payload) ? { categoryIds: payload } : payload
  const response = await apiClient.patch('/admin/categories/reorder', body)
  return response.data
}

export async function deleteCategoryApi(id) {
  const response = await apiClient.delete(`/admin/categories/${id}`)
  return response.data
}

export async function translateTextApi(text) {
  if (!text || !text.trim()) return ''
  try {
    const response = await apiClient.post('/admin/translate', { text: text.trim() })
    return response.data?.data?.translated || response.data?.translated || ''
  } catch {
    return ''
  }
}

export async function fetchAdminNotifications() {
  const response = await apiClient.get('/admin/notifications')
  return response.data
}

export async function fetchAdminProfile() {
  const response = await apiClient.get('/admin/profile')
  return response.data
}

export async function updateAdminProfile(data) {
  const response = await apiClient.patch('/admin/profile', data)
  return response.data
}

export async function fetchVehicleTypes(params = {}) {
  const response = await apiClient.get('/admin/vehicle-types', { params })
  const items = Array.isArray(response.data?.data)
    ? response.data.data
    : Array.isArray(response.data?.items)
    ? response.data.items
    : Array.isArray(response.data)
    ? response.data
    : []
  return {
    ...response.data,
    data: items,
    items,
  }
}

export async function createVehicleTypeApi(data) {
  const payload = typeof data === 'string' ? { name: data } : data
  const response = await apiClient.post('/admin/vehicle-types', payload)
  return response.data
}

export async function patchVehicleTypeApi(id, data = {}) {
  const response = await apiClient.patch(`/admin/vehicle-types/${id}`, data)
  return response.data
}

export async function deleteVehicleTypeApi(id) {
  const response = await apiClient.delete(`/admin/vehicle-types/${id}`)
  return response.data
}

export async function fetchCategoryAssetsApi() {
  const response = await apiClient.get('/admin/category-assets')
  return response.data?.data || response.data || []
}

export async function uploadCategoryAssetApi(data) {
  const response = await apiClient.post('/admin/category-assets', data)
  return response.data?.data || response.data
}

export async function deleteCategoryAssetApi(id) {
  const response = await apiClient.delete(`/admin/category-assets/${id}`)
  return response.data?.data || response.data
}

export async function fetchCitiesApi(params = {}) {
  try {
    const response = await apiClient.get('/admin/cities', { params })
    const items = Array.isArray(response.data?.data)
      ? response.data.data
      : Array.isArray(response.data?.items)
      ? response.data.items
      : Array.isArray(response.data)
      ? response.data
      : []
    return items
  } catch {
    try {
      const response = await apiClient.get('/cities', { params })
      return Array.isArray(response.data?.data)
        ? response.data.data
        : Array.isArray(response.data?.items)
        ? response.data.items
        : Array.isArray(response.data)
        ? response.data
        : []
    } catch {
      return []
    }
  }
}

export async function createCityApi(data) {
  const response = await apiClient.post('/admin/cities', data)
  return response.data?.data || response.data
}

export async function patchCityApi(id, data = {}) {
  const response = await apiClient.patch(`/admin/cities/${id}`, data)
  return response.data?.data || response.data
}

export async function deleteCityApi(id) {
  const response = await apiClient.delete(`/admin/cities/${id}`)
  return response.data?.data || response.data
}




