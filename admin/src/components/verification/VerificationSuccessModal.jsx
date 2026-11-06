import React from 'react'
import {
  X,
  Check,
  XCircle,
  RotateCcw,
  MapPin,
  CreditCard,
  Calendar,
  AlertCircle,
  ArrowLeft,
  ExternalLink,
} from 'lucide-react'

export function VerificationSuccessModal({
  isOpen,
  onClose,
  onBackToQueue,
  onViewProfile,
  outcome = 'verified', // 'verified' | 'invalid' | 'resubmit'
  remarks = '',
  provider = {
    id: 'QA-2024-003',
    name: 'Ahmad Raza',
    city: 'Jeddah',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
    timestamp: '22 Sep, 10:24 AM',
  },
}) {
  if (!isOpen) return null

  // Configuration for Verified, Invalid, Resubmit
  const config = {
    verified: {
      title: 'Successfully Verified',
      subtitle: "The document has been reviewed and approved in accordance with Qareeb's verification standards.",
      icon: Check,
      iconBg: 'bg-gradient-to-tr from-[#8B53FE] to-[#A67AFE]',
      shadowColor: 'shadow-[#8B53FE]/35',
      glowColor: 'bg-[#8B53FE]/20',
      badgeText: 'Approved',
      badgeStyle: 'bg-[#E9FBF0] text-[#16A34A]',
      dateLabel: 'Approved On',
      bannerBg: 'bg-[#F4EFFE]',
      bannerText: 'text-[#7032F0]',
      bannerIconColor: 'bg-[#8B53FE]',
      bannerMessage: 'The provider will be notified of the approval and can start receiving service requests once all platform checks are complete.',
      primaryBtnBg: 'bg-[#8B53FE] hover:bg-[#7032F0]',
      sparkColors: ['#38BDF8', '#FBBF24', '#8B53FE', '#EC4899', '#06B6D4', '#22C55E', '#F59E0B'],
    },
    invalid: {
      title: 'Document Marked as Invalid',
      subtitle: "The document does not meet Qareeb's standards and has been rejected.",
      icon: X,
      iconBg: 'bg-gradient-to-tr from-[#EF4444] to-[#F87171]',
      shadowColor: 'shadow-[#EF4444]/35',
      glowColor: 'bg-[#EF4444]/20',
      badgeText: 'Rejected',
      badgeStyle: 'bg-[#FEE2E2] text-[#DC2626]',
      dateLabel: 'Rejected On',
      bannerBg: 'bg-[#FEF2F2]',
      bannerText: 'text-[#DC2626]',
      bannerIconColor: 'bg-[#DC2626]',
      bannerMessage: 'The provider will be notified of the rejection along with your remarks and instructions to resolve the issue.',
      primaryBtnBg: 'bg-[#DC2626] hover:bg-[#B91C1C]',
      sparkColors: ['#EF4444', '#F87171', '#FCA5A5', '#F87171', '#EF4444', '#DC2626', '#B91C1C'],
    },
    resubmit: {
      title: 'Resubmission Requested',
      subtitle: 'The provider has been notified to re-upload a compliant, clear copy of this document.',
      icon: RotateCcw,
      iconBg: 'bg-gradient-to-tr from-[#8B53FE] to-[#9A68FE]',
      shadowColor: 'shadow-[#8B53FE]/35',
      glowColor: 'bg-[#8B53FE]/20',
      badgeText: 'Resubmission',
      badgeStyle: 'bg-[#EFF6FF] text-[#2563EB]',
      dateLabel: 'Requested On',
      bannerBg: 'bg-[#F4EFFE]',
      bannerText: 'text-[#7032F0]',
      bannerIconColor: 'bg-[#8B53FE]',
      bannerMessage: 'Your remarks and instructions have been dispatched to the provider via push notification and SMS.',
      primaryBtnBg: 'bg-[#8B53FE] hover:bg-[#7032F0]',
      sparkColors: ['#38BDF8', '#8B53FE', '#A855F7', '#FBBF24', '#06B6D4', '#6366F1', '#EC4899'],
    },
  }[outcome] || config.verified

  const IconComp = config.icon

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/35 backdrop-blur-md transition-all duration-200 animate-in fade-in select-none">
      {/* Background click to dismiss */}
      <div className="absolute inset-0" onClick={onClose} />

      {/* Modal Dialog Box */}
      <div
        style={{
          width: '490px',
          borderRadius: '24px',
          boxSizing: 'border-box',
        }}
        className="relative z-10 bg-white p-7 rounded-[24px] shadow-2xl border border-[#EBEBEB] flex flex-col gap-5 animate-in zoom-in-95 duration-200"
      >
        {/* Top Close Button */}
        <button
          type="button"
          onClick={onClose}
          className="absolute top-5 right-5 w-8 h-8 rounded-full text-[#9EAFA9] hover:text-[#1C2926] hover:bg-[#F5F5F7] flex items-center justify-center transition-colors cursor-pointer"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Celebratory / Status Icon with Radiating Confetti Rays */}
        <div className="flex flex-col items-center justify-center relative pt-2">
          {/* Confetti / Radiating Particle Graphic */}
          <div className="relative flex items-center justify-center">
            {/* Ambient Glow */}
            <div className={`absolute w-24 h-24 rounded-full ${config.glowColor} blur-xl animate-pulse`} />

            {/* Radiating Ray Sparks */}
            <svg
              className="absolute -inset-4 w-28 h-28 pointer-events-none"
              viewBox="0 0 100 100"
              fill="none"
            >
              <line x1="50" y1="12" x2="50" y2="2" stroke={config.sparkColors[0]} strokeWidth="2.5" strokeLinecap="round" />
              <line x1="77" y1="23" x2="84" y2="16" stroke={config.sparkColors[1]} strokeWidth="2.5" strokeLinecap="round" />
              <line x1="88" y1="50" x2="98" y2="50" stroke={config.sparkColors[2]} strokeWidth="2.5" strokeLinecap="round" />
              <line x1="77" y1="77" x2="85" y2="85" stroke={config.sparkColors[3]} strokeWidth="2.5" strokeLinecap="round" />
              <line x1="50" y1="88" x2="50" y2="98" stroke={config.sparkColors[4]} strokeWidth="2.5" strokeLinecap="round" />
              <line x1="23" y1="23" x2="16" y2="16" stroke={config.sparkColors[5]} strokeWidth="2.5" strokeLinecap="round" />
              <line x1="12" y1="50" x2="2" y2="50" stroke={config.sparkColors[6]} strokeWidth="2.5" strokeLinecap="round" />
            </svg>

            {/* Core Circular Badge */}
            <div className={`relative w-16 h-16 rounded-full ${config.iconBg} text-white flex items-center justify-center shadow-lg ${config.shadowColor}`}>
              <IconComp className="w-8 h-8 stroke-[3]" />
            </div>
          </div>

          {/* Heading & Subtitle */}
          <h2 className="text-[20px] font-bold text-[#1C2926] tracking-tight mt-4 text-center">
            {config.title}
          </h2>
          <p className="text-[13px] text-[#566663] font-normal text-center max-w-[380px] mx-auto mt-1 leading-snug">
            {config.subtitle}
          </p>
        </div>

        {/* Provider Snapshot Row */}
        <div className="flex items-center justify-between px-2 pt-1">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full overflow-hidden shrink-0 border border-[#EBEBEB]">
              <img
                src={provider.avatar}
                alt={provider.name}
                className="w-full h-full object-cover"
              />
            </div>
            <div className="flex flex-col">
              <span className="text-[14px] font-bold text-[#1C2926] leading-tight">
                {provider.name}
              </span>
              <div className="flex items-center gap-1 text-[11px] text-[#616166] mt-0.5">
                <MapPin className="w-3 h-3 text-[#9EAFA9]" />
                <span>{provider.city}</span>
              </div>
            </div>
          </div>

          {/* Status Badge */}
          <span className={`px-3 py-1 rounded-full ${config.badgeStyle} text-xs font-semibold flex items-center gap-1.5`}>
            <span className="w-1.5 h-1.5 rounded-full bg-current" />
            <span>{config.badgeText}</span>
          </span>
        </div>

        {/* Details Card (Application ID & Timestamp) */}
        <div className="w-full rounded-2xl border border-[#EBEBEB] p-3.5 grid grid-cols-2 gap-4 bg-white">
          {/* Application ID */}
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
              <CreditCard className="w-4 h-4" />
            </div>
            <div className="flex flex-col min-w-0">
              <span className="text-[10px] text-[#9EAFA9] leading-tight">Application ID</span>
              <span className="text-[13px] font-semibold text-[#1C2926] leading-tight mt-0.5 truncate">
                {provider.id}
              </span>
            </div>
          </div>

          {/* Timestamp */}
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
              <Calendar className="w-4 h-4" />
            </div>
            <div className="flex flex-col min-w-0">
              <span className="text-[10px] text-[#9EAFA9] leading-tight">{config.dateLabel}</span>
              <span className="text-[13px] font-semibold text-[#1C2926] leading-tight mt-0.5 truncate">
                {provider.timestamp || '22 Sep, 10:24 AM'}
              </span>
            </div>
          </div>
        </div>

        {/* Optional Remarks Quote Box if Remarks Provided */}
        {remarks && (
          <div className="w-full rounded-xl border border-[#EBEBEB] bg-[#F9FAFB] p-3 text-xs flex flex-col gap-1">
            <span className="text-[10px] uppercase font-bold tracking-wider text-[#9EAFA9]">
              Admin Remarks Shared With Provider
            </span>
            <p className="text-[#1C2926] italic leading-relaxed text-[12px]">
              "{remarks}"
            </p>
          </div>
        )}

        {/* Info Alert Banner */}
        <div className={`w-full rounded-xl ${config.bannerBg} p-3 flex items-start gap-2.5`}>
          <div className={`w-4 h-4 rounded-full ${config.bannerIconColor} text-white flex items-center justify-center shrink-0 mt-0.5`}>
            <AlertCircle className="w-3 h-3" />
          </div>
          <span className={`text-[11px] font-medium ${config.bannerText} leading-snug`}>
            {config.bannerMessage}
          </span>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center justify-between gap-3 pt-1">
          {/* Back to Queue Button */}
          <button
            type="button"
            onClick={onBackToQueue}
            className="flex-1 h-11 px-4 rounded-xl border border-[#EBEBEB] bg-white text-xs font-semibold text-[#1C2926] hover:bg-[#F5F5F7] flex items-center justify-center gap-2 transition-all cursor-pointer shadow-2xs"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Back to Queue</span>
          </button>

          {/* View Profile Button */}
          <button
            type="button"
            onClick={onViewProfile || onClose}
            className={`flex-1 h-11 px-5 rounded-xl ${config.primaryBtnBg} text-white text-xs font-semibold flex items-center justify-center gap-1.5 transition-all cursor-pointer shadow-xs hover:shadow-sm`}
          >
            <span>View Profile</span>
            <ExternalLink className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    </div>
  )
}

export default VerificationSuccessModal
