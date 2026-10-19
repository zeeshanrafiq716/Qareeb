import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_phone_verified_content_layout.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_screen_header.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Phone Verification Details / Complete Screen (Screen 4)
/// Appears when user taps "Verify Code" on OtpVerificationScreen.
/// Implements exact Figma branding specifications:
///
/// header branding layout:
///   width: 348;
///   height: 36;
///   top: 56px;
///   left: 20px;
///   gap: 14px;
///   angle: 0 deg;
///   opacity: 1;
///
/// icon layout:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///   border-width: 1px;
///   background: #FFFFFF;
///   border: 1px solid #1C2926;
///   box-shadow: 0px -2px 12px 0px #00000014;
///
/// < branding:
///   width: 6;
///   height: 13;
///   top: 12px;
///   left: 15px;
///   border: 1px solid #1C2926;
///
/// content: Phone Verification
///   width: 298;
///   height: 12;
///   font-family: Inter;
///   font-weight: 500 (Medium);
///   font-size: 16px;
///   line-height: 24px;
///   letter-spacing: 0px;
///   background: #1C2926;
class PhoneVerifiedScreen extends StatelessWidget {
  final Widget? body;

  const PhoneVerifiedScreen({
    super.key,
    this.body,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? designWidth : constraints.maxWidth;
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double headerTop = isDesktopWeb
                ? ProviderScreenHeader.designTop
                : (topSafeArea > 0
                    ? (topSafeArea + 12.0)
                    : ProviderScreenHeader.designTop);

            final double contentTop = isDesktopWeb
                ? ProviderPhoneVerifiedContentLayout.designTop
                : (headerTop +
                    (ProviderPhoneVerifiedContentLayout.designTop -
                        ProviderScreenHeader.designTop));

            final Widget screenContent = Opacity(
              opacity: 1.0, // opacity: 1
              child: Transform.rotate(
                angle: 0.0, // angle: 0 deg
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      // 1. Header Branding Layout
                      //    width: 348; height: 36; top: 56px; left: 20px; gap: 14px;
                      Positioned(
                        top: headerTop,
                        left: ProviderScreenHeader.designLeft, // 20.0px
                        child: const ProviderScreenHeader(
                          title: 'Phone Verification',
                        ),
                      ),

                      // 2. Next Widget Layout (Body Content Area: 350x471, top: 187px, left: 20px, gap: 20px)
                      Positioned.fill(
                        top: headerTop + ProviderScreenHeader.designHeight,
                        bottom: 0.0,
                        child: ScrollConfiguration(
                          behavior: const ProviderCardScrollBehavior(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.only(
                              top: (contentTop - (headerTop + ProviderScreenHeader.designHeight)).clamp(16.0, 95.0),
                              bottom: 24.0,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: ProviderPhoneVerifiedContentLayout.designWidth,
                                child: body ?? const ProviderPhoneVerifiedContentLayout(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF141C1A),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: designWidth,
                    height: designHeight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: ProviderColors.mintGlow.withValues(alpha: 0.25),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.60),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: ProviderColors.mintGlow.withValues(alpha: 0.08),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: screenContent,
                    ),
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
}
