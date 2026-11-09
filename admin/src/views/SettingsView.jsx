import React, { useState, useEffect, useRef } from 'react'
import {
  ShieldCheck,
  Key,
  Mail,
  Truck,
  Layers,
  Smartphone,
  Plus,
  Pencil,
  Trash2,
  Check,
  X,
  AlertCircle,
  CheckCircle2,
  Eye,
  EyeOff,
  Search,
  ChevronDown,
  ChevronsUpDown,
  Car,
  AlertTriangle,
  RotateCw,
  ArrowRight,
  Shield,
  User,
  ExternalLink,
  MapPin,
} from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import {
  fetchAdminProfile,
  updateAdminProfile,
  fetchVehicleTypes,
  createVehicleTypeApi,
  patchVehicleTypeApi,
  deleteVehicleTypeApi,
  fetchCategories,
  createCategoryApi,
  patchCategoryApi,
  deleteCategoryApi,
  fetchCitiesApi,
  createCityApi,
  patchCityApi,
  deleteCityApi,
  translateTextApi,
} from '../api/admin'
import { BRAND_COLORS } from '../theme/branding'

// Known Saudi Cities preset for instant coordinates & translation lookup
const KNOWN_SAUDI_CITIES_PRESET = {
  riyadh: { name: 'Riyadh', nameAr: 'الرياض', lat: 24.7136, lng: 46.6753, zoom: 12 },
  jeddah: { name: 'Jeddah', nameAr: 'جدة', lat: 21.5433, lng: 39.1728, zoom: 12 },
  makkah: { name: 'Makkah', nameAr: 'مكة المكرمة', lat: 21.3891, lng: 39.8579, zoom: 13 },
  mecca: { name: 'Makkah', nameAr: 'مكة المكرمة', lat: 21.3891, lng: 39.8579, zoom: 13 },
  madinah: { name: 'Madinah', nameAr: 'المدينة المنورة', lat: 24.5247, lng: 39.5692, zoom: 13 },
  medina: { name: 'Madinah', nameAr: 'المدينة المنورة', lat: 24.5247, lng: 39.5692, zoom: 13 },
  dammam: { name: 'Dammam', nameAr: 'الدمام', lat: 26.4207, lng: 50.0888, zoom: 12 },
  khobar: { name: 'Khobar', nameAr: 'الخبر', lat: 26.2818, lng: 50.2084, zoom: 13 },
  tabuk: { name: 'Tabuk', nameAr: 'تبوك', lat: 28.3835, lng: 36.5662, zoom: 12 },
  taif: { name: 'Taif', nameAr: 'الطائف', lat: 21.4373, lng: 40.5127, zoom: 12 },
  abha: { name: 'Abha', nameAr: 'أبها', lat: 18.2164, lng: 42.5053, zoom: 12 },
  buraidah: { name: 'Buraidah', nameAr: 'بريدة', lat: 26.3592, lng: 43.9818, zoom: 12 },
  jubail: { name: 'Jubail', nameAr: 'الجبيل', lat: 27.0046, lng: 49.6601, zoom: 12 },
  hail: { name: 'Hail', nameAr: 'حائل', lat: 27.5216, lng: 41.6907, zoom: 12 },
  najran: { name: 'Najran', nameAr: 'نجران', lat: 17.4924, lng: 44.1277, zoom: 12 },
  yanbu: { name: 'Yanbu', nameAr: 'ينبع', lat: 24.0895, lng: 38.0637, zoom: 12 },
  jazan: { name: 'Jazan', nameAr: 'جازان', lat: 16.8892, lng: 42.5706, zoom: 12 },
  alahsa: { name: 'Al Ahsa', nameAr: 'الأحساء', lat: 25.3835, lng: 49.5862, zoom: 12 },
}

// Default starter vehicle types if database is newly initialized
const DEFAULT_PRESET_VEHICLE_TYPES = [
  { name: 'Flatbed Tow Truck', nameAr: 'سطحة عادية', icon: 'truck', sortOrder: 1 },
  { name: 'Hydraulic Low Flatbed', nameAr: 'سطحة هيدروليك', icon: 'truck', sortOrder: 2 },
  { name: 'Wheel Lift Tow Truck', nameAr: 'ونش رفع', icon: 'truck', sortOrder: 3 },
  { name: 'Heavy Duty Recovery Truck', nameAr: 'سطحة ثقيل', icon: 'truck', sortOrder: 4 },
  { name: 'Covered Carrier', nameAr: 'سطحة مغلقة VIP', icon: 'truck', sortOrder: 5 },
  { name: 'Motorbike Carrier', nameAr: 'سطحة دبابات', icon: 'truck', sortOrder: 6 },
]

export function quickTranslateArabic(text) {
  if (!text) return ''
  const t = text.trim()
  if (t.match(/[\u0600-\u06FF]/)) return t
  const m = t.match(/\(([\u0600-\u06FF\s]+)\)/)
  if (m) return m[1].trim()

  const map = {
    // Heavy machinery & specialized vehicles
    loader: 'لودر / شيول',
    'wheel loader': 'شيول / لودر',
    'backhoe loader': 'حفار لودر',
    'water tank': 'وايت ماء / صهريج مياه',
    'water tanker': 'وايت ماء / صهريج مياه',
    watertank: 'وايت ماء',
    tank: 'خزان / صهريج',
    tanker: 'صهريج / وايت',
    'sewage tanker': 'وايت صرف صحي',
    'sewage tank': 'وايت صرف صحي',
    'fuel tanker': 'صهريج وقود / بنزين',
    'fuel tank': 'خزان وقود',
    crane: 'كرين / رافعة',
    'mobile crane': 'كرين متنقل',
    forklift: 'رافعة شوكية',
    bulldozer: 'بلدوزر',
    excavator: 'حفار',
    dumper: 'شاحنة قلاب',
    'dump truck': 'شاحنة قلاب',
    tipper: 'شاحنة تفريغ',
    trailer: 'تريلا / مقطورة',
    lowbed: 'لوبد / سطحة منخفضة',
    generator: 'مولد كهرباء',
    'air compressor': 'كمبروسر هواء',

    // Roadside & Towing
    workhouse: 'ورشة عمل',
    workshop: 'ورشة عمل',
    'work house': 'ورشة عمل',
    garage: 'كراج / ورشة',
    'car repair': 'إصلاح وصيانة السيارات',
    'auto repair': 'إصلاح وصيانة السيارات',
    maintenance: 'صيانة دورية',
    service: 'خدمة',
    services: 'خدمات',
    flatbed: 'سطحة',
    'flatbed truck': 'سطحة',
    'flatbed tow truck': 'سطحة عادية',
    'hydraulic low flatbed': 'سطحة هيدروليك',
    'wheel lift tow truck': 'ونش رفع',
    'heavy duty recovery truck': 'سطحة ثقيل',
    'heavy duty recovery': 'إنقاذ وسحب ثقيل',
    'covered carrier': 'سطحة مغلقة VIP',
    'motorbike carrier': 'سطحة دبابات',
    towing: 'ونش',
    'towing truck': 'ونش',
    'tow truck': 'ونش سحب',
    ride: 'توصيل',
    'ride sedan': 'توصيل',
    pickup: 'وانيت',
    'pickup truck': 'وانيت',
    van: 'فان',
    'family van': 'فان',
    truck: 'شاحنة',
    suv: 'دفع رباعي',
    emergency: 'طوارئ',
    'emergency beacon': 'طوارئ الطريق',
    mechanic: 'ميكانيكي',
    electrician: 'كهربائي سيارات',
    battery: 'شحن بطارية',
    'battery jumpstart': 'اشتراك بطارية',
    tire: 'إصلاح إطارات',
    'tire repair': 'إصلاح بنشر',
    'flat tire': 'تبديل إطار',
    fuel: 'توصيل وقود',
    'car wash': 'غسيل سيارات',
    'oil change': 'تغيير زيت',
    'dent repair': 'سمكرة وتعديل',
    'window tinting': 'تظليل زجاج',
  }

  const lower = t.toLowerCase().replace(/\s*\([\u0600-\u06FF\s]+\)\s*/g, ' ').trim()
  if (map[lower]) return map[lower]

  // Check subphrase / keywords
  for (const [k, v] of Object.entries(map)) {
    if (lower === k || lower.startsWith(k + ' ') || lower.endsWith(' ' + k)) {
      return v
    }
  }

  // Transliteration for popular automotive terms
  const translit = {
    loader: 'لودر',
    crane: 'كرين',
    trailer: 'تريلا',
    tank: 'صهريج',
    tanker: 'وايت',
    service: 'خدمة',
    recovery: 'إنقاذ',
  }
  for (const [en, ar] of Object.entries(translit)) {
    if (lower.includes(en)) return ar
  }

  return 'خدمة معتمدة'
}

