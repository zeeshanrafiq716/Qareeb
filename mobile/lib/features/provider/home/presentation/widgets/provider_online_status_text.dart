import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';

/// Provider Online Status Text Widget
/// Implements exact Figma branding specifications:
///
/// on main screen text layout:
///   width: 350;
///   height: 33;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// heading layout:
///   width: 129;
///   height: 12;
///   gap: 8px;
///   angle: 0 deg;
///   opacity: 1;
///
/// content: You are Online
///   width: 111;
///   height: 12;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 16px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 24px;
///   letter-spacing: 0px;
///   text-align: center;
///   background: #252527;
///
/// ellipse branding:
///   width: 10;
///   height: 10;
///   angle: 0 deg;
///   opacity: 1;
///   background: #25D366;
///
/// subheading branding:
///   content: Customers can see you on the map
///   width: 350;
///   height: 9;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 100%;
///   letter-spacing: 0px;
///   text-align: center;
///   background: #616166;
class ProviderOnlineStatusText extends StatelessWidget {
  final bool isOnline;
  final String? heading;
  final String? subheading;

  const ProviderOnlineStatusText({
    super.key,
    this.isOnline = true,
    this.heading,
    this.subheading,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 33.0;
  static const double gap = 12.0;
  static const double headingWidth = 129.0;
  static const double headingHeight = 12.0;
  static const double headingGap = 8.0;
  static const double statusDotSize = 10.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String effectiveHeading = heading ??
        (isOnline
            ? (isArabic ? 'أنت متصل الآن' : 'You are Online')
            : (isArabic ? 'أنت غير متصل' : 'You are Offline'));
    final String effectiveSubheading = subheading ??
        (isOnline
            ? (isArabic ? 'يمكن للعملاء رؤيتك على الخريطة' : 'Customers can see you on the map')
            : (isArabic ? 'لا يمكن للعملاء رؤيتك على الخريطة' : 'Customers cannot see you on the map'));

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // heading layout: width: 129; height: 12; gap: 8px; angle: 0 deg; opacity: 1;
              Opacity(
                opacity: 1.0, // opacity: 1
                child: Transform.rotate(
                  angle: 0.0, // angle: 0 deg
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // content: You are Online (width: 111, height: 12)
                      Opacity(
                        opacity: 1.0, // opacity: 1
                        child: Transform.rotate(
                          angle: 0.0, // angle: 0 deg
                          child: Text(
                            effectiveHeading,
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: isArabic ? 15.0 : 16.0,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF252527),
                              height: 1.15,
                              letterSpacing: 0.0,
                            ),
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      const SizedBox(width: headingGap), // gap: 8px

                      // ellipse branding: width: 10; height: 10; background: #25D366;
                      Opacity(
                        opacity: 1.0, // opacity: 1
                        child: Transform.rotate(
                          angle: 0.0, // angle: 0 deg
                          child: Container(
                            width: statusDotSize,
                            height: statusDotSize,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? const Color(0xFF25D366) // background: #25D366
                                  : const Color(0xFF9E9E9E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6.0), // gap: 6px matching Figma

              // subheading branding: Customers can see you on the map (width: 350, height: 9)
              Opacity(
                opacity: 1.0, // opacity: 1
                child: Transform.rotate(
                  angle: 0.0, // angle: 0 deg
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      effectiveSubheading,
                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                        fontSize: isArabic ? 11.5 : 12.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF616166),
                        height: 1.0, // line-height: 100%
                        letterSpacing: 0.0,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      textAlign: TextAlign.center,
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
    );
  }
}
