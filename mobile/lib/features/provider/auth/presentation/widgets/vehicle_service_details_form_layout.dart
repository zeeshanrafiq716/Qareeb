import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/services/backend_service.dart';

/// Vehicle & Service Details Form Layout Widget
/// Matches exact Figma branding and layout from uploaded screenshot:
///
/// 1. Vehicle Type (Dropdown, truck icon, placeholder: Flatbed Truck)
/// 2. Vehicle Color (Input/Picker, palette icon, placeholder: White)
/// 3. Plate Number (Input, license/badge icon, placeholder: ABC 1234)
/// 4. Service Category (Dropdown, truck icon, placeholder: Vehicle Towing)
/// 5. Warning Card (Amber, exclamation icon: "Category changes require admin re-approval.")
/// 6. Save Changes Button (Purple #8B53FE, 52px height, "Save Changes ->")
class VehicleServiceDetailsFormLayout extends StatefulWidget {
  final VoidCallback? onContinue;

  const VehicleServiceDetailsFormLayout({
    super.key,
    this.onContinue,
  });

  static const double designWidth = 350.0;
  static const double fieldGap = 18.0;

  @override
  State<VehicleServiceDetailsFormLayout> createState() =>
      _VehicleServiceDetailsFormLayoutState();
}

class _VehicleServiceDetailsFormLayoutState
    extends State<VehicleServiceDetailsFormLayout> {
  late final TextEditingController _serviceCategoryCtrl;
  late final TextEditingController _vehicleTypeCtrl;
  late final TextEditingController _plateNumberCtrl;
  late final TextEditingController _vehicleColorCtrl;
  bool _isLoading = false;
  late final BackendService _backendService;
  List<String> _liveServiceCategories = [];
  List<String> _liveVehicleTypes = [];

  Future<void> _loadLiveCategoriesAndTypes() async {
    try {
      final results = await Future.wait([
        _backendService.getCategories(),
        _backendService.getVehicleTypes(),
      ]);

      final cats = results[0] as List<dynamic>;
      final types = results[1] as List<String>;

      if (mounted) {
        setState(() {
          if (cats.isNotEmpty) {
            _liveServiceCategories = cats.map((c) => c.name.toString()).toList();
            if (_serviceCategoryCtrl.text.isEmpty ||
                !_liveServiceCategories.contains(_serviceCategoryCtrl.text)) {
              _serviceCategoryCtrl.text = _liveServiceCategories.first;
            }
          }
          if (types.isNotEmpty) {
            _liveVehicleTypes = types;
            if (_vehicleTypeCtrl.text.isEmpty ||
                !_liveVehicleTypes.contains(_vehicleTypeCtrl.text)) {
              _vehicleTypeCtrl.text = types.first;
            }
          }
        });
      }
    } catch (_) {}
  }

  static const List<String> vehicleColors = [
    'White',
    'Black',
    'Silver',
    'Grey',
    'Red',
    'Blue',
    'Yellow',
    'Green',
  ];

  @override
  void initState() {
    super.initState();
    final data = ProviderRegistrationStore.instance.data;
    _serviceCategoryCtrl = TextEditingController(
      text: data.serviceCategory,
    );
    _vehicleTypeCtrl = TextEditingController(
      text: data.vehicleType,
    );
    _plateNumberCtrl = TextEditingController(
      text: data.plateNumber,
    );
    _vehicleColorCtrl = TextEditingController(
      text: data.vehicleColor.isNotEmpty ? data.vehicleColor : 'White',
    );
    _backendService = BackendService(ApiClient());
    _loadLiveCategoriesAndTypes();
  }

  @override
  void dispose() {
    _serviceCategoryCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _plateNumberCtrl.dispose();
    _vehicleColorCtrl.dispose();
    super.dispose();
  }

  void _showSelectionModal({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  ),
                ),
                const SizedBox(height: 12.0),
                if (options.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'No options available',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: Color(0xFFF2F5F4),
                    ),
                    itemBuilder: (context, index) {
                      final item = options[index];
                      final isSelected = item == selectedValue;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context.auto(item),
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF1C2926),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF8B53FE),
                                size: 20.0,
                              )
                            : null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onSelected(item);
                          Navigator.of(ctx).pop();
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
  }

  Future<void> _handleSaveChanges() async {
    if (_isLoading) return;

    final isArabic = context.isArabic;
    final plate = _plateNumberCtrl.text.trim();
    final color = _vehicleColorCtrl.text.trim();
    final vehicleType = _vehicleTypeCtrl.text.trim();
    final serviceCategory = _serviceCategoryCtrl.text.trim();

    if (plate.isEmpty) {
      _showFeedback(
        context,
        isArabic ? 'يرجى إدخال رقم اللوحة' : 'Please enter vehicle plate number',
      );
      return;
    }

    if (color.isEmpty) {
      _showFeedback(
        context,
        isArabic ? 'يرجى إدخال لون المركبة' : 'Please enter vehicle color',
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Persist to central registration store
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        serviceCategory: serviceCategory,
        vehicleType: vehicleType,
        plateNumber: plate,
        vehicleColor: color,
      ),
    );

    // 2. Call backend service update
    try {
      await _backendService.updateProviderProfile(
        name: ProviderRegistrationStore.instance.data.fullName,
        categoryId: serviceCategory,
        address: '',
        city: '',
      );
    } catch (_) {
      // Graceful offline fallback
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showFeedback(
      context,
      isArabic
          ? 'تم حفظ بيانات المركبة والخدمة بنجاح'
          : 'Vehicle & service details saved successfully',
      isSuccess: true,
    );

    if (widget.onContinue != null) {
      widget.onContinue!();
      return;
    }

    // Return to Profile Tab screen
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.settings.name == '/profile' || route.isFirst);
    }
  }

  void _showFeedback(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        backgroundColor: const Color(0xFF1C2926),
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.info_outline,
              color: isSuccess ? ProviderColors.whatsappGreen : Colors.orangeAccent,
              size: 20.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Vehicle Type Field
          Text(
            isArabic ? 'نوع المركبة' : 'Vehicle Type',
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  )
                : GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showSelectionModal(
                title: isArabic ? 'اختر نوع المركبة' : 'Select Vehicle Type',
                options: _liveVehicleTypes.isNotEmpty
                    ? _liveVehicleTypes
                    : (_vehicleTypeCtrl.text.isNotEmpty
                        ? [_vehicleTypeCtrl.text]
                        : <String>[]),
                selectedValue: _vehicleTypeCtrl.text,
                onSelected: (val) {
                  setState(() => _vehicleTypeCtrl.text = val);
                },
              );
            },
            child: Container(
              height: 52.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 20.0,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Text(
                      _vehicleTypeCtrl.text.isNotEmpty
                          ? context.auto(_vehicleTypeCtrl.text)
                          : (isArabic ? 'اختر نوع المركبة' : 'Select Vehicle Type'),
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: _vehicleTypeCtrl.text.isNotEmpty
                            ? const Color(0xFF1C2926)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22.0,
                    color: Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18.0),

          // 2. Vehicle Color Field
          Text(
            isArabic ? 'لون المركبة' : 'Vehicle Color',
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  )
                : GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showSelectionModal(
                title: isArabic ? 'اختر لون المركبة' : 'Select Vehicle Color',
                options: vehicleColors,
                selectedValue: _vehicleColorCtrl.text,
                onSelected: (val) {
                  setState(() => _vehicleColorCtrl.text = val);
                },
              );
            },
            child: Container(
              height: 52.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.palette_outlined,
                    size: 20.0,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Text(
                      _vehicleColorCtrl.text,
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1C2926),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18.0),

          // 3. Plate Number Field
          Text(
            isArabic ? 'رقم اللوحة' : 'Plate Number',
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  )
                : GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  ),
          ),
          const SizedBox(height: 8.0),
          Container(
            height: 52.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                const Icon(
                  Icons.subtitles_outlined,
                  size: 20.0,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: TextField(
                    controller: _plateNumberCtrl,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1C2926),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'ABC 1234',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18.0),

          // 4. Service Category Field
          Text(
            isArabic ? 'فئة الخدمة' : 'Service Category',
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  )
                : GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showSelectionModal(
                title: isArabic ? 'اختر فئة الخدمة' : 'Select Service Category',
                options: _liveServiceCategories.isNotEmpty
                    ? _liveServiceCategories
                    : (_serviceCategoryCtrl.text.isNotEmpty
                        ? [_serviceCategoryCtrl.text]
                        : ['Service']),
                selectedValue: _serviceCategoryCtrl.text,
                onSelected: (val) {
                  setState(() => _serviceCategoryCtrl.text = val);
                },
              );
            },
            child: Container(
              height: 52.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 20.0,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Text(
                      _serviceCategoryCtrl.text.isNotEmpty
                          ? context.auto(_serviceCategoryCtrl.text)
                          : (isArabic ? 'اختر فئة الخدمة' : 'Select Service Category'),
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: _serviceCategoryCtrl.text.isNotEmpty
                            ? const Color(0xFF1C2926)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22.0,
                    color: Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22.0),

          // 5. Warning / Notice Box
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9EB),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: const Color(0xFFFED7AA),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.priority_high_rounded,
                      size: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? 'تتطلب تغييرات الفئة إعادة موافقة الإدارة.'
                            : 'Category changes require admin re-approval.',
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1C2926),
                              )
                            : GoogleFonts.inter(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1C2926),
                              ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        isArabic
                            ? 'قد يتم تقييد حسابك مؤقتاً حتى تتم الموافقة.'
                            : 'Your account may be temporarily limited until approved.',
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF616166),
                                height: 1.35,
                              )
                            : GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF616166),
                                height: 1.35,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // 6. Save Changes Button (Animated, does not hide content)
          ProviderAnimatedButton(
            onTap: _handleSaveChanges,
            isLoading: _isLoading,
            text: isArabic ? 'حفظ التغييرات' : 'Save Changes',
            textStyle: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )
                : GoogleFonts.inter(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            icon: Icon(
              isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
              size: 18.0,
              color: Colors.white,
            ),
          ),

          // Flexible bottom indicator
          const SizedBox(height: 24.0),
          const Center(child: ProviderCardBottomIndicator()),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
