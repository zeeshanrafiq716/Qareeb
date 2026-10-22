import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/home/presentation/widgets/notification_bell_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/providers/notifications_provider.dart';

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
  final String providerName;
  final String? greeting;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final bool showLanguageToggle;
  final bool? hasNotification;

  const ProviderHomeHeader({
    super.key,
    this.providerName = 'Ahmed Raza',
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
    final String effectiveGreeting = greeting ??
        (isArabic ? 'صباح الخير،' : 'Good morning,');
    final String effectiveName = isArabic ? context.auto(providerName) : providerName;
    const String defaultAvatarAsset = 'assets/images/driver_avatar.png';
    final bool isNetworkAvatar = avatarUrl != null &&
        (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://'));

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
              // 1. Left content layout: width: 132; height: 36; gap: 12px; angle: 0 deg; opacity: 1;
              Opacity(
                opacity: 1.0, // opacity: 1
                child: Transform.rotate(
                  angle: 0.0, // angle: 0 deg
                  child: SizedBox(
                    width: leftContentWidth,
                    height: leftContentHeight,
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
                                child: ClipOval(
                                  child: Container(
                                    width: avatarSize,
                                    height: avatarSize,
                                    color: const Color(0xFFFCA5A5), // Coral background matching customer side
                                    child: isNetworkAvatar
                                        ? Image.network(
                                            avatarUrl!,
                                            width: avatarSize,
                                            height: avatarSize,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Image.asset(
                                              defaultAvatarAsset,
                                              width: avatarSize,
                                              height: avatarSize,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                            avatarUrl ?? defaultAvatarAsset,
                                            width: avatarSize,
                                            height: avatarSize,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // gap: 12px;
                        const SizedBox(width: leftContentGap),

                        // Greeting + Name Column (width: 84)
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: SizedBox(
                              width: textWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // content: Good morning,
                                  // width: 84; height: 9; angle: 0 deg; opacity: 1;
                                  // font-family: Inter; font-weight: 400; font-size: 12px;
                                  // leading-trim: CAP_HEIGHT; line-height: 22px; letter-spacing: 0px; background: #616166;
                                  Opacity(
                                    opacity: 1.0, // opacity: 1
                                    child: Transform.rotate(
                                      angle: 0.0, // angle: 0 deg
                                      child: SizedBox(
                                        width: textWidth,
                                        child: Text(
                                          effectiveGreeting,
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: isArabic ? 11.0 : 12.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616166),
                                            letterSpacing: 0.0,
                                            height: 1.1,
                                          ),
                                          textHeightBehavior: const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 1.0),

                                  // content: Ahmed Raza
                                  // width: 84; height: 10; angle: 0 deg; opacity: 1;
                                  // font-family: Inter; font-weight: 500; font-size: 14px;
                                  // leading-trim: CAP_HEIGHT; line-height: 22px; letter-spacing: 0px; background: #252527;
                                  Opacity(
                                    opacity: 1.0, // opacity: 1
                                    child: Transform.rotate(
                                      angle: 0.0, // angle: 0 deg
                                      child: SizedBox(
                                        width: textWidth,
                                        child: Text(
                                          effectiveName,
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: isArabic ? 13.0 : 14.0,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF252527),
                                            letterSpacing: 0.0,
                                            height: 1.15,
                                          ),
                                          textHeightBehavior: const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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
}
