import React, { useState, useRef, useEffect } from 'react'
import { Search, Bell, ChevronDown, Command, LogOut, User, CheckCircle2, PhoneCall, Clock } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { fetchAdminNotifications } from '../../api/admin'

export function AdminTopHeader({
  searchValue = '',
  onSearchChange,
  placeholder = 'Search providers,applications, or anything...',
  fluid = false,
}) {
  const { admin, logout } = useAuth()
  const searchInputRef = useRef(null)
  const [profileDropdownOpen, setProfileDropdownOpen] = useState(false)
  const [notificationsOpen, setNotificationsOpen] = useState(false)
  const [notifications, setNotifications] = useState([])
  const [unreadCount, setUnreadCount] = useState(0)

  // Fetch real notifications from backend
  useEffect(() => {
    let mounted = true
    async function loadNotifications() {
      try {
        const res = await fetchAdminNotifications()
        if (mounted && res) {
          setNotifications(res.items || [])
          setUnreadCount(res.unreadCount || 0)
        }
      } catch {
        if (mounted) {
          setNotifications([])
          setUnreadCount(0)
        }
      }
    }
    loadNotifications()
    const interval = setInterval(loadNotifications, 30000)
    return () => {
      mounted = false
      clearInterval(interval)
    }
  }, [])

  // Listen for Cmd+K or Ctrl+K shortcut to focus search
  useEffect(() => {
    const handleKeyDown = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        searchInputRef.current?.focus()
      }
    }
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [])

  const adminName = admin?.name || 'Zeeshan Rafique'
  const adminRole = admin?.role === 'super_admin' ? 'Super Admin' : (admin?.role || 'Admin')

  return (
    <header
      style={{
        height: '80px',
        boxSizing: 'border-box',
      }}
      className={`w-full ${
        fluid ? 'max-w-none' : 'max-w-[1084px]'
      } bg-white rounded-[16px] px-6 flex items-center justify-between border border-[#EBEBEB] shadow-xs shrink-0 select-none`}
    >
      {/* ================= LEFT: SEARCH INPUT BAR ================= */}
      {/* Layout: height: 44px; width: 440px; rounded-xl; bg: #F5F5F7 */}
      <div className="relative w-full max-w-[440px] flex items-center">
        <span className="absolute left-4 text-[#9EAFA9] pointer-events-none flex items-center">
          <Search className="w-4 h-4 text-[#9EAFA9]" />
        </span>

        <input
          ref={searchInputRef}
          type="text"
          value={searchValue}
          onChange={(e) => onSearchChange && onSearchChange(e.target.value)}
          placeholder={placeholder}
          className="w-full h-[44px] bg-[#F5F5F7] text-xs font-normal text-[#1C2926] placeholder-[#9EAFA9] rounded-xl pl-11 pr-11 border border-transparent focus:bg-white focus:border-[#8B53FE] focus:ring-4 focus:ring-[#8B53FE]/10 transition-all outline-none"
        />

        {/* Shortcut Badge: ⌘ */}
        <span className="absolute right-3.5 text-[#9EAFA9] flex items-center justify-center pointer-events-none">
          <kbd className="inline-flex items-center justify-center text-xs font-sans text-[#9EAFA9] bg-transparent">
            ⌘
          </kbd>
        </span>
      </div>

      {/* ================= RIGHT: NOTIFICATIONS & USER PROFILE ================= */}
      <div className="flex items-center gap-5">
        {/* Notification Bell Button */}
        <div className="relative">
          <button
            type="button"
            onClick={() => setNotificationsOpen((prev) => !prev)}
            className="w-11 h-11 rounded-full bg-[#F5F5F7] hover:bg-[#F0EAFE] hover:text-[#8B53FE] text-[#1C2926] flex items-center justify-center transition-all cursor-pointer relative"
            title="Notifications"
          >
            <Bell className="w-4 h-4" />
            {/* Notification Badge Dot (Only if unread > 0) */}
            {unreadCount > 0 && (
              <span className="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-[#8B53FE] ring-2 ring-white" />
            )}
          </button>

          {/* Notifications Dropdown */}
          {notificationsOpen && (
            <div className="absolute right-0 mt-2 w-80 bg-white rounded-2xl shadow-xl border border-[#EFF0ED] p-4 z-50 animate-in fade-in zoom-in-95 duration-150 max-h-[380px] flex flex-col">
              <div className="flex items-center justify-between pb-2 border-b border-[#EFF0ED]">
                <span className="text-xs font-bold text-[#1C2926]">Notifications</span>
                {unreadCount > 0 ? (
                  <span className="text-[10px] font-semibold text-[#8B53FE] bg-[#F0EAFE] px-2 py-0.5 rounded-full">
                    {unreadCount} New
                  </span>
                ) : (
                  <span className="text-[10px] font-medium text-[#9EAFA9] bg-[#F5F5F7] px-2 py-0.5 rounded-full">
                    All caught up
                  </span>
                )}
              </div>
              <div className="py-2 space-y-2 text-xs overflow-y-auto flex-1">
                {notifications.length === 0 ? (
                  <div className="py-6 text-center text-[#9EAFA9]">
                    <Bell className="w-6 h-6 mx-auto mb-1.5 opacity-30 text-[#8B53FE]" />
                    <p className="text-xs font-semibold text-[#1C2926]">No new notifications</p>
                    <p className="text-[11px] text-[#616166] mt-0.5">You're all caught up!</p>
                  </div>
                ) : (
                  notifications.map((n) => (
                    <div
                      key={n.id}
                      className="p-2.5 rounded-xl bg-[#F8FAFC] border border-[#EFF0ED] space-y-1 hover:border-[#DECFFC] transition-colors"
                    >
                      <div className="font-semibold text-[#1C2926] flex items-center gap-1.5">
                        {n.type === 'call_interaction' ? (
                          <PhoneCall className="w-3.5 h-3.5 text-[#8B53FE]" />
                        ) : (
                          <CheckCircle2 className="w-3.5 h-3.5 text-[#22C55E]" />
                        )}
                        <span className="truncate">{n.title}</span>
                      </div>
                      <p className="text-[11px] text-[#566663] leading-relaxed">
                        {n.message}
                      </p>
                      {n.createdAt && (
                        <p className="text-[10px] text-[#9EAFA9]">
                          {new Date(n.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </p>
                      )}
                    </div>
                  ))
                )}
              </div>
            </div>
          )}
        </div>

        {/* Vertical Divider */}
        <div className="w-[1.2px] h-8 bg-[#EBEBEB]" />

        {/* User Profile Info with Dropdown */}
        <div className="relative">
          <button
            type="button"
            onClick={() => setProfileDropdownOpen((prev) => !prev)}
            className="flex items-center gap-3 p-1.5 pr-2 rounded-xl hover:bg-[#F5F5F7] transition-all cursor-pointer text-left"
          >
            {/* User Avatar */}
            <div className="w-10 h-10 rounded-full overflow-hidden bg-[#8B53FE] text-white flex items-center justify-center text-xs font-bold ring-2 ring-[#EFF0ED] shrink-0">
              <img
                src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&h=120&q=80"
                alt={adminName}
                className="w-full h-full object-cover"
                onError={(e) => {
                  // Fallback to initials if external image is blocked
                  e.currentTarget.style.display = 'none'
                }}
              />
              <span className="font-semibold text-xs">
                {adminName
                  .split(' ')
                  .map((n) => n[0])
                  .join('')
                  .slice(0, 2)
                  .toUpperCase()}
              </span>
            </div>

            {/* User Name & Role */}
            <div className="flex flex-col">
              <span className="text-xs font-bold text-[#1C2926] leading-snug">
                {adminName}
              </span>
              <span className="text-[11px] font-normal text-[#9EAFA9] leading-tight">
                {adminRole}
              </span>
            </div>

            {/* Chevron Icon */}
            <ChevronDown
              className={`w-4 h-4 text-[#9EAFA9] ml-1 transition-transform duration-200 ${
                profileDropdownOpen ? 'rotate-180' : ''
              }`}
            />
          </button>

          {/* Profile Dropdown Menu */}
          {profileDropdownOpen && (
            <div className="absolute right-0 mt-2 w-48 bg-white rounded-2xl shadow-xl border border-[#EFF0ED] py-2 z-50 animate-in fade-in zoom-in-95 duration-150">
              <div className="px-4 py-2 border-b border-[#EFF0ED]">
                <div className="text-xs font-bold text-[#1C2926] truncate">{adminName}</div>
                <div className="text-[10px] text-[#9EAFA9] truncate">
                  {admin?.email || 'admin@qareeb.app'}
                </div>
              </div>

              <button
                type="button"
                onClick={() => {
                  setProfileDropdownOpen(false)
                  logout()
                }}
                className="w-full px-4 py-2.5 text-xs text-left text-[#DC2626] hover:bg-[#FEF2F2] flex items-center gap-2 transition-colors cursor-pointer"
              >
                <LogOut className="w-3.5 h-3.5 text-[#DC2626]" />
                <span>Log Out</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  )
}

export default AdminTopHeader

