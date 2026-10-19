import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider OTP Resend Timer Row Widget
/// Implements exact Figma branding specifications:
///
/// next row layout:
///   width: 146;
///   height: 13;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 8px;
///
/// timer icon layout:
///   width: 13;
///   height: 13;
///   angle: 0 deg;
///   opacity: 1;
///   border-width: 1px;
///   border: 1px solid #566663;
///
/// content: Resend code in 00:59
///   width: 125;
///   height: 9;
///   font-family: Inter; font-weight: 400 (Regular); font-size: 12px;
///   leading-trim: CAP_HEIGHT; line-height: 100%; letter-spacing: 0px;
///   color: #566663;
///
/// span(00:59):
///   font-family: Inter; font-weight: 500 (Medium); font-size: 12px;
///   leading-trim: CAP_HEIGHT; line-height: 100%; letter-spacing: 0px;
///   color: #566663;
class ProviderOtpTimerRow extends StatefulWidget {
  final VoidCallback? onResend;
  final int initialSeconds;

  const ProviderOtpTimerRow({
    super.key,
    this.onResend,
    this.initialSeconds = 59,
  });

  static const double designWidth = 146.0;
  static const double designHeight = 13.0;
  static const double iconSize = 13.0;
  static const double designGap = 8.0;

  @override
  State<ProviderOtpTimerRow> createState() => _ProviderOtpTimerRowState();
}

class _ProviderOtpTimerRowState extends State<ProviderOtpTimerRow> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _handleResend() {
    if (_remainingSeconds == 0) {
      setState(() {
        _remainingSeconds = widget.initialSeconds;
      });
      _startTimer();
      widget.onResend?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final bool canResend = _remainingSeconds == 0;

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: InkWell(
          onTap: canResend ? _handleResend : null,
          borderRadius: BorderRadius.circular(4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // timer icon layout: width: 13; height: 13; border: 1px solid #566663;
              const SizedBox(
                width: ProviderOtpTimerRow.iconSize,
                height: ProviderOtpTimerRow.iconSize,
                child: CustomPaint(
                  painter: _TimerIconPainter(),
                ),
              ),

              const SizedBox(width: ProviderOtpTimerRow.designGap), // gap: 8px

              // content: Resend code in 00:59
              Text.rich(
                TextSpan(
                  text: 'Resend code in ',
                  style: ProviderTextStyles.resendTimerText,
                  children: [
                    TextSpan(
                      text: _formattedTime,
                      style: ProviderTextStyles.resendTimerSpan,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Timer clock icon painter matching Figma specifications:
/// width: 13; height: 13; border: 1px solid #566663;
class _TimerIconPainter extends CustomPainter {
  const _TimerIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProviderColors.dropdownBorder // #566663
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Circle outline
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 1.0) / 2;
    canvas.drawCircle(center, radius, paint);

    // Clock hands (pointing to 12 o'clock and ~3 o'clock)
    final handsPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.58)
      ..lineTo(center.dx, center.dy)
      ..lineTo(center.dx + radius * 0.50, center.dy);
    canvas.drawPath(handsPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
