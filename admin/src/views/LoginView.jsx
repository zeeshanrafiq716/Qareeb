import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Mail,
  Lock,
  Eye,
  EyeOff,
  ArrowRight,
  Globe,
  ChevronDown,
  ShieldCheck,
  AlertCircle,
  Loader2,
  Check,
} from 'lucide-react'
import { BrandLogo } from '../components/common/BrandLogo'
import { useAuth } from '../context/AuthContext'
import { loginAdmin } from '../api/auth'
import { translations } from '../theme/i18n'

export default function LoginView() {
  const navigate = useNavigate()
  const { login } = useAuth()

  const [lang, setLang] = useState('en')
  const [langDropdownOpen, setLangDropdownOpen] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [rememberMe, setRememberMe] = useState(true)
  const [isLoading, setIsLoading] = useState(false)
  const [errorMessage, setErrorMessage] = useState('')
  const [showForgotModal, setShowForgotModal] = useState(false)

  const t = translations[lang] || translations.en
  const isArabic = lang === 'ar'

  const handleLanguageChange = (newLang) => {
    setLang(newLang)
    setLangDropdownOpen(false)
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setErrorMessage('')

    if (!email.trim()) {
      setErrorMessage(isArabic ? 'يرجى إدخال البريد الإلكتروني' : 'Please enter your email address')
      return
    }

    if (!password) {
      setErrorMessage(isArabic ? 'يرجى إدخال كلمة المرور' : 'Please enter your password')
      return
    }

    setIsLoading(true)

    try {
      const response = await loginAdmin({ email, password })
      if (response?.data?.token) {
        login(response.data.admin, response.data.token)
        navigate('/dashboard')
      } else {
        setErrorMessage(t.invalidCredentials)
      }
    } catch (err) {
      const status = err.response?.status
      const backendMessage = err.response?.data?.error?.message

      if (status === 401) {
        setErrorMessage(t.invalidCredentials)
      } else if (backendMessage) {
        setErrorMessage(backendMessage)
      } else {
        setErrorMessage(t.connectionError)
      }
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div
      className="min-h-screen w-full bg-white flex flex-col lg:flex-row antialiased selection:bg-[#8B53FE]/20 selection:text-[#8B53FE]"
      dir={isArabic ? 'rtl' : 'ltr'}
    >
      {/* ================= LEFT BRANDED ARTWORK PANEL ================= */}
      <div className="w-full lg:w-[48%] xl:w-[50%] p-3 sm:p-4 md:p-6 flex flex-col">
        <div
          className="relative w-full h-full min-h-[460px] lg:min-h-0 rounded-[28px] md:rounded-[36px] overflow-hidden flex flex-col justify-end p-8 sm:p-10 md:p-12 lg:p-14 border border-[#EFF0ED]/80 shadow-[0px_4px_24px_0px_rgba(139,83,254,0.06)]"
          style={{
            background:
              'linear-gradient(135deg, #F8F5FF 0%, #F1EAFF 28%, #EAE0FE 56%, #FDFBFF 100%)',
          }}
        >
          {/* Ambient Purple Glow Overlays matching design */}
          <div
            className="absolute -top-24 -left-24 w-96 h-96 rounded-full pointer-events-none opacity-80 blur-3xl"
            style={{
              background: 'radial-gradient(circle, #DECFFC 0%, rgba(222,207,252,0) 70%)',
            }}
          />
          <div
            className="absolute top-1/4 -right-16 w-80 h-80 rounded-full pointer-events-none opacity-60 blur-3xl"
            style={{
              background: 'radial-gradient(circle, #BA98FE 0%, rgba(186,152,254,0) 70%)',
            }}
          />
          <div
            className="absolute -bottom-20 -left-10 w-96 h-96 rounded-full pointer-events-none opacity-50 blur-3xl"
            style={{
              background: 'radial-gradient(circle, #DECFFC 0%, rgba(222,207,252,0) 70%)',
            }}
          />

          {/* Foreground Branded Information */}
          <div className="relative z-10">
            {/* Qareeb Logo */}
            <BrandLogo iconSize={32} textColor="text-[#1C2926]" />

            {/* Sub-heading / Badge */}
            <p className="text-xs sm:text-sm font-medium text-[#566663] mt-5">
              {t.brandSubheading}
            </p>

            {/* Main Heading */}
            <h1 className="text-2xl sm:text-3xl lg:text-[34px] font-bold text-[#1C2926] mt-1.5 tracking-tight leading-snug">
              {t.brandHeading}
            </h1>

            {/* Description */}
            <p className="text-xs sm:text-sm text-[#566663] mt-3 max-w-md leading-relaxed">
              {t.brandDescription}
            </p>
          </div>
        </div>
      </div>

      {/* ================= RIGHT FORM PANEL ================= */}
      <div className="w-full lg:w-[52%] xl:w-[50%] flex flex-col justify-between p-6 sm:p-10 md:p-12 lg:p-14">
        {/* Top Header Row with Language Switcher */}
        <div className="flex justify-end w-full relative">
          <div className="relative">
            <button
              type="button"
              onClick={() => setLangDropdownOpen((prev) => !prev)}
              className="inline-flex items-center gap-2 px-3.5 py-2 rounded-full border border-[#EFF0ED] bg-white text-xs font-medium text-[#1C2926] hover:bg-[#F8FAFC] hover:border-[#DECFFC] transition-all shadow-xs cursor-pointer"
            >
              <Globe className="w-4 h-4 text-[#8B53FE]" />
              <span>{t.language}</span>
              <ChevronDown
                className={`w-3.5 h-3.5 text-[#566663] transition-transform duration-200 ${
                  langDropdownOpen ? 'rotate-180' : ''
                }`}
              />
            </button>

            {/* Language Dropdown Menu */}
            {langDropdownOpen && (
              <div
                className={`absolute ${
                  isArabic ? 'left-0' : 'right-0'
                } mt-2 w-36 bg-white border border-[#EFF0ED] rounded-xl shadow-lg py-1.5 z-50`}
              >
                <button
                  type="button"
                  onClick={() => handleLanguageChange('en')}
                  className={`w-full px-3.5 py-2 text-xs text-left flex items-center justify-between hover:bg-[#F0EAFE] transition-colors ${
                    lang === 'en' ? 'text-[#8B53FE] font-semibold' : 'text-[#1C2926]'
                  }`}
                >
                  <span>English</span>
                  {lang === 'en' && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                </button>
                <button
                  type="button"
                  onClick={() => handleLanguageChange('ar')}
                  className={`w-full px-3.5 py-2 text-xs text-left flex items-center justify-between hover:bg-[#F0EAFE] transition-colors ${
                    lang === 'ar' ? 'text-[#8B53FE] font-semibold' : 'text-[#1C2926]'
                  }`}
                >
                  <span>العربية</span>
                  {lang === 'ar' && <Check className="w-3.5 h-3.5 text-[#8B53FE]" />}
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Center: Sign In Card & Form */}
        <div className="w-full max-w-[420px] mx-auto my-auto py-8">
          {/* Header */}
          <div className="mb-7">
            <h2 className="text-2xl sm:text-3xl font-bold text-[#1C2926] tracking-tight">
              {t.welcomeBack}
            </h2>
            <p className="text-xs sm:text-sm text-[#566663] mt-2">
              {t.signInSubtitle}
            </p>
          </div>

          {/* Error Alert Banner */}
          {errorMessage && (
            <div className="mb-5 p-3.5 rounded-xl bg-[#FEF2F2] border border-[#FEE2E2] flex items-start gap-2.5 text-xs text-[#DC2626] animate-in fade-in duration-200">
              <AlertCircle className="w-4 h-4 shrink-0 mt-0.5 text-[#DC2626]" />
              <div className="flex-1">{errorMessage}</div>
            </div>
          )}

          {/* Login Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Email Field */}
            <div>
              <label
                htmlFor="email"
                className="block text-xs font-semibold text-[#1C2926] mb-2"
              >
                {t.emailLabel}
              </label>
              <div className="relative flex items-center">
                <span
                  className={`absolute ${
                    isArabic ? 'right-3.5' : 'left-3.5'
                  } text-[#9EAFA9] pointer-events-none`}
                >
                  <Mail className="w-4 h-4" />
                </span>
                <input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder={t.emailPlaceholder}
                  autoComplete="email"
                  required
                  className={`w-full bg-[#F2F5F4] text-sm text-[#1C2926] placeholder-[#9EAFA9] rounded-xl py-3.5 border border-transparent focus:bg-white focus:border-[#8B53FE] focus:ring-4 focus:ring-[#8B53FE]/10 transition-all outline-none ${
                    isArabic ? 'pr-10 pl-4' : 'pl-10 pr-4'
                  }`}
                />
              </div>
            </div>

            {/* Password Field */}
            <div>
              <label
                htmlFor="password"
                className="block text-xs font-semibold text-[#1C2926] mb-2"
              >
                {t.passwordLabel}
              </label>
              <div className="relative flex items-center">
                <span
                  className={`absolute ${
                    isArabic ? 'right-3.5' : 'left-3.5'
                  } text-[#9EAFA9] pointer-events-none`}
                >
                  <Lock className="w-4 h-4" />
                </span>
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder={t.passwordPlaceholder}
                  autoComplete="current-password"
                  required
                  className={`w-full bg-[#F2F5F4] text-sm text-[#1C2926] placeholder-[#9EAFA9] rounded-xl py-3.5 border border-transparent focus:bg-white focus:border-[#8B53FE] focus:ring-4 focus:ring-[#8B53FE]/10 transition-all outline-none ${
                    isArabic ? 'pr-10 pl-11' : 'pl-10 pr-11'
                  }`}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((prev) => !prev)}
                  tabIndex={-1}
                  className={`absolute ${
                    isArabic ? 'left-3.5' : 'right-3.5'
                  } text-[#9EAFA9] hover:text-[#566663] transition-colors p-1 cursor-pointer`}
                >
                  {showPassword ? (
                    <EyeOff className="w-4 h-4" />
                  ) : (
                    <Eye className="w-4 h-4" />
                  )}
                </button>
              </div>
            </div>

            {/* Remember Me & Forgot Password Row */}
            <div className="flex items-center justify-between pt-1">
              <label className="flex items-center gap-2 cursor-pointer select-none">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="w-4 h-4 rounded text-[#8B53FE] focus:ring-[#8B53FE] focus:ring-offset-0 border-[#EFF0ED] accent-[#8B53FE] cursor-pointer"
                />
                <span className="text-xs text-[#566663] font-normal">
                  {t.rememberMe}
                </span>
              </label>

              <button
                type="button"
                onClick={() => setShowForgotModal(true)}
                className="text-xs font-medium text-[#8B53FE] hover:text-[#7032F0] hover:underline transition-colors cursor-pointer"
              >
                {t.forgotPassword}
              </button>
            </div>

            {/* Submit Button (Sign In ->) */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full mt-4 bg-[#8B53FE] hover:bg-[#7032F0] active:scale-[0.99] disabled:opacity-60 text-white font-medium py-3.5 px-5 rounded-xl shadow-md shadow-[#8B53FE]/20 flex items-center justify-center gap-2 transition-all duration-200 cursor-pointer"
            >
              {isLoading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin text-white" />
                  <span className="text-sm">{t.signingIn}</span>
                </>
              ) : (
                <>
                  <span className="text-sm font-semibold">{t.signInButton}</span>
                  <ArrowRight
                    className={`w-4 h-4 text-white transition-transform ${
                      isArabic ? 'rotate-180' : ''
                    }`}
                  />
                </>
              )}
            </button>
          </form>
        </div>

        {/* Bottom Badge / Note: Secure Administrative Access */}
        <div className="w-full max-w-[420px] mx-auto pt-6">
          <div className="p-3.5 rounded-xl bg-[#F8FAFC] border border-[#EFF0ED] flex items-center gap-3.5">
            <div className="w-10 h-10 rounded-xl bg-[#F0EAFE] text-[#8B53FE] flex items-center justify-center shrink-0">
              <ShieldCheck className="w-5 h-5 text-[#8B53FE]" />
            </div>
            <div className="min-w-0">
              <h4 className="text-xs font-bold text-[#1C2926] leading-snug">
                {t.secureAccessTitle}
              </h4>
              <p className="text-[11px] text-[#566663] mt-0.5 truncate">
                {t.secureAccessSubtitle}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Forgot Password Modal */}
      {showForgotModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 shadow-2xl border border-[#EFF0ED] text-left">
            <div className="w-11 h-11 rounded-xl bg-[#F0EAFE] text-[#8B53FE] flex items-center justify-center mb-4">
              <Lock className="w-5 h-5" />
            </div>
            <h3 className="text-base font-bold text-[#1C2926]">
              {t.forgotPasswordTitle}
            </h3>
            <p className="text-xs text-[#566663] mt-2 leading-relaxed">
              {t.forgotPasswordMessage}
            </p>
            <div className="mt-5 flex justify-end">
              <button
                type="button"
                onClick={() => setShowForgotModal(false)}
                className="px-4 py-2 rounded-xl bg-[#8B53FE] text-white text-xs font-semibold hover:bg-[#7032F0] transition-colors cursor-pointer"
              >
                {t.close}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

