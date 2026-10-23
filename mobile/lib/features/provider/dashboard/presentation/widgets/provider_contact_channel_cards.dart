import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';

/// Provider Contact Channel Mini Cards Widget (Calls Received & WhatsApp Tabs)
/// Implements exact Figma specifications:
///
/// cRDS layout:
///   width: 350;
///   height: 68;
///   padding-right: 16px;
///   padding-left: 16px;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// 1st card branding:
///   width: 153;
///   height: 68;
///   border-radius: 12px;
///   gap: 10px;
///   angle: 0 deg;
///   opacity: 1;
///   padding: 16px;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 10px 0px #00000014;
///
/// card inner branding:
///   width: 121;
///   height: 36;
///   justify-content: space-between;
///   angle: 0 deg;
///   opacity: 1;
///
/// icon branding:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///   ellipse background: #F3F2F5;
///   call icon: width: 18; height: 16; color: #8B53FE;
///
/// content branding:
///   width: 75; height: 27; gap: 10px;
///   Calls Received: Inter 400, 10px, line-height 100%, color: #616166;
///   11: Inter 500, 14px, line-height 22px, color: #252527;
///
/// 2nd card layout:
///   width: 153; height: 68; border-radius: 12px; padding: 16px; background: #FFFFFF;
///   box-shadow: 0px 1px 10px 0px #00000014;
///   WhatsApp icon (#25D366) in 36x36 #F3F2F5 ellipse;
///   WhatsApp Tabs: Inter 400, 10px, line-height 100%, color: #616166;
///   8: Inter 500, 14px, line-height 22px, color: #252527;
class ProviderContactChannelCards extends StatelessWidget {
  final int callsCount;
  final int whatsAppCount;
  final VoidCallback? onCallsTap;
  final VoidCallback? onWhatsAppTap;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double height;

  const ProviderContactChannelCards({
    super.key,
    this.callsCount = 11,
    this.whatsAppCount = 8,
    this.onCallsTap,
    this.onWhatsAppTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.width,
    this.height = 68.0,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 68.0;
  static const double cardWidth = 153.0;
  static const double cardHeight = 68.0;
  static const double gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String callsLabel = isArabic ? 'المكالمات المستلمة' : 'Calls Received';
    final String whatsAppLabel = isArabic ? 'نقرات واتساب' : 'WhatsApp Tabs';

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: width ?? designWidth, // width: 350 or custom 318
          height: height, // height: 68
          child: Padding(
            padding: padding, // padding
            child: Row(
              children: [
                // 1st Card: Calls Received (11)
                Expanded(
                  child: _MiniChannelCard(
                    iconWidget: const Icon(
                      Icons.phone_rounded,
                      size: 18.0,
                      color: Color(0xFF8B53FE), // #8B53FE
                    ),
                    label: callsLabel,
                    value: '$callsCount',
                    onTap: onCallsTap,
                    isArabic: isArabic,
                  ),
                ),

                const SizedBox(width: gap), // gap: 12px

                // 2nd Card: WhatsApp Tabs (8)
                Expanded(
                  child: _MiniChannelCard(
                    iconWidget: const CustomPaint(
                      size: Size(20.0, 20.0),
                      painter: _WhatsAppGreenLogoPainter(),
                    ),
                    label: whatsAppLabel,
                    value: '$whatsAppCount',
                    onTap: onWhatsAppTap,
                    isArabic: isArabic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChannelCard extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isArabic;

  const _MiniChannelCard({
    required this.iconWidget,
    required this.label,
    required this.value,
    this.onTap,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ProviderContactChannelCards.cardWidth, // width: 153
      height: ProviderContactChannelCards.cardHeight, // height: 68
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // background: #FFFFFF
        borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // box-shadow: 0px 1px 10px 0px #00000014
            offset: Offset(0, 1),
            blurRadius: 10.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), // padding: 16px
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon branding: width: 36; height: 36; ellipse background: #F3F2F5;
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F2F5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: iconWidget),
                ),

                const SizedBox(width: 10.0), // gap: 10px

                // Content branding: width: 75; height: 27;
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Label (Calls Received / WhatsApp Tabs)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          label,
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF616166),
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                          maxLines: 1,
                        ),
                      ),

                      const SizedBox(height: 3.0),

                      // Value (11 / 8)
                      Text(
                        value,
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF252527),
                          height: 1.15,
                          letterSpacing: 0.0,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Official WhatsApp Logo Vector Painter in Brand Green (#25D366)
class _WhatsAppGreenLogoPainter extends CustomPainter {
  final Color color;

  const _WhatsAppGreenLogoPainter({
    this.color = const Color(0xFF25D366),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    final bubblePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final handsetPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.save();
    canvas.scale(scale, scale);

    // 1. Speech bubble outline
    final bubblePath = Path()
      ..moveTo(12.0, 2.5)
      ..cubicTo(6.75, 2.5, 2.5, 6.75, 2.5, 12.0)
      ..cubicTo(2.5, 13.75, 2.95, 15.4, 3.75, 16.85)
      ..lineTo(2.5, 21.5)
      ..lineTo(7.35, 20.25)
      ..cubicTo(8.75, 21.05, 10.35, 21.5, 12.0, 21.5)
      ..cubicTo(17.25, 21.5, 21.5, 17.25, 21.5, 12.0)
      ..cubicTo(21.5, 6.75, 17.25, 2.5, 12.0, 2.5)
      ..close();

    canvas.drawPath(bubblePath, bubblePaint);

    // 2. Handset phone outline inside
    final handsetPath = Path()
      ..moveTo(8.5, 7.5)
      ..cubicTo(8.3, 7.5, 8.0, 7.6, 7.8, 7.8)
      ..cubicTo(7.6, 8.1, 7.0, 8.7, 7.0, 9.9)
      ..cubicTo(7.0, 11.1, 7.9, 12.3, 8.0, 12.5)
      ..cubicTo(8.2, 12.6, 9.8, 15.1, 12.2, 16.1)
      ..cubicTo(14.2, 17.0, 14.6, 16.8, 15.1, 16.8)
      ..cubicTo(15.5, 16.7, 16.5, 16.2, 16.7, 15.6)
      ..cubicTo(16.9, 15.0, 16.9, 14.5, 16.8, 14.4)
      ..cubicTo(16.8, 14.3, 16.6, 14.2, 16.4, 14.1)
      ..cubicTo(16.1, 14.0, 14.9, 13.4, 14.7, 13.3)
      ..cubicTo(14.5, 13.2, 14.3, 13.2, 14.1, 13.4)
      ..cubicTo(13.9, 13.7, 13.5, 14.2, 13.3, 14.4)
      ..cubicTo(13.2, 14.6, 13.0, 14.6, 12.8, 14.5)
      ..cubicTo(12.5, 14.3, 11.7, 14.1, 10.8, 13.2)
      ..cubicTo(10.0, 12.5, 9.5, 11.7, 9.4, 11.5)
      ..cubicTo(9.3, 11.2, 9.4, 11.1, 9.5, 11.0)
      ..cubicTo(9.6, 10.9, 9.8, 10.7, 9.9, 10.5)
      ..cubicTo(10.0, 10.4, 10.1, 10.3, 10.2, 10.1)
      ..cubicTo(10.2, 10.0, 10.2, 9.8, 10.1, 9.7)
      ..cubicTo(10.1, 9.6, 9.6, 8.4, 9.4, 7.9)
      ..cubicTo(9.2, 7.4, 9.0, 7.5, 8.8, 7.5)
      ..close();

    canvas.drawPath(handsetPath, handsetPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WhatsAppGreenLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
