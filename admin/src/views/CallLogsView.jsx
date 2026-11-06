import React, { useState, useEffect } from 'react'
import {
  Phone,
  MessageCircle,
  PhoneCall,
  PhoneMissed,
  Calendar,
  Search,
  ChevronDown,
  ChevronsUpDown,
  MoreHorizontal,
  MapPin,
  Check,
  X,
} from 'lucide-react'
import { fetchCallLogs } from '../api/admin'

const INITIAL_CALL_LOGS = [
  {
    id: 'Call - 10248',
    callId: 'Call - 10248',
    requestId: 'REQ-29841',
    category: 'Tyre Repair',
    provider: {
      name: 'Ahmad Raza',
      publicId: 'PRV-10427',
      phone: '+966 55 123 4567',
      location: 'Jeddah',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
    },
    customer: {
      name: 'Ali Hassan',
      role: 'Customer',
      phone: '+966 55 123 4567',
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=120&h=120&q=80',
    },
    date: '04 Nov 2026',
    time: '10:30 AM',
    interaction: 'Call',
    status: 'Answered',
    duration: '02 min 18 sec',
  },
  {
    id: 'Call - 10249',
    callId: 'Call - 10249',
    requestId: 'REQ-29842',
    category: 'Vehicle Towing',
    provider: {
      name: 'Ali Ahmad',
      publicId: 'PRV-10428',
      phone: '+966 50 123 4567',
      location: 'Makkah',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80',
    },
    customer: {
      name: 'Faisal Khan',
      role: 'Customer',
      phone: '+966 56 112 2334',
      avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=120&h=120&q=80',
    },
    date: '22 Sept 2026',
    time: '04:30 AM',
    interaction: 'WhatsApp',
    status: 'Initiated',
    duration: 'Direct Chat',
  },
  {
    id: 'Call - 10250',
    callId: 'Call - 10250',
    requestId: 'REQ-29843',
    category: 'Fuel Delivery',
    provider: {
      name: 'Abdul Ahad',
      publicId: 'PRV-10429',
      phone: '+966 50 345 6789',
      location: 'Dammam',
      avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=120&h=120&q=80',
    },
    customer: {
      name: 'Usman Ali',
      role: 'Customer',
      phone: '+966 59 443 3221',
      avatar: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=120&h=120&q=80',
    },
    date: '22 Sept 2026',
    time: '12:30 AM',
    interaction: 'Call',
    status: 'Failed',
    duration: '00 min 00 sec',
  },
  {
    id: 'Call - 10251',
    callId: 'Call - 10251',
    requestId: 'REQ-29844',
    category: 'Tyre Repair',
    provider: {
      name: 'M Ibrahim',
      publicId: 'PRV-10430',
      phone: '+966 50 456 7890',
      location: 'Riyadh',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&h=120&q=80',
    },
    customer: {
      name: 'Haris Malik',
      role: 'Customer',
      phone: '+966 53 776 6554',
      avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&h=120&q=80',
    },
    date: '21 Sept 2026',
    time: '9:00 AM',
    interaction: 'Call',
    status: 'Answered',
    duration: '04 min 12 sec',
  },
  {
    id: 'Call - 10252',
    callId: 'Call - 10252',
    requestId: 'REQ-29845',
    category: 'Battery Jumpstart',
    provider: {
      name: 'Awais Ali',
      publicId: 'PRV-10431',
      phone: '+966 50 567 8901',
      location: 'Jeddah',
      avatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=120&h=120&q=80',
    },
    customer: {
      name: 'Ahad Raza',
      role: 'Customer',
      phone: '+966 55 332 2110',
      avatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=120&h=120&q=80',
    },
    date: '20 Sept 2026',
    time: '10:30 AM',
    interaction: 'Call',
    status: 'Answered',
    duration: '01 min 50 sec',
  },
]

