import React from 'react'
import { ChevronRight, FileClock, ClipboardCheck, RotateCcw } from 'lucide-react'

export function VerificationMetricsSection({
  activeFilter = 'all',
  onSelectFilter,
  stats = {
    pendingReview: 124,
    underReview: 32,
    resubmission: 16,
  },
}) {
  const cards = [
    {
      id: 'pending',
      title: 'Pending Review',
      count: stats.pendingReview,
      icon: FileClock,
      iconBg: 'bg-[#F4EFFE] text-[#8B53FE]',
      activeRing: 'border-[#8B53FE] ring-2 ring-[#8B53FE]/15',
    },
    {
      id: 'under_review',
      title: 'Under Review',
      count: stats.underReview,
      icon: ClipboardCheck,
      iconBg: 'bg-[#FEF3E2] text-[#D97706]',
      activeRing: 'border-[#D97706] ring-2 ring-[#D97706]/15',
    },
    {
      id: 'resubmission',
      title: 'Resubmission',
      count: stats.resubmission,
      icon: RotateCcw,
      iconBg: 'bg-[#EFF6FF] text-[#2563EB]',
      activeRing: 'border-[#2563EB] ring-2 ring-[#2563EB]/15',
    },
  ]

  return (
    <div
      style={{
        height: '181px',
        boxSizing: 'border-box',
      }}
      className="w-full max-w-[1084px] flex flex-col justify-between shrink-0 select-none"
    >
      {/* ================= TITLE & SUBTITLE ================= */}
      <div className="flex flex-col">
        <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
          Verification Queue
        </h1>
        <p className="text-[13px] text-[#566663] font-normal mt-1 leading-snug">
          Review and manage provider verification applications submitted to Qareeb.
        </p>
      </div>

      {/* ================= 3 CARDS LAYOUT (gap: 20px) ================= */}
      <div
        style={{
          gap: '20px',
        }}
        className="w-full grid grid-cols-3 shrink-0"
      >
        {cards.map((card) => {
          const IconComp = card.icon
          const isActive = activeFilter === card.id

          return (
            <div
              key={card.id}
              onClick={() => onSelectFilter && onSelectFilter(card.id)}
              className={`h-[110px] rounded-[20px] bg-white p-5 border shadow-xs flex flex-col justify-between transition-all cursor-pointer ${
                isActive
                  ? card.activeRing
                  : 'border-[#EBEBEB] hover:border-[#DECFFC] hover:shadow-sm'
              }`}
            >
              {/* Top Row: Icon + Title + Chevron */}
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3 min-w-0">
                  <div
                    className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${card.iconBg}`}
                  >
                    <IconComp className="w-4 h-4" />
                  </div>
                  <span className="text-[14px] font-medium text-[#616166] truncate">
                    {card.title}
                  </span>
                </div>

                <ChevronRight className="w-4 h-4 text-[#9EAFA9] shrink-0" />
              </div>

              {/* Bottom Row: Large Count */}
              <div className="text-[28px] font-bold text-[#1C2926] leading-none tracking-tight">
                {card.count}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}

export default VerificationMetricsSection

