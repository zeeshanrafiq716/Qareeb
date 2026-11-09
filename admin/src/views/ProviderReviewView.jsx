import React, { useState, useEffect } from 'react'
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
  Loader2,
  PauseCircle,
  Ban,
  Trash2,
} from 'lucide-react'
import { DocumentReviewSideCard } from '../components/verification/DocumentReviewSideCard'
import { VerificationSuccessModal } from '../components/verification/VerificationSuccessModal'
import {
  fetchProviderDetails,
  approveProviderApi,
  rejectProviderApi,
  suspendProviderApi,
  blockProviderApi,
  reinstateProviderApi,
  deleteProviderApi,
} from '../api/admin'

const docMetaMap = {
  iqama: {
    title: 'Iqama',
    subtitle: 'National Residence ID',
  },
  registration: {
    title: 'Vehicle Registration',
    subtitle: 'Istimara Card',
  },
  license: {
    title: 'Driving Licence',
    subtitle: "Valid Driver's License",
  },
  driving_licence: {
    title: 'Driving Licence',
    subtitle: "Valid Driver's License",
  },
  vehicle_front: {
    title: 'Vehicle Front Photo',
    subtitle: 'Front View',
  },
  vehicle_rear: {
    title: 'Vehicle Rear Photo',
    subtitle: 'Rear View',
  },
  vehicle_left_side: {
    title: 'Vehicle Left Side Photo',
    subtitle: 'Left Profile',
  },
  vehicle_right_side: {
    title: 'Vehicle Right Side Photo',
    subtitle: 'Right Profile',
  },
}

