import React from 'react'
import { ArrowRight, ChevronRight, ShieldAlert, AlertTriangle } from 'lucide-react'

export function DashboardThirdRow({
  onViewAllVerifications,
  onViewAllReports,
  onSelectProvider,
  onSelectReport,
}) {
  const verifications = [
    {
      id: 'v1',
      name: 'Ahmad Raza',
      category: 'Tyre Repair',
      date: 'Oct 29, 2026',
      status: 'Pending',
      statusColor: 'bg-[#FEF3E2] text-[#D97706]',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
    },
    {
      id: 'v2',
      name: 'Omar Abdullah',
      category: 'Vehicle Towing',
      date: 'Oct 29, 2026',
      status: 'Approved',
      statusColor: 'bg-[#E9FBF0] text-[#16A34A]',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&h=120&q=80',
    },
    {
      id: 'v3',
      name: 'Ali Hassan',
      category: 'Battery Jump Start',
      date: 'Oct 29, 2026',
      status: 'Resubmission',
      statusColor: 'bg-[#FEF3E2] text-[#D97706]',
      avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=120&h=120&q=80',
    },
  ]

  const reports = [
    {
      id: 'r1',
      title: 'Inappropriate Behaviour',
      time: '2h ago',
      provider: 'Ahmed Al-Qahtani',
      category: 'Tyre Repair',
      status: 'Open',
      statusColor: 'bg-[#FEE2E2] text-[#DC2626]',
      icon: ShieldAlert,
      iconBg: 'bg-[#FEF2F2] text-[#EF4444]',
    },
    {
      id: 'r2',
      title: 'Service Quality Issue',
      time: '3h ago',
      provider: 'Omar Abdullah',
      category: 'Vehicle Towing',
      status: 'Under Review',
      statusColor: 'bg-[#FEF3E2] text-[#D97706]',
      icon: AlertTriangle,
      iconBg: 'bg-[#FEF3E2] text-[#F59E0B]',
    },
  ]

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

        {/* 3 Provider Rows */}
        <div className="flex flex-col justify-between flex-1 min-h-0 pt-1">
          {verifications.map((item, index) => (
            <div
              key={item.id}
              onClick={() => onSelectProvider && onSelectProvider(item)}
              className={`flex items-center justify-between py-1.5 cursor-pointer hover:bg-[#F9F9FB] rounded-lg px-1.5 transition-colors ${
                index < verifications.length - 1 ? 'border-b border-[#F0EFF2]' : ''
              }`}
            >
              {/* Left: Avatar + Info */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-full overflow-hidden shrink-0 border border-[#EFF0ED]">
                  <img
                    src={item.avatar}
                    alt={item.name}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[13px] font-semibold text-[#1C2926] leading-tight truncate">
                    {item.name}
                  </span>
                  <span className="text-[11px] text-[#616166] leading-tight truncate">
                    {item.category}
                  </span>
                </div>
              </div>

              {/* Middle: Date */}
              <div className="text-[11px] text-[#616166] px-2 shrink-0">
                {item.date}
              </div>

              {/* Right: Badge + Chevron */}
              <div className="flex items-center gap-2 shrink-0">
                <span
                  className={`text-[11px] font-medium px-2.5 py-0.5 rounded-full ${item.statusColor}`}
                >
                  {item.status}
                </span>
                <ChevronRight className="w-4 h-4 text-[#9EAFA9]" />
              </div>
            </div>
          ))}
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
        {/* Top Header */}
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

        {/* 2 Report Item Cards */}
        <div className="flex flex-col gap-2.5 flex-1 min-h-0 justify-center pt-1.5">
          {reports.map((report) => {
            const IconComponent = report.icon
            return (
              <div
                key={report.id}
                onClick={() => onSelectReport && onSelectReport(report)}
                className="w-full rounded-[14px] border border-[#EBEBEB] p-2.5 flex items-center justify-between hover:border-[#DECFFC] hover:bg-[#FAF9FF] transition-all cursor-pointer"
              >
                {/* Left: Icon + Text */}
                <div className="flex items-center gap-3 min-w-0">
                  <div
                    className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${report.iconBg}`}
                  >
                    <IconComponent className="w-4 h-4" />
                  </div>
                  <div className="flex flex-col min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-[13px] font-semibold text-[#1C2926] leading-tight truncate">
                        {report.title}
                      </span>
                      <span className="text-[10px] text-[#9EAFA9] leading-tight shrink-0">
                        {report.time}
                      </span>
                    </div>
                    <span className="text-[11px] text-[#616166] leading-tight truncate mt-0.5">
                      {report.provider} · {report.category}
                    </span>
                  </div>
                </div>

                {/* Right: Badge + Chevron */}
                <div className="flex items-center gap-2 shrink-0 pl-2">
                  <span
                    className={`text-[11px] font-medium px-2.5 py-0.5 rounded-full ${report.statusColor}`}
                  >
                    {report.status}
                  </span>
                  <ChevronRight className="w-4 h-4 text-[#9EAFA9]" />
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}

export default DashboardThirdRow

