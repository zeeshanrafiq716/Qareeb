import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/upload_documents_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_continue_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_input_field.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_input_icons.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Vehicle & Service Details Form Layout Widget
/// Implements exact Figma branding specifications following previous screen:
///
/// Layout specs:
///   width: 350;
///   gap: 20px between fields;
///   gap: 24px before Continue button;
///
/// 1. Service Category (Dropdown, icon: Truck, placeholder: Vehicle Towing)
/// 2. Vehicle Type (Dropdown, icon: Truck, placeholder: Flatbed Truck)
/// 3. Plate Number (Text input, icon: LicensePlate, placeholder: ABC 1234)
/// 4. Vehicle Model (Text input, icon: Truck, placeholder: Enter vehicle model)
/// 5. Vehicle Color (Selectable/Input, icon: Palette, placeholder: White)
/// 6. Continue Button (width: 100%, height: 52, radius: 12, bg: #1D8070, text: Continue ->)
class VehicleServiceDetailsFormLayout extends StatefulWidget {
  final VoidCallback? onContinue;

  const VehicleServiceDetailsFormLayout({
    super.key,
    this.onContinue,
  });

  static const double designWidth = 350.0;
  static const double fieldGap = 20.0;
  static const double buttonGap = 24.0;

  @override
  State<VehicleServiceDetailsFormLayout> createState() =>
      _VehicleServiceDetailsFormLayoutState();
}

class _VehicleServiceDetailsFormLayoutState
    extends State<VehicleServiceDetailsFormLayout> {
  late final TextEditingController _serviceCategoryCtrl;
  late final TextEditingController _vehicleTypeCtrl;
  late final TextEditingController _plateNumberCtrl;
  late final TextEditingController _vehicleModelCtrl;
  late final TextEditingController _vehicleColorCtrl;

  static const List<String> serviceCategories = [
    'Vehicle Towing',
    'Flatbed Towing',
    'Battery Jumpstart',
    'Tire Assistance',
    'Fuel Delivery',
    'Emergency Recovery',
  ];

  static const List<String> vehicleTypes = [
    'Flatbed Truck',
    'Wheel-Lift Tow Truck',
    'Integrated Tow Truck',
    'Heavy-Duty Recovery Truck',
    'Service Van',
  ];

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
    _serviceCategoryCtrl = TextEditingController(text: 'Vehicle Towing');
    _vehicleTypeCtrl = TextEditingController(text: 'Flatbed Truck');
    _plateNumberCtrl = TextEditingController();
    _vehicleModelCtrl = TextEditingController();
    _vehicleColorCtrl = TextEditingController(text: 'White');
  }

  @override
  void dispose() {
    _serviceCategoryCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _plateNumberCtrl.dispose();
    _vehicleModelCtrl.dispose();
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
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEE0DF),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  title,
                  style: ProviderTextStyles.cardHeadingTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12.0),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Color(0xFFF2F5F4),
                    ),
                    itemBuilder: (context, index) {
                      final item = options[index];
                      final isSelected = item == selectedValue;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item,
                          style: ProviderTextStyles.profileInputText.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? ProviderColors.primaryButton
                                : const Color(0xFF1C2926),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: ProviderColors.primaryButton,
                                size: 20.0,
                              )
                            : null,
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(ctx);
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: VehicleServiceDetailsFormLayout.designWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Service Category (Dropdown)
          ProviderProfileInputField(
            label: 'Service Category',
            placeholder: 'Vehicle Towing',
            controller: _serviceCategoryCtrl,
            readOnly: true,
            onTap: () {
              _showSelectionModal(
                title: 'Select Service Category',
                options: serviceCategories,
                selectedValue: _serviceCategoryCtrl.text,
                onSelected: (val) {
                  setState(() => _serviceCategoryCtrl.text = val);
                },
              );
            },
            icon: const TruckOutlineIconWidget(),
            suffixIcon: const DropdownChevronWidget(),
          ),

          // gap: 20px
          const SizedBox(height: VehicleServiceDetailsFormLayout.fieldGap),

          // 2. Vehicle Type (Dropdown)
          ProviderProfileInputField(
            label: 'Vehicle Type',
            placeholder: 'Flatbed Truck',
            controller: _vehicleTypeCtrl,
            readOnly: true,
            onTap: () {
              _showSelectionModal(
                title: 'Select Vehicle Type',
                options: vehicleTypes,
                selectedValue: _vehicleTypeCtrl.text,
                onSelected: (val) {
                  setState(() => _vehicleTypeCtrl.text = val);
                },
              );
            },
            icon: const TruckOutlineIconWidget(),
            suffixIcon: const DropdownChevronWidget(),
          ),

          // gap: 20px
          const SizedBox(height: VehicleServiceDetailsFormLayout.fieldGap),

          // 3. Plate Number (Text Input)
          ProviderProfileInputField(
            label: 'Plate Number',
            placeholder: 'ABC 1234',
            controller: _plateNumberCtrl,
            keyboardType: TextInputType.text,
            icon: const LicensePlateOutlineIconWidget(),
          ),

          // gap: 20px
          const SizedBox(height: VehicleServiceDetailsFormLayout.fieldGap),

          // 4. Vehicle Model (Text Input)
          ProviderProfileInputField(
            label: 'Vehicle Model',
            placeholder: 'Enter vehicle model',
            controller: _vehicleModelCtrl,
            keyboardType: TextInputType.text,
            icon: const TruckOutlineIconWidget(),
          ),

          // gap: 20px
          const SizedBox(height: VehicleServiceDetailsFormLayout.fieldGap),

          // 5. Vehicle Color (Selectable/Input)
          ProviderProfileInputField(
            label: 'Vehicle Color',
            placeholder: 'White',
            controller: _vehicleColorCtrl,
            readOnly: true,
            onTap: () {
              _showSelectionModal(
                title: 'Select Vehicle Color',
                options: vehicleColors,
                selectedValue: _vehicleColorCtrl.text,
                onSelected: (val) {
                  setState(() => _vehicleColorCtrl.text = val);
                },
              );
            },
            icon: const PaletteOutlineIconWidget(),
          ),

          // gap: 24px
          const SizedBox(height: VehicleServiceDetailsFormLayout.buttonGap),

          // 6. Continue Button with same branding: width: 100%, height: 52, radius: 12, bg: #1D8070, text: Continue ->
          ProviderContinueButton(
            onTap: widget.onContinue ?? () => _defaultOnContinue(context),
          ),

          // Flexible bottom indicator: scrolls naturally at the end of the form
          const SizedBox(height: 24.0),
          const ProviderCardBottomIndicator(),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }

  void _defaultOnContinue(BuildContext context) {
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
