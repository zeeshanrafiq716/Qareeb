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
  MoreHorizontal,
  ChevronLeft,
  ChevronRight,
  Check,
  Eye,
  CheckCircle,
  Ban,
  PauseCircle,
} from 'lucide-react'
import {
  fetchProviders,
  suspendProviderApi,
  reinstateProviderApi,
  approveProviderApi,
} from '../api/admin'

const REAL_SAUDI_PROVIDERS = [
  {
    id: 'QRB-100001',
    name: 'Ahmed Raza',
    phone: '+966 50 123 4567',
    category: 'Tyre Repair',
    categoryIcon: Disc,
    location: 'Jeddah',
    registeredDate: '23 Sept 2026',
    registeredTime: '10:00 AM',
    status: 'Active',
    statusType: 'active',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QRB-100002',
    name: 'Ali Ahmad',
    phone: '+966 50 234 5678',
    category: 'Battery Jump Start',
    categoryIcon: Disc,
    location: 'Riyadh',
    registeredDate: '22 Sept 2026',
    registeredTime: '10:15 PM',
    status: 'Active',
    statusType: 'active',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QRB-100003',
    name: 'Abdul Ahad',
    phone: '+966 50 345 6789',
    category: 'Fuel Delivery',
    categoryIcon: Fuel,
    location: 'Makkah',
    registeredDate: '21 Sept 2026',
    registeredTime: '12:00 AM',
    status: 'Suspended',
    statusType: 'suspended',
    avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QRB-100004',
    name: 'M Ibrahim',
    phone: '+966 50 456 7890',
    category: 'Tyre Repair',
    categoryIcon: Disc,
    location: 'Jeddah',
    registeredDate: '20 Sept 2026',
    registeredTime: '12:30 PM',
    status: 'Inactive',
    statusType: 'inactive',
    avatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QRB-100005',
    name: 'Awais Ali',
    phone: '+966 50 567 8901',
    category: 'Vehicle Towing',
    categoryIcon: Truck,
    location: 'Madinah',
    registeredDate: '19 Sept 2026',
    registeredTime: '11:30 AM',
    status: 'Active',
    statusType: 'active',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QRB-100006',
    name: 'Usman Khan',
    phone: '+966 50 678 9012',
    category: 'Car Lockout Assistance',
    categoryIcon: Key,
    location: 'Riyadh',
    registeredDate: '18 Sept 2026',
    registeredTime: '9:00 PM',
    status: 'Active',
    statusType: 'active',
    avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&h=120&q=80',
  },
]

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
  const [activeFilterCard, setActiveFilterCard] = useState('all') // 'all' | 'active' | 'inactive' | 'suspended'
  const [activeRowMenu, setActiveRowMenu] = useState(null)
  const [selectedRows, setSelectedRows] = useState([])
  const [currentPage, setCurrentPage] = useState(1)
  const [providersList, setProvidersList] = useState(REAL_SAUDI_PROVIDERS)
  const [loading, setLoading] = useState(false)

  // Fetch real providers from backend API
  useEffect(() => {
    let mounted = true
    async function loadRealProviders() {
      try {
        setLoading(true)
        const res = await fetchProviders({ limit: 50 })
        if (!mounted) return
        const rawItems = res?.items || []
        if (rawItems.length > 0) {
          const mapped = rawItems.map((item, idx) => {
            const catName = item.category?.name || 'Tyre Repair'
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
            else if (item.status === 'pending_verification' || item.status === 'pending_otp' || item.status === 'pending_profile') stStr = 'Inactive'
            else if (item.status === 'rejected') stStr = 'Inactive'

            const avatars = [
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&h=120&q=80',
            ]

            return {
              id: item.providerId || `QRB-1000${String(idx + 1).padStart(2, '0')}`,
              backendId: item.id,
              name: item.name || 'Provider',
              phone: item.phone,
              category: catName,
              categoryIcon: Icon,
              location: item.location?.city || 'Riyadh',
              registeredDate: dateStr,
              registeredTime: timeStr,
              status: stStr,
              statusType: stStr.toLowerCase(),
              avatar: item.photoUrl || avatars[idx % avatars.length],
            }
          })
          setProvidersList(mapped)
        }
      } catch (err) {
        console.error('Failed to load real providers from backend:', err)
      } finally {
        if (mounted) setLoading(false)
      }
    }
    loadRealProviders()
    return () => {
      mounted = false
    }
  }, [])

  const stats = {
    total: providersList.length,
    active: providersList.filter((p) => p.status === 'Active').length,
    inactive: providersList.filter((p) => p.status === 'Inactive').length,
    suspended: providersList.filter((p) => p.status === 'Suspended').length,
  }

  const categories = [
    'All Categories',
    'Tyre Repair',
    'Battery Jump Start',
    'Vehicle Towing',
    'Fuel Delivery',
    'Mobile Mechanic',
    'Car Lockout Assistance',
  ]
  const statuses = ['All Status', 'Active', 'Inactive', 'Suspended']
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
      id: 'active',
      title: 'Active',
      count: stats.active,
      icon: UserCheck,
      iconBg: 'bg-[#E9FBF0] text-[#16A34A]',
      activeRing: 'border-[#16A34A] ring-2 ring-[#16A34A]/15',
    },
    {
      id: 'inactive',
      title: 'Inactive',
      count: stats.inactive,
      icon: UserX,
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
      case 'Inactive':
        return 'text-[#D97706]'
      case 'Suspended':
        return 'text-[#DC2626]'
      default:
        return 'text-[#616166]'
    }
  }

  // Filtering
  const filteredProviders = providersList.filter((p) => {
    const matchesSearch =
      !searchQuery ||
      p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.phone.includes(searchQuery) ||
      p.location.toLowerCase().includes(searchQuery.toLowerCase())

    const matchesCategory =
      selectedCategory === 'All Categories' || p.category === selectedCategory

    const matchesDropdownStatus =
      selectedStatus === 'All Status' || p.status === selectedStatus

    const matchesCardFilter =
      activeFilterCard === 'all' ||
      (activeFilterCard === 'active' && p.status === 'Active') ||
      (activeFilterCard === 'inactive' && p.status === 'Inactive') ||
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
        }
      } catch (err) {
        console.error('Failed to update provider status on backend:', err)
      }
    }
  }

  return (
    <div className="w-full max-w-[1084px] flex flex-col gap-5 shrink-0 select-none pb-8 animate-in fade-in duration-150">
      {/* ================= 1. TITLE & SUBTITLE SECTION ================= */}
      <div className="flex flex-col">
        <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
          Provider Directory
        </h1>
        <p className="text-[13px] text-[#566663] font-normal mt-1 leading-snug">
          Manage all registered providers view their details and control their account status.
        </p>
      </div>

      {/* ================= 2. 4 METRIC CARDS ROW (gap: 16px) ================= */}
      <div className="w-full grid grid-cols-2 lg:grid-cols-4 gap-4 shrink-0">
        {metricCards.map((card) => {
          const IconComp = card.icon
          const isActive = activeFilterCard === card.id

          return (
            <div
              key={card.id}
              onClick={() => setActiveFilterCard(card.id)}
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
                  <span className="text-[13px] font-medium text-[#616166] truncate">
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

      {/* ================= 3. PROVIDER DIRECTORY TABLE CONTAINER (bg: white, border: 1px solid #EBEBEB, radius: 20px) ================= */}
      <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0 overflow-hidden">
        {/* Filters Row: Search input + 3 filter dropdowns */}
        <div className="w-full px-5 py-3.5 flex items-center justify-between shrink-0">
          {/* Search Input Box */}
          <div className="relative w-full max-w-[380px] flex items-center">
            <Search className="w-4 h-4 text-[#9EAFA9] absolute left-3.5 pointer-events-none" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by name, provider ID, or phone number..."
              className="w-full h-[40px] pl-10 pr-4 text-xs font-normal text-[#1C2926] placeholder-[#9EAFA9] bg-white border border-[#EBEBEB] rounded-xl focus:border-[#8B53FE] focus:ring-2 focus:ring-[#8B53FE]/15 transition-all outline-none"
            />
          </div>

          {/* 3 Dropdown Filter Buttons */}
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

        {/* Scrollable Table Area */}
        <div className="w-full overflow-x-auto custom-card-scrollbar flex-1 flex flex-col justify-start">
          {/* Menubar / Table Header (h: 56px, bg: #F4F2F7, px-5) */}
          <div
            style={{
              height: '56px',
            }}
            className="w-full min-w-[850px] bg-[#F4F2F7] px-5 flex items-center shrink-0 text-[12px] font-semibold text-[#616166]"
          >
            {/* Checkbox */}
            <div className="w-[32px] flex items-center justify-start shrink-0">
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

            {/* Provider */}
            <div className="flex-1 min-w-[155px] flex items-center gap-1.5">
              <span>Provider</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
            </div>

            {/* Provider ID */}
            <div className="w-[105px] flex items-center gap-1.5 shrink-0">
              <span>Provider ID</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
            </div>

            {/* Service Category */}
            <div className="w-[150px] flex items-center gap-1.5 shrink-0">
              <span>Service Category</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
            </div>

            {/* Location */}
            <div className="w-[100px] flex items-center gap-1.5 shrink-0">
              <span>Location</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
            </div>

            {/* Registered On */}
            <div className="w-[120px] flex items-center gap-1.5 shrink-0">
              <span>Registered On</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
            </div>

            {/* Status */}
            <div className="w-[85px] flex items-center gap-1.5 shrink-0">
              <span>Status</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
            </div>

            {/* Action */}
            <div className="w-[145px] flex items-center justify-end gap-1.5 shrink-0 pr-1">
              <span>Action</span>
              <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
            </div>
          </div>

          {/* Table Body */}
          <div className="flex-1 flex flex-col justify-start">
            {filteredProviders.map((p) => {
              const CategoryIcon = p.categoryIcon || Disc
              const isSelected = selectedRows.includes(p.id)

              return (
                <div
                  key={p.id}
                  style={{
                    height: '60px',
                  }}
                  className={`w-full min-w-[850px] px-5 flex items-center shrink-0 border-b border-[#F0EFF2] transition-colors hover:bg-[#FAF9FD] ${
                    isSelected ? 'bg-[#F9F7FE]' : 'bg-white'
                  }`}
                >
                  {/* Checkbox */}
                  <div className="w-[32px] flex items-center justify-start shrink-0">
                    <input
                      type="checkbox"
                      checked={isSelected}
                      onChange={() => toggleSelectRow(p.id)}
                      className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
                    />
                  </div>

                  {/* Provider: Avatar + Name + Phone */}
                  <div className="flex-1 min-w-[155px] flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full overflow-hidden shrink-0 border border-[#EFF0ED]">
                      <img
                        src={p.avatar}
                        alt={p.name}
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div className="flex flex-col min-w-0">
                      <span className="text-[13px] font-semibold text-[#1C2926] leading-tight truncate">
                        {p.name}
                      </span>
                      <div className="flex items-center gap-1 text-[11px] text-[#616166] mt-0.5">
                        <Phone className="w-2.5 h-2.5 text-[#9EAFA9] shrink-0" />
                        <span className="truncate">{p.phone}</span>
                      </div>
                    </div>
                  </div>

                  {/* Provider ID */}
                  <div className="w-[105px] text-xs font-normal text-[#616166] shrink-0">
                    {p.id}
                  </div>

                  {/* Service Category */}
                  <div className="w-[150px] flex items-center gap-2 shrink-0">
                    <CategoryIcon className="w-4 h-4 text-[#9EAFA9] shrink-0" />
                    <span className="text-xs font-normal text-[#1C2926] truncate">
                      {p.category}
                    </span>
                  </div>

                  {/* Location */}
                  <div className="w-[100px] flex items-center gap-1.5 shrink-0 text-xs text-[#1C2926]">
                    <Compass className="w-3.5 h-3.5 text-[#9EAFA9] shrink-0" />
                    <span className="truncate">{p.location}</span>
                  </div>

                  {/* Registered On */}
                  <div className="w-[120px] flex flex-col shrink-0">
                    <span className="text-xs font-medium text-[#1C2926] leading-tight">
                      {p.registeredDate}
                    </span>
                    <span className="text-[11px] text-[#9EAFA9] leading-tight mt-0.5">
                      {p.registeredTime}
                    </span>
                  </div>

                  {/* Status */}
                  <div className="w-[85px] shrink-0">
                    <span
                      className={`text-[12px] font-bold leading-tight ${getStatusColor(
                        p.status
                      )}`}
                    >
                      {p.status}
                    </span>
                  </div>

                  {/* Actions: View Profile Pill + Three Dots */}
                  <div className="w-[145px] flex items-center justify-end gap-2 shrink-0 relative pr-1">
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

                      {/* Row Context Menu */}
                      {activeRowMenu === p.id && (
                        <div className="absolute right-0 mt-1 w-40 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-40 animate-in fade-in zoom-in-95 duration-100">
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
                          <button
                            type="button"
                            onClick={() => handleUpdateStatus(p.id, 'Active')}
                            className="w-full px-3 py-1.5 text-xs text-left text-[#16A34A] hover:bg-[#E9FBF0] flex items-center gap-2 cursor-pointer"
                          >
                            <CheckCircle className="w-3.5 h-3.5 text-[#16A34A]" />
                            <span>Set Active</span>
                          </button>
                          <button
                            type="button"
                            onClick={() => handleUpdateStatus(p.id, 'Inactive')}
                            className="w-full px-3 py-1.5 text-xs text-left text-[#D97706] hover:bg-[#FEF3E2] flex items-center gap-2 cursor-pointer"
                          >
                            <PauseCircle className="w-3.5 h-3.5 text-[#D97706]" />
                            <span>Set Inactive</span>
                          </button>
                          <button
                            type="button"
                            onClick={() => handleUpdateStatus(p.id, 'Suspended')}
                            className="w-full px-3 py-1.5 text-xs text-left text-[#DC2626] hover:bg-[#FEF2F2] flex items-center gap-2 cursor-pointer"
                          >
                            <Ban className="w-3.5 h-3.5 text-[#DC2626]" />
                            <span>Suspend</span>
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Numbers Carousel / Pagination Footer */}
        <div
          style={{
            height: '52px',
          }}
          className="w-full px-5 flex items-center justify-between shrink-0 border-t border-[#F0EFF2] bg-white"
        >
          {/* Left: Showing info */}
          <span className="text-xs text-[#616166] font-normal">
            Showing 1-{filteredProviders.length} of {providersList.length} providers
          </span>

          {/* Right: Numbers Carousel Controls */}
          <div className="flex items-center gap-1.5">
            {/* Previous */}
            <button
              type="button"
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
              className="w-8 h-8 rounded-lg border border-[#EBEBEB] text-[#616166] hover:bg-[#F9F9FB] flex items-center justify-center transition-colors cursor-pointer"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>

            {/* Page Numbers */}
            {[1, 2, 3, 4, 5].map((page) => {
              const isActive = currentPage === page
              return (
                <button
                  key={page}
                  type="button"
                  onClick={() => setCurrentPage(page)}
                  className={`w-8 h-8 rounded-lg text-xs font-semibold flex items-center justify-center transition-all cursor-pointer ${
                    isActive
                      ? 'border border-[#8B53FE] text-[#8B53FE] bg-white shadow-2xs'
                      : 'border border-[#EBEBEB] text-[#616166] hover:bg-[#F9F9FB]'
                  }`}
                >
                  {page}
                </button>
              )
            })}

            {/* Next */}
            <button
              type="button"
              onClick={() => setCurrentPage((p) => Math.min(5, p + 1))}
              className="w-8 h-8 rounded-lg border border-[#EBEBEB] text-[#616166] hover:bg-[#F9F9FB] flex items-center justify-center transition-colors cursor-pointer"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ProviderDirectoryView
