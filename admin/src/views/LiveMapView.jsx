import React, { useState, useEffect, useRef, useMemo, useCallback } from 'react'
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
  Layers,
  Radio,
  Clock,
  Compass,
  Phone,
  Car,
  Navigation,
  X,
  RotateCw,
} from 'lucide-react'
import { fetchAdminMapProviders, fetchCategories, fetchCitiesApi } from '../api/admin'

const GOOGLE_MAPS_API_KEY =
  import.meta.env.VITE_GOOGLE_MAPS_API_KEY || 'AIzaSyDpF68t3tu43hMcN969pPsub6QCzEwLBLE'

// Base default Saudi Arabian City coordinates
const DEFAULT_CITY_COORDINATES = {
  'All Cities': { lat: 24.0, lng: 45.0, zoom: 6, nameAr: 'جميع المدن' },
  Riyadh: { lat: 24.7136, lng: 46.6753, zoom: 12, nameAr: 'الرياض' },
  Jeddah: { lat: 21.5433, lng: 39.1728, zoom: 12, nameAr: 'جدة' },
  Makkah: { lat: 21.3891, lng: 39.8579, zoom: 13, nameAr: 'مكة المكرمة' },
  Madinah: { lat: 24.5247, lng: 39.5692, zoom: 13, nameAr: 'المدينة المنورة' },
  Dammam: { lat: 26.4207, lng: 50.0888, zoom: 12, nameAr: 'الدمام' },
  Khobar: { lat: 26.2818, lng: 50.2084, zoom: 13, nameAr: 'الخبر' },
  Tabuk: { lat: 28.3835, lng: 36.5662, zoom: 12, nameAr: 'تبوك' },
  Taif: { lat: 21.4373, lng: 40.5127, zoom: 12, nameAr: 'الطائف' },
  Abha: { lat: 18.2164, lng: 42.5053, zoom: 12, nameAr: 'أبها' },
  Buraidah: { lat: 26.3592, lng: 43.9818, zoom: 12, nameAr: 'بريدة' },
  Jubail: { lat: 27.0046, lng: 49.6601, zoom: 12, nameAr: 'الجبيل' },
  Hail: { lat: 27.5216, lng: 41.6907, zoom: 12, nameAr: 'حائل' },
  Najran: { lat: 17.4924, lng: 44.1277, zoom: 12, nameAr: 'نجران' },
  Yanbu: { lat: 24.0895, lng: 38.0637, zoom: 12, nameAr: 'ينبع' },
}

/**
 * Calculates exact great-circle distance between two GPS coordinates using Haversine formula
 */
function calculateDistanceKm(lat1, lon1, lat2, lon2) {
  if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) return '0.0'
  const R = 6371 // Earth radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180
  const dLon = ((lon2 - lon1) * Math.PI) / 180
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  const dist = R * c
  return dist < 10 ? dist.toFixed(1) : Math.round(dist).toString()
}

/**
 * Formats GPS timestamp into relative and exact clock time
 */
function formatGpsTime(isoString, isOnline) {
  if (!isoString) return { label: 'No GPS data', isLive: false, detail: 'Never', relative: 'No GPS' }
  const time = new Date(isoString).getTime()
  if (isNaN(time)) return { label: 'No GPS data', isLive: false, detail: 'Invalid', relative: 'No GPS' }
  const diffSec = Math.max(0, Math.floor((Date.now() - time) / 1000))

  const timeFormatted = new Date(isoString).toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  })

  if (isOnline && diffSec <= 20) {
    return {
      label: 'Just now',
      relative: 'Just now',
      isLive: true,
      detail: timeFormatted,
    }
  }
  if (diffSec < 60) {
    return {
      label: `${diffSec}s ago`,
      relative: `${diffSec}s ago`,
      isLive: isOnline && diffSec <= 45,
      detail: timeFormatted,
    }
  }
  const diffMin = Math.floor(diffSec / 60)
  if (diffMin < 60) {
    return {
      label: `${diffMin}m ago`,
      relative: `${diffMin}m ago`,
      isLive: false,
      detail: timeFormatted,
    }
  }
  const diffHours = Math.floor(diffMin / 60)
  if (diffHours < 24) {
    return {
      label: `${diffHours}h ago`,
      relative: `${diffHours}h ago`,
      isLive: false,
      detail: timeFormatted,
    }
  }
  return {
    label: new Date(isoString).toLocaleDateString([], { month: 'short', day: 'numeric' }),
    relative: new Date(isoString).toLocaleDateString([], { month: 'short', day: 'numeric' }),
    isLive: false,
    detail: timeFormatted,
  }
}

