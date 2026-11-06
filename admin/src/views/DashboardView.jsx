import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
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
import { useAuth } from '../context/AuthContext'
import { fetchProviders, fetchOnlineProviders } from '../api/admin'

export default function DashboardView() {
  const { admin, logout } = useAuth()
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState('dashboard')
  const [searchQuery, setSearchQuery] = useState('')
  const [reviewingProvider, setReviewingProvider] = useState(null)
  const [stats, setStats] = useState({
    totalProviders: '1,482',
    pendingVerifications: '24',
    onlineProviders: '312',
    openReports: '8',
  })

  // Fetch real counts from backend if available, fallback to figma values
  useEffect(() => {
    let isMounted = true
    async function loadStats() {
      try {
        const [allRes, onlineRes] = await Promise.allSettled([
          fetchProviders({ limit: 1 }),
          fetchOnlineProviders({ limit: 1 }),
        ])

        if (isMounted) {
          const total =
            allRes.status === 'fulfilled' && allRes.value.meta?.total != null
              ? allRes.value.meta.total.toLocaleString()
              : '1,482'

          const online =
            onlineRes.status === 'fulfilled' && onlineRes.value.meta?.total != null
              ? onlineRes.value.meta.total.toLocaleString()
              : '312'

          setStats((prev) => ({
            ...prev,
            totalProviders: total,
            onlineProviders: online,
          }))
        }
      } catch {
        // Fallback gracefully to design values
      }
    }
    loadStats()
    return () => {
      isMounted = false
    }
  }, [])

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const adminFirstName = admin?.name ? admin.name.split(' ')[0] : 'Zeeshan'

  return (
    <div className="w-full h-screen bg-[#F5F5F5] flex overflow-hidden font-sans text-[#1C2926] antialiased">
      {/* ================= EXACT FIGMA SIDEBAR ================= */}
      <AdminSidebar
        activeTab={activeTab}
        onSelectTab={setActiveTab}
        onLogout={handleLogout}
      />

      {/* ================= MAIN DASHBOARD AREA ================= */}
      <div
        className="flex-1 min-w-0 h-screen overflow-y-auto overflow-x-hidden"
        style={{
          paddingTop: '8px',
          paddingBottom: '24px',
          paddingLeft: '24px',
          paddingRight: '24px',
        }}
      >
        {/* Responsive Container: up to 1084px, fluidly scaling down without overflow */}
        <div
          style={{
            gap: '16px',
          }}
          className="w-full max-w-[1084px] flex flex-col shrink-0"
        >
          {/* ================= TOP HEADER: 1084x80 (Same across tabs) ================= */}
          <AdminTopHeader
            searchValue={searchQuery}
            onSearchChange={setSearchQuery}
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
                  city: p.location || 'Jeddah',
                  submittedDate: p.registeredDate || '22 Sept 2024',
                  nationalId: '2487654321',
                  iqamaExpiry: '12 Mar 2026',
                  whatsapp: p.phone,
                  vehicleModel: 'Toyota Dyna',
                  vehicleType: 'Flatbed Truck',
                  plateNumber: 'ABC 1234',
                  vehicleColor: 'White',
                })
              }}
            />
          ) : activeTab === 'map' ? (
            /* ===== LIVE MAP SCREEN ===== */
            <LiveMapView
              onSelectProvider={(p) => {
                setReviewingProvider({
                  ...p,
                  city: p.city || 'Riyadh',
                  submittedDate: '22 Sept 2024',
                  nationalId: '2487654321',
                  iqamaExpiry: '12 Mar 2026',
                  whatsapp: p.phone,
                  vehicleModel: 'Toyota Dyna',
                  vehicleType: 'Flatbed Truck',
                  plateNumber: 'ABC 1234',
                  vehicleColor: 'White',
                })
              }}
            />
          ) : activeTab === 'call-logs' ? (
            /* ===== CALL LOGS SCREEN ===== */
            <CallLogsView
              onViewProvider={(p) => {
                setReviewingProvider({
                  ...p,
                  city: p.location || 'Jeddah',
                  submittedDate: '22 Sept 2024',
                  nationalId: '2487654321',
                  iqamaExpiry: '12 Mar 2026',
                  whatsapp: p.phone,
                  vehicleModel: 'Toyota Dyna',
                  vehicleType: 'Flatbed Truck',
                  plateNumber: 'ABC 1234',
                  vehicleColor: 'White',
                })
              }}
            />
          ) : activeTab === 'categories' ? (
            /* ===== CATEGORY MANAGEMENT SCREEN ===== */
            <CategoryManagementView />
          ) : activeTab === 'verification' ? (
            /* ===== VERIFICATION QUEUE SCREEN ===== */
            <div className="flex flex-col gap-4 w-full">
              {/* TOP METRICS SECTION: 1084x181, gap: 20px */}
              <VerificationMetricsSection
                onSelectFilter={(filterId) => {
                  if (filterId === 'pending') {
                    setReviewingProvider({
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
                    })
                  }
                }}
              />

              {/* TABLE SECTION: 1084x699, rounded-20px */}
              <VerificationTableSection
                onViewDetails={(app) => setReviewingProvider(app)}
              />
            </div>
          ) : (
            /* ===== MAIN DASHBOARD SCREEN ===== */
            <>
              {/* 1ST ROW CARDS MAIN LAYOUT: 1084x278 */}
              <DashboardMetricsRow
                adminName={adminFirstName}
                stats={stats}
              />

              {/* 2ND ROW CARDS LAYOUT: 1084x386 (560x386 & 508x386) */}
              <DashboardSecondRow
                onViewLiveMap={() => setActiveTab('map')}
              />

              {/* 3RD ROW CARDS LAYOUT: 1084x216 (560x216 & 508x216) */}
              <DashboardThirdRow
                onViewAllVerifications={() => setActiveTab('verification')}
                onViewAllReports={() => setActiveTab('reports')}
                onSelectProvider={(p) => {
                  setReviewingProvider({
                    ...p,
                    city: 'Jeddah',
                    nationalId: '2487654321',
                    iqamaExpiry: '12 Mar 2026',
                    phone: '+966 48 570 5644',
                    whatsapp: '+966 48 574 3245',
                    vehicleModel: 'Toyota Dyna',
                    vehicleType: 'Flatbed Truck',
                    plateNumber: 'ABC 1234',
                    vehicleColor: 'White',
                  })
                  setActiveTab('verification')
                }}
              />
            </>
          )}
        </div>
      </div>
    </div>
  )
}
