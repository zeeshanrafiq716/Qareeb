import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/localization/app_locale.dart';
import '../../../providers/notifications_provider.dart';

/// Notifications Screen navigated from the Profile Tab.
/// Features the standard app header layout:
/// - Circular white back button on the left with shadow
/// - Centered "Notifications" title
/// - Symmetrical right optical balance spacer / clear button
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<Map<String, dynamic>> _sampleNotifications = [
    {
      'id': 'notif_verified',
      'titleEn': 'Account Verified',
      'titleAr': 'تم التحقق من الحساب',
      'messageEn': 'Your provider account has been verified successfully. \nYou can now go online, receive service requests, and serve customers through QAREEB.',
      'messageAr': 'تم التحقق من حساب مزود الخدمة الخاص بك بنجاح. \nيمكنك الآن الاتصال بالإنترنت واستقبال طلبات الخدمة وخدمة العملاء عبر تطبيق قريب.',
      'timeEn': 'Just now',
      'timeAr': 'الآن',
      'icon': Icons.check_rounded,
      'isRead': false,
    },
    {
      'id': 'notif_1',
      'titleEn': 'Request Accepted!',
      'titleAr': 'تم قبول طلبك!',
      'messageEn': 'Ahmad Transport has accepted your service request and is on the way.',
      'messageAr': 'قبل أحمد للنقل طلب الخدمة الخاص بك وهو في الطريق.',
      'timeEn': '2 min ago',
      'timeAr': 'منذ دقيقتين',
      'icon': Icons.check_circle_rounded,
      'isRead': false,
    },
    {
      'id': 'notif_2',
      'titleEn': 'Driver Arrived',
      'titleAr': 'وصل السائق',
      'messageEn': 'Your recovery driver is at your pickup location.',
      'messageAr': 'وصل سائق الونش إلى موقع الاستلام الخاص بك.',
      'timeEn': '15 min ago',
      'timeAr': 'منذ ١٥ دقيقة',
      'icon': Icons.location_on_rounded,
      'isRead': false,
    },
    {
      'id': 'notif_3',
      'titleEn': 'Special Offer',
      'titleAr': 'عرض خاص',
      'messageEn': 'Get 20% off on your next towing service using promo code QAREEB20.',
      'messageAr': 'احصل على خصم ٢٠٪ على خدمة السحب القادمة باستخدام الرمز QAREEB20.',
      'timeEn': '2 hours ago',
      'timeAr': 'منذ ساعتين',
      'icon': Icons.local_offer_rounded,
      'isRead': true,
    },
    {
      'id': 'notif_4',
      'titleEn': 'Service Completed',
      'titleAr': 'اكتملت الخدمة',
      'messageEn': 'Your request has been successfully completed. Thank you for using Qareeb!',
      'messageAr': 'تم إكمال طلبك بنجاح. شكراً لاستخدامك تطبيق قريب!',
      'timeEn': 'Yesterday',
      'timeAr': 'أمس',
      'icon': Icons.done_all_rounded,
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in _sampleNotifications) {
        n['isRead'] = true;
      }
    });
    ref.read(notificationsProvider.notifier).dismissCustomerNotification();
    ref.read(notificationsProvider.notifier).dismissProviderNotification();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isArabic = tr.isArabic;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

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

            final double horizontalPadding = isDesktopWeb
                ? 20.0
                : (containerWidth > 420.0
                    ? ((containerWidth - 380.0) / 2).clamp(20.0, 48.0)
                    : 20.0);

            final double safeTop = mediaQuery.padding.top;
            final double headerTopPadding = math.max(safeTop + 16.0, 66.0);

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // 1. Top Background Gradient
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    height: 260.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFF0EAFE),
                            Color(0x00F0EAFE),
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 2. Main Scrollable Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Headroom spacing
                          SizedBox(height: headerTopPadding),

                          // Standard App Notifications Header
                          _buildNotificationsHeader(context, tr, isArabic),
                          const SizedBox(height: 24.0),

                          // Notification Items
                          if (_sampleNotifications.isEmpty)
                            _buildEmptyState(tr, isArabic)
                          else
                            ..._sampleNotifications.map((notif) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildNotificationCard(notif, tr, isArabic),
                              );
                            }),

                          const SizedBox(height: 40.0),
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
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: screenContent,
                  ),
                ),
              );
            }

            return screenContent;
          },
        ),
      ),
    );
  }

  /// Standard Notifications Header:
  /// - Back button (circular white with shadow) on the left
  /// - Centered "Notifications" title
  /// - Symmetrical right optical balance spacer / "Mark All Read" button
  Widget _buildNotificationsHeader(BuildContext context, AppTranslations tr, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ellipse branding back button
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: const Key('notifications_header_back_button'),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).maybePop();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000), // 0px 1px 8px 0px #00000014
                    blurRadius: 8.0,
                    offset: Offset(0, 1),
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: const Center(
                child: _NotificationsChevron(
                  width: 7.0,
                  height: 13.0,
                  color: Color(0xFF1C2926),
                  strokeWidth: 1.8,
                  isLeft: true,
                ),
              ),
            ),
          ),
        ),

        // Centered "Notifications" Title
        Expanded(
          child: Text(
            tr.notifications,
            textAlign: TextAlign.center,
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                    height: 1.2,
                  )
                : tr.font(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                    height: 1.2,
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Mark All Read Button or Symmetrical 36px Spacer
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _markAllAsRead,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8.0,
                    offset: Offset(0, 1),
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.done_all_rounded,
                  size: 18.0,
                  color: Color(0xFF8B53FE),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Notification Card Item
  /// Built to exact Figma branding specifications:
  /// - Card: width 350, border-radius 12, padding 16, background #FFFFFF, shadow 0px 1px 12px #0000001A
  /// - Inner layout: width 318, gap 12
  /// - Left icon branding: 32x32 rounded 8, bg #F3F2F5; inner 20x20 bg #8B53FE with white checkmark
  /// - Content layout: width 274
  ///   - 1st row: Title (14px, 500, #252527) & Time (10px, 400, #616166)
  ///   - 2nd row: Message (10px, 400, #252527, line-height 100%)
  ///   - 3rd row: Mark as read (10px, 500, #8B53FE, aligned right)
  Widget _buildNotificationCard(Map<String, dynamic> notif, AppTranslations tr, bool isArabic) {
    final bool isRead = notif['isRead'] as bool;
    final String title = isArabic ? notif['titleAr'] as String : notif['titleEn'] as String;
    final String message = isArabic ? notif['messageAr'] as String : notif['messageEn'] as String;
    final String time = isArabic ? notif['timeAr'] as String : notif['timeEn'] as String;
    final IconData icon = (notif['icon'] as IconData?) ?? Icons.check_rounded;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // 0px 1px 12px 0px #0000001A
                blurRadius: 12.0,
                offset: Offset(0, 1),
                spreadRadius: 0.0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side icon branding:
              // width: 32; height: 32; border-radius: 8px; background: #F3F2F5;
              // inner branding: width: 20; height: 20; background: #8B53FE;
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F2F5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: isRead
                          ? const Color(0xFF8B53FE).withValues(alpha: 0.75)
                          : const Color(0xFF8B53FE),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 13.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0), // gap: 12px

              // Content layout: width: 274
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1st row branding: Title & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: isArabic
                                ? GoogleFonts.cairo(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF252527),
                                  )
                                : GoogleFonts.inter(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF252527),
                                    height: 22.0 / 14.0,
                                    letterSpacing: 0.0,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          time,
                          textAlign: isArabic ? TextAlign.left : TextAlign.right,
                          style: isArabic
                              ? GoogleFonts.cairo(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF616166),
                                )
                              : GoogleFonts.inter(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF616166),
                                  height: 22.0 / 10.0,
                                  letterSpacing: 0.0,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),

                    // 2nd row: Content text
                    Text(
                      message,
                      style: isArabic
                          ? GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF252527),
                              height: 1.35,
                            )
                          : GoogleFonts.inter(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF252527),
                              height: 1.35,
                              letterSpacing: 0.0,
                            ),
                    ),
                    const SizedBox(height: 8.0),

                    // 3rd row branding: Mark as read
                    Align(
                      alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              notif['isRead'] = !isRead;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            isRead
                                ? (isArabic ? 'تمت القراءة' : 'Read')
                                : (isArabic ? 'تحديد كمقروء' : 'Mark as read'),
                            textAlign: isArabic ? TextAlign.left : TextAlign.right,
                            style: isArabic
                                ? GoogleFonts.cairo(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                    color: isRead
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF8B53FE),
                                  )
                                : GoogleFonts.inter(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                    color: isRead
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF8B53FE),
                                    height: 22.0 / 10.0,
                                    letterSpacing: 0.0,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state when no notifications exist
  Widget _buildEmptyState(AppTranslations tr, bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.0,
              height: 72.0,
              decoration: const BoxDecoration(
                color: Color(0xFFF0EAFE),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 36.0,
                  color: Color(0xFF8B53FE),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              isArabic ? 'لا توجد إشعارات حالياً' : 'No notifications yet',
              style: tr.font(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C2926),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              isArabic
                  ? 'سنخطرك عند وصول أي تحديثات جديدة'
                  : 'We will notify you when new updates arrive',
              style: tr.font(
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF566663),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chevron widget direction-aware matching profile header style
class _NotificationsChevron extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;
  final bool isLeft;

  const _NotificationsChevron({
    required this.width,
    required this.height,
    required this.color,
    this.strokeWidth = 1.8,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final flip = isLeft ? isRtl : !isRtl;

    return Transform.scale(
      scaleX: flip ? -1.0 : 1.0,
      child: CustomPaint(
        size: Size(width, height),
        painter: _ChevronPainter(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ChevronPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(0.0, size.height / 2.0);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