export function LiveMapView({ onSelectProvider }) {
  const [activeStatFilter, setActiveStatFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCity, setSelectedCity] = useState('All Cities')
  const [selectedCategory, setSelectedCategory] = useState('All Categories')
  const [categoriesList, setCategoriesList] = useState(['All Categories'])
  const [cityCoordinatesMap, setCityCoordinatesMap] = useState(DEFAULT_CITY_COORDINATES)
  const [providers, setProviders] = useState([])
  const [selectedProvider, setSelectedProvider] = useState(null)
  const [calloutPoint, setCalloutPoint] = useState(null)
  const [showFleetDrawer, setShowFleetDrawer] = useState(false)
  const [isFullscreen, setIsFullscreen] = useState(false)
  const [isRefreshing, setIsRefreshing] = useState(false)

  // Real browser GPS Admin location
  const [adminLocation, setAdminLocation] = useState(null)
  const [isLocating, setIsLocating] = useState(false)

  const [statsData, setStatsData] = useState({
    online: '0',
    offline: '0',
    requests: '0',
    coverage: String(Object.keys(DEFAULT_CITY_COORDINATES).length - 1),
  })

  // Dropdown states
  const [openCityDropdown, setOpenCityDropdown] = useState(false)
  const [openCategoryDropdown, setOpenCategoryDropdown] = useState(false)
  const [openLayerDropdown, setOpenLayerDropdown] = useState(false)
  const [mapLayerType, setMapLayerType] = useState('google_roadmap')

  // Leaflet refs
  const mapContainerRef = useRef(null)
  const mapInstanceRef = useRef(null)
  const tileLayerRef = useRef(null)
  const markersLayerRef = useRef(null)
  const widgetContainerRef = useRef(null)
  const markersMapRef = useRef(new Map())
  const adminMarkerRef = useRef(null)
  const cityCenterMarkerRef = useRef(null)
  const prevCityRef = useRef(selectedCity)

  // ================= 1. Load Categories =================
  const loadCategories = useCallback(async () => {
    try {
      const res = await fetchCategories({ _t: Date.now() })
      const items = Array.isArray(res?.data)
        ? res.data
        : Array.isArray(res?.items)
        ? res.items
        : Array.isArray(res)
        ? res
        : []
      if (items.length > 0) {
        const names = ['All Categories', ...items.map((c) => c.name).filter(Boolean)]
        setCategoriesList(names)
      } else {
        setCategoriesList(['All Categories'])
      }
    } catch {
      setCategoriesList(['All Categories'])
    }
  }, [])

  // ================= 2. Load Cities =================
  const loadCities = useCallback(async () => {
    try {
      const items = await fetchCitiesApi({ enabledOnly: true, _t: Date.now() })
      if (Array.isArray(items) && items.length > 0) {
        setCityCoordinatesMap((prev) => {
          let hasDiff = false
          const nextMap = { ...prev }
          items.forEach((c) => {
            if (c.name && c.lat != null && c.lng != null) {
              const existing = nextMap[c.name]
              const nextLat = Number(c.lat)
              const nextLng = Number(c.lng)
              if (!existing || existing.lat !== nextLat || existing.lng !== nextLng) {
                hasDiff = true
                nextMap[c.name] = {
                  lat: nextLat,
                  lng: nextLng,
                  zoom: Number(c.zoom) || 12,
                  nameAr: c.nameAr || c.name_ar || '',
                }
              }
            }
          })
          return hasDiff ? nextMap : prev
        })
      }
    } catch (err) {
      console.warn('Failed to load cities for map:', err)
    }
  }, [])

  // ================= 3. Load Map Telemetry =================
  const loadMapData = useCallback(async () => {
    try {
      const res = await fetchAdminMapProviders({ _t: Date.now() })
      const data = res?.data || res

      if (data?.summary) {
        setStatsData((prev) => {
          const nextOnline = data.summary.online != null ? String(data.summary.online) : prev.online
          const nextOffline = data.summary.offline != null ? String(data.summary.offline) : prev.offline
          const nextCov = String(Math.max(1, Object.keys(cityCoordinatesMap).length - 1))
          if (prev.online === nextOnline && prev.offline === nextOffline && prev.coverage === nextCov) {
            return prev
          }
          return {
            ...prev,
            online: nextOnline,
            offline: nextOffline,
            coverage: nextCov,
          }
        })
      }

      if (Array.isArray(data?.markers)) {
        const mapped = data.markers
          .filter((m) => m.location?.latitude != null && m.location?.longitude != null)
          .map((m, idx) => {
            const loc = m.location || {}
            const lat = Number(loc.latitude)
            const lng = Number(loc.longitude)
            const presence = m.presence || {}
            const isOnline = m.mapStatus === 'online' || presence.isOnline === true
            const isSuspended = m.mapStatus === 'suspended' || m.accountStatus === 'suspended'
            const isBlocked = m.mapStatus === 'blocked' || m.accountStatus === 'blocked'
            const gpsTimestamp =
              loc.updatedAt || presence.locationUpdatedAt || presence.lastSeenAt || null

            const timeInfo = formatGpsTime(gpsTimestamp, isOnline)

            return {
              id: m.providerId || m.id,
              backendId: m.id,
              name: m.name || `Provider ${m.providerId || idx + 1}`,
              category: m.category?.name || 'Roadside Assistance',
              vehicleType: m.vehicleType || 'Service Vehicle',
              status: isOnline
                ? 'Online'
                : isSuspended
                ? 'Suspended'
                : isBlocked
                ? 'Blocked'
                : 'Offline',
              isOnline,
              isSuspended,
              isBlocked,
              mapStatus: m.mapStatus,
              hasRealGps: Boolean(loc.hasRealGps),
              lat,
              lng,
              city: loc.city || m.city || 'Riyadh',
              address: loc.address || '',
              gpsTime: gpsTimestamp,
              gpsTimeInfo: timeInfo,
              heading: (idx * 45) % 360,
              avatar:
                m.photoUrl ||
                `https://ui-avatars.com/api/?name=${encodeURIComponent(
                  m.name || 'P'
                )}&background=8B53FE&color=fff&bold=true`,
              phone: m.phone || '+966 50 123 4567',
            }
          })

        setProviders((prev) => {
          if (prev.length === mapped.length) {
            const isIdentical = prev.every((p, i) => {
              const m = mapped[i]
              return (
                m &&
                p.id === m.id &&
                p.lat === m.lat &&
                p.lng === m.lng &&
                p.status === m.status &&
                p.gpsTime === m.gpsTime
              )
            })
            if (isIdentical) return prev
          }
          return mapped
        })

        setSelectedProvider((prev) => {
          if (!prev) return mapped[0] || null
          const found = mapped.find((p) => p.id === prev.id)
          return found || mapped[0] || null
        })
      }
    } catch {
      // Keep existing telemetry on minor network glitch
    }
  }, [cityCoordinatesMap])

  // Initial load
  useEffect(() => {
    loadCategories()
    loadCities()
    loadMapData()
  }, [loadCategories, loadCities, loadMapData])

  // Background polling (every 3.5 seconds)
  useEffect(() => {
    const intervalTimer = setInterval(() => {
      loadMapData()
    }, 3500)

    const handleFocus = () => loadMapData()
    const handleVisibility = () => {
      if (document.visibilityState === 'visible') loadMapData()
    }
    window.addEventListener('focus', handleFocus)
    document.addEventListener('visibilitychange', handleVisibility)

    return () => {
      clearInterval(intervalTimer)
      window.removeEventListener('focus', handleFocus)
      document.removeEventListener('visibilitychange', handleVisibility)
    }
  }, [loadMapData])

  // Refresh All handler
  const handleRefreshAll = async () => {
    setIsRefreshing(true)
    try {
      await Promise.all([loadCategories(), loadCities(), loadMapData()])
    } finally {
      setTimeout(() => setIsRefreshing(false), 500)
    }
  }

  // ================= 4. Geolocation (Admin GPS) =================
  const handleLocateAdmin = () => {
    if (!navigator.geolocation) {
      alert('Geolocation is not supported by your browser.')
      return
    }

    setIsLocating(true)

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const lat = pos.coords.latitude
        const lng = pos.coords.longitude
        const accuracy = Math.round(pos.coords.accuracy || 0)

        const loc = { lat, lng, accuracy, timestamp: Date.now() }
        setAdminLocation(loc)
        setIsLocating(false)

        if (mapInstanceRef.current) {
          mapInstanceRef.current.flyTo([lat, lng], 14, { duration: 0.8 })
        }
      },
      (err) => {
        console.warn('Geolocation error:', err)
        setIsLocating(false)
        let msg = 'Unable to retrieve your location.'
        if (err.code === 1) msg = 'Location access was denied. Please allow location access in your browser settings.'
        else if (err.code === 2) msg = 'Location position unavailable.'
        else if (err.code === 3) msg = 'Location request timed out.'
        alert(msg)
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 10000 }
    )
  }

  const handleClearAdminLocation = () => {
    setAdminLocation(null)
    const cityConfig =
      cityCoordinatesMap[selectedCity] ||
      cityCoordinatesMap['All Cities'] ||
      { lat: 24.0, lng: 45.0, zoom: 6 }
    if (mapInstanceRef.current) {
      mapInstanceRef.current.flyTo([cityConfig.lat, cityConfig.lng], cityConfig.zoom, { duration: 0.8 })
    }
  }

  // ================= 5. Distance and Filter Processing =================
  const filteredProviders = useMemo(() => {
    const cityConfig =
      cityCoordinatesMap[selectedCity] ||
      cityCoordinatesMap['All Cities'] ||
      cityCoordinatesMap.Riyadh ||
      { lat: 24.7136, lng: 46.6753, zoom: 12 }

    const listWithDistance = providers.map((p) => {
      let distKm = '0.0'
      let distanceLabel = ''
      let isRelativeToAdmin = false

      if (adminLocation) {
        distKm = calculateDistanceKm(p.lat, p.lng, adminLocation.lat, adminLocation.lng)
        distanceLabel = 'from you'
        isRelativeToAdmin = true
      } else {
        const anchorLat = selectedCity === 'All Cities' ? 24.7136 : cityConfig.lat
        const anchorLng = selectedCity === 'All Cities' ? 46.6753 : cityConfig.lng
        distKm = calculateDistanceKm(p.lat, p.lng, anchorLat, anchorLng)
        distanceLabel = selectedCity === 'All Cities' ? 'from Riyadh' : `from ${selectedCity}`
        isRelativeToAdmin = false
      }

      return {
        ...p,
        distanceKm: distKm,
        distanceLabel,
        isRelativeToAdmin,
        distanceNum: parseFloat(distKm) || 999999,
      }
    })

    let filtered = listWithDistance.filter((p) => {
      if (selectedCategory !== 'All Categories' && p.category !== selectedCategory) {
        return false
      }

      if (selectedCity !== 'All Cities') {
        const matchesName = p.city && p.city.toLowerCase() === selectedCity.toLowerCase()
        let inRadius = false
        if (cityConfig.lat != null && cityConfig.lng != null) {
          const d = parseFloat(calculateDistanceKm(p.lat, p.lng, cityConfig.lat, cityConfig.lng))
          inRadius = d <= 120
        }
        if (!matchesName && !inRadius) return false
      }

      if (activeStatFilter === 'online' && !p.isOnline) return false
      if (activeStatFilter === 'offline' && p.isOnline) return false

      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase()
        const matchName = p.name.toLowerCase().includes(q)
        const matchId = p.id.toLowerCase().includes(q)
        const matchCat = p.category.toLowerCase().includes(q)
        const matchPhone = p.phone.toLowerCase().includes(q)
        const matchCity = (p.city || '').toLowerCase().includes(q)
        if (!matchName && !matchId && !matchCat && !matchPhone && !matchCity) return false
      }

      return true
    })

    if (adminLocation) {
      filtered = [...filtered].sort((a, b) => a.distanceNum - b.distanceNum)
    }

    return filtered
  }, [
    providers,
    selectedCategory,
    selectedCity,
    searchQuery,
    activeStatFilter,
    adminLocation,
    cityCoordinatesMap,
  ])

  // ================= 6. Map Tile Layer Manager =================
  const updateTileLayer = (type, targetMap = mapInstanceRef.current) => {
    if (!targetMap) return
    if (tileLayerRef.current) {
      try {
        targetMap.removeLayer(tileLayerRef.current)
      } catch {}
    }

    let url = `https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=${GOOGLE_MAPS_API_KEY}`
    let options = {
      subdomains: ['0', '1', '2', '3'],
      maxZoom: 20,
    }

    if (type === 'google_hybrid') {
      url = `https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&key=${GOOGLE_MAPS_API_KEY}`
    } else if (type === 'google_terrain') {
      url = `https://mt{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}&key=${GOOGLE_MAPS_API_KEY}`
    } else if (type === 'voyager') {
      url = 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png'
      options = {
        subdomains: 'abcd',
        maxZoom: 19,
      }
    }

    const newLayer = L.tileLayer(url, options).addTo(targetMap)
    newLayer.bringToBack()
    tileLayerRef.current = newLayer
  }

  // ================= 7. Map Initialization =================
  useEffect(() => {
    if (!mapContainerRef.current) return

    if (mapInstanceRef.current) {
      mapInstanceRef.current.remove()
      mapInstanceRef.current = null
    }

    const initialConfig =
      cityCoordinatesMap[selectedCity] ||
      cityCoordinatesMap['All Cities'] ||
      DEFAULT_CITY_COORDINATES['All Cities']

    const map = L.map(mapContainerRef.current, {
      center: [initialConfig.lat, initialConfig.lng],
      zoom: initialConfig.zoom,
      zoomControl: false,
      attributionControl: false,
    })

    updateTileLayer(mapLayerType, map)

    const markersGroup = L.layerGroup().addTo(map)
    markersLayerRef.current = markersGroup
    mapInstanceRef.current = map

    const updatePosition = () => {
      if (selectedProvider && map) {
        try {
          const pt = map.latLngToContainerPoint([selectedProvider.lat, selectedProvider.lng])
          setCalloutPoint({ x: pt.x, y: pt.y })
        } catch {}
      }
    }

    map.on('move', updatePosition)
    map.on('zoom', updatePosition)

    const timer = setTimeout(() => {
      map.invalidateSize({ animate: false })
      updatePosition()
    }, 200)

    return () => {
      clearTimeout(timer)
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove()
        mapInstanceRef.current = null
      }
    }
  }, [])

  // Switch map layer
  useEffect(() => {
    if (mapInstanceRef.current) {
      updateTileLayer(mapLayerType, mapInstanceRef.current)
    }
  }, [mapLayerType])

  // Fly to city ONLY when user explicitly changes selectedCity
  useEffect(() => {
    if (!mapInstanceRef.current || adminLocation) return
    if (prevCityRef.current === selectedCity) return
    prevCityRef.current = selectedCity

    const cityConfig = cityCoordinatesMap[selectedCity]
    if (cityConfig) {
      mapInstanceRef.current.flyTo([cityConfig.lat, cityConfig.lng], cityConfig.zoom, {
        duration: 0.8,
      })
    }
  }, [selectedCity, adminLocation, cityCoordinatesMap])

  // Debounced, loop-safe container resize observer (PREVENTS BLINKING)
  useEffect(() => {
    let resizeTimer = null
    let lastW = 0
    let lastH = 0

    const triggerResize = () => {
      if (!mapInstanceRef.current || !widgetContainerRef.current) return
      const rect = widgetContainerRef.current.getBoundingClientRect()
      // Only call invalidateSize if dimensions changed significantly (>4px)
      if (Math.abs(rect.width - lastW) > 4 || Math.abs(rect.height - lastH) > 4) {
        lastW = rect.width
        lastH = rect.height
        mapInstanceRef.current.invalidateSize({ animate: false })
      }
    }

    const debouncedResize = () => {
      if (resizeTimer) clearTimeout(resizeTimer)
      resizeTimer = setTimeout(triggerResize, 120)
    }

    window.addEventListener('resize', debouncedResize)

    let ro
    if (widgetContainerRef.current && typeof ResizeObserver !== 'undefined') {
      ro = new ResizeObserver(debouncedResize)
      ro.observe(widgetContainerRef.current)
    }

    const initialTimer = setTimeout(triggerResize, 200)

    return () => {
      if (resizeTimer) clearTimeout(resizeTimer)
      clearTimeout(initialTimer)
      window.removeEventListener('resize', debouncedResize)
      if (ro) ro.disconnect()
    }
  }, [])

  // Update callout coordinate whenever selectedProvider changes
  useEffect(() => {
    if (!mapInstanceRef.current || !selectedProvider) {
      setCalloutPoint(null)
      return
    }
    try {
      const pt = mapInstanceRef.current.latLngToContainerPoint([
        selectedProvider.lat,
        selectedProvider.lng,
      ])
      setCalloutPoint({ x: pt.x, y: pt.y })
    } catch {
      setCalloutPoint(null)
    }
  }, [selectedProvider])

  // ================= 8. Render Markers with SMART DIFFING (No flashing/blinking) =================
  useEffect(() => {
    if (!mapInstanceRef.current || !markersLayerRef.current) return

    const group = markersLayerRef.current

    // A. Render / Update Admin Location Beacon
    if (adminLocation) {
      const adminMarkerHtml = `
        <div style="position: relative; display: flex; align-items: center; justify-content: center; transform: translate(-50%, -50%);">
          <div style="position: absolute; width: 64px; height: 64px; border-radius: 50%; background: rgba(37, 99, 235, 0.25); animation: ping 2s cubic-bezier(0, 0, 0.2, 1) infinite;"></div>
          <div style="position: absolute; width: 40px; height: 40px; border-radius: 50%; background: rgba(59, 130, 246, 0.35); border: 2px solid rgba(37, 99, 235, 0.65);"></div>
          
          <div style="
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, #2563EB 0%, #1D4ED8 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 16px rgba(37, 99, 235, 0.6);
            border: 2.5px solid #FFFFFF;
            position: relative;
            z-index: 2;
          ">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>
              <circle cx="12" cy="7" r="4"/>
            </svg>
          </div>

          <div style="
            position: absolute;
            top: 36px;
            white-space: nowrap;
            background: #1E293B;
            color: #FFFFFF;
            font-size: 11px;
            font-weight: 700;
            padding: 3px 9px;
            border-radius: 8px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.3);
            border: 1px solid rgba(255,255,255,0.25);
            z-index: 4;
            letter-spacing: -0.2px;
          ">
            📍 Admin (You)
          </div>
        </div>
      `
      const adminIcon = L.divIcon({
        html: adminMarkerHtml,
        className: 'admin-radar-beacon',
        iconSize: [0, 0],
      })

      if (!adminMarkerRef.current) {
        adminMarkerRef.current = L.marker([adminLocation.lat, adminLocation.lng], {
          icon: adminIcon,
          zIndexOffset: 1000,
        }).addTo(group)
      } else {
        adminMarkerRef.current.setLatLng([adminLocation.lat, adminLocation.lng])
      }
    } else if (adminMarkerRef.current) {
      group.removeLayer(adminMarkerRef.current)
      adminMarkerRef.current = null
    }

    // B. Render / Update City Center Marker (only when specific city selected and no admin GPS)
    if (selectedCity !== 'All Cities' && !adminLocation) {
      const cityConfig = cityCoordinatesMap[selectedCity]
      if (cityConfig) {
        const centerIconHtml = `
          <div style="display:flex; flex-direction:column; align-items:center; transform: translate(-50%, -50%); pointer-events:none;">
            <div style="width: 30px; height: 30px; border-radius: 50%; background: #8B53FE; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(139, 83, 254, 0.4); border: 2.5px solid #FFFFFF;">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
                <circle cx="12" cy="10" r="3"/>
              </svg>
            </div>
            <div style="margin-top: 3px; text-align: center; text-shadow: 0 1px 3px rgba(255,255,255,0.9); font-weight: 700; color: #1C2926; font-size: 12px; line-height: 1.1;">
              ${selectedCity}
              <div style="font-size: 10px; font-weight: 500; color: #566663;">${cityConfig?.nameAr || ''}</div>
            </div>
          </div>
        `
        const centerIcon = L.divIcon({
          html: centerIconHtml,
          className: 'custom-center-marker',
          iconSize: [0, 0],
        })

        if (!cityCenterMarkerRef.current) {
          cityCenterMarkerRef.current = L.marker([cityConfig.lat, cityConfig.lng], {
            icon: centerIcon,
            interactive: false,
          }).addTo(group)
        } else {
          cityCenterMarkerRef.current.setLatLng([cityConfig.lat, cityConfig.lng])
          cityCenterMarkerRef.current.setIcon(centerIcon)
        }
      }
    } else if (cityCenterMarkerRef.current) {
      group.removeLayer(cityCenterMarkerRef.current)
      cityCenterMarkerRef.current = null
    }

    // C. Render / Update Provider Markers with Diffing
    const currentProviderIds = new Set()

    filteredProviders.forEach((provider) => {
      currentProviderIds.add(provider.id)
      const isSelected = selectedProvider && selectedProvider.id === provider.id
      const isOnline = provider.isOnline
      const isSuspended = provider.isSuspended || provider.isBlocked

      const badgeBg = isOnline ? '#8B53FE' : isSuspended ? '#DC2626' : '#64748B'
      const statusDotColor = isOnline ? '#16A34A' : isSuspended ? '#EF4444' : '#94A3B8'

      const markerHtml = `
        <div class="group cursor-pointer" style="transform: translate(-50%, -50%); position: relative; display: flex; align-items: center; justify-content: center;">
          ${
            isOnline
              ? `<div style="position: absolute; width: 44px; height: 44px; border-radius: 50%; background: rgba(139, 83, 254, 0.28); animation: ping 2s cubic-bezier(0, 0, 0.2, 1) infinite;"></div>`
              : ''
          }
          <div style="
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: ${badgeBg};
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 14px rgba(0, 0, 0, 0.25);
            border: 2.5px solid #FFFFFF;
            transition: all 0.2s ease;
            position: relative;
            z-index: 2;
            ${isSelected ? 'transform: scale(1.18); box-shadow: 0 0 0 4px rgba(139, 83, 254, 0.4);' : ''}
          ">
            <svg style="transform: rotate(${provider.heading}deg);" width="16" height="16" viewBox="0 0 24 24" fill="#FFFFFF" stroke="#FFFFFF" stroke-width="1.5">
              <polygon points="3 11 22 2 13 21 11 13 3 11"/>
            </svg>
          </div>
          <div style="
            position: absolute;
            bottom: -2px;
            right: -2px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: ${statusDotColor};
            border: 2px solid #FFFFFF;
            z-index: 3;
          "></div>
        </div>
      `

      const icon = L.divIcon({
        html: markerHtml,
        className: 'provider-map-marker',
        iconSize: [34, 34],
        iconAnchor: [17, 17],
      })

      const existingMarker = markersMapRef.current.get(provider.id)
      if (existingMarker) {
        existingMarker.setLatLng([provider.lat, provider.lng])
        existingMarker.setIcon(icon)
      } else {
        const marker = L.marker([provider.lat, provider.lng], { icon })
        marker.on('click', () => {
          setSelectedProvider(provider)
          if (mapInstanceRef.current) {
            mapInstanceRef.current.panTo([provider.lat, provider.lng], { animate: true, duration: 0.5 })
          }
        })
        marker.addTo(group)
        markersMapRef.current.set(provider.id, marker)
      }
    })

    // Remove obsolete markers without destroying existing ones
    for (const [id, marker] of markersMapRef.current.entries()) {
      if (!currentProviderIds.has(id)) {
        group.removeLayer(marker)
        markersMapRef.current.delete(id)
      }
    }
  }, [filteredProviders, selectedProvider, selectedCity, cityCoordinatesMap, adminLocation])

  // Zoom and navigation handlers
  const handleZoomIn = () => {
    if (mapInstanceRef.current) mapInstanceRef.current.zoomIn()
  }

  const handleZoomOut = () => {
    if (mapInstanceRef.current) mapInstanceRef.current.zoomOut()
  }

  const handleRecenter = () => {
    if (!mapInstanceRef.current) return
    if (adminLocation) {
      mapInstanceRef.current.flyTo([adminLocation.lat, adminLocation.lng], 14, { duration: 0.8 })
      return
    }
    const cityConfig =
      cityCoordinatesMap[selectedCity] ||
      cityCoordinatesMap['All Cities'] ||
      cityCoordinatesMap.Riyadh ||
      { lat: 24.0, lng: 45.0, zoom: 6 }
    mapInstanceRef.current.flyTo([cityConfig.lat, cityConfig.lng], cityConfig.zoom, { duration: 0.8 })
  }

  const handleFocusProvider = (provider) => {
    setSelectedProvider(provider)
    if (mapInstanceRef.current) {
      mapInstanceRef.current.flyTo([provider.lat, provider.lng], 15, { duration: 0.8 })
    }
  }

  // ================= 9. Fullscreen Toggle (Native Fullscreen + CSS Fallback) =================
  const toggleFullscreen = async () => {
    const el = widgetContainerRef.current
    if (!el) return

    const isCurrentlyFull = Boolean(
      document.fullscreenElement || document.webkitFullscreenElement || isFullscreen
    )

    if (!isCurrentlyFull) {
      try {
        if (el.requestFullscreen) {
          await el.requestFullscreen()
        } else if (el.webkitRequestFullscreen) {
          await el.webkitRequestFullscreen()
        } else {
          setIsFullscreen(true)
        }
      } catch (err) {
        console.warn('Native requestFullscreen blocked, using CSS fullscreen:', err)
        setIsFullscreen(true)
      }
    } else {
      try {
        if (document.fullscreenElement || document.webkitFullscreenElement) {
          if (document.exitFullscreen) {
            await document.exitFullscreen()
          } else if (document.webkitExitFullscreen) {
            await document.webkitExitFullscreen()
          }
        }
      } catch (err) {
        console.warn('Exit fullscreen error:', err)
      }
      setIsFullscreen(false)
    }

    setTimeout(() => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.invalidateSize({ animate: false })
      }
    }, 200)
  }

  // Native fullscreen event listener (syncs with Esc key)
  useEffect(() => {
    const handleFsChange = () => {
      const isNative = Boolean(document.fullscreenElement || document.webkitFullscreenElement)
      setIsFullscreen(isNative)
      setTimeout(() => {
        if (mapInstanceRef.current) {
          mapInstanceRef.current.invalidateSize({ animate: false })
        }
      }, 150)
    }

    document.addEventListener('fullscreenchange', handleFsChange)
    document.addEventListener('webkitfullscreenchange', handleFsChange)
    return () => {
      document.removeEventListener('fullscreenchange', handleFsChange)
      document.removeEventListener('webkitfullscreenchange', handleFsChange)
    }
  }, [])

  return (
    <div className="w-full flex flex-col gap-2.5 flex-1 min-h-0">
      {/* ================= COMPACT TOP METRICS STRIP ================= */}
      <div className="w-full flex items-center justify-between shrink-0 px-1 py-0.5">
        <div className="flex items-center gap-3">
          <h1 className="text-[17px] font-bold text-[#1C2926] tracking-tight">
            Live Map & Provider Fleet Tracking
          </h1>

          {/* Real-time telemetry status badge */}
          <div className="hidden sm:flex items-center gap-1.5 px-2.5 py-0.5 bg-white border border-[#E5E7EB] rounded-full shadow-2xs">
            <span className="w-2 h-2 rounded-full bg-[#16A34A] animate-pulse" />
            <span className="text-[11px] font-medium text-[#1C2926]">Live Telemetry</span>
          </div>

          {/* Admin GPS Mode active pill */}
          {adminLocation && (
            <div className="flex items-center gap-1.5 px-2.5 py-0.5 bg-[#EFF6FF] border border-[#BFDBFE] rounded-full shadow-2xs">
              <span className="w-2 h-2 rounded-full bg-[#2563EB] animate-ping" />
              <span className="text-[11px] font-bold text-[#1D4ED8]">
                Admin GPS Active (Nearby Services Mode)
              </span>
              <button
                type="button"
                onClick={handleClearAdminLocation}
                title="Reset to City Center"
                className="w-4 h-4 rounded-full hover:bg-[#DBEAFE] flex items-center justify-center text-[#1D4ED8] ml-0.5 cursor-pointer"
              >
                <X className="w-3 h-3" />
              </button>
            </div>
          )}
        </div>

        {/* 4 Compact Stat Pills */}
        <div className="flex items-center gap-2">
          {/* Online */}
          <button
            type="button"
            onClick={() => setActiveStatFilter(activeStatFilter === 'online' ? 'all' : 'online')}
            className={`px-3 py-1 rounded-xl text-[12px] font-bold flex items-center gap-1.5 transition-all cursor-pointer border ${
              activeStatFilter === 'online'
                ? 'bg-[#16A34A] text-white border-[#16A34A] shadow-xs'
                : 'bg-white text-[#16A34A] border-[#E5E7EB] hover:border-[#16A34A]'
            }`}
          >
            <span
              className={`w-2 h-2 rounded-full ${
                activeStatFilter === 'online' ? 'bg-white' : 'bg-[#16A34A] animate-pulse'
              }`}
            />
            <span>{statsData.online} Online</span>
          </button>

          {/* Offline */}
          <button
            type="button"
            onClick={() => setActiveStatFilter(activeStatFilter === 'offline' ? 'all' : 'offline')}
            className={`px-3 py-1 rounded-xl text-[12px] font-semibold flex items-center gap-1.5 transition-all cursor-pointer border ${
              activeStatFilter === 'offline'
                ? 'bg-[#616166] text-white border-[#616166] shadow-xs'
                : 'bg-white text-[#616166] border-[#E5E7EB] hover:border-[#94A3B8]'
            }`}
          >
            <span className="w-2 h-2 rounded-full bg-[#94A3B8]" />
            <span>{statsData.offline} Offline</span>
          </button>

          {/* Active Requests */}
          <div className="px-3 py-1 rounded-xl text-[12px] font-semibold bg-[#F4EFFE] text-[#8B53FE] border border-[#DECFFC] flex items-center gap-1.5 shadow-2xs">
            <ClipboardCheck className="w-3.5 h-3.5" />
            <span>{statsData.requests} Requests</span>
          </div>

          {/* Coverage Cities */}
          <div className="hidden md:flex px-3 py-1 rounded-xl text-[12px] font-semibold bg-[#FEF3E2] text-[#D97706] border border-[#FDE68A] items-center gap-1.5 shadow-2xs">
            <MapPin className="w-3.5 h-3.5" />
            <span>{statsData.coverage} Cities</span>
          </div>
        </div>
      </div>

      {/* ================= FULL SCREEN MAP CONTAINER WITH INTEGRATED PINNED FILTERS ================= */}
      <div
        ref={widgetContainerRef}
        className={`w-full bg-white flex flex-col overflow-hidden relative transition-all duration-200 ${
          isFullscreen
            ? 'fixed inset-0 z-[99999] w-screen h-screen rounded-none border-none shadow-none m-0 p-0'
            : 'rounded-2xl border border-[#EBEBEB] shadow-sm h-[calc(100vh-175px)] min-h-[540px]'
        }`}
      >
        {/* ================= PINNED TOP CONTROLS & FILTER BAR ================= */}
        <div className="w-full h-[52px] px-3.5 bg-white border-b border-[#F0EFF5] flex items-center justify-between shrink-0 z-[500] gap-2">
          {/* Left: Search input field */}
          <div className="relative w-[240px] sm:w-[280px]">
            <Search className="w-4 h-4 text-[#8C8C94] absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search provider, ID, or phone..."
              className="w-full h-[36px] pl-9 pr-3 text-[12px] text-[#1C2926] placeholder-[#8C8C94] bg-[#F9FAFB] hover:bg-white border border-[#E5E7EB] rounded-xl focus:bg-white focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
            />
          </div>

          {/* Right: Actions & Filter Dropdowns */}
          <div className="flex items-center gap-2">
            {/* Toggle Fleet List Button */}
            <button
              type="button"
              onClick={() => setShowFleetDrawer((prev) => !prev)}
              className={`h-[36px] px-3 rounded-xl text-[12px] font-semibold flex items-center gap-2 cursor-pointer transition-all border shadow-2xs ${
                showFleetDrawer
                  ? 'bg-[#8B53FE] text-white border-[#8B53FE]'
                  : 'bg-white text-[#1C2926] border-[#E5E7EB] hover:border-[#8B53FE]'
              }`}
            >
              <Radio className={`w-3.5 h-3.5 ${showFleetDrawer ? 'text-white' : 'text-[#8B53FE]'}`} />
              <span>Fleet ({filteredProviders.length})</span>
            </button>

            {/* City Filter (Includes 'All Cities' & All Settings Cities) */}
            <div className="relative">
              <button
                type="button"
                onClick={() => {
                  setOpenCityDropdown(!openCityDropdown)
                  setOpenCategoryDropdown(false)
                  setOpenLayerDropdown(false)
                }}
                className="h-[36px] px-3 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[12px] font-medium text-[#1C2926] flex items-center gap-1.5 cursor-pointer transition-colors shadow-2xs"
              >
                <MapPin className="w-3.5 h-3.5 text-[#8C8C94]" />
                <span className="max-w-[110px] truncate">{selectedCity}</span>
                <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </button>

              {openCityDropdown && (
                <div className="absolute right-0 top-10 w-52 bg-white rounded-xl shadow-xl border border-[#EBEBEB] py-1 z-[600] max-h-72 overflow-y-auto animate-in fade-in zoom-in-95 duration-100">
                  {Object.keys(cityCoordinatesMap).map((city) => {
                    const item = cityCoordinatesMap[city]
                    const isSelected = selectedCity === city
                    return (
                      <button
                        key={city}
                        type="button"
                        onClick={() => {
                          setSelectedCity(city)
                          setOpenCityDropdown(false)
                        }}
                        className={`w-full px-3.5 py-2 text-left text-[12px] flex items-center justify-between cursor-pointer transition-colors ${
                          isSelected
                            ? 'bg-[#F4EFFE] text-[#8B53FE] font-bold'
                            : 'text-[#1C2926] hover:bg-[#F9FAFB] hover:text-[#8B53FE]'
                        }`}
                      >
                        <div className="flex flex-col text-left">
                          <span className="leading-tight">{city}</span>
                          {item?.nameAr && (
                            <span className="text-[10px] text-[#8C8C94] font-arabic mt-0.5">
                              {item.nameAr}
                            </span>
                          )}
                        </div>
                        {isSelected && <Check className="w-3.5 h-3.5 text-[#8B53FE] shrink-0" />}
                      </button>
                    )
                  })}
                </div>
              )}
            </div>

            {/* Category Filter (Real Categories from Settings/API) */}
            <div className="relative">
              <button
                type="button"
                onClick={() => {
                  setOpenCategoryDropdown(!openCategoryDropdown)
                  setOpenCityDropdown(false)
                  setOpenLayerDropdown(false)
                }}
                className="h-[36px] px-3 bg-white border border-[#E5E7EB] hover:border-[#DECFFC] rounded-xl text-[12px] font-medium text-[#1C2926] flex items-center gap-1.5 cursor-pointer transition-colors shadow-2xs"
              >
                <span className="max-w-[120px] truncate">{selectedCategory}</span>
                <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </button>

              {openCategoryDropdown && (
                <div className="absolute right-0 top-10 w-52 bg-white rounded-xl shadow-xl border border-[#EBEBEB] py-1 z-[600] max-h-64 overflow-y-auto animate-in fade-in zoom-in-95 duration-100">
                  {categoriesList.map((cat) => {
                    const isSelected = selectedCategory === cat
                    return (
                      <button
                        key={cat}
                        type="button"
                        onClick={() => {
                          setSelectedCategory(cat)
                          setOpenCategoryDropdown(false)
                        }}
                        className={`w-full px-3.5 py-2 text-left text-[12px] flex items-center justify-between cursor-pointer transition-colors ${
                          isSelected
                            ? 'bg-[#F4EFFE] text-[#8B53FE] font-bold'
                            : 'text-[#1C2926] hover:bg-[#F9FAFB] hover:text-[#8B53FE]'
                        }`}
                      >
                        <span className="truncate">{cat}</span>
                        {isSelected && <Check className="w-3.5 h-3.5 text-[#8B53FE] shrink-0" />}
                      </button>
                    )
                  })}
                </div>
              )}
            </div>

            {/* Map Layer Switcher */}
            <div className="relative">
              <button
                type="button"
                onClick={() => {
                  setOpenLayerDropdown(!openLayerDropdown)
                  setOpenCityDropdown(false)
                  setOpenCategoryDropdown(false)
                }}
                className="h-[36px] px-3 bg-white border border-[#E5E7EB] hover:border-[#8B53FE] rounded-xl text-[12px] font-medium text-[#1C2926] flex items-center gap-1.5 cursor-pointer transition-colors shadow-2xs"
              >
                <Layers className="w-3.5 h-3.5 text-[#8B53FE]" />
                <span className="hidden lg:inline">
                  {mapLayerType === 'google_roadmap'
                    ? 'Google Roadmap'
                    : mapLayerType === 'google_hybrid'
                    ? 'Google Satellite'
                    : mapLayerType === 'google_terrain'
                    ? 'Google Terrain'
                    : 'Clean Pastel'}
                </span>
                <ChevronDown className="w-3.5 h-3.5 text-[#8C8C94]" />
              </button>

              {openLayerDropdown && (
                <div className="absolute right-0 top-10 w-44 bg-white rounded-xl shadow-xl border border-[#EBEBEB] py-1 z-[600] animate-in fade-in zoom-in-95 duration-100">
                  {[
                    { id: 'google_roadmap', label: 'Google Roadmap' },
                    { id: 'google_hybrid', label: 'Google Satellite' },
                    { id: 'google_terrain', label: 'Google Terrain' },
                    { id: 'voyager', label: 'Clean Pastel' },
                  ].map((layer) => (
                    <button
                      key={layer.id}
                      type="button"
                      onClick={() => {
                        setMapLayerType(layer.id)
                        setOpenLayerDropdown(false)
                      }}
                      className="w-full px-3.5 py-2 text-left text-[12px] text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                    >
                      <span>{layer.label}</span>
                      {mapLayerType === layer.id && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Instant Refresh Button (Refreshes Categories, Cities, and Live Markers) */}
            <button
              type="button"
              onClick={handleRefreshAll}
              disabled={isRefreshing}
              title="Refresh all categories, cities, and live fleet telemetry"
              className="w-[36px] h-[36px] bg-white border border-[#E5E7EB] hover:border-[#8B53FE] hover:bg-[#F9FAFB] rounded-xl flex items-center justify-center text-[#616166] hover:text-[#8B53FE] cursor-pointer transition-all shadow-2xs"
            >
              <RotateCw className={`w-4 h-4 ${isRefreshing ? 'animate-spin text-[#8B53FE]' : ''}`} />
            </button>

            {/* GPS Current Location Button (Find Nearby Services) */}
            <button
              type="button"
              onClick={handleLocateAdmin}
              disabled={isLocating}
              title={
                adminLocation
                  ? 'Re-center to your GPS location (nearby mode)'
                  : 'Detect your current GPS location to find nearby services'
              }
              className={`h-[36px] px-2.5 rounded-xl flex items-center gap-1.5 text-[12px] font-semibold cursor-pointer transition-all shadow-2xs border ${
                adminLocation
                  ? 'bg-[#2563EB] text-white border-[#2563EB] ring-2 ring-[#2563EB]/25'
                  : 'bg-white text-[#1C2926] border-[#E5E7EB] hover:border-[#2563EB] hover:text-[#2563EB]'
              }`}
            >
              <LocateFixed
                className={`w-4 h-4 ${
                  isLocating ? 'animate-spin text-[#2563EB]' : adminLocation ? 'text-white' : 'text-[#2563EB]'
                }`}
              />
              <span className="hidden sm:inline">
                {isLocating ? 'Locating...' : adminLocation ? 'GPS Active' : 'My Location'}
              </span>
            </button>

            {/* Fullscreen Button */}
            <button
              type="button"
              onClick={toggleFullscreen}
              title={isFullscreen ? 'Exit Fullscreen' : 'Expand Fullscreen'}
              className={`w-[36px] h-[36px] rounded-xl flex items-center justify-center cursor-pointer transition-all shadow-2xs border ${
                isFullscreen
                  ? 'bg-[#8B53FE] text-white border-[#8B53FE]'
                  : 'bg-white border-[#E5E7EB] text-[#616166] hover:border-[#DECFFC] hover:bg-[#F9FAFB] hover:text-[#8B53FE]'
              }`}
            >
              {isFullscreen ? (
                <Minimize2 className="w-4 h-4" />
              ) : (
                <Maximize2 className="w-4 h-4" />
              )}
            </button>
          </div>
        </div>

        {/* ================= FULL CANVAS MAP SECTION ================= */}
        <div className="w-full flex-1 min-h-0 relative bg-[#E8ECEF]">
          {/* Leaflet Map Canvas */}
          <div ref={mapContainerRef} className="w-full h-full z-0" />

          {/* Connected API Status Badge */}
          <div className="absolute left-3.5 bottom-3.5 z-[400] bg-white/95 backdrop-blur-xs px-2.5 py-1.5 rounded-xl border border-[#E5E7EB] shadow-md flex items-center gap-2 text-[11px] font-medium text-[#1C2926] select-none pointer-events-auto">
            <div className="w-2 h-2 rounded-full bg-[#16A34A] animate-pulse" />
            <span className="font-semibold text-[#8B53FE]">Google Maps API</span>
            <span className="text-[#8C8C94]">
              • {filteredProviders.length} Vehicles Visible
              {adminLocation && ' • Nearby Distance Active'}
            </span>
          </div>

          {/* ================= COLLAPSIBLE FLEET LIST DRAWER ================= */}
          {showFleetDrawer && (
            <div className="absolute left-3.5 top-3.5 bottom-12 w-[320px] bg-white/95 backdrop-blur-md rounded-2xl shadow-2xl border border-[#E5E7EB] z-[450] flex flex-col overflow-hidden animate-in fade-in slide-in-from-left-4 duration-200">
              <div className="p-3 border-b border-[#EBEBEB] flex items-center justify-between bg-white/80">
                <div className="flex items-center gap-2">
                  <div className="w-7 h-7 rounded-lg bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center">
                    <Radio className="w-4 h-4" />
                  </div>
                  <div>
                    <h3 className="text-[13px] font-bold text-[#1C2926]">Live Fleet Telemetry</h3>
                    <p className="text-[10px] text-[#616166]">
                      {filteredProviders.filter((p) => p.isOnline).length} Online ·{' '}
                      {filteredProviders.length} Visible
                      {adminLocation && ' (Sorted by nearest)'}
                    </p>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => setShowFleetDrawer(false)}
                  className="w-6 h-6 rounded-lg hover:bg-gray-100 flex items-center justify-center text-[#8C8C94] hover:text-[#1C2926] cursor-pointer"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </div>

              {/* Scrollable Provider Items */}
              <div className="flex-1 overflow-y-auto p-2 space-y-1.5 divide-y divide-[#F4F4F6]">
                {filteredProviders.length === 0 ? (
                  <div className="p-6 text-center text-[12px] text-[#8C8C94]">
                    No providers match the selected filters.
                  </div>
                ) : (
                  filteredProviders.map((p) => {
                    const isSelected = selectedProvider?.id === p.id
                    return (
                      <div
                        key={p.id}
                        onClick={() => handleFocusProvider(p)}
                        className={`p-2.5 rounded-xl cursor-pointer transition-all flex flex-col gap-1.5 ${
                          isSelected
                            ? 'bg-[#F4EFFE] border border-[#DECFFC]'
                            : 'hover:bg-gray-50 border border-transparent'
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2 min-w-0">
                            <span
                              className={`w-2 h-2 rounded-full shrink-0 ${
                                p.isOnline
                                  ? 'bg-[#16A34A] ring-2 ring-[#16A34A]/20'
                                  : p.isSuspended || p.isBlocked
                                  ? 'bg-[#DC2626]'
                                  : 'bg-[#94A3B8]'
                              }`}
                            />
                            <span className="text-[12px] font-bold text-[#1C2926] truncate">
                              {p.name}
                            </span>
                            <span className="text-[10px] text-[#8C8C94] font-mono">({p.id})</span>
                          </div>
                          <span
                            className={`text-[10px] font-semibold px-1.5 py-0.5 rounded-full ${
                              p.isOnline
                                ? 'bg-[#E9FBF0] text-[#16A34A]'
                                : p.isSuspended || p.isBlocked
                                ? 'bg-[#FEF2F2] text-[#DC2626]'
                                : 'bg-[#F5F5F7] text-[#616166]'
                            }`}
                          >
                            {p.status}
                          </span>
                        </div>

                        {/* Telemetry info row: Distance & GPS Time */}
                        <div className="flex items-center justify-between text-[10px] text-[#616166] pt-0.5">
                          <div className="flex items-center gap-1">
                            <Compass className={`w-3 h-3 ${p.isRelativeToAdmin ? 'text-[#2563EB]' : 'text-[#8B53FE]'}`} />
                            <span className={`font-bold ${p.isRelativeToAdmin ? 'text-[#2563EB]' : 'text-[#1C2926]'}`}>
                              {p.distanceKm} km
                            </span>
                            <span className="text-[#8C8C94]">{p.distanceLabel}</span>
                          </div>

                          <div className="flex items-center gap-1">
                            <Clock className="w-3 h-3 text-[#8C8C94]" />
                            <span
                              className={
                                p.gpsTimeInfo?.isLive ? 'font-bold text-[#16A34A]' : 'text-[#616166]'
                              }
                            >
                              {p.gpsTimeInfo?.relative || 'Just now'}
                            </span>
                          </div>
                        </div>
                      </div>
                    )
                  })
                )}
              </div>
            </div>
          )}

          {/* ================= FLOATING DYNAMIC ANCHORED CALLOUT CARD ================= */}
          {selectedProvider && (
            <div
              style={
                calloutPoint
                  ? {
                      position: 'absolute',
                      left: `${calloutPoint.x}px`,
                      top: `${calloutPoint.y - 12}px`,
                      transform: 'translate(-50%, -100%)',
                      zIndex: 460,
                    }
                  : {
                      position: 'absolute',
                      top: '25%',
                      left: '35%',
                      zIndex: 460,
                    }
              }
              className="animate-in fade-in zoom-in-95 duration-150 pointer-events-auto select-none"
            >
              <div
                onClick={() => {
                  if (onSelectProvider) {
                    onSelectProvider(selectedProvider)
                  }
                }}
                className="bg-white rounded-2xl shadow-2xl border border-[#DECFFC] p-3 flex flex-col gap-2 w-[275px] cursor-pointer hover:shadow-3xl transition-all"
              >
                {/* Status pill badge & Provider ID */}
                <div className="flex items-center justify-between">
                  <span
                    className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold ${
                      selectedProvider.isOnline
                        ? 'bg-[#E9FBF0] text-[#16A34A]'
                        : selectedProvider.isSuspended || selectedProvider.isBlocked
                        ? 'bg-[#FEF2F2] text-[#DC2626]'
                        : 'bg-[#F4EFFE] text-[#8B53FE]'
                    }`}
                  >
                    <span
                      className={`w-1.5 h-1.5 rounded-full ${
                        selectedProvider.isOnline ? 'bg-[#16A34A] animate-ping' : 'bg-[#8B53FE]'
                      }`}
                    />
                    {selectedProvider.status}
                  </span>
                  <span className="text-[10px] font-mono font-medium text-[#8C8C94]">
                    {selectedProvider.id}
                  </span>
                </div>

                {/* Provider Info Row */}
                <div className="flex items-center gap-2.5">
                  <img
                    src={selectedProvider.avatar}
                    alt={selectedProvider.name}
                    className="w-10 h-10 rounded-full object-cover ring-2 ring-purple-100 shrink-0"
                  />
                  <div className="flex flex-col min-w-0">
                    <span className="text-[13px] font-bold text-[#1C2926] leading-tight truncate">
                      {selectedProvider.name}
                    </span>
                    <span className="text-[11px] font-medium text-[#616166] truncate">
                      {selectedProvider.category}
                    </span>
                    <span className="text-[10px] text-[#8C8C94] truncate">
                      {selectedProvider.phone}
                    </span>
                  </div>
                </div>

                {/* Telemetry Metrics Row: Distance & Live GPS Time */}
                <div className="bg-[#FAF9FD] rounded-xl p-2 border border-[#EFEBF9] flex flex-col gap-1.5 text-[11px]">
                  {/* Distance */}
                  <div className="flex items-center justify-between text-[#1C2926]">
                    <span className="flex items-center gap-1.5 text-[#616166]">
                      <Compass
                        className={`w-3.5 h-3.5 ${
                          selectedProvider.isRelativeToAdmin ? 'text-[#2563EB]' : 'text-[#8B53FE]'
                        }`}
                      />
                      Distance
                    </span>
                    <span
                      className={`font-bold ${
                        selectedProvider.isRelativeToAdmin ? 'text-[#2563EB]' : 'text-[#8B53FE]'
                      }`}
                    >
                      {selectedProvider.distanceKm} km {selectedProvider.distanceLabel}
                    </span>
                  </div>

                  {/* GPS Time */}
                  <div className="flex items-center justify-between text-[#1C2926]">
                    <span className="flex items-center gap-1.5 text-[#616166]">
                      <Clock className="w-3.5 h-3.5 text-[#16A34A]" />
                      GPS Timestamp
                    </span>
                    <span
                      className={`font-semibold ${
                        selectedProvider.gpsTimeInfo?.isLive ? 'text-[#16A34A]' : 'text-[#616166]'
                      }`}
                    >
                      {selectedProvider.gpsTimeInfo?.label || 'Just now'}{' '}
                      <span className="text-[9px] text-[#8C8C94] font-normal">
                        ({selectedProvider.gpsTimeInfo?.detail})
                      </span>
                    </span>
                  </div>

                  {/* Coordinates & City */}
                  <div className="flex items-center justify-between text-[#8C8C94] text-[10px] pt-0.5 border-t border-[#F0EFF5]">
                    <span>{selectedProvider.city || 'KSA'}</span>
                    <span className="font-mono">
                      {selectedProvider.lat.toFixed(4)}°, {selectedProvider.lng.toFixed(4)}°
                    </span>
                  </div>
                </div>

                {/* Tap to Review prompt */}
                <div className="flex items-center justify-between pt-0.5 text-[11px] font-semibold text-[#8B53FE]">
                  <span>View Full Verification & Profile</span>
                  <ChevronRight className="w-4 h-4" />
                </div>
              </div>

              {/* Triangle pointer pointing to exact map marker */}
              <div className="w-0 h-0 border-l-[8px] border-l-transparent border-r-[8px] border-r-transparent border-t-[8px] border-t-white mx-auto filter drop-shadow-sm -mt-[1px]" />
            </div>
          )}

          {/* ================= FLOATING MAP CONTROLS (Bottom Right) ================= */}
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
              title={adminLocation ? 'Recenter to your GPS location' : 'Recenter Map'}
              className={`w-9 h-9 rounded-xl shadow-md border flex items-center justify-center transition-colors cursor-pointer ${
                adminLocation
                  ? 'bg-[#2563EB] border-[#2563EB] text-white hover:bg-[#1D4ED8]'
                  : 'bg-white border-[#E5E7EB] text-[#616166] hover:bg-gray-50 hover:text-[#1C2926]'
              }`}
            >
              <LocateFixed className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default LiveMapView
