import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Continue with WhatsApp Button Widget
/// Implements exact Figma branding specifications:
///
/// button layout:
///   width: 350;
///   height: 52;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   background: #F2F5F4;
///
/// button inner content branding:
///   width: 236;
///   height: 20;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///   top: 16px;
///   left: 57px;
///
/// inner content branding:
///   width: 201;
///   height: 22;
///   gap: 12px;
///
/// whatsap icon branding:
///   width: 22;
///   height: 22;
///   background: #25D366;
///   use real whatsap icon
///
/// content: Continue with WhatsApp
///   width: 167; height: 10;
///   font-family: Inter; font-weight: 500 (Medium); font-size: 14px;
///   leading-trim: CAP_HEIGHT; line-height: 22px; letter-spacing: 0px;
///   color: #1C2926;
///
/// > branding:
///   width: 5; height: 10; angle: 0 deg; opacity: 1;
///   border-width: 1px;
///   border: 1px solid #566663;
class ProviderWhatsAppButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ProviderWhatsAppButton({
    super.key,
    this.onTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 52.0;

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
              onTap: onTap ?? () {},
              borderRadius: BorderRadius.circular(12.0),
              child: Center(
                // button inner content branding: width: 236; height: 20; gap: 12px;
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // inner content branding: width: 201; height: 22; gap: 12px;
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // whatsap icon branding: width: 22; height: 22; background: #25D366;
                        const _WhatsAppIconWidget(),

                        const SizedBox(width: 12.0), // gap: 12px

                        // content: Continue with WhatsApp (Inter 500 Medium 14px #1C2926)
                        Text(
                          'Continue with WhatsApp',
                          style: ProviderTextStyles.whatsappButtonText,
                        ),
                      ],
                    ),

                    const SizedBox(width: 12.0), // gap: 12px

                    // > branding: width: 5; height: 10; border: 1px solid #566663;
                    const _RightChevronWidget(),
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

/// Real WhatsApp official vector icon
/// Circular green container #25D366 (22x22) with white speech-bubble and telephone handset
class _WhatsAppIconWidget extends StatelessWidget {
  const _WhatsAppIconWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.0,
      height: 22.0,
      decoration: const BoxDecoration(
        color: ProviderColors.whatsappGreen, // #25D366
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CustomPaint(
          size: Size(13.0, 13.0),
          painter: _WhatsAppIconPainter(),
        ),
      ),
    );
  }
}

/// Official WhatsApp vector icon painter matching Figma specifications:
/// Outer speech-bubble ring + classic telephone receiver inside
class _WhatsAppIconPainter extends CustomPainter {
  const _WhatsAppIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Official WhatsApp vector path defined on a 24x24 viewBox
    final double scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final path = Path()..fillType = PathFillType.evenOdd;

    // 1. Outer speech-bubble contour
    path.moveTo(12.04, 2.0);
    path.cubicTo(6.58, 2.0, 2.13, 6.45, 2.13, 11.91);
    path.cubicTo(2.13, 13.66, 2.59, 15.36, 3.45, 16.86);
    path.lineTo(2.05, 22.0);
    path.lineTo(7.3, 20.62);
    path.cubicTo(8.75, 21.41, 10.38, 21.83, 12.04, 21.83);
    path.cubicTo(17.5, 21.83, 21.95, 17.38, 21.95, 11.92);
    path.cubicTo(21.95, 9.27, 20.92, 6.78, 19.05, 4.91);
    path.cubicTo(17.18, 3.03, 14.69, 2.0, 12.04, 2.0);
    path.close();

    // 2. Inner speech-bubble hole (creating the crisp outline)
    path.moveTo(12.05, 3.67);
    path.cubicTo(14.25, 3.67, 16.31, 4.53, 17.87, 6.09);
    path.cubicTo(19.42, 7.65, 20.28, 9.72, 20.28, 11.92);
    path.cubicTo(20.28, 16.46, 16.58, 20.16, 12.04, 20.16);
    path.cubicTo(10.66, 20.16, 9.3, 19.8, 8.1, 19.11);
    path.lineTo(7.81, 18.94);
    path.lineTo(4.7, 19.76);
    path.lineTo(5.53, 16.73);
    path.lineTo(5.34, 16.43);
    path.cubicTo(4.56, 15.19, 4.15, 13.57, 4.15, 11.91);
    path.cubicTo(4.15, 7.37, 7.85, 3.67, 12.05, 3.67);
    path.close();

    // 3. Official telephone handset inside
    path.moveTo(8.53, 7.33);
    path.cubicTo(8.37, 7.33, 8.1, 7.39, 7.87, 7.64);
    path.cubicTo(7.65, 7.89, 7.02, 8.48, 7.02, 9.71);
    path.cubicTo(7.02, 10.93, 7.91, 12.11, 8.03, 12.27);
    path.cubicTo(8.16, 12.44, 9.75, 14.88, 12.19, 15.93);
    path.cubicTo(14.22, 16.81, 14.63, 16.63, 15.08, 16.59);
    path.cubicTo(15.53, 16.55, 16.53, 16.0, 16.74, 15.42);
    path.cubicTo(16.95, 14.84, 16.95, 14.34, 16.89, 14.24);
    path.cubicTo(16.82, 14.13, 16.66, 14.07, 16.41, 13.95);
    path.cubicTo(16.16, 13.82, 14.94, 13.22, 14.71, 13.14);
    path.cubicTo(14.49, 13.06, 14.32, 13.01, 14.16, 13.26);
    path.cubicTo(13.99, 13.51, 13.52, 14.07, 13.37, 14.24);
    path.cubicTo(13.23, 14.4, 13.08, 14.42, 12.83, 14.3);
    path.cubicTo(12.58, 14.17, 11.78, 13.91, 10.83, 13.07);
    path.cubicTo(10.09, 12.41, 9.59, 11.6, 9.47, 11.35);
    path.cubicTo(9.34, 11.1, 9.45, 10.97, 9.58, 10.84);
    path.cubicTo(9.69, 10.73, 9.83, 10.55, 9.95, 10.41);
    path.cubicTo(10.08, 10.26, 10.12, 10.16, 10.2, 9.99);
    path.cubicTo(10.28, 9.83, 10.24, 9.68, 10.18, 9.56);
    path.cubicTo(10.12, 9.44, 9.63, 8.23, 9.42, 7.74);
    path.cubicTo(9.22, 7.25, 9.02, 7.32, 8.87, 7.31);
    path.cubicTo(8.72, 7.31, 8.55, 7.33, 8.53, 7.33);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// > branding:
/// width: 5; height: 10; angle: 0 deg; opacity: 1; border-width: 1px; border: 1px solid #566663;
class _RightChevronWidget extends StatelessWidget {
  const _RightChevronWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(5.0, 10.0),
      painter: _RightChevronPainter(),
    );
  }
}

class _RightChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProviderColors.dropdownBorder // #566663
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width - 0.5, size.height / 2)
      ..lineTo(0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
