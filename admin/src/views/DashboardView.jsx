import React, { useState, useEffect, useCallback } from 'react'
import { useNavigate, useParams, useLocation, useSearchParams } from 'react-router-dom'
import { AdminSidebar } from '../components/layout/AdminSidebar'
import { AdminTopHeader } from '../components/layout/AdminTopHeader'
import { DashboardMetricsRow } from '../components/dashboard/DashboardMetricsRow'
import { DashboardSecondRow } from '../components/dashboard/DashboardSecondRow'
import { DashboardThirdRow } from '../components/dashboard/DashboardThirdRow'
import { VerificationMetricsSection } from '../components/verification/VerificationMetricsSection'
import { VerificationTableSection } from '../components/verification/VerificationTableSection'
import { ProviderReviewView } from './ProviderReviewView'
import { ProviderDirectoryView } from './ProviderDirectoryView'
import { LiveMapView } from './LiveMapView'
import { CallLogsView } from './CallLogsView'
import { CategoryManagementView } from './CategoryManagementView'
import { SettingsView } from './SettingsView'
import { useAuth } from '../context/AuthContext'
import { fetchProviders, fetchOnlineProviders } from '../api/admin'

const VALID_TABS = [
  'dashboard',
  'verification',
  'providers',
  'map',
  'call-logs',
  'reports',
  'categories',
  'admin-access',
  'settings',
]