export function CallLogsView() {
  const [selectedDateRange, setSelectedDateRange] = useState('Last 7 Days')
  const [openDateDropdown, setOpenDateDropdown] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedInteraction, setSelectedInteraction] = useState('All Interactions')
  const [openInteractionDropdown, setOpenInteractionDropdown] = useState(false)
  const [selectedCallStatus, setSelectedCallStatus] = useState('All Call Statuses')
  const [openStatusDropdown, setOpenStatusDropdown] = useState(false)
  const [selectedCallRows, setSelectedCallRows] = useState([])
  const [activeCallDetail, setActiveCallDetail] = useState(null)
  const [currentPage, setCurrentPage] = useState(1)

  // Real backend logs sync
  const [logs, setLogs] = useState(INITIAL_CALL_LOGS)
  const [totalCount, setTotalCount] = useState(315)

  useEffect(() => {
    let isMounted = true
    async function loadLogs() {
      try {
        const res = await fetchCallLogs({ limit: 10 })
        const items = res?.items || res?.data || res
        if (isMounted && Array.isArray(items) && items.length > 0) {
          const mapped = items.map((cl, idx) => ({
            id: cl.id || `Call - ${10248 + idx}`,
            callId: `Call - ${10248 + idx}`,
            requestId: `REQ-${29841 + idx}`,
            category: cl.category_name || 'Tyre Repair',
            provider: {
              name: cl.provider_name || cl.provider?.name || INITIAL_CALL_LOGS[idx % INITIAL_CALL_LOGS.length].provider.name,
              publicId: cl.provider_public_id || `PRV-${10427 + idx}`,
              phone: cl.provider_phone || cl.provider?.phone || '+966 55 123 4567',
              location: cl.provider_city || INITIAL_CALL_LOGS[idx % INITIAL_CALL_LOGS.length].provider.location,
              avatar: INITIAL_CALL_LOGS[idx % INITIAL_CALL_LOGS.length].provider.avatar,
            },
            customer: {
              name: cl.customer_name || cl.customer?.name || INITIAL_CALL_LOGS[idx % INITIAL_CALL_LOGS.length].customer.name,
              role: 'Customer',
              phone: cl.customer_phone || '+966 55 123 4567',
              avatar: INITIAL_CALL_LOGS[idx % INITIAL_CALL_LOGS.length].customer.avatar,
            },
            date: cl.started_at ? new Date(cl.started_at).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }) : '04 Nov 2026',
            time: cl.started_at ? new Date(cl.started_at).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }) : '10:30 AM',
            interaction: cl.channel === 'whatsapp' ? 'WhatsApp' : 'Call',
            status: cl.status_code === 'completed' || cl.status === 'completed' ? 'Answered' : cl.status_code === 'failed' ? 'Failed' : 'Initiated',
            duration: cl.duration_seconds ? `${String(Math.floor(cl.duration_seconds / 60)).padStart(2, '0')} min ${String(cl.duration_seconds % 60).padStart(2, '0')} sec` : '02 min 18 sec',
          }))
          setLogs(mapped)
          if (res?.meta?.total) setTotalCount(res.meta.total)
        }
      } catch {
        // Keep fallback logs
      }
    }
    loadLogs()
    return () => {
      isMounted = false
    }
  }, [selectedDateRange])

  // Filter logs
  const filteredLogs = logs.filter((log) => {
    if (selectedInteraction !== 'All Interactions') {
      if (log.interaction.toLowerCase() !== selectedInteraction.toLowerCase()) return false
    }
    if (selectedCallStatus !== 'All Call Statuses') {
      if (log.status.toLowerCase() !== selectedCallStatus.toLowerCase()) return false
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      const matchProvider = log.provider.name.toLowerCase().includes(q)
      const matchCustomer = log.customer.name.toLowerCase().includes(q)
      const matchPhone =
        log.provider.phone.includes(q) || log.customer.phone.includes(q)
      if (!matchProvider && !matchCustomer && !matchPhone) return false
    }
    return true
  })

  // Checkbox select all toggle
  const isAllSelected =
    filteredLogs.length > 0 && selectedCallRows.length === filteredLogs.length

  const handleSelectAll = () => {
    if (isAllSelected) {
      setSelectedCallRows([])
    } else {
      setSelectedCallRows(filteredLogs.map((l) => l.id))
    }
  }

  const handleToggleRow = (id) => {
    setSelectedCallRows((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    )
  }

  const metricCards = [
    {
      id: 'total',
      title: 'Total Calls',
      count: '315',
      percentage: '12%',
      isPositive: true,
      icon: Phone,
      iconBg: 'bg-[#F4EFFE] text-[#8B53FE]',
    },
    {
      id: 'whatsapp',
      title: 'WhatsApp Interactions',
      count: '87',
      percentage: '14%',
      isPositive: true,
      icon: MessageCircle,
      iconBg: 'bg-[#E9FBF0] text-[#16A34A]',
    },
    {
      id: 'answered',
      title: 'Answered Calls',
      count: '76',
      percentage: '12%',
      isPositive: true,
      icon: PhoneCall,
      iconBg: 'bg-[#E0F2FE] text-[#0284C7]',
    },
    {
      id: 'failed',
      title: 'Failed Calls',
      count: '60',
      percentage: '-12%',
      isPositive: false,
      icon: PhoneMissed,
      iconBg: 'bg-[#FEE2E2] text-[#DC2626]',
    },
  ]

  return (
    <div className="w-full max-w-[1084px] flex flex-col gap-4 shrink-0 select-none pb-8 animate-in fade-in duration-150 overflow-x-hidden">
      {/* ================= 1ST ROW BRANDING: 1084x52, justify-between ================= */}
      <div
        style={{
          height: '52px',
        }}
        className="w-full max-w-[1084px] flex items-center justify-between shrink-0"
      >
        <div className="flex flex-col">
          <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
            Call Logs
          </h1>
          <p className="text-[13px] text-[#566663] font-normal mt-0.5 leading-snug">
            Track and audit phone calls and WhatsApp interactions between customers and providers.
          </p>
        </div>

        {/* Date Filter Dropdown */}
        <div className="relative">
          <button
            type="button"
            onClick={() => setOpenDateDropdown(!openDateDropdown)}
            className="h-[42px] px-4 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[13px] font-medium text-[#1C2926] flex items-center gap-2.5 cursor-pointer transition-colors shadow-2xs"
          >
            <Calendar className="w-4 h-4 text-[#616166]" />
            <span>{selectedDateRange}</span>
            <ChevronDown className="w-4 h-4 text-[#8C8C94]" />
          </button>

          {openDateDropdown && (
            <div className="absolute right-0 top-12 w-44 bg-white rounded-xl shadow-lg border border-[#EBEBEB] py-1 z-[500] animate-in fade-in zoom-in-95 duration-100">
              {['Today', 'Last 7 Days', 'Last 30 Days', 'This Month', 'All Time'].map((range) => (
                <button
                  key={range}
                  type="button"
                  onClick={() => {
                    setSelectedDateRange(range)
                    setOpenDateDropdown(false)
                  }}
                  className="w-full px-3.5 py-2 text-left text-[13px] text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                >
                  <span>{range}</span>
                  {selectedDateRange === range && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* ================= 4 METRIC CARDS LAYOUT: 1084x170, radius: 20px, gap: 12px ================= */}
      <div
        style={{
          height: '170px',
          gap: '12px',
        }}
        className="w-full max-w-[1084px] grid grid-cols-2 lg:grid-cols-4 shrink-0"
      >
        {metricCards.map((card) => {
          const IconComp = card.icon

          return (
            <div
              key={card.id}
              style={{
                height: '170px',
                borderRadius: '20px',
                padding: '20px',
                background: '#FFFFFF',
                boxSizing: 'border-box',
              }}
              className="w-full min-w-0 border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0 hover:border-[#DECFFC] hover:shadow-sm transition-all"
            >
              {/* Card Top: Icon + Title */}
              <div className="flex items-center gap-3 min-w-0">
                <div
                  className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${card.iconBg}`}
                >
                  <IconComp className="w-4.5 h-4.5" />
                </div>
                <span className="text-[14px] font-medium text-[#616166] truncate min-w-0">
                  {card.title}
                </span>
              </div>

              {/* Card Middle: Big Value */}
              <div className="text-[32px] font-bold text-[#1C2926] leading-none tracking-tight">
                {card.count}
              </div>

              {/* Card Bottom: Percentage badge + VS Last Week */}
              <div className="flex items-center gap-2">
                <span
                  className={`inline-flex items-center gap-1 text-[12px] font-semibold px-2 py-0.5 rounded-full ${
                    card.isPositive
                      ? 'bg-[#E9FBF0] text-[#16A34A]'
                      : 'bg-[#FEE2E2] text-[#DC2626]'
                  }`}
                >
                  {card.isPositive ? '▲' : '▼'} {card.percentage}
                </span>
                <span className="text-[12px] text-[#8C8C94] font-normal">
                  VS Last Week
                </span>
              </div>
            </div>
          )
        })}
      </div>

      {/* ================= NEXT WIDGET LAYOUT: 1084x638, radius: 20px, background: #FFFFFF ================= */}
      <div
        style={{
          borderRadius: '20px',
          background: '#FFFFFF',
          boxSizing: 'border-box',
        }}
        className="w-full max-w-[1084px] min-h-[638px] border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0 overflow-hidden"
      >
        <div className="w-full flex flex-col">
          {/* ================= FILTERS LAYOUT: 1084x50, padding: 0 20px, justify-between ================= */}
          <div
            style={{
              height: '50px',
              paddingLeft: '20px',
              paddingRight: '20px',
            }}
            className="w-full flex items-center justify-between shrink-0 mt-3"
          >
            {/* Search Input: width ~380px */}
            <div className="relative w-full max-w-[380px]">
              <Search className="w-4 h-4 text-[#8C8C94] absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search by provider, customer or phone number..."
                className="w-full h-[38px] pl-9 pr-3 text-[13px] text-[#1C2926] placeholder-[#8C8C94] bg-[#FFFFFF] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
              />
            </div>

            {/* Right: Interaction Filter & Status Filter */}
            <div className="flex items-center gap-2.5">
              {/* Interaction Dropdown */}
              <div className="relative">
                <button
                  type="button"
                  onClick={() => {
                    setOpenInteractionDropdown(!openInteractionDropdown)
                    setOpenStatusDropdown(false)
                  }}
                  className="h-[38px] px-3.5 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[13px] font-medium text-[#1C2926] flex items-center gap-2 cursor-pointer transition-colors shadow-2xs"
                >
                  <span>{selectedInteraction}</span>
                  <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
                </button>

                {openInteractionDropdown && (
                  <div className="absolute right-0 top-11 w-44 bg-white rounded-xl shadow-lg border border-[#EBEBEB] py-1 z-[500] animate-in fade-in zoom-in-95 duration-100">
                    {['All Interactions', 'Call', 'WhatsApp'].map((inter) => (
                      <button
                        key={inter}
                        type="button"
                        onClick={() => {
                          setSelectedInteraction(inter)
                          setOpenInteractionDropdown(false)
                        }}
                        className="w-full px-3.5 py-2 text-left text-[13px] text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                      >
                        <span>{inter}</span>
                        {selectedInteraction === inter && (
                          <Check className="w-3.5 h-3.5 text-[#8B53FE]" />
                        )}
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
                    setOpenStatusDropdown(!openStatusDropdown)
                    setOpenInteractionDropdown(false)
                  }}
                  className="h-[38px] px-3.5 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[13px] font-medium text-[#1C2926] flex items-center gap-2 cursor-pointer transition-colors shadow-2xs"
                >
                  <span>{selectedCallStatus}</span>
                  <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
                </button>

                {openStatusDropdown && (
                  <div className="absolute right-0 top-11 w-44 bg-white rounded-xl shadow-lg border border-[#EBEBEB] py-1 z-[500] animate-in fade-in zoom-in-95 duration-100">
                    {['All Call Statuses', 'Answered', 'Initiated', 'Failed'].map((st) => (
                      <button
                        key={st}
                        type="button"
                        onClick={() => {
                          setSelectedCallStatus(st)
                          setOpenStatusDropdown(false)
                        }}
                        className="w-full px-3.5 py-2 text-left text-[13px] text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                      >
                        <span>{st}</span>
                        {selectedCallStatus === st && (
                          <Check className="w-3.5 h-3.5 text-[#8B53FE]" />
                        )}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* ================= TABS / TABLE HEADER LAYOUT: 1084x56, padding: 16px 20px (ZERO HORIZONTAL SCROLL) ================= */}
          <div className="w-full overflow-hidden mt-3">
            <div
              style={{
                height: '56px',
                paddingLeft: '20px',
                paddingRight: '20px',
              }}
              className="w-full bg-[#F9FAFB] border-y border-[#F0EFF5] flex items-center text-[12px] font-semibold text-[#616166]"
            >
              {/* Select All Checkbox */}
              <div className="w-8 shrink-0 flex items-center">
                <input
                  type="checkbox"
                  checked={isAllSelected}
                  onChange={handleSelectAll}
                  className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
                />
              </div>

              <div className="flex-[1.8] min-w-0 flex items-center gap-1.5 cursor-pointer pr-2">
                <span>Provider</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="flex-[1.5] min-w-0 flex items-center gap-1.5 cursor-pointer pr-2">
                <span>Customer</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="flex-[1.5] min-w-0 flex items-center gap-1.5 cursor-pointer pr-2">
                <span>Date & Time</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="flex-[1.2] shrink-0 flex items-center gap-1.5 cursor-pointer pr-2">
                <span>Interaction</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="flex-[1.1] shrink-0 flex items-center gap-1.5 cursor-pointer pr-2">
                <span>Status</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>

              <div className="w-[140px] shrink-0 flex items-center justify-end gap-1.5 pr-2 cursor-pointer">
                <span>Action</span>
                <ChevronsUpDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </div>
            </div>

            {/* ================= TABLE ROWS LAYOUT: 1084x60, border-bottom: 1px ================= */}
            <div className="w-full flex flex-col divide-y divide-[#F0EFF5]">
              {filteredLogs.map((log) => {
                const isChecked = selectedCallRows.includes(log.id)

                return (
                  <div
                    key={log.id}
                    style={{
                      height: '60px',
                      paddingLeft: '20px',
                      paddingRight: '20px',
                    }}
                    className="w-full flex items-center hover:bg-[#FBFBFC] transition-colors"
                  >
                    {/* Checkbox */}
                    <div className="w-8 shrink-0 flex items-center">
                      <input
                        type="checkbox"
                        checked={isChecked}
                        onChange={() => handleToggleRow(log.id)}
                        className="w-4 h-4 rounded border-[#D1D5DB] text-[#8B53FE] focus:ring-[#8B53FE] cursor-pointer"
                      />
                    </div>

                    {/* Provider Column */}
                    <div className="flex-[1.8] min-w-0 flex items-center gap-2.5 pr-2">
                      <img
                        src={log.provider.avatar}
                        alt={log.provider.name}
                        className="w-8 h-8 rounded-full object-cover shrink-0"
                      />
                      <div className="flex flex-col min-w-0">
                        <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                          {log.provider.name}
                        </span>
                        <span className="text-[11px] text-[#8C8C94] flex items-center gap-0.5 truncate">
                          <MapPin className="w-3 h-3 shrink-0" />
                          {log.provider.location}
                        </span>
                      </div>
                    </div>

                    {/* Customer Column */}
                    <div className="flex-[1.5] min-w-0 flex items-center gap-2.5 pr-2">
                      <img
                        src={log.customer.avatar}
                        alt={log.customer.name}
                        className="w-8 h-8 rounded-full object-cover shrink-0"
                      />
                      <div className="flex flex-col min-w-0">
                        <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                          {log.customer.name}
                        </span>
                      </div>
                    </div>

                    {/* Date & Time Column */}
                    <div className="flex-[1.5] min-w-0 flex flex-col justify-center pr-2">
                      <span className="text-[13px] font-medium text-[#1C2926] truncate">
                        {log.date}
                      </span>
                      <span className="text-[11px] text-[#8C8C94] truncate">
                        {log.time}
                      </span>
                    </div>

                    {/* Interaction Pill */}
                    <div className="flex-[1.2] shrink-0 flex items-center pr-2">
                      {log.interaction === 'WhatsApp' ? (
                        <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[12px] font-medium bg-[#E9FBF0] text-[#16A34A] shrink-0">
                          <MessageCircle className="w-3.5 h-3.5" />
                          WhatsApp
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[12px] font-medium bg-[#F4EFFE] text-[#8B53FE] shrink-0">
                          <Phone className="w-3.5 h-3.5" />
                          Call
                        </span>
                      )}
                    </div>

                    {/* Status Pill */}
                    <div className="flex-[1.1] shrink-0 flex items-center pr-2">
                      {log.status === 'Answered' ? (
                        <span className="inline-flex items-center px-3 py-1 rounded-full text-[12px] font-medium bg-[#E9FBF0] text-[#16A34A] shrink-0">
                          Answered
                        </span>
                      ) : log.status === 'Initiated' ? (
                        <span className="inline-flex items-center px-3 py-1 rounded-full text-[12px] font-medium bg-[#E0F2FE] text-[#0284C7] shrink-0">
                          Initiated
                        </span>
                      ) : (
                        <span className="inline-flex items-center px-3 py-1 rounded-full text-[12px] font-medium bg-[#FEE2E2] text-[#DC2626] shrink-0">
                          Failed
                        </span>
                      )}
                    </div>

                    {/* Actions */}
                    <div className="w-[140px] shrink-0 flex items-center justify-end gap-2 pr-2">
                      <button
                        type="button"
                        onClick={() => setActiveCallDetail(log)}
                        className="px-3.5 py-1.5 rounded-xl text-[12px] font-medium text-[#8B53FE] bg-[#F4EFFE] hover:bg-[#E9E2FD] transition-colors cursor-pointer shrink-0"
                      >
                        View Details
                      </button>
                      <button
                        type="button"
                        onClick={() => setActiveCallDetail(log)}
                        className="w-7 h-7 rounded-lg flex items-center justify-center text-[#8C8C94] hover:bg-gray-100 hover:text-[#1C2926] transition-colors cursor-pointer shrink-0"
                      >
                        <MoreHorizontal className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        </div>

        {/* ================= FOOTER / PAGINATION ================= */}
        <div
          style={{
            height: '60px',
            paddingLeft: '20px',
            paddingRight: '20px',
          }}
          className="w-full border-t border-[#F0EFF5] flex items-center justify-between shrink-0"
        >
          <span className="text-[13px] text-[#616166]">
            Showing 1-{filteredLogs.length} of {totalCount} Calls
          </span>

          {/* Pagination Controls */}
          <div className="flex items-center gap-1.5">
            <button
              type="button"
              disabled={currentPage === 1}
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
              className="w-8 h-8 rounded-lg border border-[#E5E7EB] flex items-center justify-center text-[#616166] hover:bg-gray-50 disabled:opacity-40 cursor-pointer"
            >
              ‹
            </button>
            {[1, 2, 3, 4, 5].map((pageNum) => (
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
              disabled={currentPage === 5}
              onClick={() => setCurrentPage((p) => Math.min(5, p + 1))}
              className="w-8 h-8 rounded-lg border border-[#E5E7EB] flex items-center justify-center text-[#616166] hover:bg-gray-50 disabled:opacity-40 cursor-pointer"
            >
              ›
            </button>
          </div>
        </div>
      </div>

      {/* ================= EXACT FIGMA RIGHT SIDEBAR POPUP (515x745, right-aligned, height according to screen, scrollbar) ================= */}
      {activeCallDetail && (
        <div className="fixed inset-0 z-[1000] flex items-start justify-end p-5 bg-black/30 backdrop-blur-md transition-all duration-200 animate-in fade-in select-none">
          {/* Backdrop click to dismiss */}
          <div
            className="absolute inset-0"
            onClick={() => setActiveCallDetail(null)}
          />

          {/* Right-aligned Sidebar Card */}
          <aside
            style={{
              width: '515px',
              height: '745px',
              maxHeight: 'calc(100vh - 40px)',
              borderRadius: '20px',
              padding: '20px',
              background: '#FFFFFF',
              boxSizing: 'border-box',
            }}
            className="relative z-10 w-full max-w-[515px] shadow-2xl border border-[#EBEBEB] flex flex-col justify-between overflow-y-auto overflow-x-hidden custom-card-scrollbar animate-in slide-in-from-right-8 duration-200 shrink-0"
          >
            {/* Inner Content Layout: width: 475px, gap: 24px */}
            <div
              style={{
                width: '100%',
                maxWidth: '475px',
                gap: '24px',
              }}
              className="flex flex-col mx-auto"
            >
              {/* ================= 1. HEADING LAYOUT: 475x43, justify-between ================= */}
              <div
                style={{
                  height: '43px',
                }}
                className="w-full flex items-start justify-between shrink-0"
              >
                <div className="flex flex-col">
                  <h2 className="text-[18px] font-bold text-[#1C2926] leading-tight tracking-tight">
                    Communication Details
                  </h2>
                  <p className="text-[13px] text-[#616166] mt-0.5 leading-snug">
                    Call interactions between customer and provider.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setActiveCallDetail(null)}
                  className="w-8 h-8 -mr-1 -mt-1 rounded-lg flex items-center justify-center text-[#616166] hover:bg-gray-100 hover:text-[#1C2926] transition-colors cursor-pointer"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* ================= 2. BADGE LAYOUT: 475x68, radius: 12px, padding: 16px, background: #F3EFFE, justify-between ================= */}
              <div
                style={{
                  height: '68px',
                  borderRadius: '12px',
                  padding: '16px',
                  background: '#F3EFFE',
                  boxSizing: 'border-box',
                }}
                className="w-full flex items-center justify-between shrink-0"
              >
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl bg-[#E6DEFC] text-[#8B53FE] flex items-center justify-center shrink-0">
                    {activeCallDetail.interaction === 'WhatsApp' ? (
                      <MessageCircle className="w-5 h-5 text-[#16A34A]" />
                    ) : (
                      <Phone className="w-4.5 h-4.5 text-[#8B53FE]" />
                    )}
                  </div>
                  <div className="flex flex-col">
                    <span className="text-[14px] font-bold text-[#1C2926] leading-tight">
                      {activeCallDetail.interaction === 'WhatsApp' ? 'WhatsApp Chat' : 'Phone Call'}
                    </span>
                    <span className="text-[12px] text-[#616166] mt-0.5">
                      {activeCallDetail.callId}
                    </span>
                  </div>
                </div>

                {/* Status badge pill */}
                <span
                  className={`inline-flex items-center px-3 py-1 rounded-full text-[12px] font-semibold ${
                    activeCallDetail.status === 'Answered'
                      ? 'bg-[#E9FBF0] text-[#16A34A]'
                      : activeCallDetail.status === 'Initiated'
                      ? 'bg-[#E0F2FE] text-[#0284C7]'
                      : 'bg-[#FEE2E2] text-[#DC2626]'
                  }`}
                >
                  {activeCallDetail.status}
                </span>
              </div>

              {/* ================= 3. CONTENT LAYOUT (CALL INFO): 475x66, gap: 20px ================= */}
              <div
                style={{
                  height: '66px',
                  gap: '20px',
                }}
                className="w-full flex flex-col justify-between shrink-0"
              >
                <h3 className="text-[14px] font-bold text-[#1C2926]">
                  Call Information
                </h3>
                <div className="flex flex-col gap-1.5 text-[13px]">
                  <div className="flex items-center justify-between">
                    <span className="text-[#616166]">Date & Time</span>
                    <span className="text-[#1C2926] font-medium">
                      {activeCallDetail.date}, {activeCallDetail.time}
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-[#616166]">Time Duration</span>
                    <span className="text-[#1C2926] font-medium">
                      {activeCallDetail.duration}
                    </span>
                  </div>
                </div>
              </div>

              {/* Subtle divider */}
              <div className="w-full h-[1px] bg-[#F0EFF5] shrink-0" />

              {/* ================= 4. PROVIDER DETAILS LAYOUT: 475x97, gap: 10px ================= */}
              <div
                style={{
                  height: '97px',
                  gap: '10px',
                }}
                className="w-full flex flex-col justify-between shrink-0"
              >
                <h3 className="text-[14px] font-bold text-[#1C2926]">
                  Provider Details
                </h3>

                {/* Provider info card */}
                <div className="flex items-center gap-3">
                  <img
                    src={activeCallDetail.provider.avatar}
                    alt={activeCallDetail.provider.name}
                    className="w-10 h-10 rounded-full object-cover shrink-0"
                  />
                  <div className="flex flex-col">
                    <span className="text-[14px] font-bold text-[#1C2926] leading-tight">
                      {activeCallDetail.provider.name}
                    </span>
                    <span className="text-[12px] text-[#8C8C94] mt-0.5">
                      {activeCallDetail.provider.publicId}
                    </span>
                  </div>
                </div>

                <div className="flex items-center justify-between text-[13px]">
                  <span className="text-[#616166]">Phone Number</span>
                  <span className="text-[#1C2926] font-medium">
                    {activeCallDetail.provider.phone}
                  </span>
                </div>
              </div>

              {/* Subtle divider */}
              <div className="w-full h-[1px] bg-[#F0EFF5] shrink-0" />

              {/* ================= 5. CUSTOMER DETAILS LAYOUT: 475x97, gap: 10px ================= */}
              <div
                style={{
                  height: '97px',
                  gap: '10px',
                }}
                className="w-full flex flex-col justify-between shrink-0"
              >
                <h3 className="text-[14px] font-bold text-[#1C2926]">
                  Customer Details
                </h3>

                {/* Customer info card */}
                <div className="flex items-center gap-3">
                  <img
                    src={activeCallDetail.customer.avatar}
                    alt={activeCallDetail.customer.name}
                    className="w-10 h-10 rounded-full object-cover shrink-0"
                  />
                  <div className="flex flex-col">
                    <span className="text-[14px] font-bold text-[#1C2926] leading-tight">
                      {activeCallDetail.customer.name}
                    </span>
                    <span className="text-[12px] text-[#8C8C94] mt-0.5">
                      {activeCallDetail.customer.role}
                    </span>
                  </div>
                </div>

                <div className="flex items-center justify-between text-[13px]">
                  <span className="text-[#616166]">Phone Number</span>
                  <span className="text-[#1C2926] font-medium">
                    {activeCallDetail.customer.phone}
                  </span>
                </div>
              </div>

              {/* Subtle divider */}
              <div className="w-full h-[1px] bg-[#F0EFF5] shrink-0" />

              {/* ================= 6. RELATED SERVICE REQUEST LAYOUT: 475x66, gap: 20px ================= */}
              <div
                style={{
                  height: '66px',
                  gap: '20px',
                }}
                className="w-full flex flex-col justify-between shrink-0"
              >
                <h3 className="text-[14px] font-bold text-[#1C2926]">
                  Related Service Request
                </h3>
                <div className="flex flex-col gap-1.5 text-[13px]">
                  <div className="flex items-center justify-between">
                    <span className="text-[#616166]">Request ID</span>
                    <span className="text-[#8B53FE] font-semibold">
                      {activeCallDetail.requestId}
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-[#616166]">Service Category</span>
                    <span className="text-[#1C2926] font-medium">
                      {activeCallDetail.category}
                    </span>
                  </div>
                </div>
              </div>

              {/* ================= 7. BUTTON LAYOUT: 475x48, radius: 12px, padding: 16px 24px, background: #2D2A3D ================= */}
              <button
                type="button"
                onClick={() => setActiveCallDetail(null)}
                style={{
                  height: '48px',
                  borderRadius: '12px',
                  paddingTop: '14px',
                  paddingBottom: '14px',
                  paddingLeft: '24px',
                  paddingRight: '24px',
                  background: '#2D2A3D',
                  boxSizing: 'border-box',
                }}
                className="w-full flex items-center justify-center text-white text-[15px] font-semibold hover:bg-[#1E1B2B] active:scale-[0.99] transition-all cursor-pointer shrink-0 shadow-sm mt-2 mb-1"
              >
                Close
              </button>
            </div>
          </aside>
        </div>
      )}
    </div>
  )
}

export default CallLogsView
