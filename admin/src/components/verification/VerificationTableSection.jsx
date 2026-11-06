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
} from 'lucide-react'
import {
  fetchProviders,
  approveProviderApi,
  rejectProviderApi,
} from '../../api/admin'

const REAL_SAUDI_APPLICATIONS = [
  {
    id: 'QA-2024-003',
    backendId: '3fc8e74c-d926-4d60-a162-7063cd892758',
    providerId: 'QRB-202403',
    name: 'Ahmad Raza',
    city: 'Jeddah',
    category: 'Tyre Repair',
    categoryIcon: Disc,
    submittedDate: '23 Sept 2026',
    submittedTime: '10:30 AM',
    status: 'Pending Review',
    statusType: 'pending',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
    nationalId: '2487654321',
    iqamaExpiry: '12 Mar 2026',
    phone: '+966 48 570 5644',
    whatsapp: '+966 48 570 5644',
    vehicleModel: 'Toyota Dyna',
    vehicleType: 'Flatbed Truck',
    plateNumber: 'ABC 1234',
    vehicleColor: 'White',
  },
  {
    id: 'QA-2024-001',
    backendId: '4c536750-1642-4a74-94c0-d03db80654a8',
    providerId: 'QRB-100001',
    name: 'Ahmed Raza',
    city: 'Jeddah',
    category: 'Tyre Repair',
    categoryIcon: Disc,
    submittedDate: '23 Sept 2026',
    submittedTime: '10:30 AM',
    status: 'Approved',
    statusType: 'approved',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QA-2024-002',
    backendId: '3bf01dff-92f9-4075-b6ce-325ee184290e',
    providerId: 'QRB-100002',
    name: 'Ali Ahmad',
    city: 'Riyadh',
    category: 'Battery Jump Start',
    categoryIcon: Disc,
    submittedDate: '22 Sept 2026',
    submittedTime: '04:30 AM',
    status: 'Approved',
    statusType: 'approved',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QA-2024-004',
    backendId: '66eaaa98-139e-4f15-9803-9da85d75a9b0',
    providerId: 'QRB-100003',
    name: 'Abdul Ahad',
    city: 'Makkah',
    category: 'Fuel Delivery',
    categoryIcon: Fuel,
    submittedDate: '21 Sept 2026',
    submittedTime: '9:00 AM',
    status: 'Under Review',
    statusType: 'under_review',
    avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QA-2024-005',
    backendId: '1073a412-3622-4f11-81a6-8dd89c8e45a1',
    providerId: 'QRB-100004',
    name: 'M Ibrahim',
    city: 'Jeddah',
    category: 'Tyre Repair',
    categoryIcon: Disc,
    submittedDate: '20 Sept 2026',
    submittedTime: '10:30 AM',
    status: 'Approved',
    statusType: 'approved',
    avatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=120&h=120&q=80',
  },
  {
    id: 'QA-2024-006',
    backendId: '70eb72d0-95d9-4452-bd01-8829d78be993',
    providerId: 'QRB-100005',
    name: 'Awais Ali',
    city: 'Madinah',
    category: 'Vehicle Towing',
    categoryIcon: Truck,
    submittedDate: '19 Sept 2026',
    submittedTime: '12:30 PM',
    status: 'Approved',
    statusType: 'approved',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&h=120&q=80',
  },
]

