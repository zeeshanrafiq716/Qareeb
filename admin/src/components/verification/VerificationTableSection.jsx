import React, { useState, useEffect } from 'react'
import {
  Search,
  ChevronDown,
  ChevronsUpDown,
  MapPin,
  MoreHorizontal,
  ChevronLeft,
  ChevronRight,
  Disc,
  Truck,
  Fuel,
  Wrench,
  Key,
  Check,
  Eye,
  CheckCircle,
  XCircle,
  RotateCcw,
  Clock,
  Phone,
  PauseCircle,
  Ban,
  Trash2,
} from 'lucide-react'
import {
  fetchProviders,
  fetchCategories,
  approveProviderApi,
  rejectProviderApi,
  suspendProviderApi,
  blockProviderApi,
  deleteProviderApi,
} from '../../api/admin'

export function VerificationTableSection({
  onViewDetails,
  activeFilter = 'all',
  onUpdateStats,
}) {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategory, setSelectedCategory] = useState('All Categories')
  const [selectedStatus, setSelectedStatus] = useState('All Status')
  const [selectedDateRange, setSelectedDateRange] = useState('Last 30 Days')
  const [categoryOpen, setCategoryOpen] = useState(false)
  const [statusOpen, setStatusOpen] = useState(false)
  const [dateRangeOpen, setDateRangeOpen] = useState(false)
  const [activeRowMenu, setActiveRowMenu] = useState(null)
  const [selectedRows, setSelectedRows] = useState([])
  const [currentPage, setCurrentPage] = useState(1)
  const [applicationsList, setApplicationsList] = useState([])
  const [loading, setLoading] = useState(true)
  const [toastMessage, setToastMessage] = useState('')
  const [toastType, setToastType] = useState('success')

  const showToast = (msg, type = 'success') => {
    setToastMessage(msg)
    setToastType(type)
    setTimeout(() => setToastMessage(''), 3500)
  }

  useEffect(() => {
    const handleOutsideClick = () => {
      setActiveRowMenu(null)
    }
    document.addEventListener('click', handleOutsideClick)
    return () => document.removeEventListener('click', handleOutsideClick)
  }, [])

  useEffect(() => {
    let mounted = true
    async function loadApplications(isSilent = false) {
      try {
        if (!isSilent) setLoading(true)
        const res = await fetchProviders({ limit: 100 })
        if (!mounted) return
        const rawItems = Array.isArray(res?.data)
          ? res.data
          : Array.isArray(res?.items)
          ? res.items
          : Array.isArray(res)
          ? res
          : []
        // Only show providers who completed onboarding steps and submitted for verification
        const onboardedItems = rawItems.filter(
          (item) => item.status !== 'pending_otp' && item.status !== 'pending_profile'
        )
        const mapped = onboardedItems.map((item, idx) => {
          const catName = item.category?.name || 'Roadside Assistance'
          let Icon = Disc
          if (catName.toLowerCase().includes('tow')) Icon = Truck
          else if (catName.toLowerCase().includes('fuel')) Icon = Fuel
          else if (catName.toLowerCase().includes('mechanic')) Icon = Wrench
          else if (catName.toLowerCase().includes('lockout')) Icon = Key

          const createdAt = item.createdAt ? new Date(item.createdAt) : new Date()
          const dateStr = createdAt.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })
          const timeStr = createdAt.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })

          let stBadge = 'Approved'
          let stType = 'approved'
          if (item.status === 'pending_verification') {
            stBadge = 'Pending Review'
            stType = 'pending'
          } else if (item.status === 'rejected') {
            if (item.statusReason && item.statusReason.toLowerCase().includes('resubmi')) {
              stBadge = 'Resubmission'
              stType = 'resubmission'
            } else {
              stBadge = 'Rejected'
              stType = 'rejected'
            }
          } else if (item.status === 'suspended') {
            stBadge = 'Under Review'
            stType = 'under_review'
          }

          const displayName = item.name && item.name.trim().length > 0 && item.name !== 'Provider'
            ? item.name
            : (item.phone ? `Provider (${item.phone})` : 'New Provider')

          const isOnline = Boolean(item.isOnline ?? item.presence?.isOnline)
          const lat = item.location?.latitude != null ? Number(item.location.latitude) : null
          const lng = item.location?.longitude != null ? Number(item.location.longitude) : null

          const rawCity = item.location?.city || item.city || item.location?.address
          const cleanCity = (!rawCity || rawCity.toLowerCase().trim() === 'pending')
            ? (item.location?.latitude ? `${Number(item.location.latitude).toFixed(4)}, ${Number(item.location.longitude).toFixed(4)}` : 'Location Pending')
            : rawCity

          return {
            id: item.providerId?.replace('QRB-', 'QA-2024-') || `QA-2024-${String(idx + 1).padStart(3, '0')}`,
            backendId: item.id,
            providerId: item.providerId,
            name: displayName,
            isOnline,
            latitude: lat,
            longitude: lng,
            hasCoordinates: lat != null && lng != null,
            city: cleanCity,
            category: catName,
            categoryIcon: Icon,
            submittedDate: dateStr,
            submittedTime: timeStr,
            status: stBadge,
            statusType: stType,
            avatar: item.photoUrl || `https://images.unsplash.com/photo-${1500000000000 + (idx * 1234567) % 500000000}?auto=format&fit=crop&w=120&h=120&q=80`,
            phone: item.phone,
            whatsapp: item.whatsapp || item.whatsappNumber || item.phone,
            nationalId: item.nationalId || item.iqamaNumber || 'Pending Submission',
            iqamaExpiry: item.iqamaExpiry || 'Pending Submission',
            vehicleModel: item.vehicleModel || 'Pending Submission',
            vehicleType: item.vehicleType || 'Roadside Vehicle',
            plateNumber: item.plateNumber || 'Pending Submission',
            vehicleColor: item.vehicleColor || 'Pending',
          }
        })

        // Prioritize pending review items at top
        mapped.sort((a, b) => (a.status === 'Pending Review' ? -1 : 1))
        setApplicationsList(mapped)
      } catch (err) {
        console.error('Failed to load verification applications from backend:', err)
      } finally {
        if (mounted && !isSilent) setLoading(false)
      }
    }

    // 1. Initial load
    loadApplications(false)

    // 2. Real-time background sync interval (every 2.5 seconds without manual refresh)
    const intervalTimer = setInterval(() => {
      loadApplications(true)
    }, 2500)

    // 3. Instant sync when browser tab gains focus or window becomes visible
    const handleFocus = () => loadApplications(true)
    const handleVisibility = () => {
      if (document.visibilityState === 'visible') loadApplications(true)
    }
    window.addEventListener('focus', handleFocus)
    document.addEventListener('visibilitychange', handleVisibility)

    return () => {
      mounted = false
      clearInterval(intervalTimer)
      window.removeEventListener('focus', handleFocus)
      document.removeEventListener('visibilitychange', handleVisibility)
    }
  }, [])

  useEffect(() => {
    if (onUpdateStats && applicationsList) {
      onUpdateStats({
        pendingReview: applicationsList.filter((a) => a.status === 'Pending Review').length,
        underReview: applicationsList.filter((a) => a.status === 'Under Review').length,
        resubmission: applicationsList.filter((a) => a.status === 'Resubmission' || a.status === 'Rejected').length,
      })
    }
  }, [applicationsList])

  const [categories, setCategories] = useState(['All Categories'])

  // Load real categories dynamically (No mock/seed data)
  useEffect(() => {
    async function loadRealCategories() {
      try {
        const res = await fetchCategories()
        const items = res?.data || res?.items || []
        const apiNames = items.map((c) => c.name).filter(Boolean)
        const appCatNames = applicationsList
          .map((a) => a.category)
          .filter((cat) => cat && cat !== 'Pending Submission')
        const unique = Array.from(new Set([...apiNames, ...appCatNames]))
        setCategories(['All Categories', ...unique])
      } catch {
        const appCatNames = Array.from(
          new Set(
            applicationsList
              .map((a) => a.category)
              .filter((cat) => cat && cat !== 'Pending Submission')
          )
        )
        setCategories(['All Categories', ...appCatNames])
      }
    }
    loadRealCategories()
  }, [applicationsList])
  const statuses = ['All Status', 'Pending Review', 'Under Review', 'Resubmission', 'Rejected', 'Approved']
  const dateRanges = ['Today', 'Last 7 Days', 'Last 30 Days', 'This Month', 'All Time']

  const getStatusBadge = (status) => {
    switch (status) {
      case 'Pending Review':
        return 'bg-[#F4EFFE] text-[#8B53FE]'
      case 'Under Review':
        return 'bg-[#FEF3E2] text-[#D97706]'
      case 'Resubmission':
        return 'bg-[#EFF6FF] text-[#2563EB]'
      case 'Rejected':
        return 'bg-[#FEE2E2] text-[#DC2626]'
      case 'Approved':
        return 'bg-[#E9FBF0] text-[#16A34A]'
      case 'Suspended':
        return 'bg-[#FFF7ED] text-[#EA580C]'
      case 'Blocked':
        return 'bg-[#FFF1F2] text-[#E11D48]'
      default:
        return 'bg-[#F3F4F6] text-[#4B5563]'
    }
  }

  // Filter applications
  const filteredApplications = applicationsList.filter((app) => {
    const matchesSearch =
      !searchQuery ||
      app.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      app.id?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (app.phone && app.phone.includes(searchQuery)) ||
      app.city?.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesCategory =
      selectedCategory === 'All Categories' || app.category === selectedCategory
    const matchesStatus =
      selectedStatus === 'All Status' || app.status === selectedStatus
    const matchesCardFilter =
      activeFilter === 'all' ||
      (activeFilter === 'pending' && app.status === 'Pending Review') ||
      (activeFilter === 'under_review' && app.status === 'Under Review') ||
      (activeFilter === 'resubmission' && (app.status === 'Resubmission' || app.status === 'Rejected'))
    return matchesSearch && matchesCategory && matchesStatus && matchesCardFilter
  })

  const toggleSelectAll = () => {
    if (selectedRows.length === filteredApplications.length) {
      setSelectedRows([])
    } else {
      setSelectedRows(filteredApplications.map((app) => app.id))
    }
  }

  const toggleSelectRow = (id) => {
    setSelectedRows((prev) =>
      prev.includes(id) ? prev.filter((r) => r !== id) : [...prev, id]
    )
  }

  const handleApprove = async (app) => {
    setActiveRowMenu(null)
    const prevStatus = app.status
    const prevStatusType = app.statusType
    setApplicationsList((prev) =>
      prev.map((a) => (a.id === app.id ? { ...a, status: 'Approved', statusType: 'approved' } : a))
    )
    if (app.backendId) {
      try {
        await approveProviderApi(app.backendId, 'Approved by admin')
        showToast(`Provider "${app.name}" approved successfully!`)
      } catch (err) {
        console.error('Failed to approve application on backend:', err)
        const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
        showToast(`Failed to approve: ${msg}`, 'error')
        setApplicationsList((prev) =>
          prev.map((a) => (a.id === app.id ? { ...a, status: prevStatus, statusType: prevStatusType } : a))
        )
      }
    }
  }

  const handleReject = async (app) => {
    setActiveRowMenu(null)
    const prevStatus = app.status
    const prevStatusType = app.statusType
    setApplicationsList((prev) =>
      prev.map((a) => (a.id === app.id ? { ...a, status: 'Rejected', statusType: 'rejected' } : a))
    )
    if (app.backendId) {
      try {
        await rejectProviderApi(app.backendId, 'Rejected by admin')
        showToast(`Provider "${app.name}" marked as Rejected`)
      } catch (err) {
        console.error('Failed to reject application on backend:', err)
        const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
        showToast(`Failed to reject: ${msg}`, 'error')
        setApplicationsList((prev) =>
          prev.map((a) => (a.id === app.id ? { ...a, status: prevStatus, statusType: prevStatusType } : a))
        )
      }
    }
  }

  const handleRequestResubmission = async (app) => {
    setActiveRowMenu(null)
    const prevStatus = app.status
    const prevStatusType = app.statusType
    setApplicationsList((prev) =>
      prev.map((a) => (a.id === app.id ? { ...a, status: 'Resubmission', statusType: 'resubmission' } : a))
    )
    if (app.backendId) {
      try {
        await rejectProviderApi(app.backendId, 'Resubmission requested: please re-upload clear documents')
        showToast(`Resubmission requested for "${app.name}"`)
      } catch (err) {
        console.error('Failed to request resubmission on backend:', err)
        const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
        showToast(`Failed to request resubmission: ${msg}`, 'error')
        setApplicationsList((prev) =>
          prev.map((a) => (a.id === app.id ? { ...a, status: prevStatus, statusType: prevStatusType } : a))
        )
      }
    }
  }

  const handleSuspend = async (app) => {
    setActiveRowMenu(null)
    const prevStatus = app.status
    const prevStatusType = app.statusType
    setApplicationsList((prev) =>
      prev.map((a) => (a.id === app.id ? { ...a, status: 'Suspended', statusType: 'suspended' } : a))
    )
    if (app.backendId) {
      try {
        await suspendProviderApi(app.backendId, 'Suspended by admin')
        showToast(`Provider "${app.name}" suspended`)
      } catch (err) {
        console.error('Failed to suspend provider on backend:', err)
        const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
        showToast(`Failed to suspend: ${msg}`, 'error')
        setApplicationsList((prev) =>
          prev.map((a) => (a.id === app.id ? { ...a, status: prevStatus, statusType: prevStatusType } : a))
        )
      }
    }
  }

  const handleBlock = async (app) => {
    setActiveRowMenu(null)
    const prevStatus = app.status
    const prevStatusType = app.statusType
    setApplicationsList((prev) =>
      prev.map((a) => (a.id === app.id ? { ...a, status: 'Blocked', statusType: 'blocked' } : a))
    )
    if (app.backendId) {
      try {
        await blockProviderApi(app.backendId, 'Blocked by admin')
        showToast(`Provider "${app.name}" blocked`)
      } catch (err) {
        console.error('Failed to block provider on backend:', err)
        const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
        showToast(`Failed to block: ${msg}`, 'error')
        setApplicationsList((prev) =>
          prev.map((a) => (a.id === app.id ? { ...a, status: prevStatus, statusType: prevStatusType } : a))
        )
      }
    }
  }

  const handleDelete = async (app) => {
    setActiveRowMenu(null)
    if (!window.confirm(`Are you sure you want to delete application for "${app.name}"? This action cannot be undone.`)) {
      return
    }
    const prevList = [...applicationsList]
    setApplicationsList((prev) => prev.filter((a) => a.id !== app.id))
    if (app.backendId) {
      try {
        await deleteProviderApi(app.backendId)
        showToast(`Provider "${app.name}" deleted successfully`)
      } catch (err) {
        console.error('Failed to delete provider on backend:', err)
        const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
        showToast(`Failed to delete: ${msg}`, 'error')
        setApplicationsList(prevList)
      }
    }
  }

  return (
    <div
      style={{
        borderRadius: '20px',
        border: '1px solid #EBEBEB',
        background: '#FFFFFF',
        boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.03)',
      }}
      className="w-full max-w-[1084px] flex flex-col justify-between shrink-0 overflow-visible select-none animate-in fade-in duration-150 relative"
    >
      {/* Toast Notification */}
      {toastMessage && (
        <div
          className={`fixed top-6 right-8 text-white text-xs px-4 py-2.5 rounded-xl shadow-xl z-50 flex items-center gap-2 animate-in slide-in-from-top-2 ${
            toastType === 'error' ? 'bg-[#DC2626]' : 'bg-[#1C2926]'
          }`}
        >
          {toastType === 'error' ? (
            <XCircle className="w-4 h-4 text-white" />
          ) : (
            <Check className="w-4 h-4 text-[#22C55E]" />
          )}
          <span>{toastMessage}</span>
        </div>
      )}
      {/* Filters Row */}
      <div className="w-full px-5 py-3.5 flex items-center justify-between shrink-0">
        <div className="relative w-full max-w-[380px] flex items-center">
          <Search className="w-4 h-4 text-[#9EAFA9] absolute left-3.5 pointer-events-none" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by provider, category, or location..."
            className="w-full h-[40px] pl-10 pr-4 text-xs font-normal text-[#1C2926] placeholder-[#9EAFA9] bg-white border border-[#EBEBEB] rounded-xl focus:border-[#8B53FE] focus:ring-2 focus:ring-[#8B53FE]/15 transition-all outline-none"
          />
        </div>

        <div className="flex items-center gap-3">
          {/* Categories */}
          <div className="relative">
            <button
              type="button"
              onClick={() => {
                setCategoryOpen((prev) => !prev)
                setStatusOpen(false)
                setDateRangeOpen(false)
              }}
              className="h-[40px] px-3.5 rounded-xl border border-[#EBEBEB] bg-white text-xs font-medium text-[#1C2926] hover:bg-[#F9F9FB] flex items-center gap-2 transition-all cursor-pointer shadow-2xs"
            >
              <span>{selectedCategory === 'All Categories' ? 'Categories' : selectedCategory}</span>
              <ChevronDown className="w-3.5 h-3.5 text-[#566663]" />
            </button>
            {categoryOpen && (
              <div className="absolute right-0 mt-1.5 w-48 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-30 animate-in fade-in zoom-in-95 duration-100">
                {categories.map((cat) => (
                  <button
                    key={cat}
                    type="button"
                    onClick={() => {
                      setSelectedCategory(cat)
                      setCategoryOpen(false)
                    }}
                    className={`w-full px-3.5 py-2 text-xs text-left flex items-center justify-between hover:bg-[#F0EAFE] transition-colors cursor-pointer ${
                      selectedCategory === cat ? 'text-[#8B53FE] font-semibold' : 'text-[#1C2926]'
                    }`}
                  >
                    <span className="truncate">{cat}</span>
                    {selectedCategory === cat && <Check className="w-3.5 h-3.5 text-[#8B53FE] shrink-0" />}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Status */}
          <div className="relative">
            <button
              type="button"
              onClick={() => {
                setStatusOpen((prev) => !prev)
                setCategoryOpen(false)
                setDateRangeOpen(false)
              }}
              className="h-[40px] px-3.5 rounded-xl border border-[#EBEBEB] bg-white text-xs font-medium text-[#1C2926] hover:bg-[#F9F9FB] flex items-center gap-2 transition-all cursor-pointer shadow-2xs"
            >
              <span>{selectedStatus === 'All Status' ? 'Status' : selectedStatus}</span>
              <ChevronDown className="w-3.5 h-3.5 text-[#566663]" />
            </button>
            {statusOpen && (
              <div className="absolute right-0 mt-1.5 w-40 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-30 animate-in fade-in zoom-in-95 duration-100">
                {statuses.map((st) => (
                  <button
                    key={st}
                    type="button"
                    onClick={() => {
                      setSelectedStatus(st)
                      setStatusOpen(false)
                    }}
                    className={`w-full px-3.5 py-2 text-xs text-left flex items-center justify-between hover:bg-[#F0EAFE] transition-colors cursor-pointer ${
                      selectedStatus === st ? 'text-[#8B53FE] font-semibold' : 'text-[#1C2926]'
                    }`}
                  >
                    <span>{st}</span>
                    {selectedStatus === st && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Registered Date */}
          <div className="relative">
            <button
              type="button"
              onClick={() => {
                setDateRangeOpen((prev) => !prev)
                setCategoryOpen(false)
                setStatusOpen(false)
              }}
              className="h-[40px] px-3.5 rounded-xl border border-[#EBEBEB] bg-white text-xs font-medium text-[#1C2926] hover:bg-[#F9F9FB] flex items-center gap-2 transition-all cursor-pointer shadow-2xs"
            >
              <span>{selectedDateRange}</span>
              <ChevronDown className="w-3.5 h-3.5 text-[#566663]" />
            </button>
            {dateRangeOpen && (
              <div className="absolute right-0 mt-1.5 w-40 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-30 animate-in fade-in zoom-in-95 duration-100">
                {dateRanges.map((dr) => (
                  <button
                    key={dr}
                    type="button"
                    onClick={() => {
                      setSelectedDateRange(dr)
                      setDateRangeOpen(false)
                    }}
                    className={`w-full px-3.5 py-2 text-xs text-left flex items-center justify-between hover:bg-[#F0EAFE] transition-colors cursor-pointer ${
                      selectedDateRange === dr ? 'text-[#8B53FE] font-semibold' : 'text-[#1C2926]'
                    }`}
                  >
                    <span>{dr}</span>
                    {selectedDateRange === dr && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Table Wrapper - No Horizontal Scrollbar */}
      <div className="w-full overflow-x-hidden flex-1 flex flex-col justify-start min-h-[300px]">
        <div
          style={{
            height: '56px',
          }}
          className="w-full bg-[#F4F2F7] px-4 sm:px-5 flex items-center shrink-0 text-[12px] font-semibold text-[#616166]"
        >
          <div className="w-[32px] flex items-center justify-start shrink-0">
            <input
              type="checkbox"
              checked={
                selectedRows.length > 0 &&
                selectedRows.length === filteredApplications.length
              }
              onChange={toggleSelectAll}
              className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
            />
          </div>
          <div className="flex-1 min-w-[120px] flex items-center gap-1.5 pr-2">
            <span>Provider</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>
          <div className="w-[130px] flex items-center gap-1.5 shrink-0">
            <span>Service Category</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>
          <div className="w-[185px] flex items-center gap-1.5 shrink-0 pr-2">
            <span>Location</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>
          <div className="w-[115px] flex items-center gap-1.5 shrink-0">
            <span>Submitted On</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>
          <div className="w-[105px] flex items-center gap-1.5 shrink-0">
            <span>Status</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>
          <div className="w-[125px] flex items-center justify-end gap-1.5 shrink-0 pr-1">
            <span>Action</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>
        </div>

        {/* Table Body / Real Empty State */}
        <div className="flex-1 flex flex-col justify-start">
          {loading ? (
            <div className="w-full py-16 flex flex-col items-center justify-center text-center text-[#9EAFA9]">
              <div className="w-7 h-7 border-2 border-[#8B53FE] border-t-transparent rounded-full animate-spin mb-3" />
              <p className="text-xs text-[#616166]">Loading verification applications...</p>
            </div>
          ) : filteredApplications.length === 0 ? (
            <div className="w-full py-16 flex flex-col items-center justify-center text-center text-[#9EAFA9]">
              <Clock className="w-10 h-10 mb-2 text-[#DECFFC]" />
              <p className="text-sm font-semibold text-[#1C2926]">No applications pending review</p>
              <p className="text-xs text-[#616166] mt-1 max-w-sm">
                When new providers complete onboarding and submit documents, their applications will appear here for review.
              </p>
            </div>
          ) : (
            filteredApplications.map((app, idx) => {
              const CategoryIcon = app.categoryIcon || Disc
              const isSelected = selectedRows.includes(app.id)
              const isBottomRow = idx >= filteredApplications.length - 2 && filteredApplications.length > 1

              return (
                <div
                  key={app.id}
                  style={{
                    height: '62px',
                  }}
                  className={`w-full px-4 sm:px-5 flex items-center shrink-0 border-b border-[#F0EFF2] transition-colors hover:bg-[#FAF9FD] ${
                    isSelected ? 'bg-[#F9F7FE]' : 'bg-white'
                  }`}
                >
                  <div className="w-[32px] flex items-center justify-start shrink-0">
                    <input
                      type="checkbox"
                      checked={isSelected}
                      onChange={() => toggleSelectRow(app.id)}
                      className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
                    />
                  </div>

                  <div className="flex-1 min-w-[120px] flex items-center pr-2">
                    <div className="flex flex-col min-w-0">
                      <div className="flex items-center gap-1.5">
                        <span className="text-[13px] font-semibold text-[#1C2926] leading-tight truncate">
                          {app.name}
                        </span>
                        <span
                          title={app.isOnline ? 'Online' : 'Offline'}
                          className={`w-2 h-2 rounded-full shrink-0 ${
                            app.isOnline
                              ? 'bg-[#22C55E] ring-2 ring-[#22C55E]/30 animate-pulse'
                              : 'bg-[#D1D5DB]'
                          }`}
                        />
                      </div>
                      {app.phone ? (
                        <div className="flex items-center gap-1 text-[11px] text-[#616166] mt-0.5">
                          <Phone className="w-2.5 h-2.5 text-[#9EAFA9] shrink-0" />
                          <span className="truncate">{app.phone}</span>
                        </div>
                      ) : (
                        <span className="text-[11px] text-[#9EAFA9] mt-0.5">New Registration</span>
                      )}
                    </div>
                  </div>

                  <div className="w-[130px] flex items-center gap-2 shrink-0">
                    <div className="w-6 h-6 rounded-md bg-[#F5F3FF] flex items-center justify-center shrink-0 text-[#8B53FE]">
                      <CategoryIcon className="w-3.5 h-3.5" />
                    </div>
                    <span className="text-xs font-medium text-[#1C2926] truncate">
                      {app.category}
                    </span>
                  </div>

                  <div className="w-[185px] flex flex-col justify-center shrink-0 text-xs pr-2">
                    <div className="flex items-center gap-1.5 text-[#1C2926]" title={app.city}>
                      <MapPin
                        className={`w-3.5 h-3.5 shrink-0 ${
                          app.isOnline ? 'text-[#16A34A] animate-pulse' : 'text-[#8B53FE]'
                        }`}
                      />
                      <span className="font-medium text-[12px] text-[#1C2926] leading-tight break-words line-clamp-1">
                        {app.city}
                      </span>
                    </div>
                    {app.hasCoordinates && (
                      <span
                        className="text-[10px] text-[#616166] font-mono mt-0.5 pl-5 truncate"
                        title={`GPS: ${app.latitude}, ${app.longitude}`}
                      >
                        {app.latitude.toFixed(4)}, {app.longitude.toFixed(4)}
                      </span>
                    )}
                  </div>

                  <div className="w-[115px] flex flex-col shrink-0">
                    <span className="text-xs font-medium text-[#1C2926] leading-tight">
                      {app.submittedDate}
                    </span>
                    <span className="text-[11px] text-[#9EAFA9] leading-tight mt-0.5">
                      {app.submittedTime}
                    </span>
                  </div>

                  <div className="w-[105px] shrink-0">
                    <span
                      className={`inline-flex items-center px-2.5 py-1 rounded-full text-[11px] font-semibold leading-none ${getStatusBadge(
                        app.status
                      )}`}
                    >
                      {app.status}
                    </span>
                  </div>

                  <div className="w-[125px] flex items-center justify-end gap-1.5 shrink-0 relative pr-1">
                    <button
                      type="button"
                      onClick={() => onViewDetails && onViewDetails(app)}
                      className="whitespace-nowrap px-2.5 py-1.5 rounded-lg bg-[#EFF6FF] text-[#2563EB] hover:bg-[#DBEAFE] text-xs font-semibold transition-colors cursor-pointer shrink-0 shadow-2xs"
                    >
                      View Details
                    </button>

                    <div className="relative shrink-0">
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation()
                          setActiveRowMenu((prev) => (prev === app.id ? null : app.id))
                        }}
                        className="p-1 rounded-md text-[#9EAFA9] hover:text-[#1C2926] hover:bg-[#F3F4F6] transition-colors cursor-pointer"
                      >
                        <MoreHorizontal className="w-4 h-4" />
                      </button>

                      {activeRowMenu === app.id && (
                        <div
                          className={`absolute right-0 w-44 bg-white border border-[#EFF0ED] rounded-xl shadow-xl py-1.5 z-50 animate-in fade-in zoom-in-95 duration-100 ${
                            isBottomRow ? 'bottom-full mb-1' : 'top-full mt-1'
                          }`}
                        >
                          <button
                            type="button"
                            onClick={() => {
                              setActiveRowMenu(null)
                              if (onViewDetails) onViewDetails(app)
                            }}
                            className="w-full px-3 py-1.5 text-xs text-left text-[#1C2926] hover:bg-[#F0EAFE] flex items-center gap-2 cursor-pointer"
                          >
                            <Eye className="w-3.5 h-3.5 text-[#8B53FE]" />
                            <span>Inspect Docs</span>
                          </button>

                          {app.status === 'Approved' ? (
                            <>
                              <button
                                type="button"
                                onClick={() => handleSuspend(app)}
                                className="w-full px-3 py-1.5 text-xs text-left text-[#EA580C] hover:bg-[#FFF7ED] flex items-center gap-2 cursor-pointer"
                              >
                                <PauseCircle className="w-3.5 h-3.5 text-[#EA580C]" />
                                <span>Suspend</span>
                              </button>
                              <button
                                type="button"
                                onClick={() => handleBlock(app)}
                                className="w-full px-3 py-1.5 text-xs text-left text-[#E11D48] hover:bg-[#FFF1F2] flex items-center gap-2 cursor-pointer"
                              >
                                <Ban className="w-3.5 h-3.5 text-[#E11D48]" />
                                <span>Block</span>
                              </button>
                              <button
                                type="button"
                                onClick={() => handleDelete(app)}
                                className="w-full px-3 py-1.5 text-xs text-left text-[#DC2626] hover:bg-[#FEF2F2] flex items-center gap-2 cursor-pointer border-t border-[#F0EFF2]"
                              >
                                <Trash2 className="w-3.5 h-3.5 text-[#DC2626]" />
                                <span>Delete</span>
                              </button>
                            </>
                          ) : (
                            <>
                              <button
                                type="button"
                                onClick={() => handleApprove(app)}
                                className="w-full px-3 py-1.5 text-xs text-left text-[#16A34A] hover:bg-[#E9FBF0] flex items-center gap-2 cursor-pointer"
                              >
                                <CheckCircle className="w-3.5 h-3.5 text-[#16A34A]" />
                                <span>Approve</span>
                              </button>
                              <button
                                type="button"
                                onClick={() => handleRequestResubmission(app)}
                                className="w-full px-3 py-1.5 text-xs text-left text-[#D97706] hover:bg-[#FEF3E2] flex items-center gap-2 cursor-pointer"
                              >
                                <RotateCcw className="w-3.5 h-3.5 text-[#D97706]" />
                                <span>Request Resubmission</span>
                              </button>
                              <button
                                type="button"
                                onClick={() => handleReject(app)}
                                className="w-full px-3 py-1.5 text-xs text-left text-[#DC2626] hover:bg-[#FEF2F2] flex items-center gap-2 cursor-pointer"
                              >
                                <XCircle className="w-3.5 h-3.5 text-[#DC2626]" />
                                <span>Reject</span>
                              </button>
                            </>
                          )}
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              )
            })
          )}
        </div>
      </div>

      {/* Footer */}
      <div
        style={{
          height: '52px',
        }}
        className="w-full px-5 flex items-center justify-between shrink-0 border-t border-[#F0EFF2] bg-white"
      >
        <span className="text-xs text-[#616166] font-normal">
          Showing {filteredApplications.length} of {applicationsList.length} applications
        </span>

        <div className="flex items-center gap-1.5">
          <button
            type="button"
            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            className="w-8 h-8 rounded-lg border border-[#EBEBEB] text-[#616166] hover:bg-[#F9F9FB] flex items-center justify-center transition-colors cursor-pointer"
          >
            <ChevronLeft className="w-4 h-4" />
          </button>
          <button
            type="button"
            className="w-8 h-8 rounded-lg text-xs font-semibold flex items-center justify-center border border-[#8B53FE] text-[#8B53FE] bg-white shadow-2xs"
          >
            1
          </button>
          <button
            type="button"
            onClick={() => setCurrentPage((p) => p + 1)}
            className="w-8 h-8 rounded-lg border border-[#EBEBEB] text-[#616166] hover:bg-[#F9F9FB] flex items-center justify-center transition-colors cursor-pointer"
          >
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  )
}

export default VerificationTableSection
