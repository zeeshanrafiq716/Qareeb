import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_content_layout.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_header.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Admin Approval Screen
/// Appears when user taps "Allow Location" on ProviderLocationPermissionScreen.
/// Implements exact Figma branding specifications following previous screen headers:
///
/// header layout:
///   width: 350;
///   height: 36;
///   top: 56px;
///   left: 20px;
///   gap: 14px;
///   circular back button: 36x36;
///   title: "Admin Approval"; (Inter 500 Medium 16px line-height 24px #1C2926)
class AdminApprovalScreen extends StatelessWidget {
  final Widget? body;

  const AdminApprovalScreen({
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
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? designWidth : constraints.maxWidth;
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double headerTop = isDesktopWeb
                ? ProviderAdminApprovalHeader.designTop
                : (topSafeArea > 0
                    ? (topSafeArea + 12.0)
                    : ProviderAdminApprovalHeader.designTop);

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
                      // 1. Header Layout
                      //    width: double.infinity; height: 36; top: 56px; left: 20px; right: 20px;
                      Positioned(
                        top: headerTop,
                        left: 20.0,
                        right: 20.0,
                        child: const ProviderAdminApprovalHeader(),
                      ),

                      // 2. Body Content Slot (Non-scrollable on standard screens, equal 20px margins)
                      Positioned.fill(
                        top: headerTop + ProviderAdminApprovalHeader.designHeight + 24.0,
                        bottom: 0.0,
                        child: ScrollConfiguration(
                          behavior: const ProviderCardScrollBehavior(),
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 12.0,
                              bottom: 24.0,
                            ),
                            child: body ?? const ProviderAdminApprovalContentLayout(),
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
