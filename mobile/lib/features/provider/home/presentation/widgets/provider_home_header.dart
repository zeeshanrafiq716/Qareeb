import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/home/presentation/widgets/notification_bell_button.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/providers/notifications_provider.dart';
import 'package:mobile/services/profile_stats_service.dart';

/// Provider Home Screen Header Widget
/// Implements exact Figma branding specifications:
///
/// header layout:
///   width: 390;
///   height: 36;
///   justify-content: space-between;
///   angle: 0 deg;
///   opacity: 1;
///   padding-right: 20px;
///   padding-left: 20px;
///
/// left content layout:
///   width: 132;
///   height: 36;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// img layout:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///
/// content: Good morning,
///   width: 84;
///   height: 9;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #616166;
///
/// content: Ahmed Raza
///   width: 84;
///   height: 10;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 14px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #252527;
///
/// notification icon layout:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///   border-width: 1px;
class ProviderHomeHeader extends ConsumerWidget {
  final String? providerName;
  final String? greeting;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final bool showLanguageToggle;
  final bool? hasNotification;

  const ProviderHomeHeader({
    super.key,
    this.providerName,
    this.greeting,
    this.avatarUrl,
    this.onProfileTap,
    this.onNotificationTap,
    this.showLanguageToggle = true,
    this.hasNotification,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 36.0;
  static const double horizontalPadding = 20.0;
  static const double leftContentWidth = 132.0;
  static const double leftContentHeight = 36.0;
  static const double leftContentGap = 12.0;
  static const double avatarSize = 36.0;
  static const double textWidth = 84.0;
  static const double notificationIconSize = 36.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isArabic = context.isArabic;
    final registrationData = ref.watch(providerRegistrationProvider);
    final String storedName = registrationData.fullName.isNotEmpty
        ? registrationData.fullName
        : ProviderRegistrationStore.instance.data.fullName;
    final String effectiveRawName = (providerName != null && providerName!.isNotEmpty)
        ? providerName!
        : (storedName.isNotEmpty ? storedName : 'Ahmed Raza');

    // Dynamic timeline-based greeting:
    // 05:00 - 11:59: Good morning
    // 12:00 - 16:59: Good afternoon
    // 17:00 - 21:59: Good evening
    // 22:00 - 04:59: Good evening / night
    final int hour = DateTime.now().hour;
    final String timelineGreeting;
    if (hour >= 5 && hour < 12) {
      timelineGreeting = isArabic ? 'صباح الخير،' : 'Good morning,';
    } else if (hour >= 12 && hour < 17) {
      timelineGreeting = isArabic ? 'مساء الخير،' : 'Good afternoon,';
    } else if (hour >= 17 && hour < 22) {
      timelineGreeting = isArabic ? 'مساء الخير،' : 'Good evening,';
    } else {
      timelineGreeting = isArabic ? 'مساء الخير،' : 'Good evening,';
    }
    final String effectiveGreeting = greeting ?? timelineGreeting;

    final String effectiveName = isArabic ? context.auto(effectiveRawName) : effectiveRawName;
    const String defaultAvatarAsset = 'assets/images/driver_avatar.png';

    // Ensure saved photo is loaded into notifier if not already done
    if (ProfileStatsService.instance.providerPhotoNotifier.value == null) {
      ProfileStatsService.instance.getSavedPhotoPath(isProvider: true);
    }

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: double.infinity,
          height: designHeight,
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-content: space-between
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Left content layout: avatar + dynamic greeting & name
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // img layout: width: 36; height: 36; angle: 0 deg; opacity: 1;
                    Opacity(
                      opacity: 1.0, // opacity: 1
                      child: Transform.rotate(
                        angle: 0.0, // angle: 0 deg
                        child: SizedBox(
                          width: avatarSize,
                          height: avatarSize,
                          child: GestureDetector(
                            onTap: onProfileTap,
                            child: ValueListenableBuilder<String?>(
                              valueListenable: ProfileStatsService.instance.providerPhotoNotifier,
                              builder: (context, savedPhotoPath, _) {
                                final effectivePhoto = (avatarUrl != null && avatarUrl!.isNotEmpty)
                                    ? avatarUrl!
                                    : (savedPhotoPath ?? '');
                                final bool isNetworkAvatar = effectivePhoto.startsWith('http://') ||
                                    effectivePhoto.startsWith('https://');
                                final bool isLocalFile = !isNetworkAvatar &&
                                    effectivePhoto.isNotEmpty &&
                                    File(effectivePhoto).existsSync();
                                final bool isAsset = !isNetworkAvatar &&
                                    !isLocalFile &&
                                    effectivePhoto.isNotEmpty &&
                                    effectivePhoto != defaultAvatarAsset;

                                Widget avatarContent;
                                if (isNetworkAvatar) {
                                  avatarContent = Image.network(
                                    effectivePhoto,
                                    width: avatarSize,
                                    height: avatarSize,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _defaultAvatarIcon(),
                                  );
                                } else if (isLocalFile) {
                                  avatarContent = Image.file(
                                    File(effectivePhoto),
                                    width: avatarSize,
                                    height: avatarSize,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _defaultAvatarIcon(),
                                  );
                                } else if (isAsset) {
                                  avatarContent = Image.asset(
                                    effectivePhoto,
                                    width: avatarSize,
                                    height: avatarSize,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _defaultAvatarIcon(),
                                  );
                                } else {
                                  avatarContent = _defaultAvatarIcon();
                                }

                                return ClipOval(
                                  child: Container(
                                    width: avatarSize,
                                    height: avatarSize,
                                    color: const Color(0xFFF0EAFE),
                                    child: avatarContent,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // gap: 12px;
                    const SizedBox(width: leftContentGap),

                    // Greeting + Name (Arabic Cairo glyphs need scale-to-fit in 36px header)
                    Expanded(
                      child: SizedBox(
                        height: leftContentHeight,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: textWidth * 2.2,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    effectiveGreeting,
                                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                      fontSize: isArabic ? 11.0 : 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF616166),
                                      letterSpacing: 0.0,
                                      height: isArabic ? 1.0 : 1.1,
                                    ),
                                    textHeightBehavior: const TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    effectiveName,
                                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                      fontSize: isArabic ? 13.0 : 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF252527),
                                      letterSpacing: 0.0,
                                      height: isArabic ? 1.0 : 1.15,
                                    ),
                                    textHeightBehavior: const TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // 2. Right side: Language Toggle (optional) + Notification Icon
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showLanguageToggle) ...[
                    const ProviderAnimatedLanguageToggle.compact(),
                    const SizedBox(width: 12.0),
                  ],

                  // Notification icon layout: width: 36; height: 36; angle: 0 deg; opacity: 1; border-width: 1px;
                  NotificationBellButton(
                    hasNotification: hasNotification ??
                        ref.watch(notificationsProvider).hasProviderUnread,
                    onTap: onNotificationTap ??
                        () {
                          ref
                              .read(notificationsProvider.notifier)
                              .toggleProviderCard();
                        },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatarIcon() {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        size: 22.0,
        color: Color(0xFF8B53FE),
      ),
    );
  }
}
