import React, { useState, useEffect, useRef } from 'react'
import {
  Search,
  ChevronDown,
  ChevronsUpDown,
  MoreHorizontal,
  Pencil,
  Users,
  Check,
  X,
  Camera,
  Upload,
  LayoutGrid,
  List,
  Plus,
  Trash2,
  ChevronRight,
  AlertTriangle,
} from 'lucide-react'
import {
  fetchCategories,
  createCategoryApi,
  patchCategoryApi,
  deleteCategoryApi,
} from '../api/admin'

// Real PNG assets matching the customer mobile application (exact 98x60 format)
const APP_CATEGORY_ASSETS = [
  { id: 'flatbed', label: 'Flatbed Truck', path: '/assets/categories/flatbed_truck.png' },
  { id: 'towing', label: 'Towing Truck', path: '/assets/categories/towing.png' },
  { id: 'car_ride', label: 'Ride Sedan', path: '/assets/categories/car_ride.png' },
  { id: 'pickup', label: 'Pickup Truck', path: '/assets/categories/pickup.png' },
  { id: 'rider', label: 'Motorbike', path: '/assets/categories/rider_bike.png' },
  { id: 'van', label: 'Family Van', path: '/assets/categories/van.png' },
  { id: 'emergency', label: 'Emergency Beacon', path: '/assets/categories/emergency_beacon.png' },
  { id: 'heavy_truk', label: 'Heavy Truck', path: '/assets/categories/truk.png' },
]

const INITIAL_CATEGORIES = [
  {
    id: 'cat-1',
    name: 'Tyre Repair',
    subtitle: 'Vehicle tyre & replacement',
    description: 'Vehicle tyre and replacements services.',
    image: '/assets/categories/flatbed_truck.png',
    providersCount: 24,
    dateCreated: '12 Sept 2026',
    status: 'Active',
  },
  {
    id: 'cat-2',
    name: 'Battery Jump Start',
    subtitle: 'Emergency jumpstart aid',
    description: 'Emergency battery jump start assistance.',
    image: '/assets/categories/emergency_beacon.png',
    providersCount: 18,
    dateCreated: '14 Sept 2026',
    status: 'Active',
  },
  {
    id: 'cat-3',
    name: 'Vehicle Towing',
    subtitle: 'Safe flatbed towing',
    description: 'Safe and reliable vehicle towing services.',
    image: '/assets/categories/towing.png',
    providersCount: 14,
    dateCreated: '17 Sept 2026',
    status: 'Active',
  },
  {
    id: 'cat-4',
    name: 'Fuel Delivery',
    subtitle: 'On-demand fuel refill',
    description: 'On-demand fuel delivery to your location.',
    image: '/assets/categories/pickup.png',
    providersCount: 19,
    dateCreated: '21 Sept 2026',
    status: 'Active',
  },
  {
    id: 'cat-5',
    name: 'Mobile Mechanic',
    subtitle: 'On-site vehicle repairs',
    description: 'On-site vehicle repairs and maintenance.',
    image: '/assets/categories/car_ride.png',
    providersCount: 13,
    dateCreated: '23 Sept 2026',
    status: 'Inactive',
  },
  {
    id: 'cat-6',
    name: 'Car Lockout',
    subtitle: 'Lost key & lockout aid',
    description: 'Vehicle lockout and lost key assistance.',
    image: '/assets/categories/van.png',
    providersCount: 10,
    dateCreated: '25 Sept 2026',
    status: 'Active',
  },
]

