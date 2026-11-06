import React, { useState } from 'react'
import {
  ArrowLeft,
  MapPin,
  User,
  ShieldCheck,
  CreditCard,
  Calendar,
  Phone,
  MessageCircle,
  Disc,
  Truck,
  Palette,
  ExternalLink,
  FileText,
  CheckCircle2,
  XCircle,
  RotateCcw,
  Smartphone,
  Eye,
  Check,
} from 'lucide-react'
import { DocumentReviewSideCard } from '../components/verification/DocumentReviewSideCard'
import { VerificationSuccessModal } from '../components/verification/VerificationSuccessModal'

export function ProviderReviewView({
  provider = {
    id: 'QA-2024-003',
    name: 'Ahmad Raza',
    city: 'Jeddah',
    category: 'Tyre Repair',
    submittedDate: '22 Sept 2024',
    status: 'Pending',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
    nationalId: '2487654321',
    iqamaExpiry: '12 Mar 2026',
    phone: '+966 48 570 5644',
    whatsapp: '+966 48 574 3245',
    vehicleModel: 'Toyota Dyna',
    vehicleType: 'Flatbed Truck',
    plateNumber: 'ABC 1234',
    vehicleColor: 'White',
  },
  onBack,
  onApprove,
  onReject,
  onRequestResubmit,
}) {
  const [selectedDocModal, setSelectedDocModal] = useState(null)
  const [showSuccessModal, setShowSuccessModal] = useState(false)
  const [outcomeType, setOutcomeType] = useState('verified') // 'verified' | 'invalid' | 'resubmit'
  const [outcomeRemarks, setOutcomeRemarks] = useState('')
  const [reviewStatus, setReviewStatus] = useState(provider.status || 'Pending')
  const [toastMessage, setToastMessage] = useState('')

  const showToast = (msg) => {
    setToastMessage(msg)
    setTimeout(() => setToastMessage(''), 3000)
  }

  const initialDocuments = [
    {
      id: 'iqama',
      title: 'Iqama',
      subtitle: 'National Residence ID',
      timestamp: '22 Sep, 10:15 AM',
      fileType: 'JPG (1.4 MB)',
      status: 'Pending',
      statusColor: 'bg-[#FEF3E2] text-[#D97706]',
      previewUrl: 'https://images.unsplash.com/photo-1633265486064-086b219458ec?auto=format&fit=crop&w=600&q=80',
    },
    {
      id: 'registration',
      title: 'Vehicle Registration',
      subtitle: '',
      timestamp: '22 Sep, 10:18 AM',
      fileType: 'JPG (2.1 MB)',
      status: 'Pending',
      statusColor: 'bg-[#FEF3E2] text-[#D97706]',
      previewUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=600&q=80',
    },
    {
      id: 'license',
      title: 'Driving Licence',
      subtitle: '',
      timestamp: '22 Sep, 10:20 AM',
      fileType: 'JPG (1.8 MB)',
      status: 'Pending',
      statusColor: 'bg-[#FEF3E2] text-[#D97706]',
      previewUrl: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=600&q=80',
    },
    {
      id: 'vehicle_front',
      title: 'Vehicle Front Photo',
      subtitle: '',
      timestamp: '22 Sep, 10:21 AM',
      fileType: 'JPG (3.8 MB)',
      status: 'Pending',
      statusColor: 'bg-[#FEF3E2] text-[#D97706]',
      previewUrl: 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=600&q=80',
    },
    {
      id: 'vehicle_rear',
      title: 'Vehicle Rear Photo',
      subtitle: '',
      timestamp: '22 Sep, 10:22 AM',
      fileType: 'JPG (4.2 MB)',
      status: 'Pending',
      statusColor: 'bg-[#FEF3E2] text-[#D97706]',
      previewUrl: 'https://images.unsplash.com/photo-1519003722824-194d4455a60c?auto=format&fit=crop&w=600&q=80',
    },
  ]

  const [documents, setDocuments] = useState(initialDocuments)

  const agreements = [
    {
      id: 'contract',
      title: 'Service Provider Contract',
      meta: 'Version 1.0 · 22 Sep 2026',
      status: 'Accepted',
      icon: FileText,
    },
    {
      id: 'conduct',
      title: 'Code of Conduct & Guidelines',
      meta: 'Consent recorded · 22 Sep 2026',
      status: 'Accepted',
      icon: ShieldCheck,
    },
    {
      id: 'otp',
      title: 'Final OTP Confirmation',
      meta: 'Registered phone · 22 Sep 2026',
      status: 'Verified',
      icon: Smartphone,
    },
  ]

  const handleApproveAction = () => {
    setReviewStatus('Approved')
    showToast('Provider application approved successfully!')
    if (onApprove) onApprove(provider)
  }

  const handleRejectAction = () => {
    setReviewStatus('Rejected')
    showToast('Provider application marked as Rejected')
    if (onReject) onReject(provider)
  }

  const handleResubmitAction = () => {
    setReviewStatus('Resubmission')
    showToast('Resubmission request sent to provider')
    if (onRequestResubmit) onRequestResubmit(provider)
  }

  return (
    <div className="w-full max-w-[1084px] flex flex-col gap-5 shrink-0 select-none pb-8 animate-in fade-in duration-150">
      {/* Toast Alert */}
      {toastMessage && (
        <div className="fixed top-6 right-8 bg-[#1C2926] text-white text-xs px-4 py-2.5 rounded-xl shadow-xl z-50 flex items-center gap-2 animate-in slide-in-from-top-2">
          <Check className="w-4 h-4 text-[#22C55E]" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* ================= CONTENT HEADER LAYOUT: width: 1084; height: 85; gap: 24px ================= */}
      <div
        style={{
          height: '85px',
        }}
        className="w-full flex items-center justify-between shrink-0"
      >
        <div className="flex flex-col gap-1.5">
          {/* Breadcrumb Navigation with Back Button */}
          <div className="flex items-center gap-2 text-xs">
            <button
              type="button"
              onClick={onBack}
              className="flex items-center gap-1.5 text-[#616166] hover:text-[#8B53FE] font-medium transition-colors cursor-pointer group"
            >
              <ArrowLeft className="w-3.5 h-3.5 transition-transform group-hover:-translate-x-0.5" />
              <span>Verification Queue</span>
            </button>
            <span className="text-[#9EAFA9]">/</span>
            <span className="text-[#8B53FE] font-medium">Provider Review</span>
          </div>

          {/* Title & Subtitle */}
          <div>
            <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
              Provider Review
            </h1>
            <p className="text-[13px] text-[#566663] font-normal leading-snug mt-0.5">
              Review the provider's submitted information and documents to complete the verification process.
            </p>
          </div>
        </div>

        {/* Action Decision Buttons */}
        <div className="flex items-center gap-2.5 shrink-0">
          <button
            type="button"
            onClick={handleRejectAction}
            className="px-4 py-2 rounded-xl border border-[#FEE2E2] bg-white text-[#DC2626] hover:bg-[#FEF2F2] text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-2xs"
          >
            <XCircle className="w-3.5 h-3.5" />
            <span>Reject</span>
          </button>

          <button
            type="button"
            onClick={handleResubmitAction}
            className="px-4 py-2 rounded-xl border border-[#FEF3E2] bg-white text-[#D97706] hover:bg-[#FEF3E2] text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-2xs"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span>Request Resubmission</span>
          </button>

          <button
            type="button"
            onClick={handleApproveAction}
            className="px-5 py-2 rounded-xl bg-[#22C55E] hover:bg-[#16A34A] text-white text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-xs hover:shadow-sm"
          >
            <CheckCircle2 className="w-4 h-4" />
            <span>Approve Provider</span>
          </button>
        </div>
      </div>

      {/* ================= 2-COLUMN MAIN CONTENT (LEFT: 537px, RIGHT: 531px, GAP: 16px) ================= */}
      <div className="w-full grid grid-cols-1 lg:grid-cols-[537fr_531fr] gap-4 items-start">
        {/* ================= LEFT COLUMN (537px) ================= */}
        <div className="w-full flex flex-col gap-4">
          {/* 1ST CARD: PROVIDER SUMMARY */}
          <div
            style={{
              borderRadius: '16px',
              padding: '20px',
              boxSizing: 'border-box',
            }}
            className="w-full bg-white border border-[#EBEBEB] shadow-xs flex flex-col justify-between gap-4"
          >
            {/* Top row: Avatar + Name + City + Status Badge */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-11 h-11 rounded-full overflow-hidden shrink-0 border border-[#EFF0ED]">
                  <img
                    src={provider.avatar}
                    alt={provider.name}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div className="flex flex-col">
                  <h2 className="text-[16px] font-bold text-[#1C2926] leading-tight">
                    {provider.name}
                  </h2>
                  <div className="flex items-center gap-1 text-[11px] text-[#616166] mt-0.5">
                    <MapPin className="w-3 h-3 text-[#9EAFA9]" />
                    <span>{provider.city}</span>
                  </div>
                </div>
              </div>

              {/* Status Badge */}
              <span className="px-3 py-1 text-xs font-semibold rounded-md bg-[#FEF3E2] text-[#D97706]">
                {reviewStatus}
              </span>
            </div>

            {/* Bottom row: Application ID & Submitted Date */}
            <div className="grid grid-cols-2 pt-2 border-t border-[#F0EFF2]">
              <div>
                <span className="text-[11px] text-[#9EAFA9] block">Application ID</span>
                <span className="text-[13px] font-semibold text-[#1C2926] mt-0.5 block">
                  {provider.id}
                </span>
              </div>
              <div>
                <span className="text-[11px] text-[#9EAFA9] block">Submitted Date</span>
                <span className="text-[13px] font-semibold text-[#1C2926] mt-0.5 block">
                  {provider.submittedDate}
                </span>
              </div>
            </div>
          </div>

          {/* 2ND CARD: PERSONAL INFORMATION */}
          <div
            style={{
              borderRadius: '16px',
              padding: '20px',
              boxSizing: 'border-box',
            }}
            className="w-full bg-white border border-[#EBEBEB] shadow-xs flex flex-col justify-between gap-3.5"
          >
            <h3 className="text-[16px] font-bold text-[#1C2926] tracking-tight">
              Personal Information
            </h3>

            {/* 3 Rows × 2 Columns Info Grid */}
            <div className="grid grid-cols-2 gap-y-3 gap-x-4 pt-1">
              {/* Row 1: Full Name */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <User className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Full Name</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.name}
                  </span>
                </div>
              </div>

              {/* Row 1: Background Check */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#E9FBF0] text-[#16A34A] flex items-center justify-center shrink-0">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Background Check</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    Passed <span className="text-[#16A34A] font-normal">(Absher Linked)</span>
                  </span>
                </div>
              </div>

              {/* Row 2: Iqama / National ID */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <CreditCard className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Iqama / National ID</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.nationalId}
                  </span>
                </div>
              </div>

              {/* Row 2: Iqama Expiry */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Calendar className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Iqama Expiry</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.iqamaExpiry}
                  </span>
                </div>
              </div>

              {/* Row 3: Phone Number */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Phone className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Phone Number</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.phone}
                  </span>
                </div>
              </div>

              {/* Row 3: WhatsApp Number */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#E9FBF0] text-[#16A34A] flex items-center justify-center shrink-0">
                  <MessageCircle className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Whatsppp Number</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.whatsapp}
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* 3RD CARD: VEHICLE & SERVICE DETAILS */}
          <div
            style={{
              borderRadius: '16px',
              padding: '20px',
              boxSizing: 'border-box',
            }}
            className="w-full bg-white border border-[#EBEBEB] shadow-xs flex flex-col justify-between gap-3.5"
          >
            <h3 className="text-[16px] font-bold text-[#1C2926] tracking-tight">
              Vehicle & Service Details
            </h3>

            <div className="grid grid-cols-2 gap-y-3 gap-x-4">
              {/* Service Category */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Disc className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Service Category</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.category}
                  </span>
                </div>
              </div>

              {/* Vehicle Model */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Truck className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Vehicle Model</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.vehicleModel}
                  </span>
                </div>
              </div>

              {/* Vehicle Type */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Truck className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Vehicle Type</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.vehicleType}
                  </span>
                </div>
              </div>

              {/* Plate Number */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <CreditCard className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Plate Number</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.plateNumber}
                  </span>
                </div>
              </div>

              {/* Vehicle Color */}
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Palette className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="text-[11px] text-[#9EAFA9]">Vehicle Color</span>
                  <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                    {provider.vehicleColor}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* ================= RIGHT COLUMN (531px) ================= */}
        <div className="w-full flex flex-col gap-4">
          {/* 1ST CARD: SUBMITTED DOCUMENTS */}
          <div
            style={{
              borderRadius: '16px',
              padding: '20px',
              boxSizing: 'border-box',
            }}
            className="w-full bg-white border border-[#EBEBEB] shadow-xs flex flex-col justify-between gap-3"
          >
            <h3 className="text-[16px] font-bold text-[#1C2926] tracking-tight">
              Submited Documents
            </h3>

            {/* Document Items List */}
            <div className="flex flex-col gap-2.5 flex-1 min-h-0 justify-between pt-1">
              {documents.map((doc) => (
                <div
                  key={doc.id}
                  onClick={() => setSelectedDocModal(doc)}
                  className="w-full p-2.5 rounded-xl border border-[#EBEBEB] hover:border-[#DECFFC] hover:bg-[#FAF9FF] bg-white flex items-center justify-between transition-colors cursor-pointer"
                >
                  {/* Left: Thumbnail + Title & Meta */}
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-12 h-9 rounded-lg overflow-hidden bg-[#F5F5F7] border border-[#EFF0ED] shrink-0">
                      <img
                        src={doc.previewUrl}
                        alt={doc.title}
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div className="flex flex-col min-w-0">
                      <div className="flex items-center gap-1.5">
                        <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                          {doc.title}
                        </span>
                        {doc.subtitle && (
                          <span className="text-[11px] text-[#9EAFA9] truncate">
                            {doc.subtitle}
                          </span>
                        )}
                      </div>
                      <span className="text-[10px] text-[#9EAFA9] truncate mt-0.5">
                        {doc.timestamp} • {doc.fileType}
                      </span>
                    </div>
                  </div>

                  {/* Right: Status Pill & View Action */}
                  <div className="flex items-center gap-3 shrink-0 pl-2">
                    <span
                      className={`text-[11px] font-medium px-2 py-0.5 rounded-md ${doc.statusColor}`}
                    >
                      ● {doc.status}
                    </span>

                    <button
                      type="button"
                      onClick={() => setSelectedDocModal(doc)}
                      className="text-xs font-semibold text-[#8B53FE] hover:text-[#7032F0] flex items-center gap-1 cursor-pointer transition-colors"
                    >
                      <span>View</span>
                      <ExternalLink className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* 2ND CARD: AGREEMENT & CONSENT */}
          <div
            style={{
              borderRadius: '16px',
              padding: '20px',
              boxSizing: 'border-box',
            }}
            className="w-full bg-white border border-[#EBEBEB] shadow-xs flex flex-col justify-between gap-3"
          >
            <h3 className="text-[16px] font-bold text-[#1C2926] tracking-tight">
              Agreement & Consent
            </h3>

            {/* Consent Items */}
            <div className="flex flex-col gap-2.5 flex-1 min-h-0 justify-between pt-1">
              {agreements.map((item) => {
                const ItemIcon = item.icon
                return (
                  <div
                    key={item.id}
                    className="w-full p-2.5 rounded-xl border border-[#EBEBEB] bg-white flex items-center justify-between"
                  >
                    {/* Left: Icon + Text */}
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-8 h-8 rounded-lg bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center shrink-0">
                        <ItemIcon className="w-4 h-4" />
                      </div>
                      <div className="flex flex-col min-w-0">
                        <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                          {item.title}
                        </span>
                        <span className="text-[11px] text-[#9EAFA9] truncate mt-0.5">
                          {item.meta}
                        </span>
                      </div>
                    </div>

                    {/* Right: Accepted Badge & External Link */}
                    <div className="flex items-center gap-2.5 shrink-0 pl-2">
                      <span className="text-[11px] font-semibold text-[#16A34A] bg-[#E9FBF0] px-2.5 py-0.5 rounded-full flex items-center gap-1">
                        <Check className="w-3 h-3 stroke-[3]" />
                        <span>{item.status}</span>
                      </span>
                      <button
                        type="button"
                        onClick={() =>
                          showToast(`Opened document record for: ${item.title}`)
                        }
                        className="text-[#9EAFA9] hover:text-[#8B53FE] transition-colors p-1"
                      >
                        <ExternalLink className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        </div>
      </div>

      {/* ================= DOCUMENT REVIEW SIDE CARD (BLUR BACKGROUND + SLIDE-IN CARD) ================= */}
      <DocumentReviewSideCard
        isOpen={Boolean(selectedDocModal)}
        document={selectedDocModal || {}}
        onClose={() => setSelectedDocModal(null)}
        onSubmitReview={({ documentId, status, remarks }) => {
          setSelectedDocModal(null)
          setOutcomeType(status)
          setOutcomeRemarks(remarks)

          // Update document in documents list
          setDocuments((prev) =>
            prev.map((d) => {
              if (d.id === documentId) {
                if (status === 'verified') {
                  return {
                    ...d,
                    status: 'Approved',
                    statusColor: 'bg-[#E9FBF0] text-[#16A34A]',
                  }
                } else if (status === 'invalid') {
                  return {
                    ...d,
                    status: 'Rejected',
                    statusColor: 'bg-[#FEE2E2] text-[#DC2626]',
                  }
                } else {
                  return {
                    ...d,
                    status: 'Resubmission',
                    statusColor: 'bg-[#EFF6FF] text-[#2563EB]',
                  }
                }
              }
              return d
            })
          )

          // Trigger the corresponding outcome modal popup
          setShowSuccessModal(true)
        }}
      />

      {/* ================= OUTCOME MODAL POPUP (VERIFIED / INVALID / RESUBMIT) ================= */}
      <VerificationSuccessModal
        isOpen={showSuccessModal}
        outcome={outcomeType}
        remarks={outcomeRemarks}
        provider={{
          ...provider,
          timestamp: '22 Sep, 10:24 AM',
        }}
        onClose={() => setShowSuccessModal(false)}
        onBackToQueue={() => {
          setShowSuccessModal(false)
          if (onBack) onBack()
        }}
        onViewProfile={() => {
          setShowSuccessModal(false)
          showToast(`Saved ${outcomeType} status for provider document`)
        }}
      />
    </div>
  )
}

export default ProviderReviewView

