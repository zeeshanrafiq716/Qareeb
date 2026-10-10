import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Urgent Assistance Card widget with exact Figma inner content styling:
/// - Container: width 350, height 70, border-radius 12px, padding 16px, background #FFFFFF
/// - Inner content row: width 316, height 36, justify-content: space-between
/// - Left side content: width 214, height 36, gap: 12px
///   - Bell Vector: width 20, height 16, color #FF6E05 centered in 36x36 circular badge
///   - Text column: width 166, height 29
///     - "Need urgent assistance?": 14px Inter Medium (500), #1C2926
///     - "Get Help Now": 12px Inter Regular (400), #566663
/// - Right side content: chevron icon #566663
class UrgentAssistanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? child;
  final VoidCallback? onTap;

  const UrgentAssistanceCard({
    super.key,
    this.title = 'Need urgent assistance?',
    this.subtitle = 'Get Help Now',
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: 350.0,
      height: 70.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFFFD5C2), // Subtle peach border from mockup
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child ??
          SizedBox(
            width: 316.0,
            height: 36.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                    // Left side content: width: 214; height: 36; gap: 12px;
                    SizedBox(
                      width: 214.0,
                      height: 36.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Vector of bell: width: 20, height: 16, background: #FF6E05
                          // Centered at top: 10px, left: 8px inside 36x36 badge
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFF2EB), // Warm soft peach circle badge
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_active_outlined,
                                size: 20.0,
                                color: Color(0xFFFF6E05), // #FF6E05
                              ),
                            ),
                          ),

                          // gap: 12px
                          const SizedBox(width: 12.0),

                          // Text column: width: 166; height: 29;
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // "Need urgent assistance?": 14px, Inter Medium, line-height 22px, #1C2926
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1C2926),
                                    height: 1.1,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                // "Get Help Now": 12px, Inter Regular, line-height 22px, #566663
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                    height: 1.1,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side chevron arrow icon: color: #566663
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 22.0,
                      color: Color(0xFF566663),
                    ),
                  ],
                ),
              ),
    );

    if (onTap == null) {
      return Center(child: cardContent);
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: cardContent,
        ),
      ),
    );
  }
}
