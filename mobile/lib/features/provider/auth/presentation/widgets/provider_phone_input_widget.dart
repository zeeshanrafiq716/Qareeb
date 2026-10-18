import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Phone Number Widget Layout
/// Implements exact Figma branding specifications:
///
/// phone number widget layout:
///   width: 350;
///   height: 120.22216796875;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 16px;
///
/// 1st row layout:
///   width: 350;
///   height: 52.22222137451172;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 10px;
///
/// number code card layout:
///   width: 126;
///   height: 52.22222137451172;
///   gap: 10px;
///   border-radius: 12px;
///   padding: 16px;
///   background: #F2F5F4;
///
/// row 1 2nd card layout:
///   width: 214;
///   height: 52;
///   border-radius: 12px;
///   background: #F2F5F4;
///   content: 50 123 4567 (Inter 400 14px line-height 22px #566663)
///
/// button layout:
///   width: 350;
///   height: 52;
///   border-radius: 12px;
///   background: #1D8070;
///   content: Continue (Inter 500 14px line-height 22px #FFFFFF)
///   arrow icon branding: width: 14; height: 12; border: 1.5px solid #FFFFFF;
class ProviderPhoneInputWidget extends StatefulWidget {
  final TextEditingController? controller;
  final VoidCallback? onContinue;
  final VoidCallback? onCountryCodeTap;

