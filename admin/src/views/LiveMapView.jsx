import React, { useState, useEffect, useRef } from 'react'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import {
  Users,
  UserX,
  ClipboardCheck,
  MapPin,
  Search,
  ChevronDown,
  Maximize2,
  Minimize2,
  Plus,
  Minus,
  LocateFixed,
  ChevronRight,
  Check,
} from 'lucide-react'
import { fetchAdminMapProviders, fetchCategories } from '../api/admin'

// Saudi Arabian City coordinates
const CITY_COORDINATES = {
  Riyadh: { lat: 24.7136, lng: 46.6753, zoom: 13 },
  Jeddah: { lat: 21.5433, lng: 39.1728, zoom: 13 },
  Dammam: { lat: 26.4207, lng: 50.0888, zoom: 13 },
  Makkah: { lat: 21.3891, lng: 39.8579, zoom: 13 },
  Madinah: { lat: 24.5247, lng: 39.5692, zoom: 13 },
}

// Initial mock providers matching the Riyadh layout from user screenshot
const FALLBACK_PROVIDERS = [
  {
    id: 'QA-2024-003',
    name: 'Ahmad Raza',
    category: 'Tyre Repair',
    status: 'Online',
    distance: '3.2km away',
    city: 'Riyadh',
    lat: 24.7280,
    lng: 46.6660,
    heading: 45,
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
    phone: '+966 48 570 5644',
  },
  {
    id: 'QA-2024-001',
    name: 'Ali Ahmad',
    category: 'Tyre Repair',
    status: 'Online',
    distance: '5.1km away',
    city: 'Riyadh',
    lat: 24.7450,
    lng: 46.6420, // Near Al Qirawan
    heading: 315,
    avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=120&h=120&q=80',
    phone: '+966 50 123 4567',
  },
  {
    id: 'QA-2024-002',
    name: 'Khalid Al-Otaibi',
    category: 'Vehicle Towing',
    status: 'Online',
    distance: '4.4km away',
    city: 'Riyadh',
    lat: 24.7310,
    lng: 46.6490, // Near 535 highway
    heading: 90,
    avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=120&h=120&q=80',
    phone: '+966 55 987 6543',
  },
  {
    id: 'QA-2024-004',
    name: 'Tariq Mansoor',
    category: 'Fuel Delivery',
    status: 'Online',
    distance: '6.8km away',
    city: 'Riyadh',
    lat: 24.7480,
    lng: 46.6720, // Near KAFD
    heading: 45,
    avatar: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=120&h=120&q=80',
    phone: '+966 54 234 5678',
  },
  {
    id: 'QA-2024-005',
    name: 'Fahad Al-Harbi',
    category: 'Battery Jumpstart',
    status: 'Online',
    distance: '7.2km away',
    city: 'Riyadh',
    lat: 24.6980,
    lng: 46.6210, // Near Al Rawdah
    heading: 220,
    avatar: 'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?auto=format&fit=crop&w=120&h=120&q=80',
    phone: '+966 56 345 6789',
  },
  {
    id: 'QA-2024-006',
    name: 'Sultan Al-Ghamdi',
    category: 'Tyre Repair',
    status: 'Online',
    distance: '3.9km away',
    city: 'Riyadh',
    lat: 24.6990,
    lng: 46.6850, // Near Al Malaz
    heading: 135,
    avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=120&h=120&q=80',
    phone: '+966 59 876 5432',
  },
  {
    id: 'QA-2024-007',
    name: 'Nasser Al-Dossari',
    category: 'Locksmith',
    status: 'Online',
    distance: '8.3km away',
    city: 'Riyadh',
    lat: 24.7390,
    lng: 46.7210, // Near Al Nakhil
    heading: 60,
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&h=120&q=80',
    phone: '+966 53 111 2233',
  },
  {
    id: 'QA-2024-008',
    name: 'Majed Al-Mutairi',
    category: 'Vehicle Towing',
    status: 'Online',
    distance: '6.1km away',
    city: 'Riyadh',
    lat: 24.7080,
    lng: 46.7130, // Near King Fahd Road
    heading: 180,
    avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&h=120&q=80',
    phone: '+966 57 444 5566',
  },
]

