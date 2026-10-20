import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'urgent_assistance_card.dart';

/// Header widget strictly following the brand specifications:
/// - Dimensions: width 390, height 246
/// - Background: linear-gradient(180deg, #9FFFCB 0%, rgba(159, 255, 203, 0.37284) 68.53%, rgba(159, 255, 203, 0) 100%)
/// - Layout & Typography: Exact specifications from Figma redlines (20px margins, 24px vertical gaps)
class HomeHeaderWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            height: 246.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.009, -1.0),
                  end: Alignment(-0.009, 1.0),
                  stops: [0.0, 1.0],
                  colors: [
                    Color(0x5F8B53FE), // rgba(139, 83, 254, 0.37284) at -0.59%
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
              // Status bar spacing
              SizedBox(height: effectiveTopPadding + 8.0),

          // 1. Profile, Location & Notification Row
          // width: 390; height: 36; justify-content: space-between; padding-left: 20px; padding-right: 20px;
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 36.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Avatar + Location Details
                  Row(
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

                      const SizedBox(width: 10.0),

                      // Location text column
                      () {
                        final locationColumn = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Current location": 12px, Inter, weight 400, line-height 22px, letter-spacing 0px
                            Text(
                              locationLabel,
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4A5568),
                                height: 1.1,
                                letterSpacing: 0.0,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            // "Karachi Pakistan": 14px, Inter, weight 400, line-height 22px, letter-spacing 0px
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  location,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF14221E),
                                    height: 1.1,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
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
                    ],
                  ),

                  // Notification icon: width: 36; height: 36; background: #FFFFFF; border: 1px solid #525252
                  () {
                    final bellButton = Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFFFFF),
                        border: Border.all(
                          color: const Color(0xFF525252),
                          width: 1.0,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 18.0,
                          color: Color(0xFF525252),
                        ),
                      ),
                    );

                    if (onNotificationTap == null) return bellButton;
                    return GestureDetector(
                      onTap: onNotificationTap,
                      child: bellButton,
                    );
                  }(),
                ],
              ),
            ),
          ),

          // 24px vertical space between Profile row and Greeting ('24px I' redline)
          const SizedBox(height: 24.0),

          // 2. Greeting Section: "Hello, Shayan" and "Explore Something"
          // width: 130; height: 36; top: 116px; left: 130px; gap: 12px;
          Center(
            child: SizedBox(
              width: 130.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "Hello, Shayan"
                  // font-family: Inter; font-weight: 500; font-size: 20px; line-height: 22px; letter-spacing: 0px; text-align: center; color: #1C2926;
                  Text(
                    'Hello, $userName',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1C2926),
                      letterSpacing: 0.0,
                      height: 1.1,
                    ),
                  ),

                  // gap: 12px
                  const SizedBox(height: 12.0),

                  // "Explore Something"
                  // font-family: Inter; font-weight: 400; font-size: 12px; line-height: 22px; letter-spacing: 0px; text-align: center; color: #566663;
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF566663),
                      letterSpacing: 0.0,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

              // 24px vertical space below greeting towards card ('24px I' redline, bringing top to 176px)
              const SizedBox(height: 24.0),

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
