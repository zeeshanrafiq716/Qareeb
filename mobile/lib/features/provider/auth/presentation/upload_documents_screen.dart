import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_upload_documents_header.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_upload_documents_list.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Upload Documents Screen (Screen 7)
/// Appears when user taps "Continue" on Vehicle & Service Details Screen.
/// Follows exact previous screen header branding and layout:
///
/// header layout:
///   width: 350;
///   height: 36;
///   top: 56px;
///   left: 20px;
///   gap: 16px;
///   circular back button: 36x36;
///   title: "Upload Documents";
///   subtitle: "Upload the required documents for verification.";
class UploadDocumentsScreen extends StatelessWidget {
  final Widget? body;

  const UploadDocumentsScreen({
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
                ? ProviderUploadDocumentsHeader.designTop
                : (topSafeArea > 0
                    ? (topSafeArea + 12.0)
                    : ProviderUploadDocumentsHeader.designTop);

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
                      //    width: 350; height: 36; top: 56px; left: 20px; gap: 16px;
                      Positioned(
                        top: headerTop,
                        left: ProviderUploadDocumentsHeader.designLeft, // 20.0px
                        child: const ProviderUploadDocumentsHeader(),
                      ),

                      // 2. Body Content Slot (Scrollable full height)
                      Positioned.fill(
                        top: headerTop + ProviderUploadDocumentsHeader.designHeight,
                        bottom: 0.0,
                        child: ScrollConfiguration(
                          behavior: const ProviderCardScrollBehavior(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.only(
                              top: (152.0 -
                                      (headerTop +
                                          ProviderUploadDocumentsHeader.designHeight))
                                  .clamp(16.0, 100.0), // exact 60px gap matching previous screen (first card at top: 152px)
                              bottom: 24.0,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: ProviderUploadDocumentsHeader.designWidth,
                                child: body ?? const ProviderUploadDocumentsList(),
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