export function VerificationTableSection({
  onViewDetails,
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
  const [applicationsList, setApplicationsList] = useState(REAL_SAUDI_APPLICATIONS)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    let mounted = true
    async function loadApplications() {
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

            let stBadge = 'Approved'
            let stType = 'approved'
            if (item.status === 'pending_verification' || item.status === 'pending_profile' || item.status === 'pending_otp') {
              stBadge = 'Pending Review'
              stType = 'pending'
            } else if (item.status === 'rejected') {
              stBadge = 'Rejected'
              stType = 'rejected'
            } else if (item.status === 'suspended') {
              stBadge = 'Under Review'
              stType = 'under_review'
            }

            const avatars = [
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&h=120&q=80',
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&h=120&q=80',
            ]

            return {
              id: item.providerId?.replace('QRB-', 'QA-2024-') || `QA-2024-${String(idx + 1).padStart(3, '0')}`,
              backendId: item.id,
              providerId: item.providerId,
              name: item.name || 'Provider',
              city: item.location?.city || 'Riyadh',
              category: catName,
              categoryIcon: Icon,
              submittedDate: dateStr,
              submittedTime: timeStr,
              status: stBadge,
              statusType: stType,
              avatar: item.photoUrl || avatars[idx % avatars.length],
              phone: item.phone,
              nationalId: '2487654321',
              iqamaExpiry: '12 Mar 2026',
              vehicleModel: 'Toyota Dyna',
              vehicleType: 'Flatbed Truck',
              plateNumber: 'ABC 1234',
              vehicleColor: 'White',
            }
          })

          // Sort so Pending Review is at the top
          mapped.sort((a, b) => (a.status === 'Pending Review' ? -1 : 1))
          setApplicationsList(mapped)
        }
      } catch (err) {
        console.error('Failed to load verification applications from backend:', err)
      } finally {
        if (mounted) setLoading(false)
      }
    }
    loadApplications()
    return () => {
      mounted = false
    }
  }, [])

  const categories = [
    'All Categories',
    'Tyre Repair',
    'Battery Jump Start',
    'Vehicle Towing',
    'Fuel Delivery',
    'Mobile Mechanic',
    'Car Lockout Assistance',
  ]
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
      default:
        return 'bg-[#F3F4F6] text-[#4B5563]'
    }
  }

  // Filter applications based on search and filters
  const filteredApplications = applicationsList.filter((app) => {
    const matchesSearch =
      !searchQuery ||
      app.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      app.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      app.city.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesCategory =
      selectedCategory === 'All Categories' || app.category === selectedCategory
    const matchesStatus =
      selectedStatus === 'All Status' || app.status === selectedStatus
    return matchesSearch && matchesCategory && matchesStatus
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
    setApplicationsList((prev) =>
      prev.map((a) => (a.id === app.id ? { ...a, status: 'Approved', statusType: 'approved' } : a))
    )
    if (app.backendId) {
      try {
        await approveProviderApi(app.backendId, 'Approved by admin')
      } catch (err) {
        console.error('Failed to approve application on backend:', err)
      }
    }
  }

  const handleReject = async (app) => {
    setActiveRowMenu(null)
    setApplicationsList((prev) =>
      prev.map((a) => (a.id === app.id ? { ...a, status: 'Rejected', statusType: 'rejected' } : a))
    )
    if (app.backendId) {
      try {
        await rejectProviderApi(app.backendId, 'Rejected by admin')
      } catch (err) {
        console.error('Failed to reject application on backend:', err)
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
      className="w-full max-w-[1084px] flex flex-col justify-between shrink-0 overflow-hidden select-none animate-in fade-in duration-150"
    >
      {/* ================= 1. FILTERS ROW (1084x40 inside padding) ================= */}
      <div className="w-full px-5 py-3.5 flex items-center justify-between shrink-0">
        {/* Search Input Box */}
        <div className="relative w-full max-w-[380px] flex items-center">
          <Search className="w-4 h-4 text-[#9EAFA9] absolute left-3.5 pointer-events-none" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by provider, application, or anything..."
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

      {/* ================= 2. TABLE WRAPPER ================= */}
      <div className="w-full overflow-x-auto custom-card-scrollbar flex-1 flex flex-col justify-start">
        {/* Table Header: h-56px, bg-[#F4F2F7], px-5 */}
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
                selectedRows.length === filteredApplications.length
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

          {/* Application ID */}
          <div className="w-[105px] flex items-center gap-1.5 shrink-0">
            <span>Application ID</span>
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

          {/* Submitted On */}
          <div className="w-[120px] flex items-center gap-1.5 shrink-0">
            <span>Submitted On</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>

          {/* Status */}
          <div className="w-[100px] flex items-center gap-1.5 shrink-0">
            <span>Status</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>

          {/* Action */}
          <div className="w-[140px] flex items-center justify-end gap-1.5 shrink-0 pr-1">
            <span>Action</span>
            <ChevronsUpDown className="w-3.5 h-3.5 text-[#9EAFA9]" />
          </div>
        </div>

        {/* Table Body */}
        <div className="flex-1 flex flex-col justify-start">
          {filteredApplications.map((app) => {
            const CategoryIcon = app.categoryIcon || Disc
            const isSelected = selectedRows.includes(app.id)

            return (
              <div
                key={app.id}
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
                    onChange={() => toggleSelectRow(app.id)}
                    className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
                  />
                </div>

                {/* Provider: Avatar + Name + City */}
                <div className="flex-1 min-w-[155px] flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full overflow-hidden shrink-0 border border-[#EFF0ED]">
                    <img
                      src={app.avatar}
                      alt={app.name}
                      className="w-full h-full object-cover"
                    />
                  </div>
                  <div className="flex flex-col min-w-0">
                    <span className="text-[13px] font-semibold text-[#1C2926] leading-tight truncate">
                      {app.name}
                    </span>
                    <div className="flex items-center gap-1 text-[11px] text-[#616166] mt-0.5">
                      <MapPin className="w-2.5 h-2.5 text-[#9EAFA9] shrink-0" />
                      <span className="truncate">{app.city}</span>
                    </div>
                  </div>
                </div>

                {/* Application ID */}
                <div className="w-[105px] text-xs font-normal text-[#616166] shrink-0">
                  {app.id}
                </div>

                {/* Service Category */}
                <div className="w-[150px] flex items-center gap-2 shrink-0">
                  <CategoryIcon className="w-4 h-4 text-[#9EAFA9] shrink-0" />
                  <span className="text-xs font-normal text-[#1C2926] truncate">
                    {app.category}
                  </span>
                </div>

                {/* Location */}
                <div className="w-[100px] flex items-center gap-1.5 shrink-0 text-xs text-[#1C2926]">
                  <MapPin className="w-3.5 h-3.5 text-[#9EAFA9] shrink-0" />
                  <span className="truncate">{app.city}</span>
                </div>

                {/* Submitted On */}
                <div className="w-[120px] flex flex-col shrink-0">
                  <span className="text-xs font-medium text-[#1C2926] leading-tight">
                    {app.submittedDate}
                  </span>
                  <span className="text-[11px] text-[#9EAFA9] leading-tight mt-0.5">
                    {app.submittedTime}
                  </span>
                </div>

                {/* Status Badge */}
                <div className="w-[100px] shrink-0">
                  <span
                    className={`inline-flex items-center px-2.5 py-1 rounded-full text-[11px] font-semibold leading-none ${getStatusBadge(
                      app.status
                    )}`}
                  >
                    {app.status}
                  </span>
                </div>

                {/* Actions: View Details Pill + Three Dots */}
                <div className="w-[140px] flex items-center justify-end gap-2 shrink-0 relative pr-1">
                  <button
                    type="button"
                    onClick={() => onViewDetails && onViewDetails(app)}
                    className="whitespace-nowrap px-3 py-1.5 rounded-lg bg-[#EFF6FF] text-[#2563EB] hover:bg-[#DBEAFE] text-xs font-medium transition-colors cursor-pointer shrink-0"
                  >
                    View Details
                  </button>

                  <div className="relative shrink-0">
                    <button
                      type="button"
                      onClick={() =>
                        setActiveRowMenu((prev) => (prev === app.id ? null : app.id))
                      }
                      className="p-1 rounded-md text-[#9EAFA9] hover:text-[#1C2926] hover:bg-[#F3F4F6] transition-colors cursor-pointer"
                    >
                      <MoreHorizontal className="w-4 h-4" />
                    </button>

                    {/* Row Context Menu */}
                    {activeRowMenu === app.id && (
                      <div className="absolute right-0 mt-1 w-40 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-40 animate-in fade-in zoom-in-95 duration-100">
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
                          onClick={() => setActiveRowMenu(null)}
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
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      </div>

      {/* ================= 4. NUMBERS CAROUSEL / PAGINATION (1044x32, px-5, py-3) ================= */}
      <div
        style={{
          height: '52px',
        }}
        className="w-full px-5 flex items-center justify-between shrink-0 border-t border-[#F0EFF2] bg-white"
      >
        {/* Left: Showing info */}
        <span className="text-xs text-[#616166] font-normal">
          Showing 1-{filteredApplications.length} of {applicationsList.length} applications
        </span>

        {/* Right: Numbers Carousel Controls */}
        <div className="flex items-center gap-1.5">
          {/* Previous Page Button */}
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

          {/* Next Page Button */}
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
  )
}

export default VerificationTableSection
