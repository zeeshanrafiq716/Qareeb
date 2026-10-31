import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';
import 'package:mobile/models/country_model.dart';

/// Modal bottom sheet allowing provider to pick their country from a complete list.
/// Designed to seamlessly match the Qareeb design system.
class ProviderCountryPickerModal extends StatefulWidget {
  final CountryModel selectedCountry;
  final ValueChanged<CountryModel> onCountrySelected;

  const ProviderCountryPickerModal({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  static Future<CountryModel?> show(
    BuildContext context, {
    required CountryModel selectedCountry,
  }) {
    return showModalBottomSheet<CountryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => ProviderCountryPickerModal(
        selectedCountry: selectedCountry,
        onCountrySelected: (c) => Navigator.of(context).pop(c),
      ),
    );
  }

  @override
  State<ProviderCountryPickerModal> createState() => _ProviderCountryPickerModalState();
}

class _ProviderCountryPickerModalState extends State<ProviderCountryPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryModel> _filteredCountries = CountryModel.allCountries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredCountries = CountryModel.allCountries;
      });
      return;
    }

    setState(() {
      _filteredCountries = CountryModel.allCountries.where((country) {
        final nameEn = country.nameEn.toLowerCase();
        final nameAr = country.nameAr.toLowerCase();
        final dial = country.dialCode.replaceAll('+', '').toLowerCase();
        final code = country.code.toLowerCase();
        final cleanQuery = query.replaceAll('+', '');

        return nameEn.contains(query) ||
            nameAr.contains(query) ||
            dial.contains(cleanQuery) ||
            code.contains(cleanQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double modalHeight = (screenHeight * 0.75).clamp(380.0, 680.0);

    return Container(
      height: modalHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.0),
          topRight: Radius.circular(28.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16.0,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12.0),

          // Top Grab Handle (Matching Figma Bar layout)
          Center(
            child: Container(
              width: 60.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: ProviderColors.cardHandleBar, // #EFF0ED
                borderRadius: BorderRadius.circular(60.0),
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          // Title & Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'اختر الدولة' : 'Select Country',
                  style: ProviderTextStyles.cardHeadingTitle.copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20.0, color: Color(0xFF566663)),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14.0),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 48.0,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: BoxDecoration(
                color: ProviderColors.inputBackground, // #F2F5F4
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF566663),
                    size: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: ProviderTextStyles.phoneInput,
                      cursorColor: ProviderColors.primaryButton,
                      decoration: InputDecoration(
                        hintText: isArabic ? 'ابحث باسم الدولة أو رمز الاتصال...' : 'Search by country or dial code...',
                        hintStyle: ProviderTextStyles.phonePlaceholder,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                      },
                      child: const Icon(
                        Icons.cancel,
                        color: Color(0xFFADB8B4),
                        size: 18.0,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12.0),

          // Country List
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      isArabic ? 'لم يتم العثور على نتائج' : 'No countries found',
                      style: ProviderTextStyles.cardHeadingSubtitle,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1.0,
                      thickness: 0.6,
                      color: Color(0xFFF0F2F1),
                    ),
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final bool isSelected = country.code == widget.selectedCountry.code;

                      return InkWell(
                        onTap: () => widget.onCountrySelected(country),
                        borderRadius: BorderRadius.circular(10.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                          child: Row(
                            children: [
                              // Country Flag
                              SizedBox(
                                width: 34.0,
                                height: 24.0,
                                child: Center(
                                  child: Text(
                                    country.flagEmoji,
                                    style: const TextStyle(fontSize: 22.0),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14.0),

                              // Country Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      country.localizedName(isArabic),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15.0,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected ? ProviderColors.primaryButton : const Color(0xFF1C2926),
                                      ),
                                    ),
                                    Text(
                                      isArabic ? country.nameEn : country.nameAr,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11.0,
                                        color: Color(0xFF8E9996),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Dial Code
                              Text(
                                country.dialCode,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? ProviderColors.primaryButton : const Color(0xFF566663),
                                ),
                              ),

                              const SizedBox(width: 10.0),

                              // Selection Checkmark
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: ProviderColors.primaryButton,
                                  size: 18.0,
                                )
                              else
                                const SizedBox(width: 18.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
