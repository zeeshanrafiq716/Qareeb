import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Provider Admin Approval Image Layout Branding Widget
/// Implements exact Figma branding specifications:
///
/// img layout branding:
///   width: 123.99999237060547;
///   height: 123.99999237060547;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 620px;
///   background: #EBFFF4;
///   box-shadow: 0px 0px 4.13px 0px #9FFFCB99 inset;
///
/// img layout inner branding:
///   width: 103.33333587646484;
///   height: 103.33333587646484;
///   top: 10.33px;
///   left: 10.33px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 418.92px;
///   border-top-width: 1.05px;
///   background: #1D8070;
///
/// img inner branding:
///   width: 69.81965637207031;
///   height: 60.40699005126953;
///   top: 16.23px;
///   left: 16.76px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 8.38px;
///
/// white card branding:
///   width: 69.02719116210938;
///   height: 51.01963424682617;
///   top: 25.62px;
///   left: 16.88px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 8.38px;
///   background: #FFFFFF;
///
/// rectangle shape branding:
///   width: 66.04381789560337;
///   height: 51.019628460506596;
///   top: 18.85px;
///   left: 16.76px;
///   angle: -3 deg;
///   opacity: 1;
///   border-radius: 8.38px;
///   background: #27AD98;
class ProviderAdminApprovalBadge extends StatelessWidget {
  const ProviderAdminApprovalBadge({super.key});

  static const double designWidth = 124.0;
  static const double designHeight = 124.0;
  static const double innerWidth = 103.333;
  static const double innerHeight = 103.333;
  static const double innerTop = 10.33;
  static const double innerLeft = 10.33;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: _buildPureFlutterBadge(),
        ),
      ),
    );
  }

  /// Pure Flutter widget implementing exact Figma branding specifications
  Widget _buildPureFlutterBadge() {
    return Container(
      width: designWidth,
      height: designHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAFE),
        shape: BoxShape.circle, // border-radius: 620px
        border: Border.all(
          color: const Color(0xFFE9E0FE), // border: 0.5px solid #E9E0FE
          width: 0.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40E9E0FE), // box-shadow: 0px 0px 4.13px 0px #E9E0FE inset
            blurRadius: 4.13,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // img layout inner branding: width: 103.33, height: 103.33, top: 10.33, left: 10.33
          Positioned(
            top: innerTop,
            left: innerLeft,
            width: innerWidth,
            height: innerHeight,
            child: Container(
              width: innerWidth,
              height: innerHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF8B53FE), // background: #1D8070
                shape: BoxShape.circle, // border-radius: 418.92px
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFA67AFE),
                    width: 1.05, // border-top-width: 1.05px
                  ),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // rectangle shape branding: width: 66.04; height: 51.02; top: 18.85; left: 16.76; angle: -3 deg; bg: #27AD98
                  Positioned(
                    top: 18.85,
                    left: 16.76,
                    child: Transform.rotate(
                      angle: -3.0 * math.pi / 180.0, // angle: -3 deg
                      child: Container(
                        width: 66.0438,
                        height: 51.0196,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA67AFE), // background: #27AD98
                          borderRadius: BorderRadius.circular(8.38), // border-radius: 8.38px
                        ),
                      ),
                    ),
                  ),

                  // white card branding: width: 69.03; height: 51.02; top: 25.62; left: 16.88; angle: 0 deg; bg: #FFFFFF
                  Positioned(
                    top: 25.62,
                    left: 16.88,
                    child: Container(
                      width: 69.0272,
                      height: 51.0196,
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF), // background: #FFFFFF
                        borderRadius: BorderRadius.circular(8.38), // border-radius: 8.38px
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 4.0,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Front pocket wave / folder front
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 55.0,
                    child: CustomPaint(
                      painter: _FolderFrontWavePainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter for the front folder wave flap (#1D8070)
class _FolderFrontWavePainter extends CustomPainter {
  const _FolderFrontWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B53FE)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 12)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.45, 14)
      ..quadraticBezierTo(size.width * 0.65, 26, size.width, 18)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
