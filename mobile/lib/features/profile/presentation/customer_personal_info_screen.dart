import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/app_locale.dart';
import '../../../models/country_model.dart';
import '../../../services/profile_stats_service.dart';
import '../../customer/auth/data/customer_auth_store.dart';
import '../../provider/auth/presentation/widgets/provider_animated_button.dart';
import '../../provider/auth/presentation/widgets/provider_country_picker_modal.dart';

/// Customer Personal Information Settings Screen
/// Allows customer to view and update their full name, phone number, and avatar
class CustomerPersonalInfoScreen extends ConsumerStatefulWidget {
  const CustomerPersonalInfoScreen({super.key});

  @override
  ConsumerState<CustomerPersonalInfoScreen> createState() =>
      _CustomerPersonalInfoScreenState();
}

class _CustomerPersonalInfoScreenState
    extends ConsumerState<CustomerPersonalInfoScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  CountryModel _selectedCountry = CountryModel.defaultCountry;
  String? _photoPath;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final store = CustomerAuthStore.instance;
    _nameController = TextEditingController(text: store.fullName);

    String cleanPhone = store.phone;
    if (cleanPhone.startsWith(_selectedCountry.dialCode)) {
      cleanPhone = cleanPhone.substring(_selectedCountry.dialCode.length).trim();
    }
    _phoneController = TextEditingController(text: cleanPhone);

    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final stats = await ProfileStatsService.instance.getStats(isProvider: false);
    if (mounted) {
      setState(() => _photoPath = stats.photoPath);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleCountryPicker() async {
    HapticFeedback.selectionClick();
    final picked = await ProviderCountryPickerModal.show(
      context,
      selectedCountry: _selectedCountry,
    );
    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final savedPath = await ProfileStatsService.instance.pickAndSavePhoto(
        source: source,
        isProvider: false,
      );
      if (savedPath != null && mounted) {
        setState(() => _photoPath = savedPath);
        await CustomerAuthStore.instance.updateProfile(photoPath: savedPath);
      }
    } catch (_) {}
  }

  void _showPhotoOptions() {
    final isArabic = context.isArabic;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 16.0,
          bottom: MediaQuery.of(bottomContext).padding.bottom + 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              isArabic ? 'تغيير صورة الملف الشخصي' : 'Change Profile Photo',
              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C2926),
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF8B53FE)),
              title: Text(
                isArabic ? 'التقاط صورة بالكاميرا' : 'Take a Photo',
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(fontSize: 14.5),
              ),
              onTap: () {
                Navigator.pop(bottomContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF8B53FE)),
              title: Text(
                isArabic ? 'اختيار من المعرض' : 'Choose from Gallery',
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(fontSize: 14.5),
              ),
              onTap: () {
                Navigator.pop(bottomContext);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            if (_photoPath != null && _photoPath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                title: Text(
                  isArabic ? 'إزالة الصورة الحالية' : 'Remove Photo',
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                    fontSize: 14.5,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(bottomContext);
                  await ProfileStatsService.instance.removePhoto(isProvider: false);
                  await CustomerAuthStore.instance.updateProfile(photoPath: '');
                  if (mounted) setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final isArabic = context.isArabic;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

    if (name.isEmpty) {
      setState(() => _errorMessage = isArabic ? 'يرجى إدخال الاسم' : 'Please enter your name');
      _nameFocusNode.requestFocus();
      return;
    }

    if (phone.isEmpty) {
      setState(() => _errorMessage = isArabic ? 'يرجى إدخال رقم الهاتف' : 'Please enter your phone number');
      _phoneFocusNode.requestFocus();
      return;
    }

    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7) {
      setState(() => _errorMessage = isArabic ? 'يرجى إدخال رقم هاتف صحيح' : 'Please enter a valid phone number');
      _phoneFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fullPhoneNumber = '${_selectedCountry.dialCode}$digitsOnly';

      await CustomerAuthStore.instance.updateProfile(
        fullName: name,
        phone: fullPhoneNumber,
        countryCode: _selectedCountry.dialCode,
        photoPath: _photoPath,
      );

      if (!mounted) return;

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تم تحديث المعلومات الشخصية بنجاح'
                : 'Personal information updated successfully',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = isArabic
              ? 'حدث خطأ أثناء حفظ التغييرات'
              : 'Error saving changes, please try again';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLocaleProvider);
    final isArabic = context.isArabic;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : mediaQuery.size.width;
            final screenHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : mediaQuery.size.height;

            final bool isDesktopWeb = screenWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : screenWidth;
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (screenHeight - 32.0).clamp(520.0, 844.0))
                : screenHeight;

            final double safeTop = mediaQuery.padding.top;
            final double headerTopPadding = math.max(safeTop + 14.0, 52.0);

            final bool hasPhoto = _photoPath != null &&
                _photoPath!.isNotEmpty &&
                File(_photoPath!).existsSync();

            final Widget content = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // Top subtle gradient
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    height: 200.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFF0EAFE),
                            Color(0x00F0EAFE),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main Scrollable Body
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: headerTopPadding),

                          // Header Row (Back Button + Centered Title)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 8.0,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isArabic
                                          ? Icons.chevron_right_rounded
                                          : Icons.chevron_left_rounded,
                                      size: 24.0,
                                      color: const Color(0xFF1C2926),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C2926),
                                ),
                              ),
                              const SizedBox(width: 36.0), // Spacer for centering
                            ],
                          ),

                          const SizedBox(height: 28.0),

                          // Centered Avatar with Camera Badge
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 90.0,
                                  height: 90.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF0EAFE),
                                    border: Border.all(
                                      color: const Color(0xFF8B53FE).withValues(alpha: 0.25),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: hasPhoto
                                        ? Image.file(
                                            File(_photoPath!),
                                            fit: BoxFit.cover,
                                            width: 90.0,
                                            height: 90.0,
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 50.0,
                                              color: const Color(0xFF8B53FE).withValues(alpha: 0.7),
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _showPhotoOptions,
                                    child: Container(
                                      width: 30.0,
                                      height: 30.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF252527),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4.0,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.camera_alt_rounded,
                                          size: 15.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24.0),

                          // Error notice if any
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: const Color(0xFFF87171)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 18.0, color: Color(0xFFDC2626)),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFB91C1C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],

                          // 1. Full Name Input Card
                          Text(
                            isArabic ? 'الاسم الكامل' : 'Full Name',
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(height: 6.0),

                          Container(
                            height: 52.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: _nameFocusNode.hasFocus
                                    ? const Color(0xFF8B53FE)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 20.0,
                                  color: Color(0xFF71717A),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    textCapitalization: TextCapitalization.words,
                                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1C2926),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isArabic
                                          ? 'مثال: عبد الله المنصور'
                                          : 'e.g. Abdullah Al-Mansoor',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (_) {
                                      if (_errorMessage != null) {
                                        setState(() => _errorMessage = null);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // 2. Phone Number Input Card
                          Text(
                            isArabic ? 'رقم الهاتف' : 'Phone Number',
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(height: 6.0),

                          // Number code on left side, number field on right side (Enforce LTR)
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: _handleCountryPicker,
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Container(
                                    height: 52.0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F5F4),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _selectedCountry.flagEmoji,
                                          style: const TextStyle(fontSize: 18.0),
                                        ),
                                        const SizedBox(width: 6.0),
                                        Text(
                                          _selectedCountry.dialCode,
                                          style: GoogleFonts.inter(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1C2926),
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18.0,
                                          color: Color(0xFF71717A),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Container(
                                    height: 52.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F5F4),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: _phoneFocusNode.hasFocus
                                            ? const Color(0xFF8B53FE)
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                    child: Center(
                                      child: TextField(
                                        controller: _phoneController,
                                        focusNode: _phoneFocusNode,
                                        keyboardType: TextInputType.phone,
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.left,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(12),
                                        ],
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C2926),
                                          letterSpacing: 0.5,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: _selectedCountry.exampleNumber,
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (_) {
                                          if (_errorMessage != null) {
                                            setState(() => _errorMessage = null);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24.0),

                          // Account Status Box
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38.0,
                                  height: 38.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.verified_user_rounded,
                                      size: 20.0,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isArabic ? 'نوع الحساب' : 'Account Type',
                                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                          fontSize: 11.5,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      Text(
                                        isArabic ? 'حساب عميل نشط' : 'Active Customer Account',
                                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32.0),

                          // Save Changes Button (Animated Branded Button - Never Disappears On Click)
                          ProviderAnimatedButton(
                            height: 52.0,
                            isLoading: _isLoading,
                            backgroundColor: const Color(0xFF252527),
                            foregroundColor: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: _isLoading ? null : _handleSave,
                            text: isArabic ? 'حفظ التغييرات' : 'Save Changes',
                            textStyle: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            icon: const Icon(
                              Icons.check_rounded,
                              size: 18.0,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF141C1A),
                child: Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(42),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 32,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: content,
                  ),
                ),
              );
            }

            return content;
          },
        ),
      ),
    );
  }
}
