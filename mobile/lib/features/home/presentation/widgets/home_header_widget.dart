import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../providers/notifications_provider.dart';
import 'language_toggle_widget.dart';
import 'notification_bell_button.dart';
import 'urgent_assistance_card.dart';

/// Header widget strictly following the brand specifications:
/// - Dimensions: width 390, height 246
/// - Background: linear-gradient(180deg, #9FFFCB 0%, rgba(159, 255, 203, 0.37284) 68.53%, rgba(159, 255, 203, 0) 100%)
/// - Layout & Typography: Exact specifications from Figma redlines (20px margins, 24px vertical gaps)
class HomeHeaderWidget extends ConsumerWidget {
  final String userName;
  final String subtitle;
  final String location;
  final String locationLabel;
  final Widget? cardContent;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCardTap;

  const HomeHeaderWidget({
    super.key,
    this.userName = 'Shayan',
    this.subtitle = 'Explore Something',
    this.location = 'Karachi Pakistan',
    this.locationLabel = 'Current location',
    this.cardContent,
    this.onNotificationTap,
    this.onLocationTap,
    this.onProfileTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final String effectiveLocationLabel = (locationLabel == 'Current location')
        ? tr.currentLocation
        : locationLabel;

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // On web/desktop or simulated frames, ensure minimum 44px for authentic notch spacing
    final double effectiveTopPadding = statusBarHeight > 0 ? statusBarHeight : 44.0;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Background Gradient (width: 390; height: 246)
          // linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 256.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.009, -1.0),
                  end: Alignment(-0.009, 1.0),
                  stops: [0.0, 1.0],
                  colors: [
                    Color(0x188B53FE), // rgba(139, 83, 254, 0.094) soft subtle top tint
                    Color(0x008B53FE), // rgba(139, 83, 254, 0) at 29.8%
                  ],
                ),
              ),
            ),
          ),

          // Foreground Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status bar spacing with minor top breathing room
              SizedBox(height: effectiveTopPadding + 18.0),

          // 1. Profile, Location & Notification Row
          // width: 390; height: 36; justify-content: space-between; padding-left: 20px; padding-right: 20px;
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Avatar + Location Details
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar: width: 36; height: 36; circular
                        ClipOval(
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            color: const Color(0xFFFCA5A5), // Peach/coral background from reference
                            child: onProfileTap != null
                                ? GestureDetector(
                                    onTap: onProfileTap,
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
                                      width: 36.0,
                                      height: 36.0,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Icon(
                                          Icons.face_rounded,
                                          size: 26.0,
                                          color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
                                    width: 36.0,
                                    height: 36.0,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Icon(
                                        Icons.face_rounded,
                                        size: 26.0,
                                        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 8.0),

                        // Location text column
                        Flexible(
                          child: () {
                            final locationColumn = Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // "Current location"
                                Text(
                                  effectiveLocationLabel,
                                  style: tr.font(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF4A5568),
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1.0),
                                // "Karachi Pakistan"
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        location,
                                        style: tr.font(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF14221E),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 2.0),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16.0,
                                      color: Color(0xFF14221E),
                                    ),
                                  ],
                                ),
                              ],
                            );

                            if (onLocationTap == null) return locationColumn;
                            return GestureDetector(
                              onTap: onLocationTap,
                              behavior: HitTestBehavior.translucent,
                              child: locationColumn,
                            );
                          }(),
                        ),
                      ],
                    ),
                  ),

                  // Right side: Language Toggle with linear gradient + Notification icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const LanguageToggleWidget(),
                      const SizedBox(width: 8.0),
                      NotificationBellButton(
                        hasNotification: ref.watch(notificationsProvider).hasCustomerUnread,
                        onTap: onNotificationTap ??
                            () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .toggleCustomerCard();
                            },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

              // Spacing between Profile row and Urgent Assistance Card
              const SizedBox(height: 16.0),

              // 3. Urgent Assistance Card Container:
              // width: 350; height: 70; top: 176px; left: 20px; angle: 0 deg; opacity: 1; gap: 10px; border-width: 1px; border-radius: 12px; padding: 16px; background: #FFFFFF;
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: UrgentAssistanceCard(
                  onTap: onCardTap,
                  child: cardContent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
