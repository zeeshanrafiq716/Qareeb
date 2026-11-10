import React from 'react'

export function BrandLogo({ className = '', iconSize = 28, showText = true, textColor = 'text-[#1C2926]' }) {
  return (
    <div className={`flex items-center gap-2.5 ${className}`}>
      {/* Brand Icon: Purple circle with Q ring notch */}
      <div
        className="relative flex items-center justify-center shrink-0 rounded-full bg-[#8B53FE] text-white shadow-sm"
        style={{ width: iconSize, height: iconSize }}
      >
        <svg
          viewBox="0 0 24 24"
          className="w-3/5 h-3/5"
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

      {showText && (
        <span className={`font-bold tracking-wider text-base font-sans uppercase ${textColor}`}>
          ZESHO
        </span>
      )}
    </div>
  )
}

export default BrandLogo

