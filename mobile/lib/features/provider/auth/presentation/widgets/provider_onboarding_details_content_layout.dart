import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/upload_documents_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_button.dart';
import 'package:mobile/models/category_model.dart';
import 'package:mobile/models/vehicle_type_model.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider Onboarding Consolidated Details Content Layout Widget
/// Implements:
/// - Clean, completely empty input fields for manual user entry (no by-default text in name, color, plate, etc.)
/// - Service Category dropdown with options from Admin side (clean layout, no admin taglines/badges)
/// - Vehicle Type dropdown with options from Admin side (clean layout, no admin taglines/badges)
/// - Responsive, overflow-free scrollable layout
class ProviderOnboardingDetailsContentLayout extends StatefulWidget {
  final VoidCallback? onContinue;

  const ProviderOnboardingDetailsContentLayout({
    super.key,
    this.onContinue,
  });

  static const double fieldGap = 16.0;

  @override
  State<ProviderOnboardingDetailsContentLayout> createState() =>
      _ProviderOnboardingDetailsContentLayoutState();
}

class _ProviderOnboardingDetailsContentLayoutState
    extends State<ProviderOnboardingDetailsContentLayout> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _colorCtrl;
  late final String _registeredPhone;

  String? _selectedCategory;
  String? _selectedVehicleType;
  CategoryModel? _selectedCategoryModel;
  VehicleTypeModel? _selectedVehicleTypeModel;

  List<String> _adminCategories = CategoryModel.defaultCategories.map((c) => c.name).toList();
  List<CategoryModel> _adminCategoryModels = List.from(CategoryModel.defaultCategories);
  List<VehicleTypeModel> _adminVehicleTypeModels = List.from(VehicleTypeModel.defaultVehicleTypes);
  bool _isLoadingAdminOptions = false;

  bool _isLoading = false;
  late final BackendService _backendService;
  Timer? _liveSyncTimer;
  VoidCallback? _activeSheetUpdater;

  @override
  void initState() {
    super.initState();
    final savedData = ProviderRegistrationStore.instance.data;

    // All editable input fields start 100% empty (no default text in name, vehicle color, plate, etc.)
    _nameCtrl = TextEditingController(text: savedData.fullName.isNotEmpty ? savedData.fullName : '');
    _registeredPhone = savedData.phone.isNotEmpty ? savedData.phone : '';
    _whatsappCtrl = TextEditingController(text: savedData.whatsappNumber);
    _plateCtrl = TextEditingController(text: savedData.plateNumber);
    _colorCtrl = TextEditingController(text: savedData.vehicleColor);

    _selectedCategory = savedData.serviceCategory.isNotEmpty ? savedData.serviceCategory : null;
    _selectedVehicleType = savedData.vehicleType.isNotEmpty ? savedData.vehicleType : null;
    _selectedCategoryModel = _selectedCategory != null
        ? _adminCategoryModels.cast<CategoryModel?>().firstWhere(
              (c) => c?.name == _selectedCategory,
              orElse: () => null,
            )
        : null;
    _selectedVehicleTypeModel = _selectedVehicleType != null
        ? _adminVehicleTypeModels.cast<VehicleTypeModel?>().firstWhere(
              (v) => v?.name == _selectedVehicleType,
              orElse: () => null,
            )
        : null;

    _backendService = BackendService(ApiClient());
    _loadAdminOptions();

    // Live background sync (every 15s) so Admin panel changes reflect automatically
    _liveSyncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadAdminOptions(silent: true);
    });
  }

  Future<void> _loadAdminOptions({bool silent = false, VoidCallback? onRefreshed}) async {
    try {
      // Independent parallel fetches so if one endpoint has network delay/error, other still succeeds
      final results = await Future.wait([
        _backendService.getCategories().catchError((_) => CategoryModel.defaultCategories),
        _backendService.getVehicleTypeModels().catchError((_) => VehicleTypeModel.defaultVehicleTypes),
      ]);

      final categories = results[0] as List<CategoryModel>;
      final vehicleTypes = results[1] as List<VehicleTypeModel>;

      if (mounted) {
        final activeCats = categories.where((c) => c.isEnabled).toList();
        final activeTypes = vehicleTypes.where((v) => v.isEnabled).toList();

        final finalCats = activeCats.isNotEmpty
            ? activeCats
            : (_adminCategoryModels.isNotEmpty ? _adminCategoryModels : CategoryModel.defaultCategories);
        final finalTypes = activeTypes.isNotEmpty
            ? activeTypes
            : (_adminVehicleTypeModels.isNotEmpty ? _adminVehicleTypeModels : VehicleTypeModel.defaultVehicleTypes);

        final newCats = finalCats.map((c) => c.name).toSet().toList();

        setState(() {
          _adminCategoryModels = finalCats;
          _adminVehicleTypeModels = finalTypes;
          _adminCategories = newCats;
          _isLoadingAdminOptions = false;

          // Maintain model selections
          if (_selectedCategory != null) {
            final found = _adminCategoryModels.cast<CategoryModel?>().firstWhere(
                  (c) => c?.name == _selectedCategory || c?.id.toString() == _selectedCategory,
                  orElse: () => null,
                );
            if (found != null) {
              _selectedCategoryModel = found;
              _selectedCategory = found.name;
            }
          }

          if (_selectedVehicleType != null) {
            final found = _adminVehicleTypeModels.cast<VehicleTypeModel?>().firstWhere(
                  (v) => v?.name == _selectedVehicleType || v?.id.toString() == _selectedVehicleType,
                  orElse: () => null,
                );
            if (found != null) {
              _selectedVehicleTypeModel = found;
              _selectedVehicleType = found.name;
            }
          }
        });

        _activeSheetUpdater?.call();
        onRefreshed?.call();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_adminCategoryModels.isEmpty) {
            _adminCategoryModels = List.from(CategoryModel.defaultCategories);
            _adminCategories = _adminCategoryModels.map((c) => c.name).toList();
          }
          if (_adminVehicleTypeModels.isEmpty) {
            _adminVehicleTypeModels = List.from(VehicleTypeModel.defaultVehicleTypes);
          }
          _isLoadingAdminOptions = false;
        });
        _activeSheetUpdater?.call();
        onRefreshed?.call();
      }
    }
  }

  @override
  void dispose() {
    _liveSyncTimer?.cancel();
    _activeSheetUpdater = null;
    _nameCtrl.dispose();
    _whatsappCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  void _showCategoryDropdown() {
    final isArabic = context.isArabic;

    // Trigger instant refresh right when user taps dropdown
    _loadAdminOptions(silent: true);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            _activeSheetUpdater = () {
              if (bottomSheetContext.mounted) {
                setModalState(() {});
              }
            };

            final options = _adminCategoryModels.isNotEmpty
                ? _adminCategoryModels
                : (_adminCategories.isNotEmpty
                    ? _adminCategories
                        .map((name) => CategoryModel(id: name, name: name, slug: name))
                        .toList()
                    : CategoryModel.defaultCategories);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF0ED),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'اختر نوع الخدمة' : 'Select Service Category',
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                          ),
                        ),
                        if (_isLoadingAdminOptions)
                          const SizedBox(
                            width: 14.0,
                            height: 14.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Color(0xFF8B53FE),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    if (options.isEmpty && _isLoadingAdminOptions)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8B53FE),
                          ),
                        ),
                      )
                    else if (options.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          isArabic ? 'لا توجد فئات خدمات متاحة' : 'No service categories available',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: const Color(0xFF71717A),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (_, _) => const Divider(height: 1.0, color: Color(0xFFF3F4F6)),
                          itemBuilder: (context, index) {
                            final cat = options[index];
                            final isSelected = _selectedCategoryModel?.id == cat.id ||
                                _selectedCategory == cat.name;
                            final displayName = cat.localizedName(isArabic);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.local_shipping_outlined,
                                color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF71717A),
                              ),
                              title: Text(
                                displayName,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF1C2926),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF8B53FE))
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryModel = cat;
                                  _selectedCategory = cat.name;

                                  // Clear conflicting vehicle type if it doesn't match new category
                                  final newVehicleOptions = VehicleTypeModel.getVehicleTypesForCategory(
                                    cat.name,
                                    backendOptions: _adminVehicleTypeModels,
                                  );
                                  if (_selectedVehicleType != null &&
                                      !newVehicleOptions.any((v) => v.name == _selectedVehicleType)) {
                                    _selectedVehicleType = null;
                                    _selectedVehicleTypeModel = null;
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _activeSheetUpdater = null;
    });
  }

  void _showVehicleTypeDropdown() {
    final isArabic = context.isArabic;

    // Trigger instant refresh right when user taps dropdown
    _loadAdminOptions(silent: true);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            _activeSheetUpdater = () {
              if (bottomSheetContext.mounted) {
                setModalState(() {});
              }
            };

            final options = VehicleTypeModel.getVehicleTypesForCategory(
              _selectedCategory,
              backendOptions: _adminVehicleTypeModels.isNotEmpty ? _adminVehicleTypeModels : null,
            );

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF0ED),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'اختر نوع المركبة' : 'Select Vehicle Type',
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                          ),
                        ),
                        if (_isLoadingAdminOptions)
                          const SizedBox(
                            width: 14.0,
                            height: 14.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Color(0xFF8B53FE),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    if (options.isEmpty && _isLoadingAdminOptions)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8B53FE),
                          ),
                        ),
                      )
                    else if (options.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          isArabic ? 'لا توجد أنواع مركبات محددة' : 'No vehicle types available',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: const Color(0xFF71717A),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (_, _) => const Divider(height: 1.0, color: Color(0xFFF3F4F6)),
                          itemBuilder: (context, index) {
                            final vType = options[index];
                            final isSelected = _selectedVehicleTypeModel?.id == vType.id ||
                                _selectedVehicleType == vType.name;
                            final displayName = vType.localizedName(isArabic);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.fire_truck_outlined,
                                color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF71717A),
                              ),
                              title: Text(
                                displayName,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF1C2926),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF8B53FE))
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedVehicleTypeModel = vType;
                                  _selectedVehicleType = vType.name;
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _activeSheetUpdater = null;
    });
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    final isArabic = context.isArabic;
    final name = _nameCtrl.text.trim();
    final whatsapp = _whatsappCtrl.text.trim();
    final plate = _plateCtrl.text.trim();
    final color = _colorCtrl.text.trim();

    if (name.isEmpty) {
      _showFeedback(
        isArabic ? 'يرجى إدخال الاسم الكامل' : 'Please enter your full name',
      );
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _showFeedback(
        isArabic ? 'يرجى اختيار نوع الخدمة' : 'Please select service category',
      );
      return;
    }

    if (_selectedVehicleType == null || _selectedVehicleType!.isEmpty) {
      _showFeedback(
        isArabic ? 'يرجى اختيار نوع المركبة' : 'Please select vehicle type',
      );
      return;
    }

    if (plate.isEmpty) {
      _showFeedback(
        isArabic ? 'يرجى إدخال رقم اللوحة' : 'Please enter plate number',
      );
      return;
    }

    setState(() => _isLoading = true);

    // Save manually entered details + selected options into store
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        fullName: name,
        whatsappNumber: whatsapp.isNotEmpty ? whatsapp : _registeredPhone,
        serviceCategory: _selectedCategory,
        vehicleType: _selectedVehicleType,
        plateNumber: plate,
        vehicleColor: color,
      ),
    );

    // Sync with backend API in background if available
    try {
      final categoryId = _selectedCategoryModel?.id ?? _selectedCategory ?? '';
      final vehicleTypeId = _selectedVehicleTypeModel?.id ?? '';
      await _backendService.updateProviderProfile(
        name: name,
        categoryId: categoryId,
        categoryName: _selectedCategory,
        whatsappNumber: whatsapp.isNotEmpty ? whatsapp : _registeredPhone,
        vehicleType: _selectedVehicleType,
        vehicleTypeId: vehicleTypeId,
        vehicleModel: _selectedVehicleType,
        plateNumber: plate,
        vehicleColor: color,
        address: '',
        city: '',
      );
    } catch (_) {
      // Best-effort offline/mock fallback
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const UploadDocumentsScreen(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF1C2926),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Top Security Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F3FE),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFE7DBFE), width: 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 16.0,
                  color: Color(0xFF8B53FE),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  isArabic
                      ? 'رقم الهاتف المسجل يُستخدم لأمان الحساب وتأكيد هوية المزود.'
                      : 'Your login phone number is used for account security and verification.',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF566663),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: ProviderOnboardingDetailsContentLayout.fieldGap),

        // Section Title: Personal Details
        Text(
          isArabic ? 'البيانات الشخصية' : 'Personal Details',
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C2926),
          ),
        ),

        const SizedBox(height: 12.0),

        // 2. Full Name Field (User types manually, 100% empty initial text)
        _buildFieldLabel(isArabic ? 'الاسم الكامل' : 'Full Name'),
        const SizedBox(height: 6.0),
        _buildTextInputContainer(
          icon: Icons.person_outline_rounded,
          child: TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1C2926),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: isArabic ? 'أدخل اسمك الكامل' : 'Enter your full name',
              hintStyle: GoogleFonts.inter(
                fontSize: 14.0,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        _buildHelperText(
          isArabic ? 'هذا الاسم سيظهر للعملاء عند طلب الخدمة.' : 'This name will be visible to customers.',
        ),

        const SizedBox(height: ProviderOnboardingDetailsContentLayout.fieldGap),

        // 3. Registered Phone Number (Read-only login phone)
        _buildFieldLabel(isArabic ? 'رقم الهاتف' : 'Phone number'),
        const SizedBox(height: 6.0),
        _buildTextInputContainer(
          icon: Icons.phone_outlined,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _registeredPhone.isNotEmpty
                      ? _registeredPhone
                      : (isArabic ? 'رقم الهاتف المسجل' : 'Registered phone number'),
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: _registeredPhone.isNotEmpty ? const Color(0xFF1C2926) : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EAF0),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  isArabic ? 'للقراءة فقط' : 'Read-only',
                  style: GoogleFonts.inter(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              const Icon(
                Icons.lock_outline_rounded,
                size: 16.0,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        _buildHelperText(
          isArabic ? 'هذا هو رقم هاتفك المسجل ولا يمكن تعديله.' : 'This is your registered login number and cannot be changed.',
        ),

        const SizedBox(height: ProviderOnboardingDetailsContentLayout.fieldGap),

        // 4. WhatsApp Number (User types manually, 100% empty initial text, optional)
        _buildFieldLabel(isArabic ? 'رقم واتساب (اختياري)' : 'WhatsApp number (Optional)'),
        const SizedBox(height: 6.0),
        _buildTextInputContainer(
          icon: Icons.chat_bubble_outline_rounded,
          child: TextField(
            controller: _whatsappCtrl,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1C2926),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: isArabic ? 'أدخل رقم واتساب (اختياري)' : 'Enter WhatsApp number (Optional)',
              hintStyle: GoogleFonts.inter(
                fontSize: 14.0,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        _buildHelperText(
          isArabic ? 'يمكنك إضافة رقم واتساب للتواصل مع العملاء.' : 'You can add your secondary WhatsApp number.',
        ),

        const SizedBox(height: ProviderOnboardingDetailsContentLayout.fieldGap),

        // Section Title: Service & Vehicle Details
        Text(
          isArabic ? 'تفاصيل الخدمة والمركبة' : 'Service & Vehicle Details',
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C2926),
          ),
        ),

        const SizedBox(height: 12.0),

        // 5. Service Category Dropdown (Clean layout, no admin taglines/badges)
        _buildFieldLabel(isArabic ? 'نوع الخدمة' : 'Service Category'),
        const SizedBox(height: 6.0),
        InkWell(
          onTap: _showCategoryDropdown,
          borderRadius: BorderRadius.circular(12.0),
          child: _buildTextInputContainer(
            icon: Icons.local_shipping_outlined,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedCategoryModel != null
                        ? _selectedCategoryModel!.localizedName(isArabic)
                        : (_selectedCategory != null && _selectedCategory!.isNotEmpty
                            ? (isArabic ? context.auto(_selectedCategory!) : _selectedCategory!)
                            : (isArabic ? 'اختر نوع الخدمة' : 'Select Service Category')),
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: (_selectedCategoryModel != null ||
                              (_selectedCategory != null && _selectedCategory!.isNotEmpty))
                          ? const Color(0xFF1C2926)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                if (_isLoadingAdminOptions)
                  const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(strokeWidth: 1.8, color: Color(0xFF8B53FE)),
                  )
                else
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF71717A),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: ProviderOnboardingDetailsContentLayout.fieldGap),

        // 6. Vehicle Type Dropdown (Clean layout, no admin taglines/badges)
        _buildFieldLabel(isArabic ? 'نوع المركبة' : 'Vehicle Type'),
        const SizedBox(height: 6.0),
        InkWell(
          onTap: _showVehicleTypeDropdown,
          borderRadius: BorderRadius.circular(12.0),
          child: _buildTextInputContainer(
            icon: Icons.fire_truck_outlined,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedVehicleTypeModel != null
                        ? _selectedVehicleTypeModel!.localizedName(isArabic)
                        : (_selectedVehicleType != null && _selectedVehicleType!.isNotEmpty
                            ? (isArabic ? context.auto(_selectedVehicleType!) : _selectedVehicleType!)
                            : (isArabic ? 'اختر نوع المركبة' : 'Select Vehicle Type')),
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: (_selectedVehicleTypeModel != null ||
                              (_selectedVehicleType != null && _selectedVehicleType!.isNotEmpty))
                          ? const Color(0xFF1C2926)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                if (_isLoadingAdminOptions)
                  const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(strokeWidth: 1.8, color: Color(0xFF8B53FE)),
                  )
                else
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF71717A),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: ProviderOnboardingDetailsContentLayout.fieldGap),

        // 7. Plate Number Field (User types manually, 100% empty initial text)
        _buildFieldLabel(isArabic ? 'رقم اللوحة' : 'Plate Number'),
        const SizedBox(height: 6.0),
        _buildTextInputContainer(
          icon: Icons.badge_outlined,
          child: TextField(
            controller: _plateCtrl,
            textCapitalization: TextCapitalization.characters,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1C2926),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: isArabic ? 'أدخل رقم اللوحة (مثال: أ ب ج ١٢٣٤)' : 'Enter plate number (e.g. ABC 1234)',
              hintStyle: GoogleFonts.inter(
                fontSize: 14.0,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),

        const SizedBox(height: ProviderOnboardingDetailsContentLayout.fieldGap),

        // 8. Vehicle Color Field (User types manually, 100% empty initial text)
        _buildFieldLabel(isArabic ? 'لون المركبة' : 'Vehicle Color'),
        const SizedBox(height: 6.0),
        _buildTextInputContainer(
          icon: Icons.palette_outlined,
          child: TextField(
            controller: _colorCtrl,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1C2926),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: isArabic ? 'أدخل لون المركبة (مثال: أبيض)' : 'Enter vehicle color (e.g. White)',
              hintStyle: GoogleFonts.inter(
                fontSize: 14.0,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),

        const SizedBox(height: 28.0),

        // 9. Continue Button (Animated Press & Never Hides)
        ProviderAnimatedButton(
          onTap: _handleContinue,
          isLoading: _isLoading,
          backgroundColor: const Color(0xFF2D2A3D),
          foregroundColor: Colors.white,
          text: isArabic ? 'المتابعة' : 'Continue',
          icon: Icon(
            isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
            size: 18.0,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1C2926),
      ),
    );
  }

  Widget _buildHelperText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF71717A),
        height: 1.3,
      ),
    );
  }

  Widget _buildTextInputContainer({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      height: 52.0,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F4),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20.0,
            color: const Color(0xFF566663),
          ),
          const SizedBox(width: 12.0),
          Container(
            width: 1.0,
            height: 20.0,
            color: const Color(0xFFD6DAD8),
          ),
          const SizedBox(width: 12.0),
          Expanded(child: child),
        ],
      ),
    );
  }
}