export default function DashboardView() {
  const { admin, logout } = useAuth()
  const navigate = useNavigate()
  const { tab: urlTab } = useParams()
  const location = useLocation()
  const [searchParams] = useSearchParams()

  const resolveCurrentTab = () => {
    // 1. URL path param :tab (e.g. /dashboard/settings or /settings)
    if (urlTab && VALID_TABS.includes(urlTab)) {
      return urlTab
    }
    // 2. Query param ?tab=settings
    const queryTab = searchParams.get('tab')
    if (queryTab && VALID_TABS.includes(queryTab)) {
      return queryTab
    }
    // 3. Pathname segments (e.g. /dashboard/settings or /settings)
    const seg = location.pathname.replace(/^\/dashboard\/?/, '').replace(/^\//, '').split('/')[0]
    if (seg && VALID_TABS.includes(seg)) {
      return seg
    }
    // 4. Saved active tab from localStorage
    const saved = localStorage.getItem('qareeb_admin_active_tab')
    if (saved && VALID_TABS.includes(saved)) {
      return saved
    }
    return 'dashboard'
  }

  const [activeTab, setActiveTab] = useState(resolveCurrentTab)

  // Keep state synchronized with URL changes (browser back/forward navigation)
  useEffect(() => {
    const nextTab = resolveCurrentTab()
    if (nextTab && nextTab !== activeTab) {
      setActiveTab(nextTab)
      localStorage.setItem('qareeb_admin_active_tab', nextTab)
    }
  }, [urlTab, location.pathname])

  // Keep URL synchronized with the active tab on initial mount or direct link
  useEffect(() => {
    if (activeTab && activeTab !== 'dashboard') {
      if (!location.pathname.includes(activeTab)) {
        navigate(`/dashboard/${activeTab}`, { replace: true })
      }
    }
  }, [])

  const handleSelectTab = (tab) => {
    if (!VALID_TABS.includes(tab)) return
    setReviewingProvider(null)
    setActiveTab(tab)
    localStorage.setItem('qareeb_admin_active_tab', tab)
    if (tab === 'dashboard') {
      navigate('/dashboard', { replace: true })
    } else {
      navigate(`/dashboard/${tab}`, { replace: true })
    }
  }
  const [searchQuery, setSearchQuery] = useState('')
  const [reviewingProvider, setReviewingProvider] = useState(null)
  const [verificationFilter, setVerificationFilter] = useState('all')
  const [verificationStats, setVerificationStats] = useState({
    pendingReview: 0,
    underReview: 0,
    resubmission: 0,
  })
  const [stats, setStats] = useState({
    totalProviders: '0',
    pendingVerifications: '0',
    onlineProviders: '0',
    openReports: '0',
  })
  const [overviewStats, setOverviewStats] = useState({
    approved: 0,
    rejected: 0,
    resubmission: 0,
  })
  const [verificationChartData, setVerificationChartData] = useState([])
  const [dashboardMapPins, setDashboardMapPins] = useState([])

  // Fetch real counts directly from backend
  useEffect(() => {
    let isMounted = true
    async function loadStats() {
      try {
        const [allRes, onlineRes] = await Promise.allSettled([
          fetchProviders({ limit: 100 }),
          fetchOnlineProviders({ limit: 1 }),
        ])

        if (isMounted) {
          const allItems =
            allRes.status === 'fulfilled'
              ? Array.isArray(allRes.value?.data)
                ? allRes.value.data
                : Array.isArray(allRes.value?.items)
                ? allRes.value.items
                : []
              : []

          // Only count providers who completed onboarding steps
          const onboarded = allItems.filter(
            (p) => p.status !== 'pending_otp' && p.status !== 'pending_profile'
          )

          const total = onboarded.length.toLocaleString()

          const pendingCount = onboarded.filter(
            (p) => p.status === 'pending_verification'
          ).length

          const online =
            onlineRes.status === 'fulfilled' && onlineRes.value?.meta?.total != null
              ? onlineRes.value.meta.total.toLocaleString()
              : '0'

          const approvedCount = onboarded.filter((p) => p.status === 'approved').length
          const rejectedCount = onboarded.filter(
            (p) => p.status === 'rejected' && (!p.statusReason || !p.statusReason.toLowerCase().includes('resubmi'))
          ).length
          const resubmissionCount = onboarded.filter(
            (p) => p.status === 'resubmission' || (p.status === 'rejected' && p.statusReason?.toLowerCase().includes('resubmi'))
          ).length

          setOverviewStats({
            approved: approvedCount,
            rejected: rejectedCount,
            resubmission: resubmissionCount,
          })

          const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          const todayDow = new Date().getDay()
          const dayCounts = [0, 0, 0, 0, 0, 0, 0]
          for (const p of onboarded) {
            if (p.createdAt) {
              const dow = new Date(p.createdAt).getDay()
              dayCounts[dow] += 1
            }
          }
          setVerificationChartData(
            days.map((day, idx) => ({
              day,
              value: dayCounts[idx],
              active: idx === todayDow,
            }))
          )

          const onlineItems =
            onlineRes.status === 'fulfilled'
              ? Array.isArray(onlineRes.value?.data)
                ? onlineRes.value.data
                : Array.isArray(onlineRes.value?.items)
                ? onlineRes.value.items
                : []
              : []
          const pins = onlineItems
            .filter((p) => p.location?.latitude != null && p.location?.longitude != null)
            .map((p, idx) => {
              const lat = Number(p.location.latitude)
              const lng = Number(p.location.longitude)
              const top = `${40 + (idx * 17) % 45}%`
              const left = `${30 + (idx * 23) % 55}%`
              return {
                id: p.id,
                top,
                left,
                name: p.name,
                category: p.category?.name || 'Roadside Assistance',
                location: p.location?.city || `${lat.toFixed(2)}, ${lng.toFixed(2)}`,
                status: 'Online',
              }
            })
          setDashboardMapPins(pins)

          setStats({
            totalProviders: total,
            pendingVerifications: pendingCount.toLocaleString(),
            onlineProviders: online,
            openReports: '0',
          })
        }
      } catch {
        if (isMounted) {
          setStats({
            totalProviders: '0',
            pendingVerifications: '0',
            onlineProviders: '0',
            openReports: '0',
          })
        }
      }
    }
    // 1. Initial load
    loadStats()

    // 2. Real-time background sync interval (every 2.5 seconds without manual refresh)
    const intervalTimer = setInterval(() => {
      loadStats()
    }, 2500)

    // 3. Instant sync when browser tab gains focus or window becomes visible
    const handleFocus = () => loadStats()
    const handleVisibility = () => {
      if (document.visibilityState === 'visible') loadStats()
    }
    window.addEventListener('focus', handleFocus)
    document.addEventListener('visibilitychange', handleVisibility)

    return () => {
      isMounted = false
      clearInterval(intervalTimer)
      window.removeEventListener('focus', handleFocus)
      document.removeEventListener('visibilitychange', handleVisibility)
    }
  }, [])

  const handleLogout = () => {
    localStorage.removeItem('qareeb_admin_active_tab')
    logout()
    navigate('/login')
  }

  const handleSelectProviderForReview = useCallback((p) => {
    setReviewingProvider({
      ...p,
      backendId: p.backendId || p.id,
      city: p.city || 'Pending',
      submittedDate: 'Recent',
      nationalId: p.nationalId || p.iqamaNumber || 'Pending Submission',
      iqamaExpiry: p.iqamaExpiry || 'Pending Submission',
      whatsapp: p.whatsapp || p.whatsappNumber || p.phone,
      vehicleModel: p.vehicleModel || 'Pending Submission',
      vehicleType: p.vehicleType || p.category || 'Roadside Vehicle',
      plateNumber: p.plateNumber || 'Pending Submission',
      vehicleColor: p.vehicleColor || 'Pending',
    })
  }, [])

  const adminFirstName = admin?.name ? admin.name.split(' ')[0] : 'Zeeshan'

  return (
    <div className="w-full h-screen bg-[#F5F5F5] flex overflow-hidden font-sans text-[#1C2926] antialiased">
      {/* ================= EXACT FIGMA SIDEBAR ================= */}
      <AdminSidebar
        activeTab={activeTab}
        onSelectTab={handleSelectTab}
        onLogout={handleLogout}
        pendingVerificationsCount={parseInt(stats.pendingVerifications) || 0}
      />

      {/* ================= MAIN DASHBOARD AREA ================= */}
      <div className="flex-1 min-w-0 h-screen overflow-y-auto overflow-x-hidden pt-2 pb-6 px-4 sm:px-6 flex flex-col">
        {/* Responsive Container: up to 1084px for regular views, 100% fluid full-screen for Live Map */}
        <div
          className={`w-full flex flex-col shrink-0 ${
            activeTab === 'map' && !reviewingProvider
              ? 'max-w-none flex-1 gap-2.5 pb-6'
              : 'max-w-[1084px] gap-4'
          }`}
        >
          {/* ================= TOP HEADER: (Same across tabs) ================= */}
          <AdminTopHeader
            searchValue={searchQuery}
            onSearchChange={setSearchQuery}
            fluid={activeTab === 'map' && !reviewingProvider}
          />

          {/* ================= TAB CONTENT ================= */}
          {reviewingProvider ? (
            /* ===== PROVIDER REVIEW SCREEN (WITH BACK BUTTON) ===== */
            <ProviderReviewView
              provider={reviewingProvider}
              onBack={() => setReviewingProvider(null)}
              onApprove={() => setReviewingProvider(null)}
              onReject={() => setReviewingProvider(null)}
              onRequestResubmit={() => setReviewingProvider(null)}
            />
          ) : activeTab === 'providers' ? (
            /* ===== PROVIDER DIRECTORY SCREEN ===== */
            <ProviderDirectoryView
              onViewProfile={(p) => {
                setReviewingProvider({
                  ...p,
                  backendId: p.backendId || p.id,
                  city: p.location || p.city || 'Pending',
                  submittedDate: p.registeredDate || 'Recent',
                  nationalId: p.nationalId || p.iqamaNumber || 'Pending Submission',
                  iqamaExpiry: p.iqamaExpiry || 'Pending Submission',
                  whatsapp: p.whatsapp || p.whatsappNumber || p.phone,
                  vehicleModel: p.vehicleModel || 'Pending Submission',
                  vehicleType: p.vehicleType || p.category || 'Roadside Vehicle',
                  plateNumber: p.plateNumber || 'Pending Submission',
                  vehicleColor: p.vehicleColor || 'Pending',
                })
              }}
            />
          ) : activeTab === 'map' ? (
            /* ===== LIVE MAP SCREEN ===== */
            <LiveMapView onSelectProvider={handleSelectProviderForReview} />
          ) : activeTab === 'call-logs' ? (
            /* ===== CALL LOGS SCREEN ===== */
            <CallLogsView
              onViewProvider={(p) => {
                setReviewingProvider({
                  ...p,
                  backendId: p.backendId || p.id,
                  city: p.location || p.city || 'Pending',
                  submittedDate: 'Recent',
                  nationalId: p.nationalId || p.iqamaNumber || 'Pending Submission',
                  iqamaExpiry: p.iqamaExpiry || 'Pending Submission',
                  whatsapp: p.whatsapp || p.whatsappNumber || p.phone,
                  vehicleModel: p.vehicleModel || 'Pending Submission',
                  vehicleType: p.vehicleType || p.category || 'Roadside Vehicle',
                  plateNumber: p.plateNumber || 'Pending Submission',
                  vehicleColor: p.vehicleColor || 'Pending',
                })
              }}
            />
          ) : activeTab === 'categories' ? (
            /* ===== CATEGORY MANAGEMENT SCREEN ===== */
            <CategoryManagementView />
          ) : activeTab === 'settings' ? (
            /* ===== SETTINGS SCREEN ===== */
            <SettingsView />
          ) : activeTab === 'verification' ? (
            /* ===== VERIFICATION QUEUE SCREEN ===== */
            <div className="flex flex-col gap-4 w-full">
              {/* TOP METRICS SECTION: 1084x181, gap: 20px */}
              <VerificationMetricsSection
                activeFilter={verificationFilter}
                onSelectFilter={(filterId) => {
                  setVerificationFilter((prev) => (prev === filterId ? 'all' : filterId))
                }}
                stats={verificationStats}
              />

              {/* TABLE SECTION: 1084x699, rounded-20px */}
              <VerificationTableSection
                activeFilter={verificationFilter}
                onViewDetails={(app) => setReviewingProvider(app)}
                onUpdateStats={(counts) => setVerificationStats(counts)}
              />
            </div>
          ) : (
            /* ===== MAIN DASHBOARD SCREEN ===== */
            <>
              {/* 1ST ROW CARDS MAIN LAYOUT: 1084x278 */}
              <DashboardMetricsRow
                adminName={adminFirstName}
                stats={stats}
                onCardClick={(cardId) => {
                  if (cardId === 'total-providers') {
                    handleSelectTab('providers')
                  } else if (cardId === 'pending-verifications') {
                    setVerificationFilter('pending')
                    handleSelectTab('verification')
                  } else if (cardId === 'online-providers') {
                    handleSelectTab('map')
                  } else if (cardId === 'open-reports') {
                    handleSelectTab('reports')
                  }
                }}
              />

              {/* 2ND ROW CARDS LAYOUT: 1084x386 (560x386 & 508x386) */}
              <DashboardSecondRow
                onViewLiveMap={() => handleSelectTab('map')}
                overviewStats={overviewStats}
                chartData={verificationChartData}
                mapPins={dashboardMapPins}
              />

              {/* 3RD ROW CARDS LAYOUT: 1084x216 (560x216 & 508x216) */}
              <DashboardThirdRow
                onViewAllVerifications={() => handleSelectTab('verification')}
                onViewAllReports={() => handleSelectTab('reports')}
                onSelectProvider={(p) => {
                  setReviewingProvider({
                    ...p,
                    backendId: p.backendId || p.id,
                    city: p.city || p.location || 'Pending',
                    nationalId: p.nationalId || p.iqamaNumber || 'Pending Submission',
                    iqamaExpiry: p.iqamaExpiry || 'Pending Submission',
                    phone: p.phone || '',
                    whatsapp: p.whatsapp || p.whatsappNumber || p.phone || '',
                    vehicleModel: p.vehicleModel || 'Pending Submission',
                    vehicleType: p.vehicleType || p.category || 'Roadside Vehicle',
                    plateNumber: p.plateNumber || 'Pending Submission',
                    vehicleColor: p.vehicleColor || 'Pending',
                  })
                  handleSelectTab('verification')
                }}
              />
            </>
          )}
        </div>
      </div>
    </div>
  )
}