export function SettingsView() {
  const { admin, updateAdmin } = useAuth()

  // Main Active Tab: 'security' | 'vehicles' | 'categories' | 'preview'
  const [activeTab, setActiveTab] = useState('security')

  // Global Alert Message
  const [alert, setAlert] = useState(null) // { type: 'success' | 'error', message: string }
  const showAlert = (message, type = 'success') => {
    setAlert({ type, message })
    setTimeout(() => {
      setAlert(null)
    }, 5000)
  }

  // ================= 1. SECURITY / ADMIN PROFILE STATE =================
  const [adminName, setAdminName] = useState(admin?.name || 'Administrator')
  const [adminEmail, setAdminEmail] = useState(admin?.email || 'admin@qareeb.com')
  const [currentEmailInput, setCurrentEmailInput] = useState(admin?.email || '')
  const [isUpdatingEmail, setIsUpdatingEmail] = useState(false)

  // Password fields
  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showCurrentPass, setShowCurrentPass] = useState(false)
  const [showNewPass, setShowNewPass] = useState(false)
  const [showConfirmPass, setShowConfirmPass] = useState(false)
  const [isUpdatingPassword, setIsUpdatingPassword] = useState(false)

  // ================= 2. VEHICLE TYPES STATE =================
  const [vehicleTypes, setVehicleTypes] = useState([])
  const [loadingVehicles, setLoadingVehicles] = useState(false)
  const [vehicleSearch, setVehicleSearch] = useState('')
  const [vehicleStatusFilter, setVehicleStatusFilter] = useState('All')
  const [vehicleModalOpen, setVehicleModalOpen] = useState(false)
  const [editingVehicle, setEditingVehicle] = useState(null)
  const [vehicleFormName, setVehicleFormName] = useState('')
  const [vehicleFormNameAr, setVehicleFormNameAr] = useState('')
  const [vehicleFormCategory, setVehicleFormCategory] = useState('')
  const [vehicleFormStatus, setVehicleFormStatus] = useState('Active')
  const [vehicleFormSort, setVehicleFormSort] = useState(0)
  const [vehicleSaving, setVehicleSaving] = useState(false)
  const [deletingVehicle, setDeletingVehicle] = useState(null)

  // ================= 3. CATEGORIES STATE =================
  const [categories, setCategories] = useState([])
  const [loadingCategories, setLoadingCategories] = useState(false)
  const [categorySearch, setCategorySearch] = useState('')
  const [categoryModalOpen, setCategoryModalOpen] = useState(false)
  const [editingCategory, setEditingCategory] = useState(null)
  const [categoryFormName, setCategoryFormName] = useState('')
  const [categoryFormNameAr, setCategoryFormNameAr] = useState('')
  const [categoryFormSubtitle, setCategoryFormSubtitle] = useState('')
  const [categoryFormSubtitleAr, setCategoryFormSubtitleAr] = useState('')
  const [categoryFormStatus, setCategoryFormStatus] = useState('Active')
  const [categorySaving, setCategorySaving] = useState(false)
  const [deletingCategory, setDeletingCategory] = useState(null)

  // ================= 3B. CITIES STATE =================
  const [cities, setCities] = useState([])
  const [loadingCities, setLoadingCities] = useState(false)
  const [citySearch, setCitySearch] = useState('')
  const [cityStatusFilter, setCityStatusFilter] = useState('All')
  const [cityModalOpen, setCityModalOpen] = useState(false)
  const [editingCity, setEditingCity] = useState(null)
  const [cityFormName, setCityFormName] = useState('')
  const [cityFormNameAr, setCityFormNameAr] = useState('')
  const [cityFormLat, setCityFormLat] = useState('')
  const [cityFormLng, setCityFormLng] = useState('')
  const [cityFormZoom, setCityFormZoom] = useState('13')
  const [cityFormStatus, setCityFormStatus] = useState('Active')
  const [cityFormSort, setCityFormSort] = useState(0)
  const [citySaving, setCitySaving] = useState(false)
  const [deletingCity, setDeletingCity] = useState(null)
  const [translatingCity, setTranslatingCity] = useState(false)
  const cityTranslateTimer = useRef(null)

  // ================= 4. ONBOARDING PREVIEW STATE =================
  const [previewLang, setPreviewLang] = useState('ar') // 'ar' | 'en' (defaults to Arabic matching user screen)
  const [previewSelectedCategory, setPreviewSelectedCategory] = useState('')
  const [previewSelectedVehicleType, setPreviewSelectedVehicleType] = useState('')
  const [previewCategoryOpen, setPreviewCategoryOpen] = useState(false)
  const [previewVehicleOpen, setPreviewVehicleOpen] = useState(false)

  // Auto-translate state & refs
  const [translatingVehicle, setTranslatingVehicle] = useState(false)
  const [translatingCategory, setTranslatingCategory] = useState(false)
  const vehicleTranslateTimer = useRef(null)
  const categoryTranslateTimer = useRef(null)

  const handleTranslateVehicle = async (text) => {
    if (!text || !text.trim()) return
    setTranslatingVehicle(true)
    try {
      const quick = quickTranslateArabic(text)
      setVehicleFormNameAr(quick)
      const online = await translateTextApi(text)
      if (online && online.trim()) {
        setVehicleFormNameAr(online.trim())
      }
    } finally {
      setTranslatingVehicle(false)
    }
  }

  const handleTranslateCategory = async (text) => {
    if (!text || !text.trim()) return
    setTranslatingCategory(true)
    try {
      const quick = quickTranslateArabic(text)
      setCategoryFormNameAr(quick)
      const online = await translateTextApi(text)
      if (online && online.trim()) {
        setCategoryFormNameAr(online.trim())
      }
    } finally {
      setTranslatingCategory(false)
    }
  }

  // Load Admin Profile
  useEffect(() => {
    async function loadProfile() {
      try {
        const res = await fetchAdminProfile()
        const data = res?.data || res
        if (data?.email) {
          setAdminEmail(data.email)
          setCurrentEmailInput(data.email)
          if (data.name) setAdminName(data.name)
        }
      } catch {
        // Fallback to authContext state
        if (admin?.email) {
          setAdminEmail(admin.email)
          setCurrentEmailInput(admin.email)
        }
      }
    }
    loadProfile()
  }, [admin])

  // Load Vehicle Types
  const loadVehicleTypes = async () => {
    try {
      setLoadingVehicles(true)
      const res = await fetchVehicleTypes()
      const items = Array.isArray(res?.data)
        ? res.data
        : Array.isArray(res?.items)
        ? res.items
        : Array.isArray(res)
        ? res
        : []
      setVehicleTypes(items)
    } catch {
      setVehicleTypes([])
    } finally {
      setLoadingVehicles(false)
    }
  }

  // Load Categories
  const loadCategories = async () => {
    try {
      setLoadingCategories(true)
      const res = await fetchCategories()
      const items = Array.isArray(res?.data)
        ? res.data
        : Array.isArray(res?.items)
        ? res.items
        : Array.isArray(res)
        ? res
        : []
      setCategories(items)
    } catch {
      setCategories([])
    } finally {
      setLoadingCategories(false)
    }
  }

  // Load Operational Cities
  const loadCities = async () => {
    try {
      setLoadingCities(true)
      const res = await fetchCitiesApi()
      const items = Array.isArray(res?.data)
        ? res.data
        : Array.isArray(res?.items)
        ? res.items
        : Array.isArray(res)
        ? res
        : []
      setCities(items)
    } catch {
      setCities([])
    } finally {
      setLoadingCities(false)
    }
  }

  useEffect(() => {
    loadVehicleTypes()
    loadCategories()
    loadCities()
  }, [])

  // ================= EMAIL UPDATE HANDLER =================
  const handleUpdateEmail = async (e) => {
    e.preventDefault()
    if (!currentEmailInput.trim()) {
      showAlert('Please enter a valid email address.', 'error')
      return
    }
    if (currentEmailInput.trim().toLowerCase() === adminEmail.toLowerCase()) {
      showAlert('New email is the same as the current email.', 'error')
      return
    }

    try {
      setIsUpdatingEmail(true)
      const res = await updateAdminProfile({ email: currentEmailInput.trim().toLowerCase() })
      const updatedData = res?.data || res
      const nextEmail = updatedData.admin?.email || currentEmailInput.trim().toLowerCase()
      setAdminEmail(nextEmail)
      if (updateAdmin) {
        updateAdmin({ email: nextEmail }, updatedData.token)
      }
      showAlert('Admin email updated successfully!')
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Failed to update email'
      showAlert(msg, 'error')
    } finally {
      setIsUpdatingEmail(false)
    }
  }

  // ================= PASSWORD UPDATE HANDLER =================
  const handleUpdatePassword = async (e) => {
    e.preventDefault()
    if (!currentPassword) {
      showAlert('Please enter your current password.', 'error')
      return
    }
    if (!newPassword || newPassword.length < 6) {
      showAlert('New password must be at least 6 characters long.', 'error')
      return
    }
    if (newPassword !== confirmPassword) {
      showAlert('New password and confirm password do not match.', 'error')
      return
    }

    try {
      setIsUpdatingPassword(true)
      const res = await updateAdminProfile({
        currentPassword,
        newPassword,
      })
      const updatedData = res?.data || res
      if (updateAdmin && updatedData.token) {
        updateAdmin({}, updatedData.token)
      }
      setCurrentPassword('')
      setNewPassword('')
      setConfirmPassword('')
      showAlert('Admin password changed successfully!')
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Failed to update password'
      showAlert(msg, 'error')
    } finally {
      setIsUpdatingPassword(false)
    }
  }

  // ================= VEHICLE TYPES CRUD =================
  const handleOpenAddVehicle = () => {
    setEditingVehicle(null)
    setVehicleFormName('')
    setVehicleFormNameAr('')
    setVehicleFormCategory(categories[0]?.id || '')
    setVehicleFormStatus('Active')
    setVehicleFormSort(vehicleTypes.length + 1)
    setVehicleModalOpen(true)
  }

  const handleOpenEditVehicle = (vt) => {
    setEditingVehicle(vt)
    setVehicleFormName(vt.name)
    setVehicleFormNameAr(vt.nameAr || vt.name_ar || quickTranslateArabic(vt.name))
    setVehicleFormCategory(vt.categoryId || vt.category_id || '')
    setVehicleFormStatus(vt.isEnabled === false ? 'Inactive' : 'Active')
    setVehicleFormSort(vt.sortOrder ?? 0)
    setVehicleModalOpen(true)
  }

  const handleSaveVehicleType = async () => {
    if (!vehicleFormName.trim()) {
      showAlert('Vehicle type name is required.', 'error')
      return
    }

    try {
      setVehicleSaving(true)
      const finalAr = vehicleFormNameAr.trim() || quickTranslateArabic(vehicleFormName)
      const payload = {
        name: vehicleFormName.trim(),
        nameAr: finalAr,
        name_ar: finalAr,
        categoryId: vehicleFormCategory || null,
        isEnabled: vehicleFormStatus === 'Active',
        sortOrder: Number(vehicleFormSort) || 0,
      }

      if (editingVehicle?.id) {
        await patchVehicleTypeApi(editingVehicle.id, payload)
        showAlert('Vehicle type updated successfully!')
      } else {
        await createVehicleTypeApi(payload)
        showAlert('New vehicle type added successfully!')
      }

      setVehicleModalOpen(false)
      loadVehicleTypes()
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Error saving vehicle type'
      showAlert(msg, 'error')
    } finally {
      setVehicleSaving(false)
    }
  }

  const handleToggleVehicleStatus = async (vt) => {
    const nextStatus = !vt.isEnabled
    try {
      // Optimistic update
      setVehicleTypes((prev) =>
        prev.map((item) => (item.id === vt.id ? { ...item, isEnabled: nextStatus } : item))
      )
      if (vt.id) {
        await patchVehicleTypeApi(vt.id, { isEnabled: nextStatus })
      }
      showAlert(`Vehicle type marked as ${nextStatus ? 'Active' : 'Inactive'}.`)
    } catch {
      loadVehicleTypes()
    }
  }

  const handleConfirmDeleteVehicle = async () => {
    if (!deletingVehicle) return
    try {
      if (deletingVehicle.id) {
        await deleteVehicleTypeApi(deletingVehicle.id)
      }
      setVehicleTypes((prev) => prev.filter((item) => item.id !== deletingVehicle.id))
      showAlert('Vehicle type deleted successfully.')
    } catch (err) {
      const msg = err.response?.data?.message || 'Could not delete vehicle type'
      showAlert(msg, 'error')
    } finally {
      setDeletingVehicle(null)
    }
  }

  // ================= CATEGORIES CRUD =================
  const handleOpenAddCategory = () => {
    setEditingCategory(null)
    setCategoryFormName('')
    setCategoryFormNameAr('')
    setCategoryFormSubtitle('')
    setCategoryFormSubtitleAr('')
    setCategoryFormStatus('Active')
    setCategoryModalOpen(true)
  }

  const handleOpenEditCategory = (cat) => {
    setEditingCategory(cat)
    setCategoryFormName(cat.name)
    setCategoryFormNameAr(cat.nameAr || cat.name_ar || quickTranslateArabic(cat.name))
    setCategoryFormSubtitle(cat.subtitle || '')
    setCategoryFormSubtitleAr(cat.subtitleAr || cat.subtitle_ar || '')
    setCategoryFormStatus(cat.isEnabled === false || cat.is_enabled === false ? 'Inactive' : 'Active')
    setCategoryModalOpen(true)
  }

  const handleSaveCategory = async () => {
    if (!categoryFormName.trim()) {
      showAlert('Category name is required.', 'error')
      return
    }

    try {
      setCategorySaving(true)
      const finalAr = categoryFormNameAr.trim() || quickTranslateArabic(categoryFormName)
      const payload = {
        name: categoryFormName.trim(),
        nameAr: finalAr,
        name_ar: finalAr,
        subtitle: categoryFormSubtitle.trim() || undefined,
        subtitleAr: categoryFormSubtitleAr.trim() || undefined,
        subtitle_ar: categoryFormSubtitleAr.trim() || undefined,
        isEnabled: categoryFormStatus === 'Active',
      }

      if (editingCategory?.id) {
        await patchCategoryApi(editingCategory.id, payload)
        showAlert('Service category updated successfully!')
      } else {
        await createCategoryApi(payload)
        showAlert('New service category added successfully!')
      }

      setCategoryModalOpen(false)
      loadCategories()
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Error saving category'
      showAlert(msg, 'error')
    } finally {
      setCategorySaving(false)
    }
  }

  const handleToggleCategoryStatus = async (cat) => {
    const isCurrentlyEnabled = cat.isEnabled !== false && cat.is_enabled !== false
    const nextStatus = !isCurrentlyEnabled
    try {
      setCategories((prev) =>
        prev.map((item) =>
          item.id === cat.id ? { ...item, isEnabled: nextStatus, is_enabled: nextStatus } : item
        )
      )
      if (cat.id) {
        await patchCategoryApi(cat.id, { isEnabled: nextStatus })
      }
      showAlert(`Category marked as ${nextStatus ? 'Active' : 'Inactive'}.`)
    } catch {
      loadCategories()
    }
  }

  const handleConfirmDeleteCategory = async () => {
    if (!deletingCategory) return
    try {
      await deleteCategoryApi(deletingCategory.id)
      setCategories((prev) => prev.filter((item) => item.id !== deletingCategory.id))
      showAlert('Category deleted successfully.')
    } catch (err) {
      const msg = err.response?.data?.message || 'Could not delete category'
      showAlert(msg, 'error')
    } finally {
      setDeletingCategory(null)
    }
  }

  // ================= CITIES HANDLERS =================
  const handleOpenAddCity = () => {
    setEditingCity(null)
    setCityFormName('')
    setCityFormNameAr('')
    setCityFormLat('')
    setCityFormLng('')
    setCityFormZoom('13')
    setCityFormStatus('Active')
    setCityFormSort(cities.length + 1)
    setCityModalOpen(true)
  }

  const handleOpenEditCity = (city) => {
    setEditingCity(city)
    setCityFormName(city.name || '')
    setCityFormNameAr(city.nameAr || city.name_ar || '')
    setCityFormLat(city.lat != null ? String(city.lat) : String(city.latitude || ''))
    setCityFormLng(city.lng != null ? String(city.lng) : String(city.longitude || ''))
    setCityFormZoom(String(city.zoom || 13))
    setCityFormStatus(city.isEnabled !== false && city.is_enabled !== false ? 'Active' : 'Inactive')
    setCityFormSort(city.sortOrder || city.sort_order || 0)
    setCityModalOpen(true)
  }

  const handleTranslateCity = async (text) => {
    if (!text || !text.trim()) return
    setTranslatingCity(true)
    try {
      const key = text.trim().toLowerCase().replace(/[^a-z]/g, '')
      const preset = KNOWN_SAUDI_CITIES_PRESET[key]
      if (preset && preset.nameAr) {
        setCityFormNameAr(preset.nameAr)
        if (!cityFormLat && preset.lat) setCityFormLat(String(preset.lat))
        if (!cityFormLng && preset.lng) setCityFormLng(String(preset.lng))
        setTranslatingCity(false)
        return
      }
      const online = await translateTextApi(text)
      if (online && online.trim()) {
        setCityFormNameAr(online.trim())
      }
    } catch {} finally {
      setTranslatingCity(false)
    }
  }

  const handleSaveCity = async () => {
    if (!cityFormName.trim()) {
      showAlert('City name is required', 'error')
      return
    }
    const lat = parseFloat(cityFormLat)
    const lng = parseFloat(cityFormLng)
    if (isNaN(lat) || isNaN(lng)) {
      showAlert('Valid latitude and longitude numbers are required', 'error')
      return
    }

    setCitySaving(true)
    try {
      const isEnabled = cityFormStatus === 'Active'
      const payload = {
        name: cityFormName.trim(),
        nameAr: cityFormNameAr.trim() || undefined,
        name_ar: cityFormNameAr.trim() || undefined,
        latitude: lat,
        longitude: lng,
        lat: lat,
        lng: lng,
        zoom: parseInt(cityFormZoom, 10) || 13,
        isEnabled,
        is_enabled: isEnabled,
        sortOrder: Number(cityFormSort) || 0,
      }

      if (editingCity) {
        await patchCityApi(editingCity.id, payload)
        showAlert(`City "${payload.name}" updated successfully.`)
      } else {
        await createCityApi(payload)
        showAlert(`City "${payload.name}" added to coverage list successfully.`)
      }

      setCityModalOpen(false)
      loadCities()
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Error saving city'
      showAlert(msg, 'error')
    } finally {
      setCitySaving(false)
    }
  }

  const handleToggleCityStatus = async (city) => {
    const nextStatus = !(city.isEnabled !== false && city.is_enabled !== false)
    try {
      setCities((prev) =>
        prev.map((item) =>
          item.id === city.id ? { ...item, isEnabled: nextStatus, is_enabled: nextStatus } : item
        )
      )
      await patchCityApi(city.id, { isEnabled: nextStatus, is_enabled: nextStatus })
      showAlert(`City marked as ${nextStatus ? 'Active' : 'Inactive'}.`)
    } catch {
      loadCities()
    }
  }

  const handleConfirmDeleteCity = async () => {
    if (!deletingCity) return
    try {
      await deleteCityApi(deletingCity.id)
      setCities((prev) => prev.filter((item) => item.id !== deletingCity.id))
      showAlert('City removed from coverage successfully.')
    } catch (err) {
      const msg = err.response?.data?.message || 'Could not delete city'
      showAlert(msg, 'error')
    } finally {
      setDeletingCity(null)
    }
  }

  const filteredCities = cities.filter((c) => {
    if (cityStatusFilter !== 'All') {
      const isActive = c.isEnabled !== false && c.is_enabled !== false
      if (cityStatusFilter === 'Active' && !isActive) return false
      if (cityStatusFilter === 'Inactive' && isActive) return false
    }
    if (citySearch.trim()) {
      const q = citySearch.toLowerCase()
      const matchName = (c.name || '').toLowerCase().includes(q)
      const matchAr = (c.nameAr || c.name_ar || '').toLowerCase().includes(q)
      return matchName || matchAr
    }
    return true
  })

  // Filtered Vehicle Types
  const filteredVehicles = vehicleTypes.filter((vt) => {
    if (vehicleStatusFilter !== 'All') {
      const isActive = vt.isEnabled !== false
      if (vehicleStatusFilter === 'Active' && !isActive) return false
      if (vehicleStatusFilter === 'Inactive' && isActive) return false
    }
    if (vehicleSearch.trim()) {
      const q = vehicleSearch.toLowerCase()
      const matchName = vt.name.toLowerCase().includes(q)
      const matchCat = (vt.categoryName || '').toLowerCase().includes(q)
      return matchName || matchCat
    }
    return true
  })

  // Filtered Categories
  const filteredCategories = categories.filter((c) => {
    if (categorySearch.trim()) {
      const q = categorySearch.toLowerCase()
      const matchName = c.name.toLowerCase().includes(q)
      const matchSub = (c.subtitle || '').toLowerCase().includes(q)
      return matchName || matchSub
    }
    return true
  })

  // Enabled options for Onboarding Preview
  const enabledCategories = categories.filter(
    (c) => c.isEnabled !== false && c.is_enabled !== false
  )
  const enabledVehicleTypes = vehicleTypes.filter((v) => v.isEnabled !== false)

  return (
    <div className="w-full max-w-[1084px] flex flex-col gap-5 shrink-0 select-none pb-12 animate-in fade-in duration-200">
      {/* ================= ALERT BANNER ================= */}
      {alert && (
        <div
          className={`w-full px-5 py-3.5 rounded-2xl flex items-center justify-between text-[13px] font-medium shadow-xs transition-all ${
            alert.type === 'error'
              ? 'bg-[#FEF2F2] border border-[#FCA5A5] text-[#DC2626]'
              : 'bg-[#F0FDF4] border border-[#86EFAC] text-[#16A34A]'
          }`}
        >
          <div className="flex items-center gap-2.5">
            {alert.type === 'error' ? (
              <AlertCircle className="w-4 h-4 shrink-0 text-[#DC2626]" />
            ) : (
              <CheckCircle2 className="w-4 h-4 shrink-0 text-[#16A34A]" />
            )}
            <span>{alert.message}</span>
          </div>
          <button
            type="button"
            onClick={() => setAlert(null)}
            className="p-1 rounded-md hover:bg-black/5 cursor-pointer"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* ================= 1ST ROW: TITLE & OVERVIEW ================= */}
      <div className="w-full flex items-center justify-between shrink-0">
        <div className="flex flex-col">
          <h1 className="text-[22px] font-bold text-[#1C2926] tracking-tight leading-tight">
            Settings & System Configuration
          </h1>
          <p className="text-[13px] text-[#566663] font-normal mt-0.5 leading-snug">
            Manage admin security credentials, vehicle classifications, and onboarding dropdown options.
          </p>
        </div>

        {/* Quick status pills */}
        <div className="flex items-center gap-2">
          <div className="bg-white border border-[#E5E7EB] rounded-xl px-3 py-1.5 flex items-center gap-2 text-[12px] shadow-2xs">
            <span className="w-2 h-2 rounded-full bg-[#16A34A]" />
            <span className="text-[#616166]">Admin:</span>
            <span className="font-semibold text-[#1C2926] max-w-[160px] truncate">{adminEmail}</span>
          </div>
          <div className="bg-[#F4EFFE] border border-[#DECFFC] rounded-xl px-3 py-1.5 flex items-center gap-2 text-[12px]">
            <Truck className="w-3.5 h-3.5 text-[#8B53FE]" />
            <span className="text-[#8B53FE] font-semibold">{vehicleTypes.length} Vehicles</span>
          </div>
          <div className="bg-[#F4EFFE] border border-[#DECFFC] rounded-xl px-3 py-1.5 flex items-center gap-2 text-[12px]">
            <MapPin className="w-3.5 h-3.5 text-[#8B53FE]" />
            <span className="text-[#8B53FE] font-semibold">{cities.length} Cities</span>
          </div>
        </div>
      </div>

      {/* ================= 2ND ROW: TAB NAVIGATION CARDS ================= */}
      <div className="w-full grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
        {[
          {
            id: 'security',
            title: 'Account & Security',
            desc: 'Change admin email & password',
            icon: ShieldCheck,
          },
          {
            id: 'vehicles',
            title: 'Vehicle Types',
            desc: `${vehicleTypes.length} types for onboarding`,
            icon: Truck,
          },
          {
            id: 'categories',
            title: 'Service Categories',
            desc: `${categories.length} active service categories`,
            icon: Layers,
          },
          {
            id: 'cities',
            title: 'Cities & Coverage',
            desc: `${cities.length} operational map cities`,
            icon: MapPin,
          },
          {
            id: 'preview',
            title: 'Onboarding Preview',
            desc: 'Live driver dropdowns simulator',
            icon: Smartphone,
          },
        ].map((tab) => {
          const isActive = activeTab === tab.id
          const TabIcon = tab.icon

          return (
            <button
              key={tab.id}
              type="button"
              onClick={() => setActiveTab(tab.id)}
              className={`p-4 rounded-[16px] border text-left transition-all cursor-pointer flex flex-col justify-between h-[96px] ${
                isActive
                  ? 'bg-white border-[#8B53FE] shadow-sm ring-1 ring-[#8B53FE]/30'
                  : 'bg-white border-[#EBEBEB] hover:border-[#D1D5DB] shadow-2xs'
              }`}
            >
              <div className="flex items-center justify-between w-full">
                <div
                  className={`w-8 h-8 rounded-xl flex items-center justify-center ${
                    isActive ? 'bg-[#F4EFFE] text-[#8B53FE]' : 'bg-[#F9FAFB] text-[#616166]'
                  }`}
                >
                  <TabIcon className="w-4 h-4" />
                </div>
                {isActive && (
                  <span className="w-2 h-2 rounded-full bg-[#8B53FE]" />
                )}
              </div>
              <div>
                <h4
                  className={`text-[13px] font-semibold leading-tight ${
                    isActive ? 'text-[#8B53FE]' : 'text-[#1C2926]'
                  }`}
                >
                  {tab.title}
                </h4>
                <p className="text-[11px] text-[#8C8C94] mt-0.5 truncate">{tab.desc}</p>
              </div>
            </button>
          )
        })}
      </div>

      {/* ================= 3RD ROW: ACTIVE TAB CONTENT ================= */}

      {/* ===== TAB 1: ACCOUNT & SECURITY ===== */}
      {activeTab === 'security' && (
        <div className="w-full flex flex-col gap-4 animate-in fade-in duration-150">
          {/* Admin Profile Overview Banner */}
          <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] p-5 shadow-xs flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-[#8B53FE] to-[#7032F0] text-white flex items-center justify-center font-bold text-xl shadow-xs">
                {adminName ? adminName.charAt(0).toUpperCase() : 'A'}
              </div>
              <div className="flex flex-col">
                <div className="flex items-center gap-2">
                  <h3 className="text-[16px] font-bold text-[#1C2926] leading-tight">{adminName}</h3>
                  <span className="px-2 py-0.5 bg-[#F4EFFE] text-[#8B53FE] text-[11px] font-semibold rounded-full border border-[#DECFFC]">
                    Super Admin
                  </span>
                  <span className="px-2 py-0.5 bg-[#E9FBF0] text-[#16A34A] text-[11px] font-semibold rounded-full border border-[#BBF7D0]">
                    Active
                  </span>
                </div>
                <p className="text-[13px] text-[#566663] mt-0.5">
                  Primary administrator account with full privileges across Qareeb platform.
                </p>
                <div className="flex items-center gap-3 mt-1.5 text-[12px] text-[#8C8C94]">
                  <span>Email: <strong className="text-[#1C2926]">{adminEmail}</strong></span>
                  <span>•</span>
                  <span>Role: Administrator</span>
                </div>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <div className="px-3 py-1.5 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB] text-[12px] text-[#616166] flex items-center gap-1.5">
                <Shield className="w-3.5 h-3.5 text-[#16A34A]" />
                <span>Protected by 256-bit JWT</span>
              </div>
            </div>
          </div>

          <div className="w-full grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Change Email Card */}
            <div className="bg-white rounded-[20px] border border-[#EBEBEB] p-6 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-3 pb-4 border-b border-[#F0EFF5]">
                  <div className="w-10 h-10 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center shrink-0">
                    <Mail className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-[15px] font-bold text-[#1C2926]">Change Admin Email</h3>
                    <p className="text-[12px] text-[#566663]">Update the primary email used to log in to Admin Panel</p>
                  </div>
                </div>

                <form onSubmit={handleUpdateEmail} className="mt-5 space-y-4">
                  <div>
                    <label className="block text-[12px] font-medium text-[#1C2926] mb-1.5">
                      Current Email Address
                    </label>
                    <div className="relative">
                      <input
                        type="text"
                        disabled
                        value={adminEmail}
                        className="w-full h-[42px] px-3.5 bg-[#F9FAFB] border border-[#E5E7EB] rounded-xl text-[13px] text-[#616166] cursor-not-allowed"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-[12px] font-medium text-[#1C2926] mb-1.5">
                      New Email Address <span className="text-[#DC2626]">*</span>
                    </label>
                    <div className="relative">
                      <Mail className="w-4 h-4 text-[#8C8C94] absolute left-3 top-1/2 -translate-y-1/2" />
                      <input
                        type="email"
                        required
                        value={currentEmailInput}
                        onChange={(e) => setCurrentEmailInput(e.target.value)}
                        placeholder="e.g. admin@qareeb.com"
                        className="w-full h-[42px] pl-9.5 pr-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] placeholder-[#8C8C94] focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
                      />
                    </div>
                    <p className="text-[11px] text-[#8C8C94] mt-1.5">
                      You will use this new email address for all future admin logins.
                    </p>
                  </div>

                  <div className="pt-2">
                    <button
                      type="submit"
                      disabled={isUpdatingEmail}
                      className="w-full h-[42px] bg-[#8B53FE] hover:bg-[#7839EE] disabled:opacity-60 text-white rounded-xl text-[13px] font-semibold flex items-center justify-center gap-2 cursor-pointer transition-colors shadow-sm"
                    >
                      {isUpdatingEmail ? (
                        <>
                          <RotateCw className="w-4 h-4 animate-spin" />
                          <span>Updating Email...</span>
                        </>
                      ) : (
                        <>
                          <Check className="w-4 h-4 stroke-[2.5]" />
                          <span>Save New Email</span>
                        </>
                      )}
                    </button>
                  </div>
                </form>
              </div>
            </div>

            {/* Change Password Card */}
            <div className="bg-white rounded-[20px] border border-[#EBEBEB] p-6 shadow-xs flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-3 pb-4 border-b border-[#F0EFF5]">
                  <div className="w-10 h-10 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center shrink-0">
                    <Key className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-[15px] font-bold text-[#1C2926]">Change Admin Password</h3>
                    <p className="text-[12px] text-[#566663]">Ensure your account is protected with a strong password</p>
                  </div>
                </div>

                <form onSubmit={handleUpdatePassword} className="mt-5 space-y-3.5">
                  {/* Current Password */}
                  <div>
                    <label className="block text-[12px] font-medium text-[#1C2926] mb-1.5">
                      Current Password <span className="text-[#DC2626]">*</span>
                    </label>
                    <div className="relative">
                      <input
                        type={showCurrentPass ? 'text' : 'password'}
                        required
                        value={currentPassword}
                        onChange={(e) => setCurrentPassword(e.target.value)}
                        placeholder="Enter current password"
                        className="w-full h-[40px] pl-3.5 pr-10 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] placeholder-[#8C8C94] focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
                      />
                      <button
                        type="button"
                        onClick={() => setShowCurrentPass(!showCurrentPass)}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-[#8C8C94] hover:text-[#1C2926]"
                      >
                        {showCurrentPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                    </div>
                  </div>

                  {/* New Password */}
                  <div>
                    <label className="block text-[12px] font-medium text-[#1C2926] mb-1.5">
                      New Password <span className="text-[#DC2626]">*</span>
                    </label>
                    <div className="relative">
                      <input
                        type={showNewPass ? 'text' : 'password'}
                        required
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                        placeholder="Minimum 6 characters"
                        className="w-full h-[40px] pl-3.5 pr-10 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] placeholder-[#8C8C94] focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
                      />
                      <button
                        type="button"
                        onClick={() => setShowNewPass(!showNewPass)}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-[#8C8C94] hover:text-[#1C2926]"
                      >
                        {showNewPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                    </div>
                  </div>

                  {/* Confirm Password */}
                  <div>
                    <label className="block text-[12px] font-medium text-[#1C2926] mb-1.5">
                      Confirm New Password <span className="text-[#DC2626]">*</span>
                    </label>
                    <div className="relative">
                      <input
                        type={showConfirmPass ? 'text' : 'password'}
                        required
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        placeholder="Re-enter new password"
                        className={`w-full h-[40px] pl-3.5 pr-10 bg-white border rounded-xl text-[13px] text-[#1C2926] placeholder-[#8C8C94] focus:outline-none transition-all ${
                          confirmPassword && confirmPassword !== newPassword
                            ? 'border-[#DC2626] focus:border-[#DC2626]'
                            : 'border-[#E5E7EB] focus:border-[#8B53FE]'
                        }`}
                      />
                      <button
                        type="button"
                        onClick={() => setShowConfirmPass(!showConfirmPass)}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-[#8C8C94] hover:text-[#1C2926]"
                      >
                        {showConfirmPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                    </div>
                    {confirmPassword && confirmPassword !== newPassword && (
                      <p className="text-[11px] text-[#DC2626] mt-1">Passwords do not match</p>
                    )}
                  </div>

                  <div className="pt-2">
                    <button
                      type="submit"
                      disabled={isUpdatingPassword}
                      className="w-full h-[42px] bg-[#8B53FE] hover:bg-[#7839EE] disabled:opacity-60 text-white rounded-xl text-[13px] font-semibold flex items-center justify-center gap-2 cursor-pointer transition-colors shadow-sm"
                    >
                      {isUpdatingPassword ? (
                        <>
                          <RotateCw className="w-4 h-4 animate-spin" />
                          <span>Updating Password...</span>
                        </>
                      ) : (
                        <>
                          <Key className="w-4 h-4 stroke-[2.5]" />
                          <span>Update Password</span>
                        </>
                      )}
                    </button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ===== TAB 2: VEHICLE TYPES ===== */}
      {activeTab === 'vehicles' && (
        <div className="w-full flex flex-col gap-4 animate-in fade-in duration-150">
          {/* Controls Bar */}
          <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] p-4 shadow-xs flex items-center justify-between gap-4">
            <div className="flex items-center gap-3 flex-1 max-w-[400px]">
              <div className="relative w-full">
                <Search className="w-4 h-4 text-[#8C8C94] absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
                <input
                  type="text"
                  value={vehicleSearch}
                  onChange={(e) => setVehicleSearch(e.target.value)}
                  placeholder="Search vehicle type name..."
                  className="w-full h-[38px] pl-9 pr-3 text-[13px] text-[#1C2926] placeholder-[#8C8C94] bg-[#FFFFFF] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
                />
              </div>

              {/* Status filter */}
              <div className="flex items-center bg-[#F9FAFB] border border-[#E5E7EB] rounded-xl p-0.5">
                {['All', 'Active', 'Inactive'].map((st) => (
                  <button
                    key={st}
                    type="button"
                    onClick={() => setVehicleStatusFilter(st)}
                    className={`h-7 px-2.5 rounded-lg text-[11px] font-semibold transition-all cursor-pointer ${
                      vehicleStatusFilter === st
                        ? 'bg-white text-[#8B53FE] shadow-2xs'
                        : 'text-[#616166] hover:text-[#1C2926]'
                    }`}
                  >
                    {st}
                  </button>
                ))}
              </div>
            </div>

            <div className="flex items-center gap-2.5">
              <button
                type="button"
                onClick={handleOpenAddVehicle}
                className="h-[38px] px-4 bg-[#8B53FE] hover:bg-[#7839EE] text-white rounded-xl text-[13px] font-semibold flex items-center gap-2 cursor-pointer transition-colors shadow-sm"
              >
                <Plus className="w-4 h-4 stroke-[2.5]" />
                <span>Add Vehicle Type</span>
              </button>
            </div>
          </div>

          {/* Vehicle Types Table */}
          <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] shadow-xs overflow-hidden">
            {/* Table Header */}
            <div className="h-12 bg-[#F9FAFB] border-b border-[#F0EFF5] px-6 flex items-center text-[12px] font-semibold text-[#616166]">
              <div className="flex-[3] min-w-0">Vehicle Type Name</div>
              <div className="flex-[2] min-w-0">Service Category</div>
              <div className="flex-[1] min-w-0">Sort Order</div>
              <div className="flex-[1.2] min-w-0">Status</div>
              <div className="w-24 text-right">Actions</div>
            </div>

            {/* Table Body */}
            <div className="divide-y divide-[#F0EFF5]">
              {loadingVehicles ? (
                <div className="py-12 flex flex-col items-center justify-center text-[#8C8C94]">
                  <RotateCw className="w-6 h-6 animate-spin text-[#8B53FE] mb-2" />
                  <span className="text-xs">Loading vehicle types...</span>
                </div>
              ) : filteredVehicles.length === 0 ? (
                <div className="py-12 flex flex-col items-center justify-center text-center">
                  <div className="w-12 h-12 rounded-2xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center mb-3">
                    <Truck className="w-6 h-6" />
                  </div>
                  <p className="text-[14px] font-semibold text-[#1C2926]">No vehicle types found</p>
                  <p className="text-[12px] text-[#616166] mt-1 max-w-sm">
                    Click "+ Add Vehicle Type" to define vehicle types that appear in driver onboarding dropdowns.
                  </p>
                  <button
                    type="button"
                    onClick={handleOpenAddVehicle}
                    className="mt-4 px-4 py-2 bg-[#8B53FE] text-white rounded-xl text-xs font-semibold hover:bg-[#7839EE] cursor-pointer"
                  >
                    + Add Vehicle Type
                  </button>
                </div>
              ) : (
                filteredVehicles.map((vt) => {
                  const isActive = vt.isEnabled !== false

                  return (
                    <div
                      key={vt.id}
                      className="px-6 py-3.5 flex items-center hover:bg-[#FBFBFC] transition-colors"
                    >
                      <div className="flex-[3] min-w-0 flex items-center gap-3 pr-4">
                        <div className="w-9 h-9 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center shrink-0 border border-[#DECFFC]">
                          <Truck className="w-4 h-4" />
                        </div>
                        <div className="flex flex-col min-w-0">
                          <div className="flex items-center gap-2">
                            <span className="text-[13px] font-semibold text-[#1C2926] truncate">
                              {vt.name}
                            </span>
                            {(vt.nameAr || vt.name_ar) && (
                              <span
                                dir="rtl"
                                className="text-[11px] font-medium text-[#8B53FE] bg-[#F4EFFE] border border-[#DECFFC] px-2 py-0.5 rounded-md font-arabic shrink-0"
                              >
                                {vt.nameAr || vt.name_ar}
                              </span>
                            )}
                          </div>
                          <span className="text-[11px] text-[#8C8C94] truncate">
                            Slug: {vt.slug || vt.name.toLowerCase().replace(/\s+/g, '-')}
                          </span>
                        </div>
                      </div>

                      <div className="flex-[2] min-w-0 pr-4">
                        <span className="px-2.5 py-1 bg-[#F9FAFB] border border-[#E5E7EB] text-[#566663] text-[12px] font-medium rounded-lg truncate inline-block max-w-[200px]">
                          {vt.categoryName || 'General / All Categories'}
                        </span>
                      </div>

                      <div className="flex-[1] min-w-0 text-[13px] font-medium text-[#616166] pr-4">
                        #{vt.sortOrder ?? 0}
                      </div>

                      <div className="flex-[1.2] min-w-0 pr-4">
                        <button
                          type="button"
                          onClick={() => handleToggleVehicleStatus(vt)}
                          className={`px-2.5 py-1 text-[11px] font-semibold rounded-full border cursor-pointer transition-colors ${
                            isActive
                              ? 'bg-[#E9FBF0] text-[#16A34A] border-[#BBF7D0] hover:bg-[#DCFCE7]'
                              : 'bg-[#FEF2F2] text-[#DC2626] border-[#FECACA] hover:bg-[#FEE2E2]'
                          }`}
                        >
                          {isActive ? 'Active' : 'Inactive'}
                        </button>
                      </div>

                      <div className="w-24 flex items-center justify-end gap-1.5">
                        <button
                          type="button"
                          onClick={() => handleOpenEditVehicle(vt)}
                          title="Edit Vehicle Type"
                          className="w-8 h-8 rounded-lg flex items-center justify-center text-[#8B53FE] hover:bg-[#F4EFFE] transition-colors cursor-pointer"
                        >
                          <Pencil className="w-4 h-4 stroke-[1.8]" />
                        </button>
                        <button
                          type="button"
                          onClick={() => setDeletingVehicle(vt)}
                          title="Delete Vehicle Type"
                          className="w-8 h-8 rounded-lg flex items-center justify-center text-[#DC2626] hover:bg-[#FEE2E2] transition-colors cursor-pointer"
                        >
                          <Trash2 className="w-4 h-4 stroke-[1.8]" />
                        </button>
                      </div>
                    </div>
                  )
                })
              )}
            </div>

            {/* Table Footer */}
            <div className="px-6 py-3 bg-[#F9FAFB] border-t border-[#F0EFF5] flex items-center justify-between text-[12px] text-[#616166]">
              <span>Showing {filteredVehicles.length} of {vehicleTypes.length} vehicle types</span>
              <span className="text-[#8B53FE] font-medium">All active types appear directly in Onboarding dropdown</span>
            </div>
          </div>
        </div>
      )}

      {/* ===== TAB 3: SERVICE CATEGORIES ===== */}
      {activeTab === 'categories' && (
        <div className="w-full flex flex-col gap-4 animate-in fade-in duration-150">
          {/* Controls Bar */}
          <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] p-4 shadow-xs flex items-center justify-between gap-4">
            <div className="relative w-full max-w-[360px]">
              <Search className="w-4 h-4 text-[#8C8C94] absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                type="text"
                value={categorySearch}
                onChange={(e) => setCategorySearch(e.target.value)}
                placeholder="Search category name..."
                className="w-full h-[38px] pl-9 pr-3 text-[13px] text-[#1C2926] placeholder-[#8C8C94] bg-[#FFFFFF] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
              />
            </div>

            <div className="flex items-center gap-2.5">
              <button
                type="button"
                onClick={handleOpenAddCategory}
                className="h-[38px] px-4 bg-[#8B53FE] hover:bg-[#7839EE] text-white rounded-xl text-[13px] font-semibold flex items-center gap-2 cursor-pointer transition-colors shadow-sm"
              >
                <Plus className="w-4 h-4 stroke-[2.5]" />
                <span>Add Category</span>
              </button>
            </div>
          </div>

          {/* Categories Grid */}
          <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] p-5 shadow-xs">
            {loadingCategories ? (
              <div className="py-12 flex flex-col items-center justify-center text-[#8C8C94]">
                <RotateCw className="w-6 h-6 animate-spin text-[#8B53FE] mb-2" />
                <span className="text-xs">Loading categories...</span>
              </div>
            ) : filteredCategories.length === 0 ? (
              <div className="py-12 flex flex-col items-center justify-center text-center">
                <div className="w-12 h-12 rounded-2xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center mb-3">
                  <Layers className="w-6 h-6" />
                </div>
                <p className="text-[14px] font-semibold text-[#1C2926]">No service categories found</p>
                <p className="text-[12px] text-[#616166] mt-1 max-w-sm">
                  Add service categories so providers can choose their field during registration.
                </p>
                <button
                  type="button"
                  onClick={handleOpenAddCategory}
                  className="mt-4 px-4 py-2 bg-[#8B53FE] text-white rounded-xl text-xs font-semibold hover:bg-[#7839EE] cursor-pointer"
                >
                  + Add Category
                </button>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3.5">
                {filteredCategories.map((cat) => {
                  const isActive = cat.isEnabled !== false && cat.is_enabled !== false

                  return (
                    <div
                      key={cat.id}
                      className="p-4 rounded-xl border border-[#EBEBEB] hover:border-[#8B53FE] transition-all bg-white shadow-2xs flex flex-col justify-between group"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div className="w-10 h-10 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center shrink-0 border border-[#DECFFC]">
                          <Layers className="w-5 h-5" />
                        </div>

                        <div className="flex items-center gap-1.5">
                          <button
                            type="button"
                            onClick={() => handleToggleCategoryStatus(cat)}
                            className={`px-2 py-0.5 text-[10px] font-bold rounded-full border cursor-pointer ${
                              isActive
                                ? 'bg-[#E9FBF0] text-[#16A34A] border-[#BBF7D0]'
                                : 'bg-[#FEF2F2] text-[#DC2626] border-[#FECACA]'
                            }`}
                          >
                            {isActive ? 'Active' : 'Inactive'}
                          </button>
                          <button
                            type="button"
                            onClick={() => handleOpenEditCategory(cat)}
                            className="w-7 h-7 rounded-lg flex items-center justify-center text-[#8C8C94] hover:text-[#8B53FE] hover:bg-[#F4EFFE] transition-colors"
                          >
                            <Pencil className="w-3.5 h-3.5" />
                          </button>
                          <button
                            type="button"
                            onClick={() => setDeletingCategory(cat)}
                            className="w-7 h-7 rounded-lg flex items-center justify-center text-[#8C8C94] hover:text-[#DC2626] hover:bg-[#FEE2E2] transition-colors"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </div>

                      <div className="mt-3">
                        <div className="flex items-center justify-between gap-2">
                          <h4 className="text-[14px] font-semibold text-[#1C2926] leading-tight truncate">
                            {cat.name}
                          </h4>
                          {(cat.nameAr || cat.name_ar) && (
                            <span
                              dir="rtl"
                              className="text-[11px] font-medium text-[#8B53FE] bg-[#F4EFFE] border border-[#DECFFC] px-2 py-0.5 rounded-md font-arabic shrink-0"
                            >
                              {cat.nameAr || cat.name_ar}
                            </span>
                          )}
                        </div>
                        {cat.subtitle && (
                          <p className="text-[11px] text-[#8C8C94] mt-0.5 truncate">{cat.subtitle}</p>
                        )}
                      </div>

                      <div className="mt-3 pt-2.5 border-t border-[#F0EFF5] flex items-center justify-between text-[11px] text-[#8C8C94]">
                        <span>Slug: {cat.slug || cat.name.toLowerCase()}</span>
                        <span className="text-[#8B53FE] font-medium">Onboarding ready</span>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </div>
      )}

      {/* ===== TAB: CITIES MANAGEMENT ===== */}
      {activeTab === 'cities' && (
        <div className="w-full flex flex-col gap-4 animate-in fade-in duration-150">
          {/* Controls Bar */}
          <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] p-4 shadow-xs flex items-center justify-between gap-4">
            <div className="relative w-full max-w-[360px]">
              <Search className="w-4 h-4 text-[#8C8C94] absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                type="text"
                value={citySearch}
                onChange={(e) => setCitySearch(e.target.value)}
                placeholder="Search city name in English or Arabic..."
                className="w-full h-[38px] pl-9 pr-3 text-[13px] text-[#1C2926] placeholder-[#8C8C94] bg-[#FFFFFF] border border-[#E5E7EB] rounded-xl focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE] transition-all"
              />
            </div>

            <div className="flex items-center gap-2.5">
              <select
                value={cityStatusFilter}
                onChange={(e) => setCityStatusFilter(e.target.value)}
                className="h-[38px] px-3 bg-[#FFFFFF] border border-[#E5E7EB] rounded-xl text-[13px] text-[#616166] focus:outline-none focus:border-[#8B53FE] cursor-pointer"
              >
                <option value="All">All Cities</option>
                <option value="Active">Active Only</option>
                <option value="Inactive">Inactive</option>
              </select>

              <button
                type="button"
                onClick={handleOpenAddCity}
                className="h-[38px] px-4 bg-[#8B53FE] hover:bg-[#7839EE] text-white rounded-xl text-[13px] font-semibold flex items-center gap-2 cursor-pointer transition-colors shadow-sm"
              >
                <Plus className="w-4 h-4 stroke-[2.5]" />
                <span>Add City</span>
              </button>
            </div>
          </div>

          {/* Cities Grid */}
          <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] p-5 shadow-xs">
            {loadingCities ? (
              <div className="py-12 flex flex-col items-center justify-center text-[#8C8C94]">
                <RotateCw className="w-6 h-6 animate-spin text-[#8B53FE] mb-2" />
                <span className="text-xs">Loading operational cities...</span>
              </div>
            ) : filteredCities.length === 0 ? (
              <div className="py-12 flex flex-col items-center justify-center text-center">
                <div className="w-12 h-12 rounded-2xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center mb-3">
                  <MapPin className="w-6 h-6" />
                </div>
                <p className="text-[14px] font-semibold text-[#1C2926]">No operational cities found</p>
                <p className="text-[12px] text-[#616166] mt-1 max-w-sm">
                  Add cities to expand application coverage and enable Live Map navigation filtering.
                </p>
                <button
                  type="button"
                  onClick={handleOpenAddCity}
                  className="mt-4 px-4 py-2 bg-[#8B53FE] text-white rounded-xl text-xs font-semibold hover:bg-[#7839EE] cursor-pointer"
                >
                  + Add City
                </button>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3.5">
                {filteredCities.map((city) => {
                  const isActive = city.isEnabled !== false && city.is_enabled !== false

                  return (
                    <div
                      key={city.id}
                      className="p-4 rounded-xl border border-[#EBEBEB] hover:border-[#8B53FE] transition-all bg-white shadow-2xs flex flex-col justify-between group"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div className="w-10 h-10 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center shrink-0 border border-[#DECFFC]">
                          <MapPin className="w-5 h-5" />
                        </div>

                        <div className="flex items-center gap-1.5">
                          <button
                            type="button"
                            onClick={() => handleToggleCityStatus(city)}
                            className={`px-2 py-0.5 text-[10px] font-bold rounded-full border cursor-pointer ${
                              isActive
                                ? 'bg-[#E9FBF0] text-[#16A34A] border-[#BBF7D0]'
                                : 'bg-[#FEF2F2] text-[#DC2626] border-[#FECACA]'
                            }`}
                          >
                            {isActive ? 'Active' : 'Inactive'}
                          </button>
                          <button
                            type="button"
                            onClick={() => handleOpenEditCity(city)}
                            className="w-7 h-7 rounded-lg flex items-center justify-center text-[#8C8C94] hover:text-[#8B53FE] hover:bg-[#F4EFFE] transition-colors"
                          >
                            <Pencil className="w-3.5 h-3.5" />
                          </button>
                          <button
                            type="button"
                            onClick={() => setDeletingCity(city)}
                            className="w-7 h-7 rounded-lg flex items-center justify-center text-[#8C8C94] hover:text-[#DC2626] hover:bg-[#FEE2E2] transition-colors"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </div>

                      <div className="mt-3">
                        <div className="flex items-center justify-between gap-2">
                          <h4 className="text-[14px] font-semibold text-[#1C2926] leading-tight truncate">
                            {city.name}
                          </h4>
                          {(city.nameAr || city.name_ar) && (
                            <span
                              dir="rtl"
                              className="text-[11px] font-medium text-[#8B53FE] bg-[#F4EFFE] border border-[#DECFFC] px-2 py-0.5 rounded-md font-arabic shrink-0"
                            >
                              {city.nameAr || city.name_ar}
                            </span>
                          )}
                        </div>
                        <p className="text-[11px] text-[#8C8C94] mt-1 flex items-center gap-1.5">
                          <span>Lat: {city.lat ?? city.latitude}</span>
                          <span>•</span>
                          <span>Lng: {city.lng ?? city.longitude}</span>
                        </p>
                      </div>

                      <div className="mt-3 pt-2.5 border-t border-[#F0EFF5] flex items-center justify-between text-[11px] text-[#8C8C94]">
                        <span>Zoom: {city.zoom || 13}</span>
                        <span className="text-[#8B53FE] font-medium">Live Map filter synced</span>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </div>
      )}

      {/* ===== TAB 4: ONBOARDING LIVE PREVIEW ===== */}
      {activeTab === 'preview' && (
        <div className="w-full bg-white rounded-[20px] border border-[#EBEBEB] p-6 shadow-xs flex flex-col md:flex-row gap-8 items-center justify-between animate-in fade-in duration-150">
          {/* Left: Explanation */}
          <div className="flex-1 flex flex-col gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center">
              <Smartphone className="w-5 h-5" />
            </div>
            <h3 className="text-[18px] font-bold text-[#1C2926]">
              Real-time Provider Onboarding Dropdowns
            </h3>
            <p className="text-[13px] text-[#566663] leading-relaxed">
              When a new towing provider or driver signs up on the mobile app, they select their{' '}
              <strong className="text-[#1C2926]">Service Category</strong> and{' '}
              <strong className="text-[#1C2926]">Vehicle Type</strong> right here.
            </p>

            <div className="space-y-2 mt-2">
              <div className="flex items-center gap-2.5 text-[13px] text-[#1C2926]">
                <div className="w-5 h-5 rounded-full bg-[#E9FBF0] text-[#16A34A] flex items-center justify-center shrink-0">
                  <Check className="w-3.5 h-3.5 stroke-[2.5]" />
                </div>
                <span>
                  <strong>{enabledCategories.length} Service Categories</strong> actively loaded for dropdown selection
                </span>
              </div>
              <div className="flex items-center gap-2.5 text-[13px] text-[#1C2926]">
                <div className="w-5 h-5 rounded-full bg-[#E9FBF0] text-[#16A34A] flex items-center justify-center shrink-0">
                  <Check className="w-3.5 h-3.5 stroke-[2.5]" />
                </div>
                <span>
                  <strong>{enabledVehicleTypes.length} Vehicle Types</strong> actively loaded for vehicle dropdown
                </span>
              </div>
            </div>

            <div className="p-3.5 rounded-xl bg-[#F9FAFB] border border-[#E5E7EB] text-[12px] text-[#616166] mt-3">
              💡 <strong>Instant Sync:</strong> Any category or vehicle type you add or toggle in the previous tabs is immediately synced with the onboarding screen backend API.
            </div>
          </div>

          {/* Right: Mobile Mockup Matching Exactly User Image */}
          <div className="w-[340px] shrink-0 bg-[#F4F4F6] p-3 rounded-[36px] shadow-lg border border-[#E5E7EB]">
            <div className="w-full bg-white rounded-[28px] overflow-hidden p-5 flex flex-col gap-4 border border-[#EFF0ED] relative min-h-[460px]">
              {/* Notch / Speaker bar */}
              <div className="w-20 h-1 bg-gray-200 rounded-full mx-auto mb-1" />

              {/* Language Switcher for Preview */}
              <div className="flex items-center justify-between pb-2 border-b border-[#F0EFF5]">
                <span className="text-[11px] font-semibold text-[#8C8C94] uppercase tracking-wider">Language</span>
                <div className="flex items-center bg-[#F4EFFE] p-0.5 rounded-lg border border-[#DECFFC]">
                  <button
                    type="button"
                    onClick={() => setPreviewLang('ar')}
                    className={`px-2 py-0.5 text-[11px] font-bold rounded-md transition-all cursor-pointer ${
                      previewLang === 'ar' ? 'bg-[#8B53FE] text-white shadow-xs' : 'text-[#8B53FE] hover:text-[#7839EE]'
                    }`}
                  >
                    العربية
                  </button>
                  <button
                    type="button"
                    onClick={() => setPreviewLang('en')}
                    className={`px-2 py-0.5 text-[11px] font-bold rounded-md transition-all cursor-pointer ${
                      previewLang === 'en' ? 'bg-[#8B53FE] text-white shadow-xs' : 'text-[#8B53FE] hover:text-[#7839EE]'
                    }`}
                  >
                    English
                  </button>
                </div>
              </div>

              {/* Title matching user's image */}
              <div dir={previewLang === 'ar' ? 'rtl' : 'ltr'}>
                <h4 className="text-[15px] font-bold text-[#1C2926] tracking-tight">
                  {previewLang === 'ar' ? 'تفاصيل الخدمة والمركبة' : 'Service & Vehicle Details'}
                </h4>
                <p className="text-[11px] text-[#8C8C94] mt-0.5">
                  {previewLang === 'ar' ? 'يمكنك إضافة رقم واتساب للتواصل مع العملاء.' : 'Select your service domain and vehicle classification'}
                </p>
              </div>

              {/* Field 1: Service Category Dropdown */}
              <div className="flex flex-col gap-1.5 relative" dir={previewLang === 'ar' ? 'rtl' : 'ltr'}>
                <label className="text-[12px] font-medium text-[#1C2926]">
                  {previewLang === 'ar' ? 'نوع الخدمة' : 'Service Category'}
                </label>
                <button
                  type="button"
                  onClick={() => {
                    setPreviewCategoryOpen(!previewCategoryOpen)
                    setPreviewVehicleOpen(false)
                  }}
                  className="w-full h-[46px] px-3.5 bg-[#F2F5F4] rounded-[12px] flex items-center justify-between border border-transparent hover:border-[#8B53FE] transition-colors cursor-pointer"
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    <Truck className="w-4 h-4 text-[#8C8C94] shrink-0" />
                    <span className="w-[1px] h-4 bg-[#D1D5DB]" />
                    <span className="text-[13px] text-[#1C2926] truncate font-normal">
                      {previewSelectedCategory
                        ? (previewLang === 'ar'
                            ? (categories.find(c => c.name === previewSelectedCategory)?.nameAr || categories.find(c => c.name === previewSelectedCategory)?.name_ar || previewSelectedCategory)
                            : previewSelectedCategory)
                        : (previewLang === 'ar' ? 'اختر نوع الخدمة' : 'Select Service Category')}
                    </span>
                  </div>
                  <ChevronDown className="w-4 h-4 text-[#616166] shrink-0" />
                </button>

                {/* Dropdown Options Drawer */}
                {previewCategoryOpen && (
                  <div className="absolute top-[72px] left-0 right-0 bg-white rounded-xl shadow-xl border border-[#E5E7EB] py-1 z-50 max-h-48 overflow-y-auto animate-in fade-in zoom-in-95 duration-100">
                    {enabledCategories.length === 0 ? (
                      <div className="px-3 py-2 text-[11px] text-[#8C8C94] text-center">
                        {previewLang === 'ar' ? 'لا توجد فئات خدمات متاحة' : 'No active categories. Add one in settings!'}
                      </div>
                    ) : (
                      enabledCategories.map((c) => {
                        const displayName = previewLang === 'ar' ? (c.nameAr || c.name_ar || quickTranslateArabic(c.name)) : c.name
                        return (
                          <button
                            key={c.id}
                            type="button"
                            onClick={() => {
                              setPreviewSelectedCategory(c.name)
                              setPreviewCategoryOpen(false)
                            }}
                            className="w-full px-3 py-2 text-left rtl:text-right text-[12px] font-medium text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                          >
                            <span className="truncate">{displayName}</span>
                            {previewSelectedCategory === c.name && (
                              <Check className="w-3.5 h-3.5 text-[#8B53FE]" />
                            )}
                          </button>
                        )
                      })
                    )}
                  </div>
                )}
              </div>

              {/* Field 2: Vehicle Type Dropdown */}
              <div className="flex flex-col gap-1.5 relative" dir={previewLang === 'ar' ? 'rtl' : 'ltr'}>
                <label className="text-[12px] font-medium text-[#1C2926]">
                  {previewLang === 'ar' ? 'نوع المركبة' : 'Vehicle Type'}
                </label>
                <button
                  type="button"
                  onClick={() => {
                    setPreviewVehicleOpen(!previewVehicleOpen)
                    setPreviewCategoryOpen(false)
                  }}
                  className="w-full h-[46px] px-3.5 bg-[#F2F5F4] rounded-[12px] flex items-center justify-between border border-transparent hover:border-[#8B53FE] transition-colors cursor-pointer"
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    <Car className="w-4 h-4 text-[#8C8C94] shrink-0" />
                    <span className="w-[1px] h-4 bg-[#D1D5DB]" />
                    <span className="text-[13px] text-[#1C2926] truncate font-normal">
                      {previewSelectedVehicleType
                        ? (previewLang === 'ar'
                            ? (vehicleTypes.find(v => v.name === previewSelectedVehicleType)?.nameAr || vehicleTypes.find(v => v.name === previewSelectedVehicleType)?.name_ar || previewSelectedVehicleType)
                            : previewSelectedVehicleType)
                        : (previewLang === 'ar' ? 'اختر نوع المركبة' : 'Select Vehicle Type')}
                    </span>
                  </div>
                  <ChevronDown className="w-4 h-4 text-[#616166] shrink-0" />
                </button>

                {/* Dropdown Options Drawer */}
                {previewVehicleOpen && (
                  <div className="absolute top-[72px] left-0 right-0 bg-white rounded-xl shadow-xl border border-[#E5E7EB] py-1 z-50 max-h-48 overflow-y-auto animate-in fade-in zoom-in-95 duration-100">
                    {enabledVehicleTypes.length === 0 ? (
                      <div className="px-3 py-2 text-[11px] text-[#8C8C94] text-center">
                        {previewLang === 'ar' ? 'لا توجد أنواع مركبات محددة' : 'No active vehicle types. Add one in settings!'}
                      </div>
                    ) : (
                      enabledVehicleTypes.map((v) => {
                        const displayName = previewLang === 'ar' ? (v.nameAr || v.name_ar || quickTranslateArabic(v.name)) : v.name
                        return (
                          <button
                            key={v.id}
                            type="button"
                            onClick={() => {
                              setPreviewSelectedVehicleType(v.name)
                              setPreviewVehicleOpen(false)
                            }}
                            className="w-full px-3 py-2 text-left rtl:text-right text-[12px] font-medium text-[#1C2926] hover:bg-[#F4EFFE] hover:text-[#8B53FE] flex items-center justify-between cursor-pointer"
                          >
                            <span className="truncate">{displayName}</span>
                            {previewSelectedVehicleType === v.name && (
                              <Check className="w-3.5 h-3.5 text-[#8B53FE]" />
                            )}
                          </button>
                        )
                      })
                    )}
                  </div>
                )}
              </div>

              {/* Field 3: Plate Number */}
              <div className="flex flex-col gap-1.5" dir={previewLang === 'ar' ? 'rtl' : 'ltr'}>
                <label className="text-[12px] font-medium text-[#1C2926]">
                  {previewLang === 'ar' ? 'رقم اللوحة' : 'Plate Number'}
                </label>
                <div className="w-full h-[46px] px-3.5 bg-[#F2F5F4] rounded-[12px] flex items-center text-[13px] text-[#8C8C94]">
                  {previewLang === 'ar' ? 'أدخل رقم اللوحة (مثال: أ ب ج ١٢٣٤)' : 'e.g. 1234 ABC'}
                </div>
              </div>

              {/* Continue button mockup */}
              <div className="mt-auto pt-2">
                <button
                  type="button"
                  disabled
                  className="w-full h-[44px] bg-[#8B53FE] text-white rounded-[12px] text-[13px] font-semibold flex items-center justify-center gap-1.5 shadow-sm opacity-90"
                >
                  <span>Continue</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ================= MODAL: ADD / EDIT VEHICLE TYPE ================= */}
      {vehicleModalOpen && (
        <div className="fixed inset-0 bg-black/45 backdrop-blur-xs flex items-center justify-center z-[1000] p-4 animate-in fade-in duration-100">
          <div className="bg-white rounded-[24px] max-w-md w-full p-6 shadow-2xl border border-[#EBEBEB] flex flex-col gap-4 animate-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-[#F0EFF5] pb-3">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center">
                  <Truck className="w-4 h-4" />
                </div>
                <h3 className="text-[16px] font-bold text-[#1C2926]">
                  {editingVehicle ? 'Edit Vehicle Type' : 'Add New Vehicle Type'}
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setVehicleModalOpen(false)}
                className="p-1 rounded-lg hover:bg-gray-100 text-[#8C8C94] cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-3.5">
              <div>
                <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                  Vehicle Type Name (English) <span className="text-[#DC2626]">*</span>
                </label>
                <input
                  type="text"
                  value={vehicleFormName}
                  onChange={(e) => {
                    const val = e.target.value
                    setVehicleFormName(val)
                    const quick = quickTranslateArabic(val)
                    if (!vehicleFormNameAr || vehicleFormNameAr === quickTranslateArabic(vehicleFormName)) {
                      setVehicleFormNameAr(quick)
                    }
                    if (vehicleTranslateTimer.current) clearTimeout(vehicleTranslateTimer.current)
                    if (val.trim()) {
                      vehicleTranslateTimer.current = setTimeout(async () => {
                        const online = await translateTextApi(val)
                        if (online && online.trim()) {
                          setVehicleFormNameAr(online.trim())
                        }
                      }, 500)
                    }
                  }}
                  placeholder="e.g. Hydraulic Low Flatbed, Loader"
                  className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE]"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-[12px] font-medium text-[#1C2926]">
                    Arabic Translation (الاسم بالعربية) <span className="text-[#DC2626]">*</span>
                  </label>
                  <button
                    type="button"
                    disabled={translatingVehicle || !vehicleFormName.trim()}
                    onClick={() => handleTranslateVehicle(vehicleFormName)}
                    className="text-[11px] font-semibold text-[#8B53FE] hover:text-[#7839EE] cursor-pointer flex items-center gap-1 disabled:opacity-50"
                  >
                    {translatingVehicle ? '⏳ Translating...' : '✨ Auto-Translate'}
                  </button>
                </div>
                <input
                  type="text"
                  dir="rtl"
                  value={vehicleFormNameAr}
                  onChange={(e) => setVehicleFormNameAr(e.target.value)}
                  placeholder="مثال: لودر / سطحة هيدروليك"
                  className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE] font-arabic"
                />
                <p className="text-[11px] text-[#8C8C94] mt-1">
                  This Arabic name will be displayed in the mobile onboarding dropdown when the application is set to Arabic.
                </p>
              </div>

              <div>
                <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                  Associated Service Category (Optional)
                </label>
                <select
                  value={vehicleFormCategory}
                  onChange={(e) => setVehicleFormCategory(e.target.value)}
                  className="w-full h-[40px] px-3 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                >
                  <option value="">General (Applies to all categories)</option>
                  {categories.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name} {c.nameAr ? `(${c.nameAr})` : ''}
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                    Sort Order
                  </label>
                  <input
                    type="number"
                    min="0"
                    value={vehicleFormSort}
                    onChange={(e) => setVehicleFormSort(e.target.value)}
                    className="w-full h-[40px] px-3 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                  />
                </div>

                <div>
                  <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                    Status
                  </label>
                  <select
                    value={vehicleFormStatus}
                    onChange={(e) => setVehicleFormStatus(e.target.value)}
                    className="w-full h-[40px] px-3 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                  >
                    <option value="Active">Active</option>
                    <option value="Inactive">Inactive</option>
                  </select>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-3 border-t border-[#F0EFF5]">
              <button
                type="button"
                onClick={() => setVehicleModalOpen(false)}
                className="px-4 py-2 border border-[#E5E7EB] text-[#616166] text-[13px] font-medium rounded-xl hover:bg-gray-50 cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={vehicleSaving}
                onClick={handleSaveVehicleType}
                className="px-5 py-2 bg-[#8B53FE] hover:bg-[#7839EE] disabled:opacity-60 text-white text-[13px] font-semibold rounded-xl flex items-center gap-2 cursor-pointer transition-colors shadow-sm"
              >
                {vehicleSaving ? <RotateCw className="w-4 h-4 animate-spin" /> : <Check className="w-4 h-4 stroke-[2.5]" />}
                <span>Save Vehicle Type</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ================= MODAL: ADD / EDIT CATEGORY ================= */}
      {categoryModalOpen && (
        <div className="fixed inset-0 bg-black/45 backdrop-blur-xs flex items-center justify-center z-[1000] p-4 animate-in fade-in duration-100">
          <div className="bg-white rounded-[24px] max-w-md w-full p-6 shadow-2xl border border-[#EBEBEB] flex flex-col gap-4 animate-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-[#F0EFF5] pb-3">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center">
                  <Layers className="w-4 h-4" />
                </div>
                <h3 className="text-[16px] font-bold text-[#1C2926]">
                  {editingCategory ? 'Edit Service Category' : 'Add Service Category'}
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setCategoryModalOpen(false)}
                className="p-1 rounded-lg hover:bg-gray-100 text-[#8C8C94] cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-3.5">
              <div>
                <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                  Category Name (English) <span className="text-[#DC2626]">*</span>
                </label>
                <input
                  type="text"
                  value={categoryFormName}
                  onChange={(e) => {
                    const val = e.target.value
                    setCategoryFormName(val)
                    const quick = quickTranslateArabic(val)
                    if (!categoryFormNameAr || categoryFormNameAr === quickTranslateArabic(categoryFormName)) {
                      setCategoryFormNameAr(quick)
                    }
                    if (categoryTranslateTimer.current) clearTimeout(categoryTranslateTimer.current)
                    if (val.trim()) {
                      categoryTranslateTimer.current = setTimeout(async () => {
                        const online = await translateTextApi(val)
                        if (online && online.trim()) {
                          setCategoryFormNameAr(online.trim())
                        }
                      }, 500)
                    }
                  }}
                  placeholder="e.g. Water Tank, Workhouse or Towing Truck"
                  className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE]"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-[12px] font-medium text-[#1C2926]">
                    Arabic Translation (الاسم بالعربية) <span className="text-[#DC2626]">*</span>
                  </label>
                  <button
                    type="button"
                    disabled={translatingCategory || !categoryFormName.trim()}
                    onClick={() => handleTranslateCategory(categoryFormName)}
                    className="text-[11px] font-semibold text-[#8B53FE] hover:text-[#7839EE] cursor-pointer flex items-center gap-1 disabled:opacity-50"
                  >
                    {translatingCategory ? '⏳ Translating...' : '✨ Auto-Translate'}
                  </button>
                </div>
                <input
                  type="text"
                  dir="rtl"
                  value={categoryFormNameAr}
                  onChange={(e) => setCategoryFormNameAr(e.target.value)}
                  placeholder="مثال: وايت ماء / ورشة عمل"
                  className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE] font-arabic"
                />
                <p className="text-[11px] text-[#8C8C94] mt-1">
                  This Arabic name will be displayed in the mobile onboarding dropdown when the application is set to Arabic.
                </p>
              </div>

              <div>
                <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                  Subtitle / Description (English)
                </label>
                <input
                  type="text"
                  value={categoryFormSubtitle}
                  onChange={(e) => setCategoryFormSubtitle(e.target.value)}
                  placeholder="e.g. Fast local breakdown recovery"
                  className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                />
              </div>

              <div>
                <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                  Arabic Subtitle (الوصف بالعربية)
                </label>
                <input
                  type="text"
                  dir="rtl"
                  value={categoryFormSubtitleAr}
                  onChange={(e) => setCategoryFormSubtitleAr(e.target.value)}
                  placeholder="مثال: خدمة سريعة ومعتمدة لجميع الأعطال"
                  className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE] font-arabic"
                />
              </div>

              <div>
                <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                  Status
                </label>
                <select
                  value={categoryFormStatus}
                  onChange={(e) => setCategoryFormStatus(e.target.value)}
                  className="w-full h-[40px] px-3 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                >
                  <option value="Active">Active</option>
                  <option value="Inactive">Inactive</option>
                </select>
              </div>
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-3 border-t border-[#F0EFF5]">
              <button
                type="button"
                onClick={() => setCategoryModalOpen(false)}
                className="px-4 py-2 border border-[#E5E7EB] text-[#616166] text-[13px] font-medium rounded-xl hover:bg-gray-50 cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={categorySaving}
                onClick={handleSaveCategory}
                className="px-5 py-2 bg-[#8B53FE] hover:bg-[#7839EE] disabled:opacity-60 text-white text-[13px] font-semibold rounded-xl flex items-center gap-2 cursor-pointer transition-colors shadow-sm"
              >
                {categorySaving ? <RotateCw className="w-4 h-4 animate-spin" /> : <Check className="w-4 h-4 stroke-[2.5]" />}
                <span>Save Category</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ================= MODAL: ADD / EDIT CITY ================= */}
      {cityModalOpen && (
        <div className="fixed inset-0 bg-black/45 backdrop-blur-xs flex items-center justify-center z-[1000] p-4 animate-in fade-in duration-100">
          <div className="bg-white rounded-[24px] max-w-md w-full p-6 shadow-2xl border border-[#EBEBEB] flex flex-col gap-4 animate-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-[#F0EFF5] pb-3">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#F4EFFE] text-[#8B53FE] flex items-center justify-center">
                  <MapPin className="w-4 h-4" />
                </div>
                <h3 className="text-[16px] font-bold text-[#1C2926]">
                  {editingCity ? 'Edit Coverage City' : 'Add Coverage City'}
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setCityModalOpen(false)}
                className="p-1 rounded-lg hover:bg-gray-100 text-[#8C8C94] cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-3.5">
              <div>
                <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                  City Name (English) <span className="text-[#DC2626]">*</span>
                </label>
                <input
                  type="text"
                  value={cityFormName}
                  onChange={(e) => {
                    const val = e.target.value
                    setCityFormName(val)
                    const key = val.trim().toLowerCase().replace(/[^a-z]/g, '')
                    const preset = KNOWN_SAUDI_CITIES_PRESET[key]
                    if (preset) {
                      if (!cityFormNameAr || cityFormNameAr === KNOWN_SAUDI_CITIES_PRESET[cityFormName.trim().toLowerCase()]?.nameAr) {
                        setCityFormNameAr(preset.nameAr)
                      }
                      if (!cityFormLat) setCityFormLat(String(preset.lat))
                      if (!cityFormLng) setCityFormLng(String(preset.lng))
                    }
                  }}
                  placeholder="e.g. Riyadh, Jeddah, Yanbu or Hail"
                  className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE] focus:ring-1 focus:ring-[#8B53FE]"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-[12px] font-medium text-[#1C2926]">
                    Arabic Name (اسم المدينة بالعربية) <span className="text-[#DC2626]">*</span>
                  </label>
                  <button
                    type="button"
                    disabled={translatingCity || !cityFormName.trim()}
                    onClick={() => handleTranslateCity(cityFormName)}
                    className="text-[11px] font-semibold text-[#8B53FE] hover:text-[#7839EE] cursor-pointer flex items-center gap-1 disabled:opacity-50"
                  >
                    {translatingCity ? '⏳ Translating...' : '✨ Auto-Fill / Translate'}
                  </button>
                </div>
                <input
                  type="text"
                  dir="rtl"
                  value={cityFormNameAr}
                  onChange={(e) => setCityFormNameAr(e.target.value)}
                  placeholder="مثال: الرياض / جدة / ينبع"
                  className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE] font-arabic"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                    Latitude <span className="text-[#DC2626]">*</span>
                  </label>
                  <input
                    type="number"
                    step="any"
                    value={cityFormLat}
                    onChange={(e) => setCityFormLat(e.target.value)}
                    placeholder="24.7136"
                    className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                  />
                </div>
                <div>
                  <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                    Longitude <span className="text-[#DC2626]">*</span>
                  </label>
                  <input
                    type="number"
                    step="any"
                    value={cityFormLng}
                    onChange={(e) => setCityFormLng(e.target.value)}
                    placeholder="46.6753"
                    className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                    Default Zoom
                  </label>
                  <input
                    type="number"
                    value={cityFormZoom}
                    onChange={(e) => setCityFormZoom(e.target.value)}
                    placeholder="13"
                    className="w-full h-[40px] px-3.5 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                  />
                </div>
                <div>
                  <label className="block text-[12px] font-medium text-[#1C2926] mb-1">
                    Status
                  </label>
                  <select
                    value={cityFormStatus}
                    onChange={(e) => setCityFormStatus(e.target.value)}
                    className="w-full h-[40px] px-3 bg-white border border-[#E5E7EB] rounded-xl text-[13px] text-[#1C2926] focus:outline-none focus:border-[#8B53FE]"
                  >
                    <option value="Active">Active</option>
                    <option value="Inactive">Inactive</option>
                  </select>
                </div>
              </div>

              <div className="p-3 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB] text-[11px] text-[#616166]">
                📍 <strong>Live Map Sync:</strong> Adding or editing this city updates the Live Map city dropdown instantly. Selecting the city centers the map on these coordinates and calculates Haversine provider distances from its center.
              </div>
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-3 border-t border-[#F0EFF5]">
              <button
                type="button"
                onClick={() => setCityModalOpen(false)}
                className="px-4 py-2 border border-[#E5E7EB] text-[#616166] text-[13px] font-medium rounded-xl hover:bg-gray-50 cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={citySaving}
                onClick={handleSaveCity}
                className="px-5 py-2 bg-[#8B53FE] hover:bg-[#7839EE] disabled:opacity-60 text-white text-[13px] font-semibold rounded-xl flex items-center gap-2 cursor-pointer transition-colors shadow-sm"
              >
                {citySaving ? <RotateCw className="w-4 h-4 animate-spin" /> : <Check className="w-4 h-4 stroke-[2.5]" />}
                <span>Save City</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ================= MODAL: DELETE CONFIRMATION ================= */}
      {(deletingVehicle || deletingCategory || deletingCity) && (
        <div className="fixed inset-0 bg-black/45 backdrop-blur-xs flex items-center justify-center z-[1000] p-4 animate-in fade-in duration-100">
          <div className="bg-white rounded-[24px] max-w-sm w-full p-6 shadow-2xl border border-[#EBEBEB] flex flex-col gap-4 animate-in zoom-in-95 duration-150">
            <div className="w-12 h-12 rounded-2xl bg-[#FEE2E2] text-[#DC2626] flex items-center justify-center mx-auto">
              <AlertTriangle className="w-6 h-6 stroke-[2]" />
            </div>

            <div className="text-center">
              <h3 className="text-[16px] font-bold text-[#1C2926]">Are you sure?</h3>
              <p className="text-[12px] text-[#616166] mt-1.5 leading-relaxed">
                {deletingVehicle
                  ? `Delete vehicle type "${deletingVehicle.name}"? It will no longer appear in driver onboarding dropdowns.`
                  : deletingCategory
                  ? `Delete service category "${deletingCategory.name}"? This action cannot be undone.`
                  : `Delete city "${deletingCity?.name}"? It will no longer appear in the Live Map city filter.`}
              </p>
            </div>

            <div className="flex items-center gap-2.5 pt-2">
              <button
                type="button"
                onClick={() => {
                  setDeletingVehicle(null)
                  setDeletingCategory(null)
                  setDeletingCity(null)
                }}
                className="flex-1 h-[40px] border border-[#E5E7EB] text-[#616166] text-[13px] font-medium rounded-xl hover:bg-gray-50 cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={() => {
                  if (deletingVehicle) handleConfirmDeleteVehicle()
                  if (deletingCategory) handleConfirmDeleteCategory()
                  if (deletingCity) handleConfirmDeleteCity()
                }}
                className="flex-1 h-[40px] bg-[#DC2626] hover:bg-[#B91C1C] text-white text-[13px] font-semibold rounded-xl cursor-pointer transition-colors shadow-xs"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default SettingsView

