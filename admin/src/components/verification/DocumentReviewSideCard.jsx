import React, { useState } from 'react'
import {
  X,
  CheckCircle2,
  XCircle,
  RotateCcw,
  AlertCircle,
  ArrowRight,
} from 'lucide-react'

export function DocumentReviewSideCard({
  isOpen,
  onClose,
  document = {
    id: 'registration',
    title: 'Vehicle Registration (Istimara)',
    docType: 'Vehicle Registration (Istimara)',
    previewUrl: '',
  },
  onSubmitReview,
}) {
  const [selectedStatus, setSelectedStatus] = useState('resubmit') // 'verified' | 'invalid' | 'resubmit'
  const [remarks, setRemarks] = useState(
    'Please upload a clear full-page copy of your vehicle registration (Istimara). The current document is unclear.'
  )

  if (!isOpen) return null

  const handleStatusChange = (status) => {
    setSelectedStatus(status)
    if (status === 'verified') {
      setRemarks('Document verified and confirmed as valid and acceptable.')
    } else if (status === 'invalid') {
      setRemarks('Document has expired or does not match provider details. Please review and re-upload.')
    } else {
      setRemarks('Please upload a clear full-page copy of your vehicle registration (Istimara). The current document is unclear.')
    }
  }

  const handleSubmit = () => {
    if (onSubmitReview) {
      onSubmitReview({
        documentId: document.id,
        status: selectedStatus,
        remarks,
      })
    }
    onClose()
  }

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-end p-5 bg-black/30 backdrop-blur-md transition-all duration-200 animate-in fade-in select-none overflow-y-auto">
      {/* Background click to dismiss */}
      <div className="absolute inset-0" onClick={onClose} />

      {/* ================= SIDE CARD LAYOUT: 540x928 (top: 20px, right: 20px / left: 880px) ================= */}
      <aside
        style={{
          width: '540px',
          height: '928px',
          maxHeight: 'calc(100vh - 40px)',
          borderRadius: '20px',
          padding: '20px 16px 20px 20px',
          gap: '20px',
          background: '#FFFFFF',
          boxSizing: 'border-box',
        }}
        className="relative z-10 shadow-2xl border border-[#EBEBEB] flex flex-col justify-between overflow-y-auto overflow-x-hidden custom-card-scrollbar animate-in slide-in-from-right-8 duration-200"
      >
        {/* ================= CARD INNER: width: 500, height: 824, gap: 24px ================= */}
        <div
          style={{
            width: '492px',
            gap: '20px',
          }}
          className="flex flex-col"
        >
          {/* ================= 1. HEADING LAYOUT (500x43, justify-between) ================= */}
          <div
            style={{
              width: '492px',
              height: '43px',
            }}
            className="flex items-center justify-between shrink-0"
          >
            <div className="flex flex-col">
              <h2 className="text-[18px] font-bold text-[#1C2926] leading-tight">
                Review Document
              </h2>
              <p className="text-[12px] text-[#616166] leading-tight mt-0.5">
                {document.title || 'Vehicle Registration (Istimara)'}
              </p>
            </div>

            {/* Close Button */}
            <button
              type="button"
              onClick={onClose}
              className="w-9 h-9 rounded-xl border border-[#EBEBEB] bg-white text-[#616166] hover:bg-[#F5F5F7] hover:text-[#1C2926] flex items-center justify-center transition-colors cursor-pointer shadow-2xs"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          {/* ================= 2. DOCUMENT PREVIEW BOX ================= */}
          <div
            style={{
              width: '492px',
              borderRadius: '20px',
              border: '1px solid #CCCCCC',
              padding: '16px',
              boxSizing: 'border-box',
              gap: '12px',
            }}
            className="flex flex-col justify-between bg-white shrink-0 h-auto min-h-[210px] max-h-[290px]"
          >
            {/* Header text */}
            <div className="flex flex-col">
              <span className="text-[13px] font-bold text-[#1C2926] leading-tight">
                Document Preview
              </span>
              <span className="text-[11px] text-[#9EAFA9] leading-tight mt-0.5">
                Review the document carefully before selecting at status.
              </span>
            </div>

            {/* Authentic Saudi Istimara Document Image */}
            <div className="w-full h-[150px] sm:h-[180px] rounded-[14px] overflow-hidden border border-[#E5E7EB] bg-[#F9FAFB] flex items-center justify-center p-1 relative shadow-inner">
              <img
                src="/assets/istimara_card.png"
                alt="Vehicle Registration (Istimara)"
                className="w-full h-full object-contain rounded-lg"
                onError={(e) => {
                  // Fallback to placeholder if asset not loaded
                  e.currentTarget.style.display = 'none'
                }}
              />
            </div>
          </div>

          {/* ================= 3. NEXT SECTION: VERIFICATION STATUS (500x402, gap: 24px) ================= */}
          <div
            style={{
              width: '492px',
              gap: '16px',
            }}
            className="flex flex-col shrink-0"
          >
            {/* Section Heading (500x31) */}
            <div
              style={{
                width: '492px',
                height: '31px',
              }}
              className="flex flex-col justify-center"
            >
              <span className="text-[14px] font-bold text-[#1C2926] leading-tight">
                Verification Status
              </span>
              <span className="text-[11px] text-[#9EAFA9] leading-tight mt-0.5">
                Select the appropriate status for this document.
              </span>
            </div>

            {/* 3 Status Cards Row: 500x112, gap: 12px */}
            <div
              style={{
                width: '492px',
                height: '112px',
                gap: '12px',
              }}
              className="flex items-center shrink-0"
            >
              {/* Card 1: Verified (width: 156px, height: 112px) */}
              <div
                onClick={() => handleStatusChange('verified')}
                style={{
                  width: '156px',
                  height: '112px',
                  borderRadius: '12px',
                  padding: '16px',
                  borderWidth: '1px',
                  border: selectedStatus === 'verified' ? '1px solid #22C55E' : '1px solid #CCCCCC',
                  background: selectedStatus === 'verified' ? '#F0FDF4' : '#FFFFFF',
                  boxSizing: 'border-box',
                }}
                className="flex flex-col justify-between cursor-pointer transition-all hover:border-[#22C55E]"
              >
                <div className="flex items-center justify-between">
                  <div className="w-6 h-6 rounded-full flex items-center justify-center text-[#22C55E]">
                    <CheckCircle2 className="w-5 h-5 fill-[#22C55E] text-white" />
                  </div>
                  <div
                    className={`w-4 h-4 rounded-full border flex items-center justify-center ${
                      selectedStatus === 'verified'
                        ? 'border-[#22C55E] bg-[#22C55E]'
                        : 'border-[#CCCCCC] bg-white'
                    }`}
                  >
                    {selectedStatus === 'verified' && (
                      <div className="w-1.5 h-1.5 rounded-full bg-white" />
                    )}
                  </div>
                </div>
                <div className="flex flex-col">
                  <span className="text-[13px] font-bold text-[#1C2926] leading-tight">
                    Verified
                  </span>
                  <span className="text-[10px] text-[#616166] leading-tight mt-0.5">
                    Document is valid acceptable
                  </span>
                </div>
              </div>

              {/* Card 2: Invalid (width: 156px, height: 112px) */}
              <div
                onClick={() => handleStatusChange('invalid')}
                style={{
                  width: '156px',
                  height: '112px',
                  borderRadius: '12px',
                  padding: '16px',
                  borderWidth: '1px',
                  border: selectedStatus === 'invalid' ? '1px solid #EF4444' : '1px solid #CCCCCC',
                  background: selectedStatus === 'invalid' ? '#FEF2F2' : '#FFFFFF',
                  boxSizing: 'border-box',
                }}
                className="flex flex-col justify-between cursor-pointer transition-all hover:border-[#EF4444]"
              >
                <div className="flex items-center justify-between">
                  <div className="w-6 h-6 rounded-full flex items-center justify-center text-[#EF4444]">
                    <XCircle className="w-5 h-5 fill-[#EF4444] text-white" />
                  </div>
                  <div
                    className={`w-4 h-4 rounded-full border flex items-center justify-center ${
                      selectedStatus === 'invalid'
                        ? 'border-[#EF4444] bg-[#EF4444]'
                        : 'border-[#CCCCCC] bg-white'
                    }`}
                  >
                    {selectedStatus === 'invalid' && (
                      <div className="w-1.5 h-1.5 rounded-full bg-white" />
                    )}
                  </div>
                </div>
                <div className="flex flex-col">
                  <span className="text-[13px] font-bold text-[#1C2926] leading-tight">
                    Invalid
                  </span>
                  <span className="text-[10px] text-[#616166] leading-tight mt-0.5">
                    Document has an issue or is not valid
                  </span>
                </div>
              </div>

              {/* Card 3: Resubmit (width: 156px, height: 112px, background: #F4EFFE, border: 1px solid #8B53FE) */}
              <div
                onClick={() => handleStatusChange('resubmit')}
                style={{
                  width: '156px',
                  height: '112px',
                  borderRadius: '12px',
                  padding: '16px',
                  borderWidth: '1px',
                  border: selectedStatus === 'resubmit' ? '1px solid #8B53FE' : '1px solid #CCCCCC',
                  background: selectedStatus === 'resubmit' ? '#F4EFFE' : '#FFFFFF',
                  boxSizing: 'border-box',
                }}
                className="flex flex-col justify-between cursor-pointer transition-all hover:border-[#8B53FE]"
              >
                <div className="flex items-center justify-between">
                  <div className="w-6 h-6 rounded-full bg-[#8B53FE] text-white flex items-center justify-center">
                    <RotateCcw className="w-3.5 h-3.5 stroke-[2.5]" />
                  </div>
                  <div
                    className={`w-4 h-4 rounded-full border flex items-center justify-center ${
                      selectedStatus === 'resubmit'
                        ? 'border-[#8B53FE] bg-[#8B53FE]'
                        : 'border-[#CCCCCC] bg-white'
                    }`}
                  >
                    {selectedStatus === 'resubmit' && (
                      <div className="w-1.5 h-1.5 rounded-full bg-white" />
                    )}
                  </div>
                </div>
                <div className="flex flex-col">
                  <span className="text-[13px] font-bold text-[#1C2926] leading-tight">
                    Resubmit
                  </span>
                  <span className="text-[10px] text-[#616166] leading-tight mt-0.5">
                    Upload a New Document
                  </span>
                </div>
              </div>
            </div>

            {/* Admin Remarks Layout: 492x219, gap: 16px */}
            <div
              style={{
                width: '492px',
                gap: '12px',
              }}
              className="flex flex-col shrink-0"
            >
              {/* Heading (492x31) */}
              <div
                style={{
                  width: '492px',
                  height: '31px',
                }}
                className="flex flex-col justify-center"
              >
                <span className="text-[14px] font-bold text-[#1C2926] leading-tight">
                  Admin Remarks
                </span>
                <span className="text-[11px] text-[#9EAFA9] leading-tight mt-0.5">
                  Provide a reason or instructions of the provider. This will be shared with the provider.
                </span>
              </div>

              {/* Textarea Input Box (492x100, border: 1px solid #CCCCCC, radius: 12px) */}
              <div
                style={{
                  width: '492px',
                  height: '100px',
                  borderRadius: '12px',
                  border: '1px solid #CCCCCC',
                  boxSizing: 'border-box',
                }}
                className="relative bg-white p-3 flex flex-col justify-between focus-within:border-[#8B53FE] transition-colors"
              >
                <textarea
                  value={remarks}
                  onChange={(e) => setRemarks(e.target.value.slice(0, 300))}
                  placeholder="Enter remarks for the service provider..."
                  className="w-full flex-1 text-xs text-[#1C2926] placeholder-[#9EAFA9] resize-none outline-none leading-relaxed bg-transparent"
                />
                <div className="text-[10px] text-[#9EAFA9] text-right">
                  {remarks.length}/300
                </div>
              </div>

              {/* Badge Layout: 492x56, background: #F2EDFC, border-radius: 12px, padding: 16px */}
              <div
                style={{
                  width: '492px',
                  height: '56px',
                  borderRadius: '12px',
                  background: '#F2EDFC',
                  padding: '16px',
                  gap: '12px',
                  boxSizing: 'border-box',
                }}
                className="flex items-center shrink-0"
              >
                <div className="w-5 h-5 rounded-full bg-[#8B53FE] text-white flex items-center justify-center shrink-0">
                  <AlertCircle className="w-3.5 h-3.5" />
                </div>
                <span className="text-[11px] font-medium text-[#7032F0] leading-tight">
                  These instructions will be sent to the provider so they can upload the correct document.
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* ================= BUTTONS LAYOUT: width: 306.2px, height: 44px, gap: 16px ================= */}
        <div
          style={{
            width: '492px',
            height: '44px',
          }}
          className="flex items-center justify-end pt-2 shrink-0"
        >
          <div
            style={{
              width: '306.2px',
              height: '44px',
              gap: '16px',
            }}
            className="flex items-center justify-end"
          >
            {/* Cancel Button */}
            <button
              type="button"
              onClick={onClose}
              className="flex-1 h-[44px] rounded-xl border border-[#CCCCCC] bg-white text-xs font-semibold text-[#1C2926] hover:bg-[#F5F5F7] transition-all cursor-pointer shadow-2xs"
            >
              Cancel
            </button>

            {/* Submit Review Button */}
            <button
              type="button"
              onClick={handleSubmit}
              className="flex-1 h-[44px] rounded-xl bg-[#8B53FE] hover:bg-[#7032F0] text-white text-xs font-semibold flex items-center justify-center gap-1.5 transition-all cursor-pointer shadow-xs hover:shadow-sm"
            >
              <span>Submit Review</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
      </aside>
    </div>
  )
}

export default DocumentReviewSideCard

