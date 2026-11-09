import React, { useState } from 'react'
import {
  ChevronDown,
  ArrowRight,
  ChevronRight,
  Check,
  MapPin,
} from 'lucide-react'

const Y_TICKS = [100, 80, 60, 40, 20, 0]
const TIME_OPTIONS = ['This Week', 'This Month', 'Last Month', 'This Year']
const DEFAULT_CHART_DATA = [
  { day: 'Sun', value: 0, active: false },
  { day: 'Mon', value: 0, active: false },
  { day: 'Tue', value: 0, active: false },
  { day: 'Wed', value: 0, active: true },
  { day: 'Thu', value: 0, active: false },
  { day: 'Fri', value: 0, active: false },
  { day: 'Sat', value: 0, active: false },
]

export function DashboardSecondRow({
  onViewLiveMap,
  overviewStats = {
    approved: 0,
    rejected: 0,
    resubmission: 0,
  },
  chartData: propChartData,
  mapPins: propMapPins,
}) {
  const [timeRange, setTimeRange] = useState('This Month')
  const [dropdownOpen, setDropdownOpen] = useState(false)
  const [hoveredBar, setHoveredBar] = useState(null)
  const [selectedProvider, setSelectedProvider] = useState(null)

  const chartData = propChartData && propChartData.length > 0 ? propChartData : DEFAULT_CHART_DATA
  const mapPins = propMapPins || []
  const maxBarValue = Math.max(10, ...chartData.map((d) => Number(d.value) || 0))
  const yTicks = [
    maxBarValue,
    Math.round(maxBarValue * 0.8),
    Math.round(maxBarValue * 0.6),
    Math.round(maxBarValue * 0.4),
    Math.round(maxBarValue * 0.2),
    0,
  ]
  const timeOptions = TIME_OPTIONS

  return (
    <div
      style={{
        gap: '16px',
        boxSizing: 'border-box',
      }}
      className="w-full max-w-[1084px] grid grid-cols-1 lg:grid-cols-[560fr_508fr] shrink-0 select-none"
    >
      {/* ================= 1ST CARD: PROVIDER VERIFICATION OVERVIEW (560x386 at 1084px) ================= */}
      <div
        style={{
          minHeight: '386px',
          height: '386px',
          borderRadius: '20px',
          boxSizing: 'border-box',
        }}
        className="w-full bg-white rounded-[20px] p-6 border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0"
      >
        {/* Top Header: Title & Time Filter */}
        <div className="flex items-center justify-between">
          <h3 className="text-[18px] font-bold text-[#1C2926] tracking-tight">
            Provider Verification Overview
          </h3>

          {/* Filter Dropdown */}
          <div className="relative">
            <button
              type="button"
              onClick={() => setDropdownOpen((prev) => !prev)}
              className="h-[36px] px-3.5 rounded-xl border border-[#EBEBEB] bg-white text-xs font-medium text-[#1C2926] hover:bg-[#F9F9FB] flex items-center gap-2 transition-all cursor-pointer shadow-2xs"
            >
              <span>{timeRange}</span>
              <ChevronDown
                className={`w-3.5 h-3.5 text-[#566663] transition-transform duration-200 ${
                  dropdownOpen ? 'rotate-180' : ''
                }`}
              />
            </button>

            {dropdownOpen && (
              <div className="absolute right-0 mt-2 w-36 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-30 animate-in fade-in zoom-in-95 duration-100">
                {timeOptions.map((opt) => (
                  <button
                    key={opt}
                    type="button"
                    onClick={() => {
                      setTimeRange(opt)
                      setDropdownOpen(false)
                    }}
                    className={`w-full px-3.5 py-2 text-xs text-left flex items-center justify-between hover:bg-[#F0EAFE] transition-colors cursor-pointer ${
                      timeRange === opt ? 'text-[#8B53FE] font-semibold' : 'text-[#1C2926]'
                    }`}
                  >
                    <span>{opt}</span>
                    {timeRange === opt && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Legend / Metrics Summary */}
        <div className="flex items-center gap-8 mt-1">
          {/* Approved */}
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-xs text-[#616166]">
              <span className="w-2 h-2 rounded-full bg-[#22C55E]" />
              <span>Approved</span>
            </div>
            <div className="text-[17px] font-bold text-[#1C2926] pl-4">
              {overviewStats.approved}
            </div>
          </div>

          {/* Rejected */}
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-xs text-[#616166]">
              <span className="w-2 h-2 rounded-full bg-[#EF4444]" />
              <span>Rejected</span>
            </div>
            <div className="text-[17px] font-bold text-[#1C2926] pl-4">
              {overviewStats.rejected}
            </div>
          </div>

          {/* Resubmission */}
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-xs text-[#616166]">
              <span className="w-2 h-2 rounded-full bg-[#F59E0B]" />
              <span>Resubmission</span>
            </div>
            <div className="text-[17px] font-bold text-[#1C2926] pl-4">
              {overviewStats.resubmission}
            </div>
          </div>
        </div>

        {/* Vertical Bar Chart with Y-Axis & Dashed Grid */}
        <div className="relative w-full h-[210px] flex pt-4">
          {/* Y-Axis Labels */}
          <div className="w-8 h-[170px] flex flex-col justify-between items-end pr-2 text-[11px] text-[#9EAFA9] font-medium shrink-0">
            {yTicks.map((val) => (
              <span key={val} className="leading-none">
                {val}
              </span>
            ))}
          </div>

          {/* Chart Plot Area with Grid Lines */}
          <div className="relative flex-1 h-[170px]">
            {/* Dashed Horizontal Grid Lines */}
            <div className="absolute inset-0 flex flex-col justify-between pointer-events-none">
              {yTicks.map((val) => (
                <div
                  key={val}
                  className="w-full border-b border-dashed border-[#F0F0F3]"
                  style={{ height: '0px' }}
                />
              ))}
            </div>

            {/* Bars Container */}
            <div className="absolute inset-0 flex items-end justify-between px-3">
              {chartData.map((item, idx) => {
                const heightPercent = maxBarValue > 0 ? Math.min(100, (Number(item.value || 0) / maxBarValue) * 100) : 0
                const isHovered = hoveredBar === idx
                const isActive = item.active

                return (
                  <div
                    key={item.day}
                    onMouseEnter={() => setHoveredBar(idx)}
                    onMouseLeave={() => setHoveredBar(null)}
                    className="flex flex-col items-center justify-end h-full relative cursor-pointer group"
                    style={{ width: '42px' }}
                  >
                    {/* Floating Value Pill for Wed / Active or on Hover */}
                    {(isActive || isHovered) && (
                      <span
                        className={`absolute text-[12px] font-bold transition-all duration-150 ${
                          isActive
                            ? 'text-[#8B53FE] -top-5.5'
                            : 'text-[#1C2926] -top-5'
                        }`}
                      >
                        {item.value}
                      </span>
                    )}

                    {/* Bar Pill */}
                    <div
                      style={{
                        height: `${heightPercent}%`,
                        width: '38px',
                      }}
                      className={`rounded-t-[12px] rounded-b-[6px] transition-all duration-200 ${
                        isActive
                          ? 'bg-[#8B53FE] shadow-sm relative overflow-hidden'
                          : isHovered
                          ? 'bg-[#D6C5FB]'
                          : 'bg-[#F2F2F5]'
                      }`}
                    >
                      {/* Diagonal stripe overlay texture on active Wed bar */}
                      {isActive && (
                        <div
                          className="absolute inset-0 opacity-20"
                          style={{
                            backgroundImage:
                              'repeating-linear-gradient(45deg, #FFFFFF, #FFFFFF 4px, transparent 4px, transparent 9px)',
                          }}
                        />
                      )}
                    </div>

                    {/* X-Axis Day Label */}
                    <span
                      className={`text-[12px] mt-2 leading-none transition-colors ${
                        isActive
                          ? 'text-[#8B53FE] font-semibold'
                          : 'text-[#9EAFA9] font-normal'
                      }`}
                    >
                      {item.day}
                    </span>
                  </div>
                )
              })}
            </div>
          </div>
        </div>
      </div>

      {/* ================= 2ND CARD: PROVIDERS ON LIVE MAP (508x386 at 1084px) ================= */}
      <div
        style={{
          minHeight: '386px',
          height: '386px',
          borderRadius: '20px',
          boxSizing: 'border-box',
        }}
        className="w-full bg-white rounded-[20px] p-6 border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0"
      >
        {/* Top Header: Title & View Live Map Action */}
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-[18px] font-bold text-[#1C2926] tracking-tight">
            Providers on Live Map
          </h3>

          <button
            type="button"
            onClick={onViewLiveMap}
            className="text-xs font-semibold text-[#8B53FE] bg-[#F4EFFE] hover:bg-[#EBE2FE] px-3.5 py-1.5 rounded-full flex items-center gap-1.5 transition-all cursor-pointer group"
          >
            <span>View Live Map</span>
            <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-0.5" />
          </button>
        </div>

        {/* Map View Container */}
        <div className="relative w-full flex-1 rounded-[16px] overflow-hidden border border-[#EBEBEB] bg-[#F4F6F9] select-none">
          {/* Vector Map Graphic (Makkah Urban Arteries & Holy Center) */}
          <svg
            className="absolute inset-0 w-full h-full object-cover"
            viewBox="0 0 500 300"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect width="500" height="300" fill="#F4F6F9" />

            {/* Subtle Urban Land mass fills */}
            <path
              d="M-20 60 C80 80, 150 20, 260 50 C370 80, 420 30, 520 70 L520 320 L-20 320 Z"
              fill="#ECEFF4"
              opacity="0.6"
            />
            <path
              d="M100 120 C180 100, 240 180, 320 140 C400 100, 480 160, 520 130 L520 300 L100 300 Z"
              fill="#E5EAF0"
              opacity="0.5"
            />

            {/* Concentric Makkah Ring Roads */}
            <circle cx="365" cy="180" r="110" stroke="#DFE4ED" strokeWidth="2.5" />
            <circle cx="365" cy="180" r="75" stroke="#DFE4ED" strokeWidth="2" strokeDasharray="4 4" />
            <circle cx="365" cy="180" r="45" stroke="#D1D9E6" strokeWidth="2" />
            <circle cx="365" cy="180" r="22" stroke="#8B53FE" strokeWidth="1.2" strokeOpacity="0.4" />

            {/* Main Highways / Roads (Purple & Gray Artery Lines) */}
            <path
              d="M10 240 C120 220, 220 160, 365 180 C440 190, 480 260, 520 280"
              stroke="#D3DBE8"
              strokeWidth="5"
              strokeLinecap="round"
            />
            <path
              d="M10 240 C120 220, 220 160, 365 180 C440 190, 480 260, 520 280"
              stroke="#FFFFFF"
              strokeWidth="3.2"
              strokeLinecap="round"
            />

            {/* North-South Ring Connector */}
            <path
              d="M260 -20 C270 90, 320 130, 365 180 C410 230, 430 280, 460 320"
              stroke="#D3DBE8"
              strokeWidth="4"
              strokeLinecap="round"
            />
            <path
              d="M260 -20 C270 90, 320 130, 365 180 C410 230, 430 280, 460 320"
              stroke="#FFFFFF"
              strokeWidth="2.5"
              strokeLinecap="round"
            />

            {/* Curved Artery */}
            <path
              d="M140 -20 C180 80, 260 180, 365 180 C440 180, 480 120, 520 90"
              stroke="#E0E6F0"
              strokeWidth="3.5"
            />

            {/* Regional Neighborhood Labels in Arabic & English */}
            <text x="353" y="146" fill="#6B7280" fontSize="10" fontWeight="600" textAnchor="middle">
              Makkah
            </text>
            <text x="353" y="158" fill="#9CA3AF" fontSize="9" textAnchor="middle">
              مكة
            </text>

            <text x="280" y="88" fill="#9CA3AF" fontSize="8" textAnchor="middle">
              Al Aziziyah
            </text>
            <text x="280" y="97" fill="#BDC5D1" fontSize="7" textAnchor="middle">
              العزيزية
            </text>

            <text x="270" y="258" fill="#9CA3AF" fontSize="8" textAnchor="middle">
              Al Taneem
            </text>
            <text x="270" y="267" fill="#BDC5D1" fontSize="7" textAnchor="middle">
              التنعيم
            </text>

            <text x="424" y="200" fill="#9CA3AF" fontSize="8" textAnchor="middle">
              Al Rabwah
            </text>
            <text x="424" y="209" fill="#BDC5D1" fontSize="7" textAnchor="middle">
              الربوة
            </text>

            {/* Central Holy Mosque Kaaba Emblem */}
            <g transform="translate(358, 168)">
              <rect x="0" y="0" width="14" height="14" rx="2.5" fill="#1F2937" />
              <rect x="0" y="3" width="14" height="2" fill="#F59E0B" />
            </g>
          </svg>

          {/* Map Marker Dots (Online Providers) */}
          {mapPins.map((pin) => (
            <div
              key={pin.id}
              style={{
                top: pin.top,
                left: pin.left,
                transform: 'translate(-50%, -50%)',
              }}
              className="absolute z-10 group"
            >
              {/* Outer Pulse Ring */}
              <span className="absolute -inset-1 rounded-full bg-[#8B53FE]/30 animate-ping" />
              {/* Core Purple Dot */}
              <div className="relative w-3.5 h-3.5 rounded-full bg-[#8B53FE] border-2 border-white shadow-sm cursor-pointer hover:scale-125 transition-transform" />
            </div>
          ))}

          {/* Active Provider Callout Card (shown when provider selected) */}
          {selectedProvider && (
            <div
              style={{
                top: '38%',
                left: '60%',
              }}
              className="absolute z-20 bg-white rounded-[16px] p-3 shadow-lg border border-[#EBEBEB] w-[210px] flex items-center justify-between animate-in fade-in zoom-in-95 duration-200"
            >
              <div className="flex items-center gap-2.5 min-w-0">
                {/* Provider Info */}
                <div className="min-w-0 flex flex-col">
                  <span className="text-[9px] font-semibold text-[#8B53FE] leading-tight">
                    {selectedProvider.status}
                  </span>
                  <span className="text-[12px] font-bold text-[#1C2926] truncate leading-snug">
                    {selectedProvider.name}
                  </span>
                  <span className="text-[10px] text-[#616166] truncate leading-tight">
                    {selectedProvider.category}
                  </span>
                  <span className="text-[9px] text-[#9EAFA9] truncate mt-0.5">
                    {selectedProvider.distance} • {selectedProvider.location}
                  </span>
                </div>
              </div>

              {/* Chevron Right */}
              <div className="text-[#9EAFA9] pl-1 shrink-0">
                <ChevronRight className="w-4 h-4 text-[#9EAFA9]" />
              </div>
            </div>
          )}

          {/* Location Pin Indicator Below the Card */}
          <div
            style={{
              top: '68%',
              left: '85%',
              transform: 'translate(-50%, -50%)',
            }}
            className="absolute z-10 flex flex-col items-center"
          >
            <div className="w-6 h-6 rounded-full bg-[#F4EFFE] border border-[#8B53FE] text-[#8B53FE] flex items-center justify-center shadow-xs">
              <MapPin className="w-3.5 h-3.5" />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default DashboardSecondRow

