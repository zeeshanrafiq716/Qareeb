import React, { useRef, useState, useEffect, useCallback } from 'react'
import {
  LayoutDashboard,
  ClipboardCheck,
  Users,
  MapPin,
  PhoneCall,
  FileText,
  Layers,
  ShieldCheck,
  Settings,
  LogOut,
  ChevronsUpDown,
} from 'lucide-react'

export function AdminSidebar({
  activeTab = 'dashboard',
  onSelectTab,
  onLogout,
  pendingVerificationsCount = 0,
}) {
  const scrollRef = useRef(null)
  const trackRef = useRef(null)

  const [canScroll, setCanScroll] = useState(false)
  const [thumbHeight, setThumbHeight] = useState(40)
  const [thumbTop, setThumbTop] = useState(0)
  const [isScrolling, setIsScrolling] = useState(false)
  const [isHovered, setIsHovered] = useState(false)
  const [isDragging, setIsDragging] = useState(false)

  const dragStartYRef = useRef(0)
  const scrollStartTopRef = useRef(0)
  const scrollTimeoutRef = useRef(null)

  const updateScrollbar = useCallback(() => {
    const el = scrollRef.current
    const track = trackRef.current
    if (!el || !track) return

    const { scrollTop, scrollHeight, clientHeight } = el
    const trackHeight = track.clientHeight

    const hasOverflow = scrollHeight > clientHeight + 4
    setCanScroll(hasOverflow)

    if (!hasOverflow || trackHeight <= 0) {
      setThumbHeight(0)
      setThumbTop(0)
      return
    }

    // Proportional thumb height (between 36px and 80% of track)
    const calculatedHeight = Math.max(
      36,
      Math.min(trackHeight * 0.8, (clientHeight / scrollHeight) * trackHeight),
    )
    setThumbHeight(calculatedHeight)

    // Position of thumb
    const maxScroll = scrollHeight - clientHeight
    const maxTop = trackHeight - calculatedHeight
    const progress = Math.min(1, Math.max(0, scrollTop / maxScroll))
    setThumbTop(progress * maxTop)
  }, [])

  useEffect(() => {
    updateScrollbar()
    const timer = setTimeout(updateScrollbar, 100)
    window.addEventListener('resize', updateScrollbar)
    return () => {
      clearTimeout(timer)
      window.removeEventListener('resize', updateScrollbar)
    }
  }, [updateScrollbar])

  const handleScroll = () => {
    updateScrollbar()
    setIsScrolling(true)

    if (scrollTimeoutRef.current) {
      clearTimeout(scrollTimeoutRef.current)
    }
    scrollTimeoutRef.current = setTimeout(() => {
      setIsScrolling(false)
    }, 800)
  }

  // Allow scrolling from anywhere inside the sidebar
  const handleSidebarWheel = (e) => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop += e.deltaY
    }
  }

  // Handle clicking on track to jump
  const handleTrackClick = (e) => {
    const track = trackRef.current
    const el = scrollRef.current
    if (!track || !el) return

    const rect = track.getBoundingClientRect()
    const clickY = e.clientY - rect.top
    const trackHeight = track.clientHeight
    const ratio = clickY / trackHeight
    const maxScroll = el.scrollHeight - el.clientHeight
    el.scrollTo({
      top: ratio * maxScroll,
      behavior: 'smooth',
    })
  }

  // Handle thumb dragging
  const handleThumbMouseDown = (e) => {
    e.stopPropagation()
    setIsDragging(true)
    dragStartYRef.current = e.clientY
    scrollStartTopRef.current = scrollRef.current ? scrollRef.current.scrollTop : 0

    const handleMouseMove = (moveEvent) => {
      const el = scrollRef.current
      const track = trackRef.current
      if (!el || !track) return

      const deltaY = moveEvent.clientY - dragStartYRef.current
      const trackHeight = track.clientHeight
      const maxScroll = el.scrollHeight - el.clientHeight
      const maxTop = trackHeight - thumbHeight
      if (maxTop <= 0) return

      const scrollDelta = (deltaY / maxTop) * maxScroll
      el.scrollTop = scrollStartTopRef.current + scrollDelta
    }

    const handleMouseUp = () => {
      setIsDragging(false)
      window.removeEventListener('mousemove', handleMouseMove)
      window.removeEventListener('mouseup', handleMouseUp)
    }

    window.addEventListener('mousemove', handleMouseMove)
    window.addEventListener('mouseup', handleMouseUp)
  }

  const menuSections = [
    {
      title: 'MENU',
      items: [
        {
          id: 'dashboard',
          label: 'Dashboard',
          icon: LayoutDashboard,
          iconSize: 22,
        },
        {
          id: 'verification',
          label: 'Verification Queue',
          icon: ClipboardCheck,
          iconSize: 20,
          badge: pendingVerificationsCount > 0 ? pendingVerificationsCount : null,
        },
        {
          id: 'providers',
          label: 'Provider Directory',
          icon: Users,
          iconSize: 20,
        },
        {
          id: 'map',
          label: 'Live Map',
          icon: MapPin,
          iconSize: 20,
        },
        {
          id: 'call-logs',
          label: 'Call Logs',
          icon: PhoneCall,
          iconSize: 20,
        },
        {
          id: 'reports',
          label: 'Reports & Complaints',
          icon: FileText,
          iconSize: 20,
        },
      ],
    },
    {
      title: 'MANAGEMENT',
      items: [
        {
          id: 'categories',
          label: 'Category Management',
          icon: Layers,
          iconSize: 20,
        },
        {
          id: 'admin-access',
          label: 'Admin Access',
          icon: ShieldCheck,
          iconSize: 20,
        },
      ],
    },
    {
      title: 'PREFERENCES',
      items: [
        {
          id: 'settings',
          label: 'Settings',
          icon: Settings,
          iconSize: 20,
        },
        {
          id: 'logout',
          label: 'Log out',
          icon: LogOut,
          iconSize: 20,
          isAction: true,
        },
      ],
    },
  ]

  const handleItemClick = (item) => {
    if (item.id === 'logout') {
      if (onLogout) onLogout()
      return
    }
    if (onSelectTab) {
      onSelectTab(item.id)
    }
  }

  return (
    <aside
      onWheel={handleSidebarWheel}
      className="w-[314px] min-w-[314px] max-w-[314px] shrink-0 bg-white rounded-[20px] border-r-[1.2px] border-[#EBEBEB] flex flex-col p-6 shadow-sm select-none"
      style={{
        height: 'calc(100vh - 16px)',
        maxHeight: '1008px',
        margin: '8px 0 8px 8px',
      }}
    >
      {/* ================= LOGO SECTION ================= */}
      <div className="w-[266px] h-[63px] rounded-[12px] border-[1.2px] border-[#EBEBEB] p-3 flex items-center justify-between bg-white shrink-0">
        <div className="w-[130px] h-[39px] flex items-center gap-3">
          {/* Circular Purple Ring Brand Icon */}
          <div className="w-8 h-8 rounded-full bg-[#8B53FE] text-white flex items-center justify-center shrink-0 shadow-xs">
            <svg
              viewBox="0 0 24 24"
              className="w-5 h-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="3.2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <circle cx="12" cy="12" r="7" />
              <path d="M16 16l3 3" />
            </svg>
          </div>
          <span className="font-bold text-base text-[#8B53FE] tracking-wide font-sans">
            QAREEB
          </span>
        </div>

        {/* Small selector chevrons on right */}
        <div className="text-[#9EAFA9] p-1">
          <ChevronsUpDown className="w-4 h-4" />
        </div>
      </div>

      {/* ================= TABS WIDGET WITH SEPARATE ANIMATED THIN SCROLLBAR ================= */}
      <div
        className="relative w-[266px] flex-1 min-h-0 flex mt-6 overflow-hidden"
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        {/* Left: Scrollable Tabs Container */}
        <div
          ref={scrollRef}
          onScroll={handleScroll}
          className="flex-1 min-h-0 overflow-y-auto space-y-6 pr-2 no-scrollbar"
        >
          {menuSections.map((section) => (
            <div key={section.title} className="space-y-1.5">
              {/* Section Heading */}
              <div className="text-[11px] font-semibold tracking-wider text-[#9EAFA9] uppercase px-4 mb-2">
                {section.title}
              </div>

              {/* Section Tabs with Equal Gap */}
              <div className="space-y-1.5">
                {section.items.map((item) => {
                  const isActive = activeTab === item.id
                  const IconComponent = item.icon

                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => handleItemClick(item)}
                      className={`w-[250px] h-[46px] rounded-[10px] flex items-center justify-between gap-3 px-4 py-3 text-left transition-all duration-150 cursor-pointer ${
                        isActive
                          ? 'bg-[#F4EFFE] border-l-[6px] border-[#8B53FE] text-[#8B53FE] font-medium'
                          : 'bg-transparent border-l-[6px] border-transparent text-[#616166] hover:bg-[#F9F9FB] hover:text-[#1C2926] font-normal'
                      }`}
                    >
                      <div className="flex items-center gap-3 min-w-0">
                        <div
                          className="flex items-center justify-center shrink-0"
                          style={{
                            width: `${item.iconSize}px`,
                            height: `${item.iconSize}px`,
                          }}
                        >
                          <IconComponent
                            className={`w-full h-full ${
                              isActive ? 'text-[#8B53FE]' : 'text-[#616166]'
                            }`}
                          />
                        </div>

                        <span
                          className="text-[16px] leading-tight truncate"
                          style={{
                            fontFamily: 'Inter, sans-serif',
                            fontWeight: isActive ? 500 : 400,
                          }}
                        >
                          {item.label}
                        </span>
                      </div>

                      {/* Optional Badge */}
                      {item.badge != null && (
                        <span className="px-2 py-0.5 text-xs font-bold rounded-full bg-[#8B53FE] text-white shrink-0">
                          {item.badge}
                        </span>
                      )}
                    </button>
                  )
                })}
              </div>
            </div>
          ))}
        </div>

        {/* Right: Separate Animated Thin Scrollbar Track & Thumb */}
        <div
          ref={trackRef}
          onClick={handleTrackClick}
          className={`w-[3.5px] h-full bg-[#F4F4F6] rounded-full relative my-1 shrink-0 overflow-hidden cursor-pointer transition-opacity duration-300 ${
            canScroll ? (isHovered || isScrolling || isDragging ? 'opacity-100' : 'opacity-40') : 'opacity-0 pointer-events-none'
          }`}
          title="Scroll navigation"
        >
          {/* Animated Glowing Purple Thumb */}
          <div
            onMouseDown={handleThumbMouseDown}
            className={`w-full rounded-full cursor-grab active:cursor-grabbing transition-all duration-150 ${
              isScrolling || isDragging || isHovered
                ? 'bg-gradient-to-b from-[#8B53FE] via-[#A67AFE] to-[#8B53FE] shadow-[0_0_8px_rgba(139,83,254,0.7)] animate-thumb-glow'
                : 'bg-[#DECFFC]'
            }`}
            style={{
              height: `${thumbHeight}px`,
              transform: `translateY(${thumbTop}px)`,
              transition: isDragging
                ? 'none'
                : 'transform 0.1s cubic-bezier(0.4, 0, 0.2, 1), background-color 0.2s ease',
            }}
          />
        </div>
      </div>
    </aside>
  )
}

export default AdminSidebar
