import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Change Phone Number Button Widget
/// Implements exact Figma branding specifications:
///
/// chnge button layout:
///   width: 350;
///   height: 52;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   background: #F2F5F4;
///
/// button content layout:
///   width: 182;
///   height: 12;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///   top: 20px;
///   left: 84px;
///
/// arrow vector branding:
///   width: 14;
///   height: 12;
///   angle: 0 deg;
///   opacity: 1;
///   border-width: 1.5px;
///   border: 1.5px solid #1C2926;
///
/// content: Change Phone Number
///   font-family: Inter; font-weight: 500 (Medium); font-size: 14px;
///   leading-trim: CAP_HEIGHT; line-height: 22px; letter-spacing: 0px;
///   color: #1C2926;
///   width: 156; height: 10;
class ProviderChangePhoneButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ProviderChangePhoneButton({
    super.key,
    this.onTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 52.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: Material(
            color: ProviderColors.inputBackground, // background: #F2F5F4
            borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
            child: InkWell(
              onTap: onTap ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(12.0),
              child: Center(
                // button content layout: width: 182; height: 12; gap: 12px;
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // arrow vector branding: width: 14; height: 12; border: 1.5px solid #1C2926;
                    const _BackArrowWidget(),

                    const SizedBox(width: designGap), // gap: 12px

                    // content: Change Phone Number (Inter 500 Medium 14px line-height 22px #1C2926)
                    Text(
                      'Change Phone Number',
                      style: ProviderTextStyles.changePhoneButtonText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackArrowWidget extends StatelessWidget {
  const _BackArrowWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14.0, 12.0),
      painter: _BackArrowPainter(),
    );
  }
}

/// Left back arrow painter matching Figma specifications:
/// width: 14; height: 12; angle: 0 deg; border: 1.5px solid #1C2926;
class _BackArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProviderColors.cardTitle // #1C2926
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double midY = size.height / 2;

    // Horizontal stem from left to right
    final shaftPath = Path()
      ..moveTo(0.5, midY)
      ..lineTo(size.width - 0.5, midY);
    canvas.drawPath(shaftPath, paint);

    // Arrowhead pointing back (left)
    final headPath = Path()
      ..moveTo(5.5, 1.5)
      ..lineTo(0.5, midY)
      ..lineTo(5.5, size.height - 1.5);
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