export function CategoryManagementView() {
  const [viewMode, setViewMode] = useState('cards') // 'cards' | 'table'
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedStatus, setSelectedStatus] = useState('All Statuses')
  const [openStatusDropdown, setOpenStatusDropdown] = useState(false)
  const [selectedRows, setSelectedRows] = useState([])
  const [categories, setCategories] = useState(INITIAL_CATEGORIES)
  const [currentPage, setCurrentPage] = useState(1)

  // Edit / Add Modal State
  const [modalMode, setModalMode] = useState('edit') // 'edit' | 'add'
  const [editingCategory, setEditingCategory] = useState(null)
  const [editName, setEditName] = useState('')
  const [editSubtitle, setEditSubtitle] = useState('')
  const [editDesc, setEditDesc] = useState('')
  const [editImage, setEditImage] = useState('')
  const [editStatus, setEditStatus] = useState('Active')

  // Delete Confirmation Modal State
  const [deletingCategory, setDeletingCategory] = useState(null)
  const [isDeleting, setIsDeleting] = useState(false)

  // More options menu dropdown
  const [activeMenuId, setActiveMenuId] = useState(null)

  // Hidden file inputs
  const cardFileInputRef = useRef(null)
  const [uploadTargetId, setUploadTargetId] = useState(null)

  // Load backend categories if available
  useEffect(() => {
    let isMounted = true
    async function loadBackendCategories() {
      try {
        const res = await fetchCategories()
        const items = res?.data || res
        if (isMounted && Array.isArray(items) && items.length > 0) {
          const merged = items.map((item, idx) => {
            const fallback = INITIAL_CATEGORIES[idx % INITIAL_CATEGORIES.length]
            return {
              id: item.id || fallback.id,
              name: item.name || fallback.name,
              subtitle: item.subtitle || fallback.subtitle,
              description: item.description || fallback.description,
              image: item.image_url || fallback.image,
              providersCount: item.providers_count || fallback.providersCount,
              dateCreated: item.created_at
                ? new Date(item.created_at).toLocaleDateString('en-GB', {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                  })
                : fallback.dateCreated,
              status: item.is_enabled === false ? 'Inactive' : 'Active',
            }
          })
          setCategories(merged)
        }
      } catch {
        // Keep fallback categories
      }
    }
    loadBackendCategories()
    return () => {
      isMounted = false
    }
  }, [])

  // Close more menu on outside click
  useEffect(() => {
    const handleOutsideClick = () => setActiveMenuId(null)
    window.addEventListener('click', handleOutsideClick)
    return () => window.removeEventListener('click', handleOutsideClick)
  }, [])

  // Filter Categories
  const filteredCategories = categories.filter((cat) => {
    if (selectedStatus !== 'All Statuses') {
      if (cat.status.toLowerCase() !== selectedStatus.toLowerCase()) return false
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      const matchName = cat.name.toLowerCase().includes(q)
      const matchSub = (cat.subtitle || '').toLowerCase().includes(q)
      const matchDesc = (cat.description || '').toLowerCase().includes(q)
      if (!matchName && !matchSub && !matchDesc) return false
    }
    return true
  })

  const isAllSelected =
    filteredCategories.length > 0 && selectedRows.length === filteredCategories.length

  const handleSelectAll = () => {
    if (isAllSelected) {
      setSelectedRows([])
    } else {
      setSelectedRows(filteredCategories.map((c) => c.id))
    }
  }

  const handleToggleRow = (id) => {
    setSelectedRows((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    )
  }

  // Handle direct file upload for a category
  const handleDirectPhotoUpload = (e) => {
    const file = e.target.files?.[0]
    if (!file || !uploadTargetId) return

    const reader = new FileReader()
    reader.onload = (event) => {
      const dataUrl = event.target.result
      setCategories((prev) =>
        prev.map((c) => (c.id === uploadTargetId ? { ...c, image: dataUrl } : c))
      )
    }
    reader.readAsDataURL(file)
  }

  const triggerPhotoUpload = (categoryId) => {
    setUploadTargetId(categoryId)
    if (cardFileInputRef.current) {
      cardFileInputRef.current.value = ''
      cardFileInputRef.current.click()
    }
  }

  const handleModalPhotoUpload = (e) => {
    const file = e.target.files?.[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (event) => {
      setEditImage(event.target.result)
    }
    reader.readAsDataURL(file)
  }

  const handleOpenEdit = (category) => {
    setModalMode('edit')
    setEditingCategory(category)
    setEditName(category.name)
    setEditSubtitle(category.subtitle || '')
    setEditDesc(category.description || '')
    setEditImage(category.image || APP_CATEGORY_ASSETS[0].path)
    setEditStatus(category.status)
  }

  const handleOpenAdd = () => {
    setModalMode('add')
    setEditingCategory({ id: `cat-${Date.now()}` })
    setEditName('')
    setEditSubtitle('')
    setEditDesc('')
    setEditImage(APP_CATEGORY_ASSETS[0].path)
    setEditStatus('Active')
  }

  const handleSaveModal = async () => {
    if (!editName.trim()) return

    if (modalMode === 'add') {
      const newCat = {
        id: `cat-${Date.now()}`,
        name: editName,
        subtitle: editSubtitle || 'Available assistance',
        description: editDesc || 'On-demand roadside assistance service.',
        image: editImage || APP_CATEGORY_ASSETS[0].path,
        providersCount: 0,
        dateCreated: new Date().toLocaleDateString('en-GB', {
          day: 'numeric',
          month: 'short',
          year: 'numeric',
        }),
        status: editStatus,
      }
      setCategories((prev) => [newCat, ...prev])
      try {
        if (typeof createCategoryApi === 'function') {
          await createCategoryApi(editName)
        }
      } catch {
        // Optimistic
      }
    } else if (editingCategory) {
      try {
        if (typeof patchCategoryApi === 'function' && editingCategory.id) {
          await patchCategoryApi(editingCategory.id, {
            name: editName,
            isEnabled: editStatus === 'Active',
          })
        }
      } catch {
        // Optimistic
      }

      setCategories((prev) =>
        prev.map((c) =>
          c.id === editingCategory.id
            ? {
                ...c,
                name: editName,
                subtitle: editSubtitle,
                description: editDesc,
                image: editImage,
                status: editStatus,
              }
            : c
        )
      )
    }

    setEditingCategory(null)
  }

  // Handle Delete Category
  const handleConfirmDelete = async () => {
    if (!deletingCategory) return
    setIsDeleting(true)

    try {
      if (typeof deleteCategoryApi === 'function' && deletingCategory.id) {
        await deleteCategoryApi(deletingCategory.id)
      }
    } catch {
      // Optimistic delete
    }

    setCategories((prev) => prev.filter((c) => c.id !== deletingCategory.id))
    setIsDeleting(false)
    setDeletingCategory(null)
  }

  return (
    <div className="w-full max-w-[1084px] flex flex-col gap-4 shrink-0 select-none pb-8 animate-in fade-in duration-150 overflow-x-hidden">
      {/* Hidden file input */}
      <input
        ref={cardFileInputRef}
        type="file"
        accept="image/*"
        onChange={handleDirectPhotoUpload}
        className="hidden"
      />

      {/* ================= 1ST ROW: TITLE & CONTROLS ================= */}
      <div className="w-full flex items-center justify-between shrink-0">
        <div className="flex flex-col">
          <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
            Category Management
          </h1>
          <p className="text-[13px] text-[#566663] font-normal mt-0.5 leading-snug">
            Manage all registered providers view their details and control their account status.
          </p>
        </div>

        {/* Right: Switcher + Add Category Button */}
        <div className="flex items-center gap-2.5">
          <div className="bg-white border border-[#E5E7EB] rounded-xl p-1 flex items-center shadow-2xs">
            <button
              type="button"
              onClick={() => setViewMode('cards')}
              title="Cards View (Customer App Style)"
              className={`h-8 px-3 rounded-lg text-[12px] font-semibold flex items-center gap-1.5 transition-all cursor-pointer ${
                viewMode === 'cards'
                  ? 'bg-[#F4EFFE] text-[#8B53FE] shadow-2xs'
                  : 'text-[#616166] hover:text-[#1C2926]'
              }`}
            >
              <LayoutGrid className="w-3.5 h-3.5" />
              <span>Cards (App Style)</span>
            </button>
            <button
              type="button"
              onClick={() => setViewMode('table')}
              title="Table View"
              className={`h-8 px-3 rounded-lg text-[12px] font-semibold flex items-center gap-1.5 transition-all cursor-pointer ${
                viewMode === 'table'
                  ? 'bg-[#F4EFFE] text-[#8B53FE] shadow-2xs'
                  : 'text-[#616166] hover:text-[#1C2926]'
              }`}
            >
              <List className="w-3.5 h-3.5" />
              <span>Table</span>
            </button>
          </div>

          <button
            type="button"
            onClick={handleOpenAdd}
            className="h-[38px] px-4 bg-[#8B53FE] hover:bg-[#7839EE] text-white rounded-xl text-[13px] font-semibold flex items-center gap-2 cursor-pointer transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4 stroke-[2.5]" />
            <span>Add Category</span>
          </button>
        </div>
      </div>

      {/* ================= FILTER BAR (Search + Status Filter) ================= */}
      <div
        style={{
          borderRadius: '20px',
          background: '#FFFFFF',
          boxSizing: 'border-box',
        }}
        className="w-full max-w-[1084px] border border-[#EBEBEB] shadow-xs px-5 py-3 flex items-center justify-between shrink-0"
      >
        <div className="relative w-full max-w-[320px]">
          <Search className="w-4 h-4 text-[#8C8C94] absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by category name"
            className="w-full h-[38px] pl-9 pr-3 text-[13px] text-[#1C2926] placeholder-[#8C8C94] bg-[#FFFFFF] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
          />
        </div>

        <div className="relative">
          <button
            type="button"
            onClick={() => setOpenStatusDropdown(!openStatusDropdown)}
            className="h-[38px] px-3.5 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[13px] font-medium text-[#1C2926] flex items-center gap-2 cursor-pointer transition-colors shadow-2xs"
          >
            <span>{selectedStatus}</span>
            <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
          </button>

          {openStatusDropdown && (
            <div className="absolute right-0 top-11 w-40 bg-white rounded-xl shadow-lg border border-[#EBEBEB] py-1 z-[500] animate-in fade-in zoom-in-95 duration-100">
              {['All Statuses', 'Active', 'Inactive'].map((st) => (
                <button
                  key={st}
                  type="button"
                  onClick={() => {
                    setSelectedStatus(st)
                    setOpenStatusDropdown(false)
                  }}
                  className="w-full px-3.5 py-2 text-left text-[13px] text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                >
                  <span>{st}</span>
                  {selectedStatus === st && (
                    <Check className="w-3.5 h-3.5 text-[#8B53FE]" />
                  )}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* ================= CONDITIONAL VIEW: CARDS vs TABLE ================= */}
      {viewMode === 'cards' ? (
        /* ================= CARDS VIEW (EXACT CUSTOMER APP 169x120 CARDS & 98x60 IMAGE SCALE) ================= */
        <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] p-5 shadow-xs flex flex-col gap-4">
          <div className="flex items-center justify-between border-b border-[#F0EFF5] pb-3">
            <div className="flex flex-col">
              <span className="text-[14px] font-bold text-[#1C2926]">
                Customer App Live Category Cards (Exact 98×60 Image Scale)
              </span>
              <span className="text-[12px] text-[#8C8C94]">
                Cards render with the exact dimensions used in the mobile customer app. Click edit or trash to manage.
              </span>
            </div>
            <span className="text-[12px] font-medium text-[#8B53FE] bg-[#F4EFFE] px-2.5 py-1 rounded-full">
              {filteredCategories.length} Categories
            </span>
          </div>

          {/* Cards Grid */}
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3.5">
            {filteredCategories.map((category) => (
              <div
                key={category.id}
                style={{
                  width: '100%',
                  maxWidth: '169px',
                  height: '136px',
                  borderRadius: '12px',
                  background: '#FFFFFF',
                  boxShadow: '0px 1px 12px 0px rgba(0,0,0,0.08), 0px 2px 8px 0px rgba(139, 83, 254, 0.08)',
                }}
                className="relative border border-[#EBEBEB] hover:border-[#8B53FE] transition-all group p-2.5 flex flex-col justify-between overflow-hidden"
              >
                {/* 1. Exact Customer App Image Placement: width: 98px, height: 60px */}
                <div
                  style={{
                    width: '98px',
                    height: '60px',
                  }}
                  className="relative flex items-center justify-start shrink-0"
                >
                  <img
                    src={category.image}
                    alt={category.name}
                    style={{
                      width: '98px',
                      height: '60px',
                      objectFit: 'contain',
                    }}
                    className="select-none pointer-events-none group-hover:scale-105 transition-transform"
                  />

                  {/* Hover Camera to upload / replace photo */}
                  <button
                    type="button"
                    onClick={() => triggerPhotoUpload(category.id)}
                    title="Change category image"
                    className="absolute inset-0 bg-black/45 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-white cursor-pointer"
                  >
                    <Camera className="w-4 h-4" />
                  </button>
                </div>

                {/* Status indicator badge & Action Buttons (Top Right) */}
                <div className="absolute top-2 right-2 flex items-center gap-1 z-10">
                  <span
                    className={`w-2 h-2 rounded-full ${
                      category.status === 'Active' ? 'bg-[#16A34A]' : 'bg-[#EA580C]'
                    }`}
                    title={category.status}
                  />
                  {/* Edit Pencil Button */}
                  <button
                    type="button"
                    onClick={() => handleOpenEdit(category)}
                    title="Edit Category"
                    className="w-5 h-5 rounded flex items-center justify-center text-[#8C8C94] hover:text-[#8B53FE] hover:bg-[#F4EFFE] opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer"
                  >
                    <Pencil className="w-3 h-3" />
                  </button>
                  {/* Delete Trash Button */}
                  <button
                    type="button"
                    onClick={() => setDeletingCategory(category)}
                    title="Delete Category"
                    className="w-5 h-5 rounded flex items-center justify-center text-[#8C8C94] hover:text-[#DC2626] hover:bg-[#FEE2E2] opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer"
                  >
                    <Trash2 className="w-3 h-3" />
                  </button>
                </div>

                {/* 2. Text Branding: Title & Subtitle + Right Vector Chevron */}
                <div className="w-full flex items-center justify-between gap-1 mt-auto">
                  <div className="flex flex-col min-w-0 pr-1">
                    <span className="text-[12px] font-semibold text-[#172623] truncate leading-tight">
                      {category.name}
                    </span>
                    <span className="text-[10px] text-[#566663] truncate leading-tight mt-0.5">
                      {category.subtitle || category.description}
                    </span>
                  </div>

                  <ChevronRight className="w-3.5 h-3.5 text-[#566663] shrink-0 stroke-[2.5]" />
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : (
        /* ================= TABLE VIEW ================= */
        <div
          style={{
            borderRadius: '20px',
            background: '#FFFFFF',
            boxSizing: 'border-box',
          }}
          className="w-full max-w-[1084px] border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0 overflow-hidden"
        >
          <div className="w-full overflow-hidden">
            {/* Table Header Row */}
            <div
              style={{
                height: '56px',
                paddingLeft: '20px',
                paddingRight: '20px',
              }}
              className="w-full bg-[#F9FAFB] border-b border-[#F0EFF5] flex items-center text-[12px] font-semibold text-[#616166]"
            >
              <div className="w-8 shrink-0 flex items-center">
                <input
                  type="checkbox"
                  checked={isAllSelected}
                  onChange={handleSelectAll}
                  className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
                />
              </div>

              <div className="flex-[3] min-w-0 flex items-center gap-1.5 cursor-pointer pr-4">
                <span>Category (App Card Asset: 98×60)</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="flex-[1.2] min-w-0 flex items-center gap-1.5 cursor-pointer pr-4">
                <span>Providers</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="flex-[1.5] min-w-0 flex items-center gap-1.5 cursor-pointer pr-4">
                <span>Date Created</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="flex-[1.2] min-w-0 flex items-center gap-1.5 cursor-pointer pr-4">
                <span>Status</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="w-[120px] shrink-0 flex items-center justify-end gap-1.5 pr-2 cursor-pointer">
                <span>Action</span>
              </div>
            </div>

            {/* Table Rows */}
            <div className="w-full flex flex-col divide-y divide-[#F0EFF5]">
              {filteredCategories.map((category) => {
                const isChecked = selectedRows.includes(category.id)
                const isMenuOpen = activeMenuId === category.id

                return (
                  <div
                    key={category.id}
                    style={{
                      height: '78px',
                      paddingLeft: '20px',
                      paddingRight: '20px',
                    }}
                    className="w-full flex items-center hover:bg-[#FBFBFC] transition-colors relative"
                  >
                    {/* Checkbox */}
                    <div className="w-8 shrink-0 flex items-center">
                      <input
                        type="checkbox"
                        checked={isChecked}
                        onChange={() => handleToggleRow(category.id)}
                        className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
                      />
                    </div>

                    {/* Category Column: 98x60 Image Asset + Title & Description */}
                    <div className="flex-[3] min-w-0 flex items-center gap-3.5 pr-4">
                      <div
                        onClick={() => triggerPhotoUpload(category.id)}
                        title="Click to change photo (exact app size: 98×60)"
                        style={{
                          width: '98px',
                          height: '60px',
                        }}
                        className="rounded-lg overflow-hidden relative bg-[#F9FAFB] border border-[#E5E7EB] flex items-center justify-center shrink-0 cursor-pointer group/thumb"
                      >
                        <img
                          src={category.image}
                          alt={category.name}
                          style={{
                            width: '98px',
                            height: '60px',
                            objectFit: 'contain',
                          }}
                        />
                        <div className="absolute inset-0 bg-black/45 opacity-0 group-hover/thumb:opacity-100 transition-opacity flex items-center justify-center">
                          <Camera className="w-4 h-4 text-white" />
                        </div>
                      </div>

                      <div className="flex flex-col min-w-0">
                        <span className="text-[13px] font-semibold text-[#1C2926] leading-tight truncate">
                          {category.name}
                        </span>
                        <span className="text-[12px] text-[#8C8C94] mt-0.5 truncate">
                          {category.description}
                        </span>
                      </div>
                    </div>

                    {/* Providers Column */}
                    <div className="flex-[1.2] min-w-0 flex items-center gap-2 pr-4">
                      <Users className="w-4 h-4 text-[#8C8C94] shrink-0" />
                      <span className="text-[13px] font-medium text-[#1C2926]">
                        {category.providersCount}
                      </span>
                    </div>

                    {/* Date Created Column */}
                    <div className="flex-[1.5] min-w-0 flex items-center pr-4">
                      <span className="text-[13px] font-medium text-[#1C2926]">
                        {category.dateCreated}
                      </span>
                    </div>

                    {/* Status Column */}
                    <div className="flex-[1.2] min-w-0 flex items-center pr-4">
                      <span
                        className={`text-[13px] font-semibold ${
                          category.status === 'Active'
                            ? 'text-[#16A34A]'
                            : 'text-[#EA580C]'
                        }`}
                      >
                        {category.status}
                      </span>
                    </div>

                    {/* Action Column: Edit Pencil + Delete Trash + Three Dots */}
                    <div className="w-[120px] shrink-0 flex items-center justify-end gap-1.5 pr-2 relative">
                      <button
                        type="button"
                        onClick={() => handleOpenEdit(category)}
                        title="Edit Category"
                        className="w-8 h-8 rounded-lg flex items-center justify-center text-[#8B53FE] hover:bg-[#F4EFFE] transition-colors cursor-pointer shrink-0"
                      >
                        <Pencil className="w-4 h-4 stroke-[1.8]" />
                      </button>

                      <button
                        type="button"
                        onClick={() => setDeletingCategory(category)}
                        title="Delete Category"
                        className="w-8 h-8 rounded-lg flex items-center justify-center text-[#DC2626] hover:bg-[#FEE2E2] transition-colors cursor-pointer shrink-0"
                      >
                        <Trash2 className="w-4 h-4 stroke-[1.8]" />
                      </button>

                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation()
                          setActiveMenuId(isMenuOpen ? null : category.id)
                        }}
                        title="More options"
                        className="w-7 h-7 rounded-lg flex items-center justify-center text-[#8C8C94] hover:bg-gray-100 hover:text-[#1C2926] transition-colors cursor-pointer shrink-0"
                      >
                        <MoreHorizontal className="w-4 h-4" />
                      </button>

                      {/* Dropdown Menu */}
                      {isMenuOpen && (
                        <div
                          onClick={(e) => e.stopPropagation()}
                          className="absolute right-2 top-10 w-44 bg-white rounded-xl shadow-xl border border-[#EBEBEB] py-1 z-[500] animate-in fade-in zoom-in-95 duration-100"
                        >
                          <button
                            type="button"
                            onClick={() => {
                              setActiveMenuId(null)
                              handleOpenEdit(category)
                            }}
                            className="w-full px-3.5 py-2 text-left text-[12px] font-medium text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center gap-2 cursor-pointer"
                          >
                            <Pencil className="w-3.5 h-3.5 text-[#8B53FE]" />
                            <span>Edit Details</span>
                          </button>
                          <button
                            type="button"
                            onClick={() => {
                              setActiveMenuId(null)
                              triggerPhotoUpload(category.id)
                            }}
                            className="w-full px-3.5 py-2 text-left text-[12px] font-medium text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center gap-2 cursor-pointer"
                          >
                            <Camera className="w-3.5 h-3.5 text-[#8B53FE]" />
                            <span>Change Photo</span>
                          </button>
                          <div className="h-[1px] bg-[#F0EFF5] my-1" />
                          <button
                            type="button"
                            onClick={() => {
                              setActiveMenuId(null)
                              setDeletingCategory(category)
                            }}
                            className="w-full px-3.5 py-2 text-left text-[12px] font-medium text-[#DC2626] hover:bg-[#FEE2E2] flex items-center gap-2 cursor-pointer"
                          >
                            <Trash2 className="w-3.5 h-3.5 text-[#DC2626]" />
                            <span>Delete Category</span>
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>

          {/* Footer / Pagination in Table */}
          <div
            style={{
              height: '60px',
              paddingLeft: '20px',
              paddingRight: '20px',
            }}
            className="w-full border-t border-[#F0EFF5] flex items-center justify-between shrink-0"
          >
            <span className="text-[13px] text-[#616166]">
              Showing 1-{filteredCategories.length} of {categories.length} categories
            </span>

            <div className="flex items-center gap-1.5">
              <button
                type="button"
                disabled={currentPage === 1}
                onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                className="w-8 h-8 rounded-lg border border-[#E5E7EB] flex items-center justify-center text-[#616166] hover:bg-gray-50 disabled:opacity-40 cursor-pointer"
              >
                ‹
              </button>
              {[1, 2, 3, 4].map((pageNum) => (
                <button
                  key={pageNum}
                  type="button"
                  onClick={() => setCurrentPage(pageNum)}
                  className={`w-8 h-8 rounded-lg text-[13px] font-medium transition-colors cursor-pointer ${
                    currentPage === pageNum
                      ? 'border border-[#8B53FE] text-[#8B53FE] bg-white shadow-2xs font-bold'
                      : 'border border-[#E5E7EB] text-[#616166] hover:bg-gray-50'
                  }`}
                >
                  {pageNum}
                </button>
              ))}
              <button
                type="button"
                disabled={currentPage === 4}
                onClick={() => setCurrentPage((p) => Math.min(4, p + 1))}
                className="w-8 h-8 rounded-lg border border-[#E5E7EB] flex items-center justify-center text-[#616166] hover:bg-gray-50 disabled:opacity-40 cursor-pointer"
              >
                ›
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ================= EDIT / ADD CATEGORY MODAL ================= */}
      {editingCategory && (
        <div className="fixed inset-0 z-[1000] flex items-center justify-center bg-black/40 backdrop-blur-xs animate-in fade-in duration-150 p-4">
          <div className="w-full max-w-[500px] bg-white rounded-2xl shadow-2xl border border-[#DECFFC] p-6 flex flex-col gap-5 animate-in zoom-in-95 duration-150 max-h-[90vh] overflow-y-auto custom-card-scrollbar">
            {/* Modal Header */}
            <div className="flex items-center justify-between border-b border-[#F0EFF5] pb-3">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center">
                  {modalMode === 'add' ? <Plus className="w-5 h-5" /> : <Pencil className="w-4.5 h-4.5" />}
                </div>
                <div>
                  <h3 className="text-[16px] font-bold text-[#1C2926]">
                    {modalMode === 'add' ? 'Add New Category' : 'Edit Category'}
                  </h3>
                  <span className="text-[12px] text-[#8C8C94]">
                    Add category asset (exact 98×60 size) for customer application cards
                  </span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setEditingCategory(null)}
                className="w-8 h-8 rounded-lg flex items-center justify-center text-[#8C8C94] hover:bg-gray-100 hover:text-[#1C2926] cursor-pointer"
              >
                <X className="w-4.5 h-4.5" />
              </button>
            </div>

            {/* Form Fields */}
            <div className="flex flex-col gap-4">
              {/* Category Photo Uploader Area */}
              <div>
                <label className="text-[12px] font-semibold text-[#616166] mb-1.5 flex items-center justify-between">
                  <span>Category Card Asset (Exact App Size: 98px × 60px)</span>
                  {editImage && (
                    <button
                      type="button"
                      onClick={() => setEditImage('')}
                      className="text-[11px] text-[#DC2626] hover:underline flex items-center gap-1 cursor-pointer"
                    >
                      <Trash2 className="w-3 h-3" /> Remove Asset
                    </button>
                  )}
                </label>

                {/* Exact 98x60 Preview & Drop Area */}
                <div className="w-full border-2 border-dashed border-[#DECFFC] rounded-2xl p-4 flex flex-col items-center justify-center gap-2 bg-[#FAF8FE] relative group">
                  {editImage ? (
                    <div className="flex flex-col items-center gap-2">
                      <div
                        style={{
                          width: '98px',
                          height: '60px',
                        }}
                        className="relative rounded-lg overflow-hidden border border-[#EBEBEB] bg-white flex items-center justify-center shadow-xs"
                      >
                        <img
                          src={editImage}
                          alt="Category preview"
                          style={{
                            width: '98px',
                            height: '60px',
                            objectFit: 'contain',
                          }}
                        />
                      </div>
                      <label className="px-3 py-1 bg-white text-[#8B53FE] border border-[#DECFFC] hover:bg-[#F4EFFE] rounded-lg text-[12px] font-semibold flex items-center gap-1.5 shadow-2xs transition-all cursor-pointer">
                        <Upload className="w-3.5 h-3.5" /> Change Photo
                        <input
                          type="file"
                          accept="image/*"
                          onChange={handleModalPhotoUpload}
                          className="hidden"
                        />
                      </label>
                    </div>
                  ) : (
                    <label className="flex flex-col items-center justify-center gap-2 cursor-pointer py-3 w-full">
                      <div className="w-10 h-10 rounded-full bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center">
                        <Upload className="w-5 h-5" />
                      </div>
                      <div className="text-center">
                        <span className="text-[13px] font-semibold text-[#8B53FE]">
                          Click to upload
                        </span>{' '}
                        <span className="text-[13px] text-[#616166]">
                          or drag & drop
                        </span>
                        <p className="text-[11px] text-[#8C8C94] mt-0.5">
                          Exact 98×60 PNG or transparent image
                        </p>
                      </div>
                      <input
                        type="file"
                        accept="image/*"
                        onChange={handleModalPhotoUpload}
                        className="hidden"
                      />
                    </label>
                  )}
                </div>

                {/* Quick App Presets Selection */}
                <div className="mt-3 flex flex-col gap-1.5">
                  <span className="text-[11px] text-[#8C8C94] font-medium">
                    Select from customer app vehicle/service assets (98×60):
                  </span>
                  <div className="flex items-center gap-2 overflow-x-auto pb-1">
                    {APP_CATEGORY_ASSETS.map((asset) => (
                      <button
                        key={asset.id}
                        type="button"
                        onClick={() => setEditImage(asset.path)}
                        title={asset.label}
                        style={{
                          width: '74px',
                          height: '46px',
                        }}
                        className={`rounded-lg overflow-hidden border-2 shrink-0 cursor-pointer transition-all bg-white p-1 flex items-center justify-center ${
                          editImage === asset.path ? 'border-[#8B53FE] ring-2 ring-[#8B53FE]/20 shadow-xs' : 'border-[#E5E7EB] opacity-75 hover:opacity-100'
                        }`}
                      >
                        <img
                          src={asset.path}
                          alt={asset.label}
                          className="w-full h-full object-contain"
                        />
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Category Title */}
              <div>
                <label className="text-[12px] font-semibold text-[#616166] mb-1.5 block">
                  Category Name / Title
                </label>
                <input
                  type="text"
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  placeholder="e.g. Tyre Repair, Towing Service"
                  className="w-full h-10 px-3.5 text-[13px] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE]"
                />
              </div>

              {/* Subtitle */}
              <div>
                <label className="text-[12px] font-semibold text-[#616166] mb-1.5 block">
                  Card Subtitle (Short)
                </label>
                <input
                  type="text"
                  value={editSubtitle}
                  onChange={(e) => setEditSubtitle(e.target.value)}
                  placeholder="e.g. Vehicle tyre & replacement"
                  className="w-full h-10 px-3.5 text-[13px] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE]"
                />
              </div>

              {/* Full Description */}
              <div>
                <label className="text-[12px] font-semibold text-[#616166] mb-1.5 block">
                  Full Description
                </label>
                <textarea
                  rows={2}
                  value={editDesc}
                  onChange={(e) => setEditDesc(e.target.value)}
                  placeholder="e.g. Vehicle tyre and replacements services."
                  className="w-full p-3 text-[13px] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] resize-none"
                />
              </div>

              {/* Status */}
              <div>
                <label className="text-[12px] font-semibold text-[#616166] mb-1.5 block">
                  Status
                </label>
                <div className="flex items-center gap-3">
                  <button
                    type="button"
                    onClick={() => setEditStatus('Active')}
                    className={`flex-1 h-9 rounded-xl text-[13px] font-semibold border flex items-center justify-center gap-1.5 cursor-pointer transition-colors ${
                      editStatus === 'Active'
                        ? 'border-[#16A34A] bg-[#E9FBF0] text-[#16A34A]'
                        : 'border-[#E5E7EB] bg-white text-[#616166] hover:bg-gray-50'
                    }`}
                  >
                    Active
                  </button>
                  <button
                    type="button"
                    onClick={() => setEditStatus('Inactive')}
                    className={`flex-1 h-9 rounded-xl text-[13px] font-semibold border flex items-center justify-center gap-1.5 cursor-pointer transition-colors ${
                      editStatus === 'Inactive'
                        ? 'border-[#EA580C] bg-[#FFF7ED] text-[#EA580C]'
                        : 'border-[#E5E7EB] bg-white text-[#616166] hover:bg-gray-50'
                    }`}
                  >
                    Inactive
                  </button>
                </div>
              </div>
            </div>

            {/* Modal Actions */}
            <div className="flex items-center justify-between pt-3 border-t border-[#F0EFF5]">
              {modalMode === 'edit' && (
                <button
                  type="button"
                  onClick={() => {
                    const cat = editingCategory
                    setEditingCategory(null)
                    setDeletingCategory(cat)
                  }}
                  className="text-[13px] font-semibold text-[#DC2626] hover:underline flex items-center gap-1 cursor-pointer"
                >
                  <Trash2 className="w-4 h-4" /> Delete
                </button>
              )}
              <div className="flex items-center gap-2.5 ml-auto">
                <button
                  type="button"
                  onClick={() => setEditingCategory(null)}
                  className="px-4 py-2 border border-[#E5E7EB] rounded-xl text-[13px] font-medium text-[#616166] hover:bg-gray-50 cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleSaveModal}
                  className="px-5 py-2 bg-[#8B53FE] hover:bg-[#7839EE] rounded-xl text-[13px] font-semibold text-white cursor-pointer shadow-sm transition-colors"
                >
                  {modalMode === 'add' ? 'Create Category' : 'Save Changes'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ================= DELETE CONFIRMATION DIALOG ================= */}
      {deletingCategory && (
        <div className="fixed inset-0 z-[1100] flex items-center justify-center bg-black/45 backdrop-blur-xs animate-in fade-in duration-150 p-4">
          <div className="w-full max-w-[420px] bg-white rounded-2xl shadow-2xl border border-[#FEE2E2] p-6 flex flex-col gap-4 animate-in zoom-in-95 duration-150">
            <div className="flex items-center gap-3">
              <div className="w-11 h-11 rounded-full bg-[#FEE2E2] text-[#DC2626] flex items-center justify-center shrink-0">
                <AlertTriangle className="w-6 h-6 stroke-[2]" />
              </div>
              <div className="flex flex-col">
                <h3 className="text-[16px] font-bold text-[#1C2926]">
                  Delete Category?
                </h3>
                <span className="text-[12px] text-[#8C8C94]">
                  This action is permanent and cannot be undone
                </span>
              </div>
            </div>

            <p className="text-[13px] text-[#566663] leading-relaxed">
              Are you sure you want to delete{' '}
              <strong className="text-[#1C2926]">"{deletingCategory.name}"</strong>?
              This will remove the category and its card from the customer application.
            </p>

            <div className="flex items-center justify-end gap-2.5 pt-2 border-t border-[#F0EFF5]">
              <button
                type="button"
                disabled={isDeleting}
                onClick={() => setDeletingCategory(null)}
                className="px-4 py-2 border border-[#E5E7EB] rounded-xl text-[13px] font-medium text-[#616166] hover:bg-gray-50 cursor-pointer disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={isDeleting}
                onClick={handleConfirmDelete}
                className="px-5 py-2 bg-[#DC2626] hover:bg-[#B91C1C] text-white rounded-xl text-[13px] font-semibold flex items-center gap-2 cursor-pointer shadow-sm transition-colors disabled:opacity-50"
              >
                <Trash2 className="w-4 h-4" />
                <span>{isDeleting ? 'Deleting...' : 'Delete Category'}</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default CategoryManagementView