  const ProviderPhoneInputWidget({
    super.key,
    this.controller,
    this.onContinue,
    this.onCountryCodeTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 120.22216796875;
  static const double row1Height = 52.22222137451172;
  static const double buttonHeight = 52.0;
  static const double rowGap = 16.0;
  static const double cardGap = 10.0;

  @override
  State<ProviderPhoneInputWidget> createState() => _ProviderPhoneInputWidgetState();
}

class _ProviderPhoneInputWidgetState extends State<ProviderPhoneInputWidget> {
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: ProviderPhoneInputWidget.designWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1st row layout: width: 350; height: 52.22; gap: 10px;
              SizedBox(
                width: ProviderPhoneInputWidget.designWidth,
                height: ProviderPhoneInputWidget.row1Height,
                child: Row(
                  children: [
                    // number code card layout: width: 126; height: 52.22; border-radius: 12px; background: #F2F5F4;
                    _buildNumberCodeCard(),

                    // gap: 10px;
                    const SizedBox(width: ProviderPhoneInputWidget.cardGap),

                    // row 1 2nd card layout: width: 214; height: 52; border-radius: 12px; background: #F2F5F4;
                    Expanded(
                      child: _buildPhoneNumberInputCard(),
                    ),
                  ],
                ),
              ),

              // gap: 16px;
              const SizedBox(height: ProviderPhoneInputWidget.rowGap),

              // button layout: width: 350; height: 52; border-radius: 12px; background: #1D8070;
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// number code card layout:
  /// width: 126; height: 52.22; border-radius: 12px; padding: 16px; background: #F2F5F4;
  /// inner content: flag (30x20.22) + gap(6px) + "+966" (37x10) + gap(10px) + dropdown(11x5) = 94px
  Widget _buildNumberCodeCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onCountryCodeTap ?? () {},
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: 126.0,
          height: ProviderPhoneInputWidget.row1Height,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: ProviderColors.inputBackground, // #F2F5F4
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // text layout: width: 73; height: 20.22; gap: 6px;
              // flag branding: width: 30; height: 20.22;
              const _SaudiFlagWidget(),

              const SizedBox(width: 6.0), // gap: 6px

              // content: +966 (Inter 500 14px line-height 22px #1C2926)
              Text(
                '+966',
                style: ProviderTextStyles.phoneCode,
              ),

              const SizedBox(width: 10.0), // gap: 10px

              // dropdown icon branding: width: 11; height: 5; border: 1px solid #566663;
              const _DropdownChevronWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// row 1 2nd card layout:
  /// width: 214; height: 52; border-radius: 12px; background: #F2F5F4;
  /// card inner content branding:
  /// content: 50 123 4567; left: 16px; Inter 400 14px line-height 22px #566663;
  Widget _buildPhoneNumberInputCard() {
    return Container(
      height: ProviderPhoneInputWidget.row1Height,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: ProviderColors.inputBackground, // #F2F5F4
        borderRadius: BorderRadius.circular(12.0),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _internalController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
          LengthLimitingTextInputFormatter(14),
        ],
        style: ProviderTextStyles.phoneInput,
        cursorColor: ProviderColors.primaryButton,
        decoration: InputDecoration(
          hintText: '50 123 4567',
          hintStyle: ProviderTextStyles.phonePlaceholder,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// button layout:
  /// width: 350; height: 52; border-radius: 12px; background: #1D8070;
  /// button inner branding:
  /// width: 87; height: 12; gap: 12px;
  /// content: Continue (Inter 500 14px line-height 22px #FFFFFF)
  /// arrow icon branding: width: 14; height: 12; border: 1.5px solid #FFFFFF
  Widget _buildContinueButton() {
    return SizedBox(
      width: ProviderPhoneInputWidget.designWidth,
      height: ProviderPhoneInputWidget.buttonHeight,
      child: ElevatedButton(
        onPressed: widget.onContinue ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: ProviderColors.primaryButton, // #1D8070
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // content: Continue (Inter 500 14px #FFFFFF)
            Text(
              'Continue',
              style: ProviderTextStyles.continueButtonText,
            ),

            // gap: 12px;
            const SizedBox(width: 12.0),

            // arrow icon branding: width: 14; height: 12; angle: -180 deg; border: 1.5px solid #FFFFFF
            const _ContinueArrowWidget(),
          ],
        ),
      ),
    );
  }
}

/// flag branding:
/// width: 30; height: 20.22222328186035; angle: 0 deg; opacity: 1;
class _SaudiFlagWidget extends StatelessWidget {
  const _SaudiFlagWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.0,
      height: 20.22222328186035,
      decoration: BoxDecoration(
        color: ProviderColors.saudiGreen, // #006C35
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: CustomPaint(
        painter: _SaudiFlagPainter(),
      ),
    );
  }
}

class _SaudiFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Stylized white sword near bottom
    final double swordY = size.height * 0.70;
    canvas.drawLine(
      Offset(size.width * 0.18, swordY),
      Offset(size.width * 0.82, swordY),
      linePaint,
    );
    // Sword hilt crossbar
    canvas.drawLine(
      Offset(size.width * 0.76, swordY - 2.0),
      Offset(size.width * 0.76, swordY + 2.0),
      linePaint,
    );

    // Stylized Arabic calligraphy representation
    final double textY = size.height * 0.38;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.20, textY - 2.0, size.width * 0.60, 4.0),
        const Radius.circular(1.5),
      ),
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// dropdown icon branding:
/// width: 11; height: 5; angle: 0 deg; opacity: 1; border-width: 1px; border: 1px solid #566663
class _DropdownChevronWidget extends StatelessWidget {
  const _DropdownChevronWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(11.0, 5.0),
      painter: _DropdownChevronPainter(),
    );
  }
}

class _DropdownChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProviderColors.dropdownBorder // #566663
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width / 2, size.height - 0.5)
      ..lineTo(size.width - 0.5, 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// arrow icon branding:
/// width: 14; height: 12; angle: -180 deg; opacity: 1; border-width: 1.5px; border: 1.5px solid #FFFFFF
class _ContinueArrowWidget extends StatelessWidget {
  const _ContinueArrowWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14.0, 12.0),
      painter: _ContinueArrowPainter(),
    );
  }
}

class _ContinueArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
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

    // Arrowhead pointing forward (right)
    final headPath = Path()
      ..moveTo(size.width - 5.5, 1.5)
      ..lineTo(size.width - 0.5, midY)
      ..lineTo(size.width - 5.5, size.height - 1.5);
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
