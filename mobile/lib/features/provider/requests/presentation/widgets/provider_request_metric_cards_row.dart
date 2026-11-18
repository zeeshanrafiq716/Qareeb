import 'package:flutter/material.dart';
import 'package:mobile/features/provider/requests/presentation/widgets/provider_request_sheet_typography.dart';

/// Distance + ETA twin cards used in provider request bottom sheets.
class ProviderRequestMetricCardsRow extends StatelessWidget {
  const ProviderRequestMetricCardsRow({
    super.key,
    required this.isArabic,
    required this.distanceValue,
    required this.etaValue,
  });

  final bool isArabic;
  final String distanceValue;
  final String etaValue;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ProviderMetricCard(
              isArabic: isArabic,
              icon: Icons.location_on_rounded,
              value: distanceValue,
              label: isArabic ? 'المسافة' : 'Distance Away',
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: _ProviderMetricCard(
              isArabic: isArabic,
              icon: Icons.access_time_rounded,
              value: etaValue,
              label: isArabic ? 'الوقت المتوقع' : 'Estimated time',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderMetricCard extends StatelessWidget {
  const _ProviderMetricCard({
    required this.isArabic,
    required this.icon,
    required this.value,
    required this.label,
  });

  final bool isArabic;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2F5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: ProviderRequestSheetTypography.iconBox,
            height: ProviderRequestSheetTypography.iconBox,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE7E6EB),
            ),
            child: Icon(
              icon,
              size: ProviderRequestSheetTypography.iconGlyph,
              color: const Color(0xFF252527),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: ProviderRequestSheetTypography.label(isArabic),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
                const SizedBox(
                    height: ProviderRequestSheetTypography.labelGap),
                Text(
                  value,
                  style: ProviderRequestSheetTypography.value(isArabic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}