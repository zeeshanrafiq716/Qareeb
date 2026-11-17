import React, { useState, useEffect } from 'react'
import {
  Users,
  UserCheck,
  UserX,
  ShieldAlert,
  Search,
  ChevronDown,
  ChevronsUpDown,
  Phone,
  Compass,
  Disc,
  Truck,
  Fuel,
  Wrench,
  Key,
  Clock,
  MoreHorizontal,
  ChevronLeft,
  ChevronRight,
  Check,
  Eye,
  CheckCircle,
  Ban,
  PauseCircle,
  Trash2,
  Plus,
  X,
} from 'lucide-react'
import {
  fetchProviders,
  fetchCategories,
  createProviderApi,
  suspendProviderApi,
  blockProviderApi,
  reinstateProviderApi,
  deleteProviderApi,
} from '../api/admin'

export function ProviderDirectoryView({
  onViewProfile,
}) {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategory, setSelectedCategory] = useState('All Categories')
  const [selectedStatus, setSelectedStatus] = useState('All Status')
  const [selectedDateRange, setSelectedDateRange] = useState('Registered Date')
  const [categoryOpen, setCategoryOpen] = useState(false)
  const [statusOpen, setStatusOpen] = useState(false)
  const [dateRangeOpen, setDateRangeOpen] = useState(false)
  const [activeFilterCard, setActiveFilterCard] = useState('all') // 'all' | 'active' | 'pending' | 'inactive' | 'suspended'
  const [activeRowMenu, setActiveRowMenu] = useState(null)
  const [selectedRows, setSelectedRows] = useState([])
  const [currentPage, setCurrentPage] = useState(1)
  const [providersList, setProvidersList] = useState([])
  const [loading, setLoading] = useState(true)
  const [showAddModal, setShowAddModal] = useState(false)
  const [addForm, setAddForm] = useState({ phone: '', name: '', categoryId: '' })
  const [categoryOptions, setCategoryOptions] = useState([])
  const [addError, setAddError] = useState('')
  const [addSaving, setAddSaving] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  // Fetch real providers from backend API
  useEffect(() => {
    let mounted = true
    async function loadRealProviders(isSilent = false) {
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
        // Business Rule: Providers show in admin panel once they register and verify phone (excluding abandoned pending_otp)
        const onboardedItems = rawItems.filter(
          (item) => item.status !== 'pending_otp'
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

          let stStr = 'Active'
          if (item.status === 'suspended') stStr = 'Suspended'
          else if (item.status === 'pending_verification') stStr = 'Pending Approval'
          else if (item.status === 'pending_profile') stStr = 'In Onboarding'
          else if (item.status === 'blocked') stStr = 'Blocked'
          else if (item.status === 'rejected') stStr = 'Inactive'

          const isOnline = Boolean(item.isOnline ?? item.presence?.isOnline)
          const lat = item.location?.latitude != null ? Number(item.location.latitude) : null
          const lng = item.location?.longitude != null ? Number(item.location.longitude) : null
          const locationCity = item.location?.city || item.city || (lat != null && lng != null ? `${lat.toFixed(4)}, ${lng.toFixed(4)}` : 'Location Pending')
          const locationAddress = item.location?.address || ''

          const rawName = (item.name || '').trim()
          const hasRealName =
            rawName.length > 0 &&
            rawName !== 'Provider' &&
            !/^provider\s*\(/i.test(rawName)
          const displayName = hasRealName
            ? rawName
            : item.phone
              ? 'Provider'
              : 'New Provider'

          return {
            id: item.providerId || `QRB-1000${String(idx + 1).padStart(2, '0')}`,
            backendId: item.id,
            name: displayName,
            phone: item.phone,
            isOnline,
            latitude: lat,
            longitude: lng,
            hasCoordinates: lat != null && lng != null,
            location: locationCity,
            address: locationAddress,
            whatsapp: item.whatsapp || item.whatsappNumber || item.phone,
            nationalId: item.nationalId || item.iqamaNumber || 'Pending Submission',
            iqamaExpiry: item.iqamaExpiry || 'Pending Submission',
            vehicleModel: item.vehicleModel || 'Pending Submission',
            vehicleType: item.vehicleType || 'Roadside Vehicle',
            plateNumber: item.plateNumber || 'Pending Submission',
            vehicleColor: item.vehicleColor || 'Pending',
            category: catName,
            categoryIcon: Icon,
            registeredDate: dateStr,
            registeredTime: timeStr,
            status: stStr,
            statusType: stStr.toLowerCase(),
            avatar: item.photoUrl || `https://images.unsplash.com/photo-${1500000000000 + (idx * 1234567) % 500000000}?auto=format&fit=crop&w=120&h=120&q=80`,
          }
        })
        setProvidersList(mapped)
      } catch (err) {
        console.error('Failed to load real providers from backend:', err)
      } finally {
        if (mounted && !isSilent) setLoading(false)
      }
    }
    // 1. Initial load
    loadRealProviders(false)

    // 2. Real-time background sync interval (every 2.5 seconds without manual refresh)
    const intervalTimer = setInterval(() => {
      loadRealProviders(true)
    }, 2500)

    // 3. Instant sync when browser tab gains focus or window becomes visible
    const handleFocus = () => loadRealProviders(true)
    const handleVisibility = () => {
      if (document.visibilityState === 'visible') loadRealProviders(true)
    }
    window.addEventListener('focus', handleFocus)
    document.addEventListener('visibilitychange', handleVisibility)

    return () => {
      mounted = false
      clearInterval(intervalTimer)
      window.removeEventListener('focus', handleFocus)
      document.removeEventListener('visibilitychange', handleVisibility)
    }
  }, [refreshKey])

  const stats = {
    total: providersList.length,
    online: providersList.filter((p) => p.isOnline).length,
    offline: providersList.filter((p) => !p.isOnline).length,
    active: providersList.filter((p) => p.status === 'Active').length,
    pending: providersList.filter((p) => p.status === 'Pending Approval' || p.status === 'In Onboarding').length,
    inactive: providersList.filter((p) => p.status === 'Inactive' || p.status === 'Blocked').length,
    suspended: providersList.filter((p) => p.status === 'Suspended').length,
  }

  const [categories, setCategories] = useState(['All Categories'])

  // Load real categories from DB and active providers (No mock/seed data)
  useEffect(() => {
    async function loadRealCategories() {
      try {
        const res = await fetchCategories()
        const items = res?.data || res?.items || []
        const apiNames = items.map((c) => c.name).filter(Boolean)
        const providerCatNames = providersList
          .map((p) => p.category)
          .filter((cat) => cat && cat !== 'Pending Registration')
        const unique = Array.from(new Set([...apiNames, ...providerCatNames]))
        setCategories(['All Categories', ...unique])
        setCategoryOptions(items.filter((c) => c.id && c.name))
      } catch {
        const providerCatNames = Array.from(
          new Set(
            providersList
              .map((p) => p.category)
              .filter((cat) => cat && cat !== 'Pending Registration')
          )
        )
        setCategories(['All Categories', ...providerCatNames])
      }
    }
    loadRealCategories()
  }, [providersList])
  const statuses = ['All Status', 'Online', 'Offline', 'Active', 'Pending Approval', 'In Onboarding', 'Inactive', 'Suspended']
  const dateRanges = ['Registered Date', 'Today', 'Last 7 Days', 'Last 30 Days', 'This Month', 'All Time']

  const metricCards = [
    {
      id: 'all',
      title: 'Total Providers',
      count: stats.total,
      icon: Users,
      iconBg: 'bg-[#F4EFFE] text-[#8B53FE]',
      activeRing: 'border-[#8B53FE] ring-2 ring-[#8B53FE]/15',
    },
    {
      id: 'online',
      title: 'Online Now',
      count: stats.online,
      icon: UserCheck,
      iconBg: 'bg-[#E9FBF0] text-[#16A34A]',
      activeRing: 'border-[#16A34A] ring-2 ring-[#16A34A]/15',
    },
    {
      id: 'pending',
      title: 'Pending Approval',
      count: stats.pending,
      icon: Clock,
      iconBg: 'bg-[#FEF3E2] text-[#D97706]',
      activeRing: 'border-[#D97706] ring-2 ring-[#D97706]/15',
    },
    {
      id: 'suspended',
      title: 'Suspended',
      count: stats.suspended,
      icon: ShieldAlert,
      iconBg: 'bg-[#FEE2E2] text-[#DC2626]',
      activeRing: 'border-[#DC2626] ring-2 ring-[#DC2626]/15',
    },
  ]

  const getStatusColor = (status) => {
    switch (status) {
      case 'Active':
        return 'text-[#16A34A]'
      case 'Pending Approval':
      case 'In Onboarding':
        return 'text-[#D97706]'
      case 'Inactive':
        return 'text-[#616166]'
      case 'Suspended':
      case 'Blocked':
        return 'text-[#DC2626]'
      default:
        return 'text-[#616166]'
    }
  }

  /** Shared grid: checkbox | provider | category | location | registered | status | action */
  const providerRowGrid =
    'grid w-full items-center gap-x-5 md:gap-x-6 ' +
    'grid-cols-[2rem_minmax(8rem,1.4fr)_minmax(7rem,1.15fr)_minmax(7rem,1.05fr)_minmax(6.25rem,0.95fr)_minmax(5.75rem,0.9fr)_minmax(6.25rem,auto)]'

  // Filtering
  const filteredProviders = providersList.filter((p) => {
    const matchesSearch =
      !searchQuery ||
      p.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.id?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (p.phone && p.phone.includes(searchQuery)) ||
      p.location?.toLowerCase().includes(searchQuery.toLowerCase())

    const matchesCategory =
      selectedCategory === 'All Categories' || p.category === selectedCategory

    const matchesDropdownStatus =
      selectedStatus === 'All Status' ||
      (selectedStatus === 'Online' && p.isOnline) ||
      (selectedStatus === 'Offline' && !p.isOnline) ||
      p.status === selectedStatus

    const matchesCardFilter =
      activeFilterCard === 'all' ||
      (activeFilterCard === 'online' && p.isOnline) ||
      (activeFilterCard === 'active' && p.status === 'Active') ||
      (activeFilterCard === 'pending' && (p.status === 'Pending Approval' || p.status === 'In Onboarding')) ||
      (activeFilterCard === 'inactive' && (p.status === 'Inactive' || p.status === 'Blocked')) ||
      (activeFilterCard === 'suspended' && p.status === 'Suspended')

    return matchesSearch && matchesCategory && matchesDropdownStatus && matchesCardFilter
  })

  const toggleSelectAll = () => {
    if (selectedRows.length === filteredProviders.length) {
      setSelectedRows([])
    } else {
      setSelectedRows(filteredProviders.map((p) => p.id))
    }
  }

  const toggleSelectRow = (id) => {
    setSelectedRows((prev) =>
      prev.includes(id) ? prev.filter((r) => r !== id) : [...prev, id]
    )
  }

  const handleUpdateStatus = async (id, newStatus) => {
    const targetProv = providersList.find((p) => p.id === id)
    setProvidersList((prev) =>
      prev.map((p) => (p.id === id ? { ...p, status: newStatus } : p))
    )
    setActiveRowMenu(null)

    if (targetProv?.backendId) {
      try {
        if (newStatus === 'Active') {
          await reinstateProviderApi(targetProv.backendId)
        } else if (newStatus === 'Suspended') {
          await suspendProviderApi(targetProv.backendId, 'Suspended by admin')
        } else if (newStatus === 'Blocked') {
          await blockProviderApi(targetProv.backendId, 'Blocked by admin')
        }
      } catch (err) {
        console.error('Failed to update provider status on backend:', err)
      }
    }
  }

  const handleAddProvider = async (e) => {
    e.preventDefault()
    setAddError('')
    if (!addForm.phone.trim()) {
      setAddError('Phone number is required.')
      return
    }
    setAddSaving(true)
    try {
      await createProviderApi({
        phone: addForm.phone.trim(),
        ...(addForm.name.trim() ? { name: addForm.name.trim() } : {}),
        ...(addForm.categoryId ? { categoryId: addForm.categoryId } : {}),
      })
      setShowAddModal(false)
      setAddForm({ phone: '', name: '', categoryId: '' })
      setRefreshKey((k) => k + 1)
    } catch (err) {
      setAddError(err?.response?.data?.message || 'Could not create provider.')
    } finally {
      setAddSaving(false)
    }
  }

  const handleDeleteProvider = async (prov) => {
    setActiveRowMenu(null)
    if (!window.confirm(`Are you sure you want to permanently delete provider "${prov.name}"? This action cannot be undone.`)) {
      return
    }
    setProvidersList((prev) => prev.filter((p) => p.id !== prov.id))
    if (prov.backendId) {
      try {
        await deleteProviderApi(prov.backendId)
      } catch (err) {
        console.error('Failed to delete provider on backend:', err)
      }
    }
  }

  return (
    <div className="w-full max-w-[1084px] flex flex-col gap-5 shrink-0 select-none pb-8 animate-in fade-in duration-150">
      {/* ================= 1. TITLE & SUBTITLE SECTION ================= */}
      <div className="flex items-start justify-between gap-4">
        <div className="flex flex-col">
          <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
            Provider Directory
          </h1>
          <p className="text-[13px] text-[#566663] font-normal mt-1 leading-snug">
            Manage all registered providers view their details and control their account status.
          </p>
        </div>
        <button
          type="button"
          onClick={() => {
            setAddError('')
            setShowAddModal(true)
          }}
          className="h-[40px] px-4 rounded-xl bg-[#8B53FE] text-white text-xs font-semibold hover:bg-[#7B43EE] flex items-center gap-2 shrink-0 cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          Add Provider
        </button>
      </div>

      {/* ================= 2. 4 METRIC CARDS ROW (gap: 16px) ================= */}
      <div className="w-full grid grid-cols-2 lg:grid-cols-4 gap-4 shrink-0">
        {metricCards.map((card) => {
          const IconComp = card.icon
          const isActive = activeFilterCard === card.id

          return (
            <div
              key={card.id}
              onClick={() => setActiveFilterCard((prev) => (prev === card.id ? 'all' : card.id))}
              className={`h-[110px] rounded-[20px] bg-white p-5 border shadow-xs flex flex-col justify-between transition-all cursor-pointer ${
                isActive
                  ? card.activeRing
                  : 'border-[#EBEBEB] hover:border-[#DECFFC] hover:shadow-sm'
              }`}
            >
              {/* Top Row: Icon + Title + Chevron */}
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2.5 min-w-0">
                  <div
                    className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${card.iconBg}`}
                  >
                    <IconComp className="w-4 h-4" />
                  </div>
                  <span className="text-[13px] font-semibold text-[#1C2926] whitespace-nowrap">
                    {card.title}
                  </span>
                </div>

                <span className="text-[#9EAFA9] text-sm">›</span>
              </div>

              {/* Bottom Row: Count */}
              <div className="text-[28px] font-bold text-[#1C2926] leading-none tracking-tight">
                {card.count}
              </div>
            </div>
          )
        })}
      </div>

      {/* ================= 3. PROVIDER DIRECTORY TABLE CONTAINER ================= */}
      <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0 overflow-hidden">
        {/* Filters Row */}
        <div className="w-full px-5 py-3.5 flex items-center justify-between shrink-0">
          <div className="relative w-full max-w-[380px] flex items-center">
            <Search className="w-4 h-4 text-[#9EAFA9] absolute left-3.5 pointer-events-none" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by name or phone number..."
              className="w-full h-[40px] pl-10 pr-4 text-xs font-normal text-[#1C2926] placeholder-[#9EAFA9] bg-white border border-[#EBEBEB] rounded-xl focus:border-[#8B53FE] focus:ring-2 focus:ring-[#8B53FE]/15 transition-all outline-none"
            />
          </div>

          <div className="flex items-center gap-3">
            {/* Categories Dropdown */}
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

            {/* Status Dropdown */}
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

            {/* Registered Date Dropdown */}
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

        {/* Table Area - No Horizontal Scrollbar */}
        <div className="w-full overflow-x-hidden flex-1 flex flex-col justify-start min-h-[300px]">
          {/* Menubar / Table Header */}
          <div
            style={{
              height: '56px',
            }}
            className={`w-full bg-[#F4F2F7] px-5 shrink-0 text-[12px] font-semibold text-[#616166] ${providerRowGrid}`}
          >
            <div className="flex items-center justify-start">
              <input
                type="checkbox"
                checked={
                  selectedRows.length > 0 &&
                  selectedRows.length === filteredProviders.length
                }
                onChange={toggleSelectAll}
                className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
              />
            </div>
            <div className="flex items-center gap-1.5 min-w-0">
              <span>Provider</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9] shrink-0" />
            </div>
            <div className="flex items-center gap-1.5 min-w-0">
              <span>Service Category</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9] shrink-0" />
            </div>
            <div className="flex items-center gap-1.5 min-w-0">
              <span>Location (GPS)</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9] shrink-0" />
            </div>
            <div className="flex items-center gap-1.5 min-w-0">
              <span>Registered On</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9] shrink-0" />
            </div>
            <div className="flex items-center gap-1.5 min-w-0">
              <span>Status</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9] shrink-0" />
            </div>
            <div className="flex items-center justify-end gap-1.5 pr-1">
              <span>Action</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9] shrink-0" />
            </div>
          </div>

          {/* Table Body / Real Empty State */}
          <div className="flex-1 flex flex-col justify-start">
            {loading ? (
              <div className="w-full py-16 flex flex-col items-center justify-center text-center text-[#9EAFA9]">
                <div className="w-7 h-7 border-2 border-[#8B53FE] border-t-transparent rounded-full animate-spin mb-3" />
                <p className="text-xs text-[#616166]">Loading real provider records...</p>
              </div>
            ) : filteredProviders.length === 0 ? (
              <div className="w-full py-16 flex flex-col items-center justify-center text-center text-[#9EAFA9]">
                <Users className="w-10 h-10 mb-2 text-[#DECFFC]" />
                <p className="text-sm font-semibold text-[#1C2926]">No providers registered yet</p>
                <p className="text-xs text-[#616166] mt-1 max-w-sm">
                  Providers who register and submit their details via the Qareeb application will be listed here.
                </p>
              </div>
            ) : (
              filteredProviders.map((p, idx) => {
                const CategoryIcon = p.categoryIcon || Disc
                const isSelected = selectedRows.includes(p.id)
                // Only open upwards if genuinely in the lower half of a longer table (never for top rows 0, 1, 2)
                const isBottomRow = filteredProviders.length >= 4 && idx >= 3 && idx >= filteredProviders.length - 2

                return (
                  <div
                    key={p.id}
                    className={`w-full px-5 min-h-[60px] py-2 shrink-0 border-b border-[#F0EFF2] transition-colors hover:bg-[#FAF9FD] ${
                      isSelected ? 'bg-[#F9F7FE]' : 'bg-white'
                    } ${activeRowMenu === p.id ? 'relative z-30' : 'relative z-0'} ${providerRowGrid}`}
                  >
                    <div className="flex items-center justify-start">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => toggleSelectRow(p.id)}
                        className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
                      />
                    </div>

                    <div className="flex items-center min-w-0">
                      <div className="flex flex-col min-w-0 w-full">
                        <div className="flex items-center gap-1.5 min-w-0">
                          <span className="text-[13px] font-semibold text-[#1C2926] leading-tight">
                            {p.name}
                          </span>
                          <span
                            title={p.isOnline ? 'Online' : 'Offline'}
                            className={`w-2 h-2 rounded-full shrink-0 ${
                              p.isOnline
                                ? 'bg-[#22C55E] ring-2 ring-[#22C55E]/30 animate-pulse'
                                : 'bg-[#D1D5DB]'
                            }`}
                          />
                        </div>
                        <div className="flex items-center gap-1 text-[11px] text-[#616166] mt-0.5 min-w-0">
                          <Phone className="w-2.5 h-2.5 text-[#9EAFA9] shrink-0" />
                          <span className="whitespace-nowrap">{p.phone}</span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center gap-2 min-w-0">
                      <CategoryIcon className="w-4 h-4 text-[#9EAFA9] shrink-0" />
                      <span className="text-xs font-normal text-[#1C2926] whitespace-normal break-words leading-snug">
                        {p.category}
                      </span>
                    </div>

                    <div className="flex flex-col min-w-0 text-xs">
                      <div className="flex items-center gap-1 text-[#1C2926] min-w-0">
                        <Compass
                          className={`w-3.5 h-3.5 shrink-0 ${
                            p.isOnline ? 'text-[#16A34A] animate-pulse' : 'text-[#9EAFA9]'
                          }`}
                        />
                        <span className="font-medium whitespace-normal break-words leading-snug">
                          {p.location}
                        </span>
                      </div>
                      {p.hasCoordinates ? (
                        <span
                          className="text-[10px] text-[#616166] font-mono mt-0.5"
                          title={`GPS: ${p.latitude}, ${p.longitude}${
                            p.address ? ` (${p.address})` : ''
                          }`}
                        >
                          {p.latitude.toFixed(4)}, {p.longitude.toFixed(4)}
                        </span>
                      ) : (
                        <span className="text-[10px] text-[#9EAFA9] mt-0.5">GPS pending</span>
                      )}
                    </div>

                    <div className="flex flex-col min-w-0">
                      <span className="text-xs font-medium text-[#1C2926] leading-tight">
                        {p.registeredDate}
                      </span>
                      <span className="text-[11px] text-[#9EAFA9] leading-tight mt-0.5">
                        {p.registeredTime}
                      </span>
                    </div>

                    <div className="flex flex-col gap-1 min-w-0">
                      <div className="flex items-center">
                        <span
                          className={`inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[11px] font-semibold ${
                            p.isOnline
                              ? 'bg-[#E9FBF0] text-[#16A34A] border border-[#BBF7D0]'
                              : 'bg-[#F3F4F6] text-[#6B7280] border border-[#E5E7EB]'
                          }`}
                        >
                          <span
                            className={`w-1.5 h-1.5 rounded-full ${
                              p.isOnline
                                ? 'bg-[#22C55E] ring-2 ring-[#22C55E]/40 animate-pulse'
                                : 'bg-[#9CA3AF]'
                            }`}
                          />
                          {p.isOnline ? 'Online' : 'Offline'}
                        </span>
                      </div>
                      <span
                        className={`text-[11px] font-medium leading-tight ${getStatusColor(
                          p.status
                        )}`}
                      >
                        {p.status}
                      </span>
                    </div>

                    <div className="flex items-center justify-end gap-2 relative pr-1">
                      <button
                        type="button"
                        onClick={() => onViewProfile && onViewProfile(p)}
                        className="whitespace-nowrap px-3 py-1.5 rounded-lg bg-[#EFF6FF] text-[#2563EB] hover:bg-[#DBEAFE] text-xs font-medium transition-colors cursor-pointer shrink-0"
                      >
                        View Profile
                      </button>

                      <div className="relative shrink-0">
                        <button
                          type="button"
                          onClick={() =>
                            setActiveRowMenu((prev) => (prev === p.id ? null : p.id))
                          }
                          className="p-1 rounded-md text-[#9EAFA9] hover:text-[#1C2926] hover:bg-[#F3F4F6] transition-colors cursor-pointer"
                        >
                          <MoreHorizontal className="w-4 h-4" />
                        </button>

                        {activeRowMenu === p.id && (
                          <div
                            className={`absolute right-0 w-44 bg-white border border-[#EFF0ED] rounded-xl shadow-xl py-1.5 z-50 animate-in fade-in zoom-in-95 duration-100 ${
                              isBottomRow ? 'bottom-full mb-1' : 'top-full mt-1'
                            }`}
                          >
                            <button
                              type="button"
                              onClick={() => {
                                setActiveRowMenu(null)
                                if (onViewProfile) onViewProfile(p)
                              }}
                              className="w-full px-3 py-1.5 text-xs text-left text-[#1C2926] hover:bg-[#F0EAFE] flex items-center gap-2 cursor-pointer"
                            >
                              <Eye className="w-3.5 h-3.5 text-[#8B53FE]" />
                              <span>View Details</span>
                            </button>
                            {p.status !== 'Active' && (
                              <button
                                type="button"
                                onClick={() => handleUpdateStatus(p.id, 'Active')}
                                className="w-full px-3 py-1.5 text-xs text-left text-[#16A34A] hover:bg-[#E9FBF0] flex items-center gap-2 cursor-pointer"
                              >
                                <CheckCircle className="w-3.5 h-3.5 text-[#16A34A]" />
                                <span>Set Active</span>
                              </button>
                            )}
                            <button
                              type="button"
                              onClick={() => handleUpdateStatus(p.id, 'Suspended')}
                              className="w-full px-3 py-1.5 text-xs text-left text-[#EA580C] hover:bg-[#FFF7ED] flex items-center gap-2 cursor-pointer"
                            >
                              <PauseCircle className="w-3.5 h-3.5 text-[#EA580C]" />
                              <span>Suspend</span>
                            </button>
                            <button
                              type="button"
                              onClick={() => handleUpdateStatus(p.id, 'Blocked')}
                              className="w-full px-3 py-1.5 text-xs text-left text-[#E11D48] hover:bg-[#FFF1F2] flex items-center gap-2 cursor-pointer"
                            >
                              <Ban className="w-3.5 h-3.5 text-[#E11D48]" />
                              <span>Block</span>
                            </button>
                            <button
                              type="button"
                              onClick={() => handleDeleteProvider(p)}
                              className="w-full px-3 py-1.5 text-xs text-left text-[#DC2626] hover:bg-[#FEF2F2] flex items-center gap-2 cursor-pointer border-t border-[#F0EFF2]"
                            >
                              <Trash2 className="w-3.5 h-3.5 text-[#DC2626]" />
                              <span>Delete</span>
                            </button>
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
            Showing {filteredProviders.length} of {providersList.length} providers
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

      {showAddModal && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/40 p-4">
          <div className="w-full max-w-md bg-white rounded-2xl shadow-xl p-6 relative">
            <button
              type="button"
              onClick={() => setShowAddModal(false)}
              className="absolute top-4 right-4 text-[#9EAFA9] hover:text-[#1C2926] cursor-pointer"
            >
              <X className="w-5 h-5" />
            </button>
            <h2 className="text-lg font-bold text-[#1C2926] mb-1">Add Provider</h2>
            <p className="text-xs text-[#616166] mb-4">
              Create a provider account. They can complete profile and verification in the app.
            </p>
            <form onSubmit={handleAddProvider} className="space-y-3">
              <div>
                <label className="text-xs font-medium text-[#616166]">Phone</label>
                <input
                  type="text"
                  value={addForm.phone}
                  onChange={(e) => setAddForm((f) => ({ ...f, phone: e.target.value }))}
                  placeholder="+966501234567"
                  className="w-full mt-1 h-10 px-3 border border-[#EBEBEB] rounded-xl text-sm outline-none focus:border-[#8B53FE]"
                />
              </div>
              <div>
                <label className="text-xs font-medium text-[#616166]">Display name (optional)</label>
                <input
                  type="text"
                  value={addForm.name}
                  onChange={(e) => setAddForm((f) => ({ ...f, name: e.target.value }))}
                  placeholder="Provider name"
                  className="w-full mt-1 h-10 px-3 border border-[#EBEBEB] rounded-xl text-sm outline-none focus:border-[#8B53FE]"
                />
              </div>
              <div>
                <label className="text-xs font-medium text-[#616166]">Category (optional)</label>
                <select
                  value={addForm.categoryId}
                  onChange={(e) => setAddForm((f) => ({ ...f, categoryId: e.target.value }))}
                  className="w-full mt-1 h-10 px-3 border border-[#EBEBEB] rounded-xl text-sm outline-none focus:border-[#8B53FE] bg-white"
                >
                  <option value="">Select category</option>
                  {categoryOptions.map((cat) => (
                    <option key={cat.id} value={cat.id}>
                      {cat.name}
                    </option>
                  ))}
                </select>
              </div>
              {addError && <p className="text-xs text-[#DC2626]">{addError}</p>}
              <button
                type="submit"
                disabled={addSaving}
                className="w-full h-10 rounded-xl bg-[#8B53FE] text-white text-sm font-semibold hover:bg-[#7B43EE] disabled:opacity-60 cursor-pointer"
              >
                {addSaving ? 'Saving…' : 'Create Provider'}
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

export default ProviderDirectoryView
