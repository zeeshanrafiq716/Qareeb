import React, { useState, useEffect } from 'react'
import {
  Users,
  UserCheck,
  UserX,
  ShieldAlert,
  Search,
  ChevronDown,
  Phone,
  MoreHorizontal,
  Ban,
  CheckCircle,
  Trash2,
  Plus,
  X,
} from 'lucide-react'
import {
  fetchCustomers,
  createCustomerApi,
  blockCustomerApi,
  unblockCustomerApi,
  deleteCustomerApi,
} from '../api/admin'

export function CustomerDirectoryView() {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedStatus, setSelectedStatus] = useState('All Status')
  const [statusOpen, setStatusOpen] = useState(false)
  const [activeFilterCard, setActiveFilterCard] = useState('all')
  const [activeRowMenu, setActiveRowMenu] = useState(null)
  const [customersList, setCustomersList] = useState([])
  const [loading, setLoading] = useState(true)
  const [showAddModal, setShowAddModal] = useState(false)
  const [addForm, setAddForm] = useState({ phone: '', name: '', password: '' })
  const [addError, setAddError] = useState('')
  const [addSaving, setAddSaving] = useState(false)

  const loadCustomers = async (silent = false) => {
    try {
      if (!silent) setLoading(true)
      const res = await fetchCustomers({ limit: 100 })
      const raw = Array.isArray(res?.data) ? res.data : Array.isArray(res?.items) ? res.items : []
      const mapped = raw.map((item) => {
        const createdAt = item.createdAt ? new Date(item.createdAt) : new Date()
        const st = item.status === 'blocked' ? 'Blocked' : 'Active'
        return {
          id: item.id,
          name: item.name || 'Customer',
          phone: item.phone,
          status: st,
          statusType: item.status || 'active',
          providerReachCount:
            item.providerReachCount ?? item.totalReachEvents ?? 0,
          joinDate: createdAt.toLocaleDateString('en-GB', {
            day: '2-digit',
            month: 'short',
            year: 'numeric',
          }),
          joinTime: createdAt.toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit',
          }),
        }
      })
      setCustomersList(mapped)
    } catch (err) {
      console.error('Failed to load customers:', err)
    } finally {
      if (!silent) setLoading(false)
    }
  }

  useEffect(() => {
    loadCustomers(false)
    const timer = setInterval(() => loadCustomers(true), 5000)
    return () => clearInterval(timer)
  }, [])

  const totalCount = customersList.length
  const activeCount = customersList.filter((c) => c.statusType === 'active').length
  const blockedCount = customersList.filter((c) => c.statusType === 'blocked').length

  const metricCards = [
    {
      id: 'all',
      title: 'Total Customers',
      count: totalCount,
      icon: Users,
      iconBg: 'bg-[#F4EFFE] text-[#8B53FE]',
      activeRing: 'border-[#8B53FE] ring-2 ring-[#8B53FE]/20',
    },
    {
      id: 'active',
      title: 'Active',
      count: activeCount,
      icon: UserCheck,
      iconBg: 'bg-[#E9FBF0] text-[#16A34A]',
      activeRing: 'border-[#16A34A] ring-2 ring-[#16A34A]/20',
    },
    {
      id: 'blocked',
      title: 'Blocked',
      count: blockedCount,
      icon: ShieldAlert,
      iconBg: 'bg-[#FFF1F2] text-[#E11D48]',
      activeRing: 'border-[#E11D48] ring-2 ring-[#E11D48]/20',
    },
  ]

  const statuses = ['All Status', 'Active', 'Blocked']

  const filteredCustomers = customersList.filter((c) => {
    if (activeFilterCard === 'active' && c.statusType !== 'active') return false
    if (activeFilterCard === 'blocked' && c.statusType !== 'blocked') return false
    if (selectedStatus === 'Active' && c.statusType !== 'active') return false
    if (selectedStatus === 'Blocked' && c.statusType !== 'blocked') return false
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      return (
        c.name.toLowerCase().includes(q) ||
        c.phone.includes(q) ||
        c.id.toLowerCase().includes(q)
      )
    }
    return true
  })

  const getStatusColor = (status) => {
    if (status === 'Blocked') return 'text-[#E11D48]'
    if (status === 'Active') return 'text-[#16A34A]'
    return 'text-[#616166]'
  }

  /** Shared grid: name | reach | join | phone (md+) | status | action */
  const customerRowGrid =
    'grid w-full items-center gap-x-5 md:gap-x-6 ' +
    'grid-cols-[minmax(7.5rem,1.35fr)_5.5rem_minmax(6.5rem,0.95fr)_minmax(4.25rem,0.65fr)_3rem] ' +
    'md:grid-cols-[minmax(8rem,1.4fr)_6.25rem_minmax(7rem,1fr)_minmax(7.5rem,1.05fr)_4.5rem_3rem]'

  const handleAddCustomer = async (e) => {
    e.preventDefault()
    setAddError('')
    if (!addForm.phone.trim() || !addForm.name.trim()) {
      setAddError('Phone and name are required.')
      return
    }
    setAddSaving(true)
    try {
      await createCustomerApi({
        phone: addForm.phone.trim(),
        name: addForm.name.trim(),
        ...(addForm.password.trim() ? { password: addForm.password.trim() } : {}),
      })
      setShowAddModal(false)
      setAddForm({ phone: '', name: '', password: '' })
      await loadCustomers(true)
    } catch (err) {
      setAddError(err?.response?.data?.message || 'Could not create customer.')
    } finally {
      setAddSaving(false)
    }
  }

  const handleBlock = async (customer) => {
    setActiveRowMenu(null)
    try {
      await blockCustomerApi(customer.id)
      setCustomersList((prev) =>
        prev.map((c) =>
          c.id === customer.id ? { ...c, status: 'Blocked', statusType: 'blocked' } : c,
        ),
      )
    } catch (err) {
      console.error(err)
    }
  }

  const handleUnblock = async (customer) => {
    setActiveRowMenu(null)
    try {
      await unblockCustomerApi(customer.id)
      setCustomersList((prev) =>
        prev.map((c) =>
          c.id === customer.id ? { ...c, status: 'Active', statusType: 'active' } : c,
        ),
      )
    } catch (err) {
      console.error(err)
    }
  }

  const handleDelete = async (customer) => {
    setActiveRowMenu(null)
    if (
      !window.confirm(
        `Delete customer "${customer.name}"? This cannot be undone.`,
      )
    ) {
      return
    }
    try {
      await deleteCustomerApi(customer.id)
      setCustomersList((prev) => prev.filter((c) => c.id !== customer.id))
    } catch (err) {
      console.error(err)
    }
  }

  return (
    <div className="w-full max-w-[1084px] flex flex-col gap-5 shrink-0 select-none pb-8 animate-in fade-in duration-150">
      <div className="flex items-start justify-between gap-4">
        <div className="flex flex-col">
          <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
            Customers
          </h1>
          <p className="text-[13px] text-[#566663] font-normal mt-1 leading-snug">
            View registered customers and manage their account access.
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
          Add Customer
        </button>
      </div>

      <div className="w-full grid grid-cols-2 lg:grid-cols-3 gap-4 shrink-0">
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
              <div className="text-[28px] font-bold text-[#1C2926] leading-none tracking-tight">
                {card.count}
              </div>
            </div>
          )
        })}
      </div>

      <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] shadow-xs flex flex-col overflow-hidden">
        <div className="w-full px-5 py-3.5 flex items-center justify-between shrink-0">
          <div className="relative w-full max-w-[380px] flex items-center">
            <Search className="w-4 h-4 text-[#9EAFA9] absolute left-3.5 pointer-events-none" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by name, ID, or phone number..."
              className="w-full h-[40px] pl-10 pr-4 text-xs font-normal text-[#1C2926] placeholder-[#9EAFA9] bg-white border border-[#EBEBEB] rounded-xl focus:border-[#8B53FE] focus:ring-2 focus:ring-[#8B53FE]/15 transition-all outline-none"
            />
          </div>
          <div className="relative">
            <button
              type="button"
              onClick={() => setStatusOpen((prev) => !prev)}
              className="h-[40px] px-3.5 rounded-xl border border-[#EBEBEB] bg-white text-xs font-medium text-[#1C2926] hover:bg-[#F9F9FB] flex items-center gap-2 cursor-pointer"
            >
              <span>{selectedStatus === 'All Status' ? 'Status' : selectedStatus}</span>
              <ChevronDown className="w-3.5 h-3.5 text-[#566663]" />
            </button>
            {statusOpen && (
              <div className="absolute right-0 mt-1.5 w-40 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-30">
                {statuses.map((st) => (
                  <button
                    key={st}
                    type="button"
                    onClick={() => {
                      setSelectedStatus(st)
                      setStatusOpen(false)
                    }}
                    className="w-full px-3.5 py-2 text-xs text-left hover:bg-[#F0EAFE] cursor-pointer"
                  >
                    {st}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        <div
          className={`w-full bg-[#F4F2F7] px-5 py-3 min-h-[56px] text-[12px] font-semibold text-[#616166] ${customerRowGrid}`}
        >
          <div className="min-w-0 pr-1">Customer name</div>
          <div className="text-center text-[11px] leading-snug px-0.5 min-w-0">
            Reach to providers
          </div>
          <div className="min-w-0">Join date</div>
          <div className="min-w-0 hidden md:block">Phone</div>
          <div className="min-w-0">Status</div>
          <div className="text-right min-w-0">Action</div>
        </div>

        {loading ? (
          <div className="w-full py-16 flex flex-col items-center text-[#9EAFA9]">
            <div className="w-7 h-7 border-2 border-[#8B53FE] border-t-transparent rounded-full animate-spin mb-3" />
            <p className="text-xs text-[#616166]">Loading customers...</p>
          </div>
        ) : filteredCustomers.length === 0 ? (
          <div className="w-full py-16 flex flex-col items-center text-center text-[#9EAFA9]">
            <UserX className="w-10 h-10 mb-2 text-[#DECFFC]" />
            <p className="text-sm font-semibold text-[#1C2926]">No customers yet</p>
            <p className="text-xs text-[#616166] mt-1 max-w-sm">
              Customers who sign up in the Qareeb app appear here, or add one manually.
            </p>
          </div>
        ) : (
          filteredCustomers.map((c, idx) => {
            const isBottomRow = filteredCustomers.length >= 4 && idx >= filteredCustomers.length - 2
            return (
              <div
                key={c.id}
                className={`w-full px-5 min-h-[60px] py-2 border-b border-[#F0EFF2] hover:bg-[#FAF9FD] bg-white ${customerRowGrid}`}
              >
                <div className="min-w-0 pr-1">
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate block">
                    {c.name}
                  </span>
                  <span className="text-[10px] text-[#9EAFA9] font-mono truncate block md:hidden">
                    {c.phone}
                  </span>
                </div>
                <div className="flex justify-center min-w-0">
                  <span className="inline-flex min-w-[28px] justify-center px-2 py-0.5 rounded-lg bg-[#F4EFFE] text-[#8B53FE] text-xs font-bold">
                    {c.providerReachCount}
                  </span>
                </div>
                <div className="min-w-0 flex flex-col text-xs leading-tight">
                  <span className="text-[#1C2926] font-medium whitespace-nowrap">{c.joinDate}</span>
                  <span className="text-[#9EAFA9] text-[11px]">{c.joinTime}</span>
                </div>
                <div className="min-w-0 hidden md:flex items-center gap-1 text-xs text-[#616166] truncate">
                  <Phone className="w-3 h-3 shrink-0 text-[#9EAFA9]" />
                  <span className="truncate">{c.phone}</span>
                </div>
                <div className={`min-w-0 text-xs font-semibold ${getStatusColor(c.status)}`}>
                  {c.status}
                </div>
                <div className="flex justify-end relative min-w-0">
                  <button
                    type="button"
                    onClick={() => setActiveRowMenu((prev) => (prev === c.id ? null : c.id))}
                    className="p-1 rounded-md text-[#9EAFA9] hover:bg-[#F3F4F6] cursor-pointer"
                  >
                    <MoreHorizontal className="w-4 h-4" />
                  </button>
                  {activeRowMenu === c.id && (
                    <div
                      className={`absolute right-0 w-40 bg-white border border-[#EFF0ED] rounded-xl shadow-xl py-1.5 z-50 ${
                        isBottomRow ? 'bottom-full mb-1' : 'top-full mt-1'
                      }`}
                    >
                      {c.statusType !== 'active' && (
                        <button
                          type="button"
                          onClick={() => handleUnblock(c)}
                          className="w-full px-3 py-1.5 text-xs text-left text-[#16A34A] hover:bg-[#E9FBF0] flex items-center gap-2 cursor-pointer"
                        >
                          <CheckCircle className="w-3.5 h-3.5" />
                          Unblock
                        </button>
                      )}
                      {c.statusType === 'active' && (
                        <button
                          type="button"
                          onClick={() => handleBlock(c)}
                          className="w-full px-3 py-1.5 text-xs text-left text-[#E11D48] hover:bg-[#FFF1F2] flex items-center gap-2 cursor-pointer"
                        >
                          <Ban className="w-3.5 h-3.5" />
                          Block
                        </button>
                      )}
                      <button
                        type="button"
                        onClick={() => handleDelete(c)}
                        className="w-full px-3 py-1.5 text-xs text-left text-[#DC2626] hover:bg-[#FEF2F2] flex items-center gap-2 border-t border-[#F0EFF2] cursor-pointer"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                        Delete
                      </button>
                    </div>
                  )}
                </div>
              </div>
            )
          })
        )}

        <div className="w-full px-5 h-[52px] flex items-center border-t border-[#F0EFF2] text-xs text-[#616166]">
          Showing {filteredCustomers.length} of {customersList.length} customers
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
            <h2 className="text-lg font-bold text-[#1C2926] mb-1">Add Customer</h2>
            <p className="text-xs text-[#616166] mb-4">Create a customer account from the admin panel.</p>
            <form onSubmit={handleAddCustomer} className="space-y-3">
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
                <label className="text-xs font-medium text-[#616166]">Full name</label>
                <input
                  type="text"
                  value={addForm.name}
                  onChange={(e) => setAddForm((f) => ({ ...f, name: e.target.value }))}
                  placeholder="Customer name"
                  className="w-full mt-1 h-10 px-3 border border-[#EBEBEB] rounded-xl text-sm outline-none focus:border-[#8B53FE]"
                />
              </div>
              <div>
                <label className="text-xs font-medium text-[#616166]">Password (optional)</label>
                <input
                  type="password"
                  value={addForm.password}
                  onChange={(e) => setAddForm((f) => ({ ...f, password: e.target.value }))}
                  placeholder="Min 6 characters"
                  className="w-full mt-1 h-10 px-3 border border-[#EBEBEB] rounded-xl text-sm outline-none focus:border-[#8B53FE]"
                />
              </div>
              {addError && <p className="text-xs text-[#DC2626]">{addError}</p>}
              <button
                type="submit"
                disabled={addSaving}
                className="w-full h-10 rounded-xl bg-[#8B53FE] text-white text-sm font-semibold hover:bg-[#7B43EE] disabled:opacity-60 cursor-pointer"
              >
                {addSaving ? 'Saving…' : 'Create Customer'}
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

export default CustomerDirectoryView