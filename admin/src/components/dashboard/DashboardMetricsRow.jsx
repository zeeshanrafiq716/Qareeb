import React, { useState } from 'react'
import {
  Users,
  Clock,
  UserCheck,
  ShieldAlert,
  Calendar,
  ChevronDown,
  ArrowUp,
  ArrowDown,
  Check,
} from 'lucide-react'

export function DashboardMetricsRow({
  adminName = 'Zeeshan',
  stats = {
    totalProviders: '1,482',
    pendingVerifications: '24',
    onlineProviders: '312',
    openReports: '8',
  },
  onDateRangeChange,
}) {
  const [dateRange, setDateRange] = useState('Last 7 Days')
  const [dropdownOpen, setDropdownOpen] = useState(false)

  const dateOptions = ['Today', 'Last 7 Days', 'Last 30 Days', 'This Month']

  const handleSelectRange = (range) => {
    setDateRange(range)
    setDropdownOpen(false)
    if (onDateRangeChange) onDateRangeChange(range)
  }

  const cardsData = [
    {
      id: 'total-providers',
      title: 'Total Providers',
      value: stats.totalProviders || '1,482',
      icon: Users,
      trend: {
        value: '12%',
        direction: 'up',
        bgColor: 'bg-[#E9FBF0]',
        textColor: 'text-[#16A34A]',
      },
      comparison: 'VS Last Week',
    },
    {
      id: 'pending-verifications',
      title: 'Pending Verifications',
      value: stats.pendingVerifications || '24',
      icon: Clock,
      trend: {
        value: '6%',
        direction: 'up',
        bgColor: 'bg-[#FEF3E2]',
        textColor: 'text-[#D97706]',
      },
      comparison: 'VS Last Week',
    },
    {
      id: 'online-providers',
      title: 'Online Providers',
      value: stats.onlineProviders || '312',
      icon: UserCheck,
      trend: {
        value: '18%',
        direction: 'up',
        bgColor: 'bg-[#E9FBF0]',
        textColor: 'text-[#16A34A]',
      },
      comparison: 'VS Last Week',
    },
    {
      id: 'open-reports',
      title: 'Open Reports',
      value: stats.openReports || '8',
      icon: ShieldAlert,
      trend: {
        value: '-20%',
        direction: 'down',
        bgColor: 'bg-[#FEE2E2]',
        textColor: 'text-[#DC2626]',
      },
      comparison: 'VS Last Week',
    },
  ]

  return (
    <div
      style={{
        height: '278px',
        borderRadius: '20px',
        paddingTop: '20px',
        paddingRight: '20px',
        paddingBottom: '16px',
        paddingLeft: '20px',
        gap: '20px',
        background: 'linear-gradient(180.59deg, #FFFFFF 26.29%, #8B53FE 277.04%)',
        boxSizing: 'border-box',
      }}
      className="w-full max-w-[1084px] flex flex-col justify-between border border-[#EBEBEB] shadow-xs shrink-0 select-none"
    >
      {/* ================= MAIN CARD HEADING LAYOUT (1044x52 at 1084px) ================= */}
      <div
        style={{
          height: '52px',
        }}
        className="w-full flex items-center justify-between shrink-0"
      >
        <div className="min-w-0 pr-4">
          <h2 className="text-[20px] font-bold text-[#1C2926] tracking-tight leading-tight truncate">
            Welcome back, {adminName}
          </h2>
          <p className="text-[12px] text-[#566663] font-normal mt-1 truncate">
            Monitor provider activity review pending applications and manage daily operations.
          </p>
        </div>

        {/* Date Filter Dropdown */}
        <div className="relative shrink-0">
          <button
            type="button"
            onClick={() => setDropdownOpen((prev) => !prev)}
            className="h-[38px] px-3.5 rounded-xl border border-[#EBEBEB] bg-white text-xs font-medium text-[#1C2926] hover:bg-[#F9F9FB] hover:border-[#DECFFC] flex items-center gap-2.5 transition-all shadow-2xs cursor-pointer shrink-0"
          >
            <Calendar className="w-4 h-4 text-[#1C2926]" />
            <span className="whitespace-nowrap">{dateRange}</span>
            <ChevronDown
              className={`w-3.5 h-3.5 text-[#566663] transition-transform duration-200 ${
                dropdownOpen ? 'rotate-180' : ''
              }`}
            />
          </button>

          {dropdownOpen && (
            <div className="absolute right-0 mt-2 w-40 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-30 animate-in fade-in zoom-in-95 duration-100">
              {dateOptions.map((opt) => (
                <button
                  key={opt}
                  type="button"
                  onClick={() => handleSelectRange(opt)}
                  className={`w-full px-3.5 py-2 text-xs text-left flex items-center justify-between hover:bg-[#F0EAFE] transition-colors cursor-pointer ${
                    dateRange === opt ? 'text-[#8B53FE] font-semibold' : 'text-[#1C2926]'
                  }`}
                >
                  <span>{opt}</span>
                  {dateRange === opt && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* ================= 4 CARDS LAYOUT (1044x170 at 1084px, gap: 12px, 252px cards) ================= */}
      <div
        style={{
          height: '170px',
          gap: '12px',
        }}
        className="w-full grid grid-cols-4 shrink-0"
      >
        {cardsData.map((card) => {
          const IconComp = card.icon
          const isUp = card.trend.direction === 'up'

          return (
            <div
              key={card.id}
              style={{
                height: '170px',
                borderRadius: '20px',
                padding: '20px',
                gap: '32px',
                background: '#FFFFFF',
                boxSizing: 'border-box',
              }}
              className="w-full min-w-0 flex flex-col justify-between shrink-0 border border-[#F0EFF5] shadow-xs hover:border-[#DECFFC] transition-all"
            >
              {/* Card Inner Heading: height: 32; gap: 12px; */}
              <div
                style={{
                  height: '32px',
                  gap: '12px',
                }}
                className="w-full flex items-center shrink-0 min-w-0"
              >
                {/* 32x32 Icon Container */}
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#566663] flex items-center justify-center shrink-0">
                  <IconComp className="w-4 h-4" />
                </div>
                {/* Label */}
                <span className="text-[14px] font-medium text-[#616166] truncate min-w-0">
                  {card.title}
                </span>
              </div>

              {/* Content: height: 66px; gap: 20px; */}
              <div
                style={{
                  height: '66px',
                }}
                className="w-full flex flex-col justify-between shrink-0 min-w-0"
              >
                {/* Value */}
                <div className="text-[28px] font-bold text-[#1C2926] leading-none tracking-tight truncate">
                  {card.value}
                </div>

                {/* Trend & Comparison */}
                <div className="flex items-center gap-1.5 sm:gap-2 min-w-0">
                  <span
                    className={`inline-flex items-center gap-1 px-1.5 sm:px-2 py-0.5 rounded-md text-[10px] sm:text-[11px] font-semibold shrink-0 ${card.trend.bgColor} ${card.trend.textColor}`}
                  >
                    {isUp ? (
                      <ArrowUp className="w-3 h-3 stroke-[2.5]" />
                    ) : (
                      <ArrowDown className="w-3 h-3 stroke-[2.5]" />
                    )}
                    <span>{card.trend.value}</span>
                  </span>

                  <span className="text-[11px] sm:text-[12px] text-[#616166] font-normal truncate min-w-0">
                    {card.comparison}
                  </span>
                </div>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}

export default DashboardMetricsRow
