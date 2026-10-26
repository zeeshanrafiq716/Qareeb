import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../models/category_model.dart';
import '../../../../providers/backend_provider.dart';
import 'category_card_widget.dart';

/// Services / Main Content section widget.
/// Specifications:
/// - Heading & Subtitle Branding (350px width, 12px text gap)
///   - Heading: "Choose Your Ride" (14px, Inter Medium 500, #1C2926)
///   - Subtitle: "Choose a service and see available options." (12px, Inter Regular 400, #566663)
///
/// Dynamic Category Grid:
/// - Exact 2-card row layout (169px wide on 390 viewport, 120px tall)
/// - 12px horizontal gap between cards
/// - 12px vertical gap between rows
/// - Admin extensible: when categories are added or fetched from backend,
///   they automatically render with this exact identical branding layout.
class ServicesSectionWidget extends ConsumerWidget {
  final String heading;
  final String subtitle;
  final List<CategoryModel>? categories;
  final void Function(CategoryModel)? onCategoryTap;
  final Widget? card1Content;
  final Widget? card2Content;
  final VoidCallback? onCard1Tap;
  final VoidCallback? onCard2Tap;

  /// Default baseline categories matching Figma branding
  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 1,
      name: 'Ride',
      slug: 'ride',
      subtitle: 'City & local rides',
      assetImage: 'assets/images/car_ride.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 2,
      name: 'Pickup',
      slug: 'pickup',
      subtitle: 'Goods & deliveries',
      assetImage: 'assets/images/pickup.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 3,
      name: 'Rider',
      slug: 'rider',
      subtitle: 'Fast & convenient',
      assetImage: 'assets/images/rider_bike.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 4,
      name: 'Van',
      slug: 'van',
      subtitle: 'Group & family travel',
      assetImage: 'assets/images/van.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 5,
      name: 'Auto',
      slug: 'auto',
      subtitle: 'Affordable local travel',
      isEnabled: true,
    ),
    CategoryModel(
      id: 6,
      name: 'Emergency',
      slug: 'emergency',
      subtitle: 'Urgent roadside aid',
      isEnabled: true,
    ),
    // 6 Additional category cards copied from the first 4 cards
    CategoryModel(
      id: 7,
      name: 'Ride',
      slug: 'ride',
      subtitle: 'City & local rides',
      assetImage: 'assets/images/car_ride.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 8,
      name: 'Pickup',
      slug: 'pickup',
      subtitle: 'Goods & deliveries',
      assetImage: 'assets/images/pickup.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 9,
      name: 'Rider',
      slug: 'rider',
      subtitle: 'Fast & convenient',
      assetImage: 'assets/images/rider_bike.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 10,
      name: 'Van',
      slug: 'van',
      subtitle: 'Group & family travel',
      assetImage: 'assets/images/van.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 11,
      name: 'Ride',
      slug: 'ride',
      subtitle: 'City & local rides',
      assetImage: 'assets/images/car_ride.png',
      isEnabled: true,
    ),
    CategoryModel(
      id: 12,
      name: 'Pickup',
      slug: 'pickup',
      subtitle: 'Goods & deliveries',
      assetImage: 'assets/images/pickup.png',
      isEnabled: true,
    ),
  ];

  const ServicesSectionWidget({
    super.key,
    this.heading = 'Choose Your Ride',
    this.subtitle = 'Choose a service and see available options.',
    this.categories,
    this.onCategoryTap,
    this.card1Content,
    this.card2Content,
    this.onCard1Tap,
    this.onCard2Tap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine active category list:
    // 1. Explicitly passed categories (e.g. customized or filtered)
    // 2. Live categories from backend provider (synced with admin dashboard)
    // 3. Default preset categories (Row 1: Ride, Pickup; Row 2: Delivery, Moto)
    List<CategoryModel> activeCategories;
    if (categories != null && categories!.isNotEmpty) {
      activeCategories = categories!.where((c) => c.isEnabled).toList();
    } else {
      final backendCategories = ref.watch(categoriesProvider);
      activeCategories = backendCategories.maybeWhen(
        data: (items) {
          final enabled = items.where((c) => c.isEnabled).toList();
          return enabled.isNotEmpty ? enabled : defaultCategories;
        },
        orElse: () => defaultCategories,
      );
    }

    final tr = ref.watch(translationsProvider);
    final String effectiveHeading =
        (heading == 'Choose Your Ride') ? tr.chooseYourRide : heading;
    final String effectiveSubtitle =
        (subtitle == 'Choose a service and see available options.')
            ? tr.chooseRideSubtitle
            : subtitle;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Heading & Subtitle text branding (width: 350, gap: 12px)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heading: Choose Your Ride
                Text(
                  effectiveHeading,
                  style: tr.font(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C2926),
                    height: 1.1,
                  ),
                ),

                // gap: reduced from 12px to 4px
                const SizedBox(height: 4.0),

                // Text: Choose a service and see available options.
                Text(
                  effectiveSubtitle,
                  style: tr.font(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF566663),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // 16px gap (brings top coordinate to categories section)
          const SizedBox(height: 16.0),

          // 2. Dynamic Categories Section (width: 350, left: 20px, gap: 12px)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildCategoryGrid(activeCategories, tr),
          ),
        ],
      ),
    );
  }

  /// Builds pairs of category cards with 12px vertical gap between rows
  /// and 12px horizontal gap between cards.
  Widget _buildCategoryGrid(List<CategoryModel> items, AppTranslations tr) {
    final List<Widget> rows = [];

    for (int i = 0; i < items.length; i += 2) {
      // 12px gap between rows
      if (i > 0) {
        rows.add(const SizedBox(height: 12.0));
      }

      final firstCategory = items[i];
      final secondCategory = (i + 1 < items.length) ? items[i + 1] : null;

      // Check if custom override content was provided for first 2 cards
      final Widget? customFirst = (i == 0) ? card1Content : null;
      final Widget? customSecond = (i == 0) ? card2Content : null;
      final VoidCallback? tapFirst = (i == 0 && onCard1Tap != null)
          ? onCard1Tap
          : (onCategoryTap != null ? () => onCategoryTap!(firstCategory) : null);
      final VoidCallback? tapSecond = (i == 0 && onCard2Tap != null)
          ? onCard2Tap
          : (secondCategory != null && onCategoryTap != null
              ? () => onCategoryTap!(secondCategory)
              : null);

      rows.add(
        Row(
          children: [
            // Card 1 in the row (169px on 390 viewport, height 120)
            Expanded(
              child: CategoryCardWidget.fromModel(
                firstCategory,
                titleOverride: tr.categoryName(firstCategory.slug, firstCategory.name),
                subtitleOverride: tr.categorySubtitle(firstCategory.slug, firstCategory.displaySubtitle),
                tr: tr,
                onTap: tapFirst,
                customContent: customFirst,
              ),
            ),

            // 12px gap between cards in the row
            const SizedBox(width: 12.0),

            // Card 2 in the row (or empty spacer to maintain 169px half slot)
            Expanded(
              child: secondCategory != null
                  ? CategoryCardWidget.fromModel(
                      secondCategory,
                      titleOverride: tr.categoryName(secondCategory.slug, secondCategory.name),
                      subtitleOverride: tr.categorySubtitle(secondCategory.slug, secondCategory.displaySubtitle),
                      tr: tr,
                      onTap: tapSecond,
                      customContent: customSecond,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}
