import React, { useState, useEffect } from 'react'
import { ArrowRight, ChevronRight, ShieldAlert, Clock, MessageSquare } from 'lucide-react'
import { fetchProviders } from '../../api/admin'

export function DashboardThirdRow({
  onViewAllVerifications,
  onViewAllReports,
  onSelectProvider,
  openReportsCount = '0',
}) {
  const [verifications, setVerifications] = useState([])

  useEffect(() => {
    let mounted = true
    async function loadRecentVerifications() {
      try {
        const res = await fetchProviders({ limit: 10 })
        if (!mounted) return
        const rawItems = Array.isArray(res?.data)
          ? res.data
          : Array.isArray(res?.items)
          ? res.items
          : Array.isArray(res)
          ? res
          : []
        // Only show providers who completed onboarding steps
        const onboardedItems = rawItems.filter(
          (p) => p.status !== 'pending_otp' && p.status !== 'pending_profile'
        )
        const mapped = onboardedItems.map((p, idx) => {
          const isPending = p.status === 'pending_verification'

          const displayName =
            p.name && p.name.trim().length > 0 && p.name !== 'Provider'
              ? p.name
              : p.phone
                ? 'Provider'
                : 'New Provider'

          let statusText = 'Inactive'
          let statusColor = 'bg-[#F3F4F6] text-[#4B5563]'
          if (p.status === 'approved') {
            statusText = 'Approved'
            statusColor = 'bg-[#E9FBF0] text-[#16A34A]'
          } else if (isPending) {
            statusText = 'Pending'
            statusColor = 'bg-[#FEF3E2] text-[#D97706]'
          } else if (p.status === 'suspended') {
            statusText = 'Suspended'
            statusColor = 'bg-[#FEE2E2] text-[#DC2626]'
          }

          return {
            id: p.id,
            name: displayName,
            category: p.category?.name || 'Pending Registration',
            date: p.createdAt
              ? new Date(p.createdAt).toLocaleDateString('en-GB', { month: 'short', day: 'numeric', year: 'numeric' })
              : 'Today',
            status: statusText,
            statusColor,
            avatar: p.photoUrl || null,
            phone: p.phone,
            city: p.location?.city || p.city || 'Pending',
          }
        })
        setVerifications(mapped)
      } catch {
        if (mounted) setVerifications([])
      }
    }
    // 1. Initial load
    loadRecentVerifications()

    // 2. Real-time background sync interval (every 2.5 seconds without manual refresh)
    const intervalTimer = setInterval(() => {
      loadRecentVerifications()
    }, 2500)

    // 3. Instant sync when browser tab gains focus or window becomes visible
    const handleFocus = () => loadRecentVerifications()
    const handleVisibility = () => {
      if (document.visibilityState === 'visible') loadRecentVerifications()
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

  return (
    <div
      style={{
        gap: '16px',
        boxSizing: 'border-box',
      }}
      className="w-full max-w-[1084px] grid grid-cols-1 lg:grid-cols-[560fr_508fr] shrink-0 select-none pb-4"
    >
      {/* ================= 1ST CARD: PROVIDER VERIFICATION OVERVIEW (560x216) ================= */}
      <div
        style={{
          minHeight: '216px',
          height: '216px',
          borderRadius: '20px',
          boxSizing: 'border-box',
        }}
        className="w-full bg-white rounded-[20px] px-5 py-3.5 border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0"
      >
        {/* Top Header */}
        <div className="flex items-center justify-between">
          <h3 className="text-[17px] font-bold text-[#1C2926] tracking-tight">
            Provider Verification Overview
          </h3>

          <button
            type="button"
            onClick={onViewAllVerifications}
            className="text-xs font-semibold text-[#8B53FE] hover:text-[#7032F0] flex items-center gap-1 transition-colors cursor-pointer group"
          >
            <span>View All</span>
            <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-0.5" />
          </button>
        </div>

        {/* Provider Rows / Empty State */}
        <div className="flex flex-col justify-center flex-1 min-h-0 pt-1">
          {verifications.length === 0 ? (
            <div className="w-full py-6 flex flex-col items-center justify-center text-center text-[#9EAFA9]">
              <Clock className="w-8 h-8 mb-1.5 text-[#DECFFC]" />
              <p className="text-xs font-semibold text-[#1C2926]">No pending verifications</p>
              <p className="text-[11px] text-[#616166] mt-0.5">
                New provider applications will appear here for review.
              </p>
            </div>
          ) : (
            verifications.map((item, index) => (
              <div
                key={item.id}
                onClick={() => onSelectProvider && onSelectProvider(item)}
                className={`flex items-center justify-between py-1.5 cursor-pointer hover:bg-[#F9F9FB] rounded-lg px-1.5 transition-colors ${
                  index < verifications.length - 1 ? 'border-b border-[#F0EFF2]' : ''
                }`}
              >
                <div className="flex items-center gap-2.5 min-w-0">
                  <div className="flex flex-col min-w-0">
                    <span className="text-[13px] font-semibold text-[#1C2926] leading-tight truncate">
                      {item.name}
                    </span>
                    <span className="text-[11px] text-[#616166] leading-tight whitespace-normal break-words">
                      {item.category}
                    </span>
                  </div>
                </div>

                <div className="text-[11px] text-[#616166] px-2 shrink-0">
                  {item.date}
                </div>

                <div className="flex items-center gap-2 shrink-0">
                  <span
                    className={`text-[11px] font-medium px-2.5 py-0.5 rounded-full ${item.statusColor}`}
                  >
                    {item.status}
                  </span>
                  <ChevronRight className="w-4 h-4 text-[#9EAFA9]" />
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* ================= 2ND CARD: REPORTS SUMMARY (508x216) — list lives in Reports tab only ================= */}
      <div
        style={{
          minHeight: '216px',
          height: '216px',
          borderRadius: '20px',
          boxSizing: 'border-box',
        }}
        className="w-full bg-white rounded-[20px] px-5 py-3.5 border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0 overflow-hidden"
      >
        <div className="flex items-center justify-between shrink-0">
          <h3 className="text-[17px] font-bold text-[#1C2926] tracking-tight">
            Reports &amp; Complaints
          </h3>

          <button
            type="button"
            onClick={onViewAllReports}
            className="text-xs font-semibold text-[#8B53FE] hover:text-[#7032F0] flex items-center gap-1 transition-colors cursor-pointer group"
          >
            <span>Open tab</span>
            <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-0.5" />
          </button>
        </div>

        <div className="flex flex-col flex-1 min-h-0 justify-center items-center text-center px-2 overflow-hidden">
          <div className="w-full py-4 flex flex-col items-center justify-center">
            <div className="w-12 h-12 rounded-2xl bg-[#F5F0FF] flex items-center justify-center text-[#8B53FE] mb-3">
              <MessageSquare className="w-6 h-6" />
            </div>
            <p className="text-2xl font-extrabold text-[#1C2926] tracking-tight">
              {openReportsCount}
            </p>
            <p className="text-xs font-semibold text-[#616166] mt-1">
              Open tickets need review
            </p>
            <p className="text-[11px] text-[#9EAFA9] mt-2 max-w-[280px] leading-relaxed">
              Support requests (including phone change) are managed only in the
              Reports &amp; Complaints tab — not on this dashboard.
            </p>
            <button
              type="button"
              onClick={onViewAllReports}
              className="mt-4 px-4 py-2 rounded-xl text-xs font-semibold text-white bg-[#8B53FE] hover:bg-[#7032F0] shadow-xs"
            >
              Go to Reports &amp; Complaints
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default DashboardThirdRow