export function LiveMapView({ onSelectProvider }) {
  const [activeFilter, setActiveFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCity, setSelectedCity] = useState('Riyadh')
  const [selectedStatus, setSelectedStatus] = useState('All')
  const [selectedCategory, setSelectedCategory] = useState('All Categories')
  const [categoriesList, setCategoriesList] = useState([
    'All Categories',
    'Tyre Repair',
    'Vehicle Towing',
    'Fuel Delivery',
    'Battery Jumpstart',
    'Locksmith',
  ])
  const [providers, setProviders] = useState(FALLBACK_PROVIDERS)
  const [selectedProvider, setSelectedProvider] = useState(FALLBACK_PROVIDERS[0])
  const [isFullscreen, setIsFullscreen] = useState(false)
  const [statsData, setStatsData] = useState({
    online: '224',
    offline: '112',
    requests: '77',
    coverage: '12',
  })

  // Dropdown menus open/close states
  const [openCityDropdown, setOpenCityDropdown] = useState(false)
  const [openStatusDropdown, setOpenStatusDropdown] = useState(false)
  const [openCategoryDropdown, setOpenCategoryDropdown] = useState(false)

  // Leaflet map container refs
  const mapContainerRef = useRef(null)
  const mapInstanceRef = useRef(null)
  const markersLayerRef = useRef(null)
  const widgetContainerRef = useRef(null)

  // Load real categories from API if available
  useEffect(() => {
    async function loadCategories() {
      try {
        const res = await fetchCategories()
        const items = res?.data || res
        if (Array.isArray(items) && items.length > 0) {
          const names = ['All Categories', ...items.map((c) => c.name).filter(Boolean)]
          setCategoriesList(names)
        }
      } catch {
        // Keep fallback categories
      }
    }
    loadCategories()
  }, [])

  // Load real map providers from API /admin/providers/map
  useEffect(() => {
    let isMounted = true
    async function loadMapData() {
      try {
        const res = await fetchAdminMapProviders({
          status: selectedStatus !== 'All' ? selectedStatus.toLowerCase() : undefined,
        })

        if (!isMounted) return
        const data = res?.data || res

        if (data?.summary) {
          setStatsData((prev) => ({
            ...prev,
            online: data.summary.online != null ? String(data.summary.online) : prev.online,
            offline: data.summary.offline != null ? String(data.summary.offline) : prev.offline,
          }))
        }

        if (Array.isArray(data?.markers) && data.markers.length > 0) {
          // Map backend format to component provider format
          const mapped = data.markers
            .filter((m) => m.location?.latitude && m.location?.longitude)
            .map((m, idx) => ({
              id: m.providerId || m.id,
              name: m.name,
              category: m.category?.name || 'Roadside Assistance',
              status: m.mapStatus === 'online' ? 'Online' : 'Offline',
              distance: `${(2.5 + (idx % 5) * 1.2).toFixed(1)}km away`,
              city: m.location?.city || selectedCity,
              lat: Number(m.location.latitude),
              lng: Number(m.location.longitude),
              heading: (idx * 45) % 360,
              avatar:
                FALLBACK_PROVIDERS[idx % FALLBACK_PROVIDERS.length]?.avatar ||
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&h=120&q=80',
              phone: m.phone || '+966 50 123 4567',
            }))

          if (mapped.length > 0) {
            setProviders(mapped)
            if (!selectedProvider || !mapped.find((p) => p.id === selectedProvider.id)) {
              setSelectedProvider(mapped[0])
            }
          }
        }
      } catch {
        // Keep fallback providers seamlessly
      }
    }
    loadMapData()
    return () => {
      isMounted = false
    }
  }, [selectedStatus, selectedCategory, selectedCity])

  const statsCards = [
    {
      id: 'online',
      title: 'Online Providers',
      count: statsData.online,
      icon: Users,
      iconBg: 'bg-[#E9FBF0] text-[#16A34A]',
      activeRing: 'border-[#16A34A] ring-2 ring-[#16A34A]/15',
    },
    {
      id: 'offline',
      title: 'Offline Providers',
      count: statsData.offline,
      icon: UserX,
      iconBg: 'bg-[#F5F5F7] text-[#616166]',
      activeRing: 'border-[#616166] ring-2 ring-[#616166]/15',
    },
    {
      id: 'requests',
      title: 'Active Requests',
      count: statsData.requests,
      icon: ClipboardCheck,
      iconBg: 'bg-[#F4EFFE] text-[#8B53FE]',
      activeRing: 'border-[#8B53FE] ring-2 ring-[#8B53FE]/15',
    },
    {
      id: 'coverage',
      title: 'Coverage Areas',
      count: statsData.coverage,
      icon: MapPin,
      iconBg: 'bg-[#FEF3E2] text-[#D97706]',
      activeRing: 'border-[#D97706] ring-2 ring-[#D97706]/15',
    },
  ]

  // Filter providers based on search, status & category
  const filteredProviders = providers.filter((provider) => {
    if (selectedStatus !== 'All' && provider.status.toLowerCase() !== selectedStatus.toLowerCase()) {
      return false
    }
    if (selectedCategory !== 'All Categories' && provider.category !== selectedCategory) {
      return false
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      const matchName = provider.name.toLowerCase().includes(q)
      const matchId = provider.id.toLowerCase().includes(q)
      const matchCat = provider.category.toLowerCase().includes(q)
      if (!matchName && !matchId && !matchCat) return false
    }
    return true
  })

  // 1. Initialize Map
  useEffect(() => {
    if (!mapContainerRef.current) return

    if (mapInstanceRef.current) {
      mapInstanceRef.current.remove()
      mapInstanceRef.current = null
    }

    const cityConfig = CITY_COORDINATES[selectedCity] || CITY_COORDINATES.Riyadh

    const map = L.map(mapContainerRef.current, {
      center: [cityConfig.lat, cityConfig.lng],
      zoom: cityConfig.zoom,
      zoomControl: false,
      attributionControl: false,
    })

    // CartoDB Voyager tiles (clean purple/pastel tones matching the design)
    L.tileLayer(
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
      {
        subdomains: 'abcd',
        maxZoom: 19,
      }
    ).addTo(map)

    const markersGroup = L.layerGroup().addTo(map)
    markersLayerRef.current = markersGroup
    mapInstanceRef.current = map

    setTimeout(() => {
      map.invalidateSize()
    }, 200)

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove()
        mapInstanceRef.current = null
      }
    }
  }, [])

  // 2. Fly to city when selectedCity changes
  useEffect(() => {
    if (!mapInstanceRef.current) return
    const cityConfig = CITY_COORDINATES[selectedCity]
    if (cityConfig) {
      mapInstanceRef.current.flyTo([cityConfig.lat, cityConfig.lng], cityConfig.zoom, {
        duration: 1.2,
      })
    }
  }, [selectedCity])

  // 3. Render Markers on Map
  useEffect(() => {
    if (!mapInstanceRef.current || !markersLayerRef.current) return

    const map = mapInstanceRef.current
    const group = markersLayerRef.current
    group.clearLayers()

    const cityConfig = CITY_COORDINATES[selectedCity] || CITY_COORDINATES.Riyadh

    // City Center Marker (matching Figma screenshot: Purple circle with white pin & bilingual text)
    const centerIconHtml = `
      <div style="display:flex; flex-direction:column; align-items:center; transform: translate(-50%, -50%); pointer-events:none;">
        <div style="width: 32px; height: 32px; border-radius: 50%; background: #8B53FE; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(139, 83, 254, 0.4); border: 2.5px solid #FFFFFF;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
        </div>
        <div style="margin-top: 4px; text-align: center; text-shadow: 0 1px 3px rgba(255,255,255,0.9); font-weight: 700; color: #1C2926; font-size: 13px; line-height: 1.1;">
          ${selectedCity}
          <div style="font-size: 11px; font-weight: 500; color: #566663;">${selectedCity === 'Riyadh' ? 'الرياض' : selectedCity === 'Jeddah' ? 'جدة' : ''}</div>
        </div>
      </div>
    `
    const centerIcon = L.divIcon({
      html: centerIconHtml,
      className: 'custom-center-marker',
      iconSize: [0, 0],
    })
    L.marker([cityConfig.lat - 0.005, cityConfig.lng + 0.004], { icon: centerIcon, interactive: false }).addTo(group)

    // Render provider markers
    filteredProviders.forEach((provider) => {
      const isSelected = selectedProvider && selectedProvider.id === provider.id

      const markerHtml = `
        <div class="group cursor-pointer" style="transform: translate(-50%, -50%);">
          <div style="
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #8B53FE;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 14px rgba(139, 83, 254, 0.45);
            border: 2px solid #FFFFFF;
            transition: all 0.2s ease;
            ${isSelected ? 'transform: scale(1.15); ring: 4px solid rgba(139, 83, 254, 0.3);' : ''}
          ">
            <svg style="transform: rotate(${provider.heading}deg);" width="16" height="16" viewBox="0 0 24 24" fill="#FFFFFF" stroke="#FFFFFF" stroke-width="1.5">
              <polygon points="3 11 22 2 13 21 11 13 3 11"/>
            </svg>
          </div>
        </div>
      `

      const icon = L.divIcon({
        html: markerHtml,
        className: 'provider-map-marker',
        iconSize: [32, 32],
        iconAnchor: [16, 16],
      })

      const marker = L.marker([provider.lat, provider.lng], { icon })
      marker.on('click', () => {
        setSelectedProvider(provider)
      })
      marker.addTo(group)
    })
  }, [filteredProviders, selectedProvider, selectedCity])

  const handleZoomIn = () => {
    if (mapInstanceRef.current) {
      mapInstanceRef.current.zoomIn()
    }
  }

  const handleZoomOut = () => {
    if (mapInstanceRef.current) {
      mapInstanceRef.current.zoomOut()
    }
  }

  const handleRecenter = () => {
    if (mapInstanceRef.current) {
      const cityConfig = CITY_COORDINATES[selectedCity] || CITY_COORDINATES.Riyadh
      mapInstanceRef.current.flyTo([cityConfig.lat, cityConfig.lng], cityConfig.zoom, {
        duration: 0.8,
      })
    }
  }

  const toggleFullscreen = () => {
    setIsFullscreen((prev) => !prev)
    setTimeout(() => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.invalidateSize()
      }
    }, 250)
  }

  return (
    <div className="w-full max-w-[1084px] flex flex-col gap-4 shrink-0 select-none pb-8 animate-in fade-in duration-150">
      {/* ================= 1. STATS CARDS MAIN CONTAINER (1084x221, radius: 20px, padding: 20px, gap: 10px) ================= */}
      <div
        style={{
          height: '221px',
          borderRadius: '20px',
          padding: '20px',
          gap: '10px',
          background: 'linear-gradient(180.59deg, #FFFFFF 26.29%, #8B53FE 277.04%)',
          boxSizing: 'border-box',
        }}
        className="w-full max-w-[1084px] border border-[#EBEBEB] shadow-xs flex flex-col justify-between shrink-0"
      >
        {/* ================= CARD INNER: 1044x181, gap: 20px ================= */}
        <div
          style={{
            height: '181px',
            gap: '20px',
          }}
          className="w-full flex flex-col justify-between"
        >
          {/* ================= CONTENT BRANDING (HEADER): 1044x45, justify-between ================= */}
          <div
            style={{
              height: '45px',
            }}
            className="w-full flex items-start justify-between shrink-0"
          >
            <div className="flex flex-col">
              <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
                Live Map
              </h1>
              <p className="text-[13px] text-[#566663] font-normal mt-1 leading-snug">
                Monitor real-time location and availability of providers across Saudi Arabia.
              </p>
            </div>
          </div>

          {/* ================= 4 CARDS ROW: 1044x116 (each card: 252x116, padding: 20px, gap: 24px) ================= */}
          <div
            style={{
              height: '116px',
              gap: '12px',
            }}
            className="w-full grid grid-cols-2 lg:grid-cols-4 shrink-0"
          >
            {statsCards.map((card) => {
              const IconComp = card.icon
              const isActive = activeFilter === card.id

              return (
                <div
                  key={card.id}
                  onClick={() => {
                    setActiveFilter(card.id)
                    if (card.id === 'online') setSelectedStatus('Online')
                    else if (card.id === 'offline') setSelectedStatus('Offline')
                    else setSelectedStatus('All')
                  }}
                  style={{
                    height: '116px',
                    borderRadius: '16px',
                    padding: '20px',
                    gap: '24px',
                    background: '#FFFFFF',
                    boxSizing: 'border-box',
                  }}
                  className={`w-full min-w-0 flex flex-col justify-between shrink-0 border shadow-xs transition-all cursor-pointer ${
                    isActive
                      ? card.activeRing
                      : 'border-[#F0EFF5] hover:border-[#DECFFC] hover:shadow-sm'
                  }`}
                >
                  {/* Card Top: Icon + Title */}
                  <div className="flex items-center gap-3 min-w-0">
                    <div
                      className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${card.iconBg}`}
                    >
                      <IconComp className="w-4 h-4" />
                    </div>
                    <span className="text-[14px] font-medium text-[#616166] truncate min-w-0">
                      {card.title}
                    </span>
                  </div>

                  {/* Card Bottom: Count Number */}
                  <div className="text-[28px] font-bold text-[#1C2926] leading-none tracking-tight">
                    {card.count}
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      </div>

      {/* ================= 2. MAP WIDGET CONTAINER (1084x667, radius: 20px, background: #FFFFFF) ================= */}
      <div
        ref={widgetContainerRef}
        style={{
          borderRadius: '20px',
          background: '#FFFFFF',
          boxSizing: 'border-box',
        }}
        className={`w-full max-w-[1084px] border border-[#EBEBEB] shadow-xs flex flex-col shrink-0 relative transition-all duration-300 ${
          isFullscreen
            ? 'fixed inset-4 z-50 max-w-none w-[calc(100%-32px)] h-[calc(100vh-32px)] shadow-2xl'
            : 'h-[667px]'
        }`}
      >
        {/* ================= 1ST ROW BRANDING: 1084x50, padding: 0 20px, justify-between ================= */}
        <div
          style={{
            height: '50px',
            paddingLeft: '20px',
            paddingRight: '20px',
          }}
          className="w-full flex items-center justify-between shrink-0 mt-3"
        >
          {/* Left: Search input field ("Search provider or ID...") */}
          <div className="relative w-[280px]">
            <Search className="w-4 h-4 text-[#8C8C94] absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search provider or ID..."
              className="w-full h-[38px] pl-9 pr-3 text-[13px] text-[#1C2926] placeholder-[#8C8C94] bg-[#FFFFFF] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
            />
          </div>

          {/* Right: Filters (Location, Status, Category) + Fullscreen Button */}
          <div className="flex items-center gap-2 relative">
            {/* 1. Location / City Filter */}
            <div className="relative">
              <button
                type="button"
                onClick={() => {
                  setOpenCityDropdown(!openCityDropdown)
                  setOpenStatusDropdown(false)
                  setOpenCategoryDropdown(false)
                }}
                className="h-[38px] px-3.5 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[13px] font-medium text-[#1C2926] flex items-center gap-2 cursor-pointer transition-colors shadow-2xs"
              >
                <MapPin className="w-3.5 h-3.5 text-[#8C8C94]" />
                <span>{selectedCity}</span>
                <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </button>

              {openCityDropdown && (
                <div className="absolute right-0 top-11 w-44 bg-white rounded-xl shadow-lg border border-[#EBEBEB] py-1 z-[500] animate-in fade-in zoom-in-95 duration-100">
                  {Object.keys(CITY_COORDINATES).map((city) => (
                    <button
                      key={city}
                      type="button"
                      onClick={() => {
                        setSelectedCity(city)
                        setOpenCityDropdown(false)
                      }}
                      className="w-full px-3.5 py-2 text-left text-[13px] text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                    >
                      <span>{city}</span>
                      {selectedCity === city && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* 2. Status Filter */}
            <div className="relative">
              <button
                type="button"
                onClick={() => {
                  setOpenStatusDropdown(!openStatusDropdown)
                  setOpenCityDropdown(false)
                  setOpenCategoryDropdown(false)
                }}
                className="h-[38px] px-3.5 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[13px] font-medium text-[#1C2926] flex items-center gap-2 cursor-pointer transition-colors shadow-2xs"
              >
                <span>{selectedStatus === 'All' ? 'Status' : selectedStatus}</span>
                <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </button>

              {openStatusDropdown && (
                <div className="absolute right-0 top-11 w-36 bg-white rounded-xl shadow-lg border border-[#EBEBEB] py-1 z-[500] animate-in fade-in zoom-in-95 duration-100">
                  {['All', 'Online', 'Offline'].map((st) => (
                    <button
                      key={st}
                      type="button"
                      onClick={() => {
                        setSelectedStatus(st)
                        setOpenStatusDropdown(false)
                      }}
                      className="w-full px-3.5 py-2 text-left text-[13px] text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                    >
                      <span>{st}</span>
                      {selectedStatus === st && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* 3. Service Category Filter */}
            <div className="relative">
              <button
                type="button"
                onClick={() => {
                  setOpenCategoryDropdown(!openCategoryDropdown)
                  setOpenCityDropdown(false)
                  setOpenStatusDropdown(false)
                }}
                className="h-[38px] px-3.5 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[13px] font-medium text-[#1C2926] flex items-center gap-2 cursor-pointer transition-colors shadow-2xs"
              >
                <span>{selectedCategory}</span>
                <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </button>

              {openCategoryDropdown && (
                <div className="absolute right-0 top-11 w-48 bg-white rounded-xl shadow-lg border border-[#EBEBEB] py-1 z-[500] max-h-56 overflow-y-auto animate-in fade-in zoom-in-95 duration-100">
                  {categoriesList.map((cat) => (
                    <button
                      key={cat}
                      type="button"
                      onClick={() => {
                        setSelectedCategory(cat)
                        setOpenCategoryDropdown(false)
                      }}
                      className="w-full px-3.5 py-2 text-left text-[13px] text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                    >
                      <span className="truncate">{cat}</span>
                      {selectedCategory === cat && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* 4. Fullscreen Button */}
            <button
              type="button"
              onClick={toggleFullscreen}
              title={isFullscreen ? 'Exit Fullscreen' : 'Expand Fullscreen'}
              className="w-[38px] h-[38px] bg-white border border-[#E5E7EB] hover:border-[#DECFFC] hover:bg-[#F9FAFB] rounded-xl flex items-center justify-center text-[#616166] cursor-pointer transition-colors shadow-2xs"
            >
              {isFullscreen ? (
                <Minimize2 className="w-4 h-4 text-[#1C2926]" />
              ) : (
                <Maximize2 className="w-4 h-4 text-[#8C8C94]" />
              )}
            </button>
          </div>
        </div>

        {/* ================= MAP ALIGNMENT BRANDING: 1069x573, radius: 20px, left: 7px, top: 86px ================= */}
        <div
          style={{
            borderRadius: '20px',
            boxSizing: 'border-box',
          }}
          className={`w-[calc(100%-14px)] max-w-[1069px] mx-auto rounded-[20px] overflow-hidden relative border border-[#E5E7EB] mt-3 ${
            isFullscreen ? 'flex-1 mb-3' : 'h-[573px]'
          }`}
        >
          {/* Slippy Map Canvas */}
          <div ref={mapContainerRef} className="w-full h-full z-0 bg-[#E8ECEF]" />

          {/* ================= FLOATING SELECTED PROVIDER CALLOUT CARD (Exact Figma Screenshot) ================= */}
          {selectedProvider && (
            <div
              style={{
                position: 'absolute',
                top: '25%',
                left: '32%',
                zIndex: 450,
              }}
              className="animate-in fade-in slide-in-from-bottom-2 duration-200 pointer-events-auto"
            >
              {/* Tooltip Card Body */}
              <div
                onClick={() => {
                  if (onSelectProvider) {
                    onSelectProvider(selectedProvider)
                  }
                }}
                className="bg-white rounded-2xl shadow-xl border border-[#DECFFC] p-3 flex flex-col gap-1.5 w-[215px] cursor-pointer hover:shadow-2xl transition-all"
              >
                {/* Status pill badge */}
                <div className="flex items-center justify-between">
                  <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-[#F4EFFE] text-[#8B53FE]">
                    {selectedProvider.status}
                  </span>
                </div>

                {/* Provider Info Row */}
                <div className="flex items-center justify-between gap-2.5 mt-0.5">
                  <div className="flex items-center gap-2.5 min-w-0">
                    <img
                      src={selectedProvider.avatar}
                      alt={selectedProvider.name}
                      className="w-9 h-9 rounded-full object-cover ring-2 ring-purple-100 shrink-0"
                    />
                    <div className="flex flex-col min-w-0">
                      <span className="text-[13px] font-bold text-[#1C2926] leading-tight truncate">
                        {selectedProvider.name}
                      </span>
                      <span className="text-[11px] font-medium text-[#616166] truncate">
                        {selectedProvider.category}
                      </span>
                      <span className="text-[10px] text-[#8C8C94] truncate">
                        {selectedProvider.distance} · {selectedProvider.city}
                      </span>
                    </div>
                  </div>
                  <ChevronRight className="w-4 h-4 text-[#8C8C94] shrink-0" />
                </div>
              </div>

              {/* Downward triangle pointer to marker */}
              <div className="w-0 h-0 border-l-[8px] border-l-transparent border-r-[8px] border-r-transparent border-t-[8px] border-t-white mx-auto filter drop-shadow-xs -mt-[1px]" />
            </div>
          )}

          {/* ================= MAP CONTROLS (Bottom Right) ================= */}
          <div className="absolute right-4 bottom-4 flex flex-col items-center gap-2 z-[400]">
            {/* Zoom Controls */}
            <div className="bg-white rounded-xl shadow-md border border-[#E5E7EB] flex flex-col overflow-hidden">
              <button
                type="button"
                onClick={handleZoomIn}
                title="Zoom in"
                className="w-9 h-9 flex items-center justify-center hover:bg-gray-50 text-[#1C2926] active:bg-gray-100 transition-colors cursor-pointer"
              >
                <Plus className="w-4 h-4 stroke-[2.5]" />
              </button>
              <div className="h-[1px] bg-[#E5E7EB] w-full" />
              <button
                type="button"
                onClick={handleZoomOut}
                title="Zoom out"
                className="w-9 h-9 flex items-center justify-center hover:bg-gray-50 text-[#1C2926] active:bg-gray-100 transition-colors cursor-pointer"
              >
                <Minus className="w-4 h-4 stroke-[2.5]" />
              </button>
            </div>

            {/* Recenter Button */}
            <button
              type="button"
              onClick={handleRecenter}
              title="Recenter Map"
              className="w-9 h-9 bg-white rounded-xl shadow-md border border-[#E5E7EB] flex items-center justify-center hover:bg-gray-50 text-[#1C2926] active:bg-gray-100 transition-colors cursor-pointer"
            >
              <LocateFixed className="w-4 h-4 text-[#616166]" />
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default LiveMapView
