import React, { useState, useEffect } from 'react'
import { ArrowRight, ChevronRight, ShieldAlert, AlertTriangle, Clock } from 'lucide-react'
import { fetchProviders } from '../../api/admin'

export function DashboardThirdRow({
  onViewAllVerifications,
  onViewAllReports,
  onSelectProvider,
  onSelectReport,
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
              : (p.phone ? `Provider (${p.phone})` : 'New Provider')

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

  const reports = []

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
                    <span className="text-[11px] text-[#616166] leading-tight truncate">
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

      {/* ================= 2ND CARD: RECENT REPORTS (508x216) ================= */}
      <div
        style={{
          minHeight: '216px',
          height: '216px',
          borderRadius: '20px',
          boxSizing: 'border-box',
        }}
        className="w-full bg-white rounded-[20px] px-5 py-3.5 border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0"
      >
        <div className="flex items-center justify-between">
          <h3 className="text-[17px] font-bold text-[#1C2926] tracking-tight">
            Recent Reports
          </h3>

          <button
            type="button"
            onClick={onViewAllReports}
            className="text-xs font-semibold text-[#8B53FE] hover:text-[#7032F0] flex items-center gap-1 transition-colors cursor-pointer group"
          >
            <span>View All</span>
            <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-0.5" />
          </button>
        </div>

        <div className="flex flex-col gap-2.5 flex-1 min-h-0 justify-center pt-1.5">
          {reports.length === 0 ? (
            <div className="w-full py-6 flex flex-col items-center justify-center text-center text-[#9EAFA9]">
              <ShieldAlert className="w-8 h-8 mb-1.5 text-[#DECFFC]" />
              <p className="text-xs font-semibold text-[#1C2926]">No open dispute reports</p>
              <p className="text-[11px] text-[#616166] mt-0.5">
                Customer feedback and incident reports will appear here.
              </p>
            </div>
          ) : (
            reports.map((report) => (
              <div
                key={report.id}
                onClick={() => onSelectReport && onSelectReport(report)}
                className="w-full rounded-[14px] border border-[#EBEBEB] p-2.5 flex items-center justify-between hover:border-[#DECFFC] hover:bg-[#FAF9FF] transition-all cursor-pointer"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-8 h-8 rounded-lg flex items-center justify-center shrink-0 bg-[#FEF2F2] text-[#EF4444]">
                    <ShieldAlert className="w-4 h-4" />
                  </div>
                  <div className="flex flex-col min-w-0">
                    <span className="text-[13px] font-semibold text-[#1C2926] leading-tight truncate">
                      {report.title}
                    </span>
                    <span className="text-[11px] text-[#616166] leading-tight truncate mt-0.5">
                      {report.provider} · {report.category}
                    </span>
                  </div>
                </div>
                <div className="flex items-center gap-2 shrink-0 pl-2">
                  <span className="text-[11px] font-medium px-2.5 py-0.5 rounded-full bg-[#FEE2E2] text-[#DC2626]">
                    {report.status}
                  </span>
                  <ChevronRight className="w-4 h-4 text-[#9EAFA9]" />
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  )
}

export default DashboardThirdRow