export function ProviderReviewView({
  provider = {
    id: 'QA-2024-001',
    name: 'New Provider',
    city: 'Location Pending',
    category: 'Roadside Assistance',
    submittedDate: 'Recent',
    status: 'Pending Review',
    avatar: '',
    nationalId: 'Pending Submission',
    iqamaExpiry: 'Pending Submission',
    phone: '',
    whatsapp: '',
    vehicleModel: 'Pending Submission',
    vehicleType: 'Roadside Vehicle',
    plateNumber: 'Pending Submission',
    vehicleColor: 'Pending',
  },
  onBack,
  onApprove,
  onReject,
  onRequestResubmit,
}) {
  const [liveProvider, setLiveProvider] = useState(provider)
  const [loadingDetails, setLoadingDetails] = useState(false)
  const [isSubmittingAction, setIsSubmittingAction] = useState(false)
  const [selectedDocModal, setSelectedDocModal] = useState(null)
  const [showSuccessModal, setShowSuccessModal] = useState(false)
  const [outcomeType, setOutcomeType] = useState('verified') // 'verified' | 'invalid' | 'resubmit'
  const [outcomeRemarks, setOutcomeRemarks] = useState('')
  const [reviewStatus, setReviewStatus] = useState(provider.status || 'Pending Review')
  const [toastMessage, setToastMessage] = useState('')

  const showToast = (msg) => {
    setToastMessage(msg)
    setTimeout(() => setToastMessage(''), 3000)
  }

  const [documents, setDocuments] = useState([])

  // Fetch full real provider details from backend API
  useEffect(() => {
    let mounted = true
    const id = provider.backendId || provider.id
    if (!id) return

    async function loadFullDetails() {
      try {
        setLoadingDetails(true)
        const res = await fetchProviderDetails(id)
        const p = res?.data || res
        if (!mounted || !p) return

        setLiveProvider((prev) => ({
          ...prev,
          ...p,
          backendId: p.id || prev.backendId || id,
          name: p.name || prev.name,
          city: p.location?.city || p.city || prev.city || 'Pending',
          phone: p.phone || prev.phone,
          whatsapp: p.whatsapp || p.whatsappNumber || prev.whatsapp || p.phone || prev.phone,
          nationalId: p.nationalId || p.iqamaNumber || prev.nationalId || 'Pending Submission',
          iqamaExpiry: p.iqamaExpiry || prev.iqamaExpiry || 'Pending Submission',
          category: p.category?.name || p.category || prev.category,
          vehicleType: p.vehicleType || prev.vehicleType || 'Roadside Vehicle',
          vehicleModel: p.vehicleModel || prev.vehicleModel || 'Pending Submission',
          plateNumber: p.plateNumber || prev.plateNumber || 'Pending Submission',
          vehicleColor: p.vehicleColor || prev.vehicleColor || 'Pending',
          avatar: p.photoUrl || prev.avatar,
        }))

        if (p.status) {
          let st = 'Pending Review'
          if (p.status === 'approved') st = 'Approved'
          else if (p.status === 'rejected') st = 'Rejected'
          else if (p.status === 'suspended') st = 'Suspended'
          else if (p.status === 'blocked') st = 'Blocked'
          setReviewStatus(st)
        }

        if (Array.isArray(p.documents) && p.documents.length > 0) {
          const mappedDocs = p.documents.map((d) => {
            const meta = docMetaMap[d.documentType] || {
              title: d.documentType ? d.documentType.replace(/_/g, ' ').toUpperCase() : 'Document',
              subtitle: '',
            }
            const dateObj = d.createdAt ? new Date(d.createdAt) : new Date()
            const dateStr =
              dateObj.toLocaleDateString('en-GB', { day: '2-digit', month: 'short' }) +
              ', ' +
              dateObj.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })

            let stBadge = 'Pending'
            let stColor = 'bg-[#FEF3E2] text-[#D97706]'
            if (d.status === 'approved') {
              stBadge = 'Approved'
              stColor = 'bg-[#E9FBF0] text-[#16A34A]'
            } else if (d.status === 'rejected') {
              stBadge = 'Rejected'
              stColor = 'bg-[#FEE2E2] text-[#DC2626]'
            }

            return {
              id: d.documentType,
              docId: d.id,
              title: meta.title,
              subtitle: meta.subtitle,
              timestamp: dateStr,
              fileType: 'Uploaded Document',
              status: stBadge,
              statusColor: stColor,
              previewUrl: d.documentUrl || null,
            }
          })

          setDocuments(mappedDocs)
        } else {
          setDocuments([])
        }
      } catch (err) {
        console.error('Failed to load full provider details:', err)
      } finally {
        if (mounted) setLoadingDetails(false)
      }
    }

    loadFullDetails()
    return () => {
      mounted = false
    }
  }, [provider.backendId, provider.id])

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

  const handleApproveAction = async () => {
    if (isSubmittingAction) return
    setIsSubmittingAction(true)
    try {
      const id = liveProvider.backendId || provider.backendId || provider.id
      await approveProviderApi(id, outcomeRemarks || 'Approved by admin')
      setReviewStatus('Approved')
      showToast('Provider application approved successfully!')
      if (onApprove) onApprove({ ...liveProvider, status: 'Approved', statusType: 'approved' })
    } catch (err) {
      const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
      showToast('Approval notice: ' + msg)
    } finally {
      setIsSubmittingAction(false)
    }
  }

  const handleRejectAction = async () => {
    if (isSubmittingAction) return
    setIsSubmittingAction(true)
    try {
      const id = liveProvider.backendId || provider.backendId || provider.id
      await rejectProviderApi(id, outcomeRemarks || 'Application rejected by admin')
      setReviewStatus('Rejected')
      showToast('Provider application marked as Rejected')
      if (onReject) onReject({ ...liveProvider, status: 'Rejected', statusType: 'rejected' })
    } catch (err) {
      const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
      showToast('Notice: ' + msg)
    } finally {
      setIsSubmittingAction(false)
    }
  }

  const handleResubmitAction = async () => {
    if (isSubmittingAction) return
    setIsSubmittingAction(true)
    try {
      const id = liveProvider.backendId || provider.backendId || provider.id
      await rejectProviderApi(id, outcomeRemarks || 'Resubmission requested: please re-upload clear documents')
      setReviewStatus('Resubmission')
      showToast('Resubmission request sent to provider')
      if (onRequestResubmit) onRequestResubmit({ ...liveProvider, status: 'Resubmission', statusType: 'resubmission' })
    } catch (err) {
      const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
      showToast('Notice: ' + msg)
    } finally {
      setIsSubmittingAction(false)
    }
  }

  const handleSuspendAction = async () => {
    if (isSubmittingAction) return
    setIsSubmittingAction(true)
    try {
      const id = liveProvider.backendId || provider.backendId || provider.id
      await suspendProviderApi(id, outcomeRemarks || 'Suspended by admin')
      setReviewStatus('Suspended')
      setLiveProvider((prev) => ({ ...prev, status: 'suspended' }))
      showToast('Provider suspended successfully')
      if (onBack) setTimeout(onBack, 1000)
    } catch (err) {
      const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
      showToast('Notice: ' + msg)
    } finally {
      setIsSubmittingAction(false)
    }
  }

  const handleBlockAction = async () => {
    if (isSubmittingAction) return
    setIsSubmittingAction(true)
    try {
      const id = liveProvider.backendId || provider.backendId || provider.id
      await blockProviderApi(id, outcomeRemarks || 'Blocked by admin')
      setReviewStatus('Blocked')
      setLiveProvider((prev) => ({ ...prev, status: 'blocked' }))
      showToast('Provider blocked successfully')
      if (onBack) setTimeout(onBack, 1000)
    } catch (err) {
      const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
      showToast('Notice: ' + msg)
    } finally {
      setIsSubmittingAction(false)
    }
  }

  const handleReinstateAction = async () => {
    if (isSubmittingAction) return
    setIsSubmittingAction(true)
    try {
      const id = liveProvider.backendId || provider.backendId || provider.id
      await reinstateProviderApi(id, 'Reinstated and approved by admin')
      setReviewStatus('Approved')
      setLiveProvider((prev) => ({ ...prev, status: 'approved' }))
      showToast('Provider reactivated and approved successfully')
    } catch (err) {
      const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
      showToast('Notice: ' + msg)
    } finally {
      setIsSubmittingAction(false)
    }
  }

  const handleDeleteAction = async () => {
    if (isSubmittingAction) return
    const provName = liveProvider.name || provider.name || 'this provider'
    if (!window.confirm(`Are you sure you want to permanently delete provider "${provName}"? This action cannot be undone.`)) {
      return
    }
    setIsSubmittingAction(true)
    try {
      const id = liveProvider.backendId || provider.backendId || provider.id
      await deleteProviderApi(id)
      showToast('Provider permanently deleted')
      if (onBack) setTimeout(onBack, 700)
    } catch (err) {
      const msg = err.response?.data?.message || err.response?.data?.error?.message || err.message
      showToast('Notice: ' + msg)
    } finally {
      setIsSubmittingAction(false)
    }
  }

  const activeProvider = liveProvider || provider

  const isApproved =
    reviewStatus?.toLowerCase() === 'approved' ||
    liveProvider?.status?.toLowerCase() === 'approved' ||
    provider?.status?.toLowerCase() === 'approved'

  const isSuspended =
    reviewStatus?.toLowerCase() === 'suspended' ||
    liveProvider?.status?.toLowerCase() === 'suspended' ||
    provider?.status?.toLowerCase() === 'suspended'

  const isBlocked =
    reviewStatus?.toLowerCase() === 'blocked' ||
    liveProvider?.status?.toLowerCase() === 'blocked' ||
    provider?.status?.toLowerCase() === 'blocked'

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
          {isApproved ? (
            /* ================= AFTER APPROVE: REJECT/APPROVE/RESUBMIT DISAPPEAR, SHOW DELETE, SUSPEND, BLOCK ================= */
            <>
              {/* Suspend Button */}
              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleSuspendAction}
                className="px-4 py-2 rounded-xl border border-[#FED7AA] bg-white text-[#EA580C] hover:bg-[#FFF7ED] disabled:opacity-50 text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-2xs"
                title="Temporarily suspend provider account"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <PauseCircle className="w-3.5 h-3.5" />}
                <span>Suspend</span>
              </button>

              {/* Block Button */}
              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleBlockAction}
                className="px-4 py-2 rounded-xl border border-[#FECDD3] bg-white text-[#E11D48] hover:bg-[#FFF1F2] disabled:opacity-50 text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-2xs"
                title="Block provider account permanently or indefinitely"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Ban className="w-3.5 h-3.5" />}
                <span>Block</span>
              </button>

              {/* Delete Button */}
              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleDeleteAction}
                className="px-4 py-2 rounded-xl bg-[#DC2626] hover:bg-[#B91C1C] disabled:opacity-50 text-white text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-xs hover:shadow-sm"
                title="Permanently delete provider and all associated records"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Trash2 className="w-3.5 h-3.5" />}
                <span>Delete</span>
              </button>
            </>
          ) : isSuspended ? (
            /* ================= ACTION BUTTONS WHEN SUSPENDED ================= */
            <>
              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleReinstateAction}
                className="px-4 py-2 rounded-xl bg-[#22C55E] hover:bg-[#16A34A] disabled:opacity-50 text-white text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-xs"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <CheckCircle2 className="w-3.5 h-3.5" />}
                <span>Reactivate / Unsuspend</span>
              </button>

              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleBlockAction}
                className="px-4 py-2 rounded-xl border border-[#FECDD3] bg-white text-[#E11D48] hover:bg-[#FFF1F2] disabled:opacity-50 text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-2xs"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Ban className="w-3.5 h-3.5" />}
                <span>Block</span>
              </button>

              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleDeleteAction}
                className="px-4 py-2 rounded-xl bg-[#DC2626] hover:bg-[#B91C1C] disabled:opacity-50 text-white text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-xs hover:shadow-sm"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Trash2 className="w-3.5 h-3.5" />}
                <span>Delete</span>
              </button>
            </>
          ) : isBlocked ? (
            /* ================= ACTION BUTTONS WHEN BLOCKED ================= */
            <>
              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleReinstateAction}
                className="px-4 py-2 rounded-xl bg-[#22C55E] hover:bg-[#16A34A] disabled:opacity-50 text-white text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-xs"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <CheckCircle2 className="w-3.5 h-3.5" />}
                <span>Unblock Provider</span>
              </button>

              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleDeleteAction}
                className="px-4 py-2 rounded-xl bg-[#DC2626] hover:bg-[#B91C1C] disabled:opacity-50 text-white text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-xs hover:shadow-sm"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Trash2 className="w-3.5 h-3.5" />}
                <span>Delete</span>
              </button>
            </>
          ) : (
            /* ================= ACTION BUTTONS WHEN PENDING REVIEW ================= */
            <>
              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleRejectAction}
                className="px-4 py-2 rounded-xl border border-[#FEE2E2] bg-white text-[#DC2626] hover:bg-[#FEF2F2] disabled:opacity-50 text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-2xs"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <XCircle className="w-3.5 h-3.5" />}
                <span>Reject</span>
              </button>

              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleResubmitAction}
                className="px-4 py-2 rounded-xl border border-[#FEF3E2] bg-white text-[#D97706] hover:bg-[#FEF3E2] disabled:opacity-50 text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-2xs"
              >
                {isSubmittingAction ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <RotateCcw className="w-3.5 h-3.5" />}
                <span>Request Resubmission</span>
              </button>

              <button
                type="button"
                disabled={isSubmittingAction}
                onClick={handleApproveAction}
                className="px-5 py-2 rounded-xl bg-[#22C55E] hover:bg-[#16A34A] disabled:opacity-50 text-white text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer shadow-xs hover:shadow-sm"
              >
                {isSubmittingAction ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle2 className="w-4 h-4" />}
                <span>Approve Provider</span>
              </button>
            </>
          )}
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
            {/* Top row: Name + City + Status Badge */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="flex flex-col">
                  <h2 className="text-[16px] font-bold text-[#1C2926] leading-tight">
                    {activeProvider.name}
                  </h2>
                  <div className="flex items-center gap-1 text-[11px] text-[#616166] mt-0.5">
                    <MapPin className="w-3 h-3 text-[#9EAFA9]" />
                    <span>{activeProvider.location?.city || activeProvider.city || 'Riyadh'}</span>
                  </div>
                </div>
              </div>

              {/* Status Badge */}
              <span className={`px-3 py-1 text-xs font-semibold rounded-md ${
                isApproved
                  ? 'bg-[#E9FBF0] text-[#16A34A]'
                  : isBlocked
                  ? 'bg-[#FEE2E2] text-[#DC2626]'
                  : isSuspended
                  ? 'bg-[#FEF3E2] text-[#D97706]'
                  : reviewStatus === 'Rejected'
                  ? 'bg-[#FEE2E2] text-[#DC2626]'
                  : 'bg-[#FEF3E2] text-[#D97706]'
              }`}>
                {reviewStatus}
              </span>
            </div>

            {/* Bottom row: Application ID & Submitted Date */}
            <div className="grid grid-cols-2 pt-2 border-t border-[#F0EFF2]">
              <div>
                <span className="text-[11px] text-[#9EAFA9] block">Application ID</span>
                <span className="text-[13px] font-semibold text-[#1C2926] mt-0.5 block">
                  {activeProvider.providerId || activeProvider.id}
                </span>
              </div>
              <div>
                <span className="text-[11px] text-[#9EAFA9] block">Submitted Date</span>
                <span className="text-[13px] font-semibold text-[#1C2926] mt-0.5 block">
                  {activeProvider.submittedDate || 'Recent'}
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
            <div className="grid grid-cols-2 gap-y-3 gap-x-3 pt-1">
              {/* Row 1: Full Name */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <User className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Full Name</span>
                  <span
                    title={activeProvider.name}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.name}
                  </span>
                </div>
              </div>

              {/* Row 1: Background Check */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#E9FBF0] text-[#16A34A] flex items-center justify-center shrink-0">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Background Check</span>
                  <span
                    title="Passed (Absher Linked)"
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    Passed <span className="text-[#16A34A] font-normal">(Absher Linked)</span>
                  </span>
                </div>
              </div>

              {/* Row 2: Iqama / National ID */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <CreditCard className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Iqama / National ID</span>
                  <span
                    title={activeProvider.nationalId || activeProvider.iqamaNumber || 'Pending Submission'}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.nationalId || activeProvider.iqamaNumber || 'Pending Submission'}
                  </span>
                </div>
              </div>

              {/* Row 2: Iqama Expiry */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Calendar className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Iqama Expiry</span>
                  <span
                    title={activeProvider.iqamaExpiry || 'Pending Submission'}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.iqamaExpiry || 'Pending Submission'}
                  </span>
                </div>
              </div>

              {/* Row 3: Phone Number */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Phone className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Phone Number</span>
                  <span
                    title={activeProvider.phone}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.phone}
                  </span>
                </div>
              </div>

              {/* Row 3: WhatsApp Number */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#E9FBF0] text-[#16A34A] flex items-center justify-center shrink-0">
                  <MessageCircle className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">WhatsApp Number</span>
                  <span
                    title={activeProvider.whatsapp || activeProvider.phone}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.whatsapp || activeProvider.phone}
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

            <div className="grid grid-cols-2 gap-y-3 gap-x-3">
              {/* Service Category */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Disc className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Service Category</span>
                  <span
                    title={activeProvider.category}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.category}
                  </span>
                </div>
              </div>

              {/* Vehicle Model */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Truck className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Vehicle Model</span>
                  <span
                    title={activeProvider.vehicleModel}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.vehicleModel}
                  </span>
                </div>
              </div>

              {/* Vehicle Type */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Truck className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Vehicle Type</span>
                  <span
                    title={activeProvider.vehicleType}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.vehicleType}
                  </span>
                </div>
              </div>

              {/* Plate Number */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <CreditCard className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Plate Number</span>
                  <span
                    title={activeProvider.plateNumber}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.plateNumber}
                  </span>
                </div>
              </div>

              {/* Vehicle Color */}
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] text-[#616166] flex items-center justify-center shrink-0">
                  <Palette className="w-4 h-4" />
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[10.5px] text-[#9EAFA9] leading-tight">Vehicle Color</span>
                  <span
                    title={activeProvider.vehicleColor}
                    className="text-[12px] font-semibold text-[#1C2926] break-words leading-tight"
                  >
                    {activeProvider.vehicleColor}
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
              Submitted Documents
            </h3>

            {/* Document Items List */}
            <div className="flex flex-col gap-2.5 flex-1 min-h-0 justify-between pt-1">
              {documents.length === 0 ? (
                <div className="w-full py-8 px-4 flex flex-col items-center justify-center text-center text-[#9EAFA9] bg-[#FAF9FB] rounded-xl border border-dashed border-[#E5E7EB]">
                  <FileText className="w-8 h-8 text-[#D1D5DB] mb-2" />
                  <span className="text-xs font-semibold text-[#616166]">No documents submitted yet</span>
                  <span className="text-[11px] text-[#9EAFA9] mt-0.5">The provider has not uploaded verification documents.</span>
                </div>
              ) : (
                documents.map((doc) => (
                  <div
                    key={doc.id}
                    onClick={() => setSelectedDocModal(doc)}
                    className="w-full p-2.5 rounded-xl border border-[#EBEBEB] hover:border-[#DECFFC] hover:bg-[#FAF9FF] bg-white flex items-center justify-between transition-colors cursor-pointer"
                  >
                    {/* Left: Thumbnail + Title & Meta */}
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-12 h-9 rounded-lg overflow-hidden bg-[#F5F5F7] border border-[#EFF0ED] shrink-0 flex items-center justify-center">
                        {doc.previewUrl ? (
                          <img
                            src={doc.previewUrl}
                            alt={doc.title}
                            className="w-full h-full object-cover"
                            onError={(e) => {
                              e.currentTarget.style.display = 'none'
                              if (e.currentTarget.nextElementSibling) {
                                e.currentTarget.nextElementSibling.style.display = 'flex'
                              }
                            }}
                          />
                        ) : null}
                        <div
                          className="w-full h-full flex items-center justify-center bg-[#F3EFFE] text-[#8B53FE]"
                          style={{ display: doc.previewUrl ? 'none' : 'flex' }}
                        >
                          <FileText className="w-4 h-4" />
                        </div>
                      </div>
                      <div className="flex flex-col min-w-0">
                        <div className="flex items-center gap-1.5">
                          <span
                            title={doc.title}
                            className="text-[12px] font-semibold text-[#1C2926] break-words line-clamp-1"
                          >
                            {doc.title}
                          </span>
                          {doc.subtitle && (
                            <span className="text-[10.5px] text-[#9EAFA9] truncate">
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
                        onClick={(e) => {
                          e.stopPropagation()
                          setSelectedDocModal(doc)
                        }}
                        className="text-xs font-semibold text-[#8B53FE] hover:text-[#7032F0] flex items-center gap-1 cursor-pointer transition-colors"
                      >
                        <span>View</span>
                        <ExternalLink className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                ))
              )}
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

