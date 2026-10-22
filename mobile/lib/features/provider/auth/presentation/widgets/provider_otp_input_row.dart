import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider OTP 6-Cards Input Row Widget
/// Implements exact Figma branding specifications:
///
/// row cards layout:
///   width: 350;
///   height: 50;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 8px / equal gap;
///
/// 1st card (Active/Filled):
///   width: 50; height: 50;
///   border-radius: 12px;
///   border: 1px solid #1D8070;
///   background: #EBFFF4;
///   content: digit (Inter 400 Regular 20px line-height 22px #000000)
///
/// 2nd card (Unfilled/Placeholder):
///   width: 50; height: 50;
///   border-radius: 12px;
///   background: #F2F5F4;
///   inner ellipse: width: 6; height: 6; background: #ADB8B4;
class ProviderOtpInputRow extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? initialValue;

  const ProviderOtpInputRow({
    super.key,
    this.onChanged,
    this.onCompleted,
    this.initialValue,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 50.0;
  static const double cardSize = 50.0;
  static const int codeLength = 6;

  @override
  State<ProviderOtpInputRow> createState() => _ProviderOtpInputRowState();
}

class _ProviderOtpInputRowState extends State<ProviderOtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      ProviderOtpInputRow.codeLength,
      (index) {
        final initial = widget.initialValue != null && widget.initialValue!.length > index
            ? widget.initialValue![index]
            : (index == 0 ? '8' : ''); // Shows '8' on 1st card matching Figma initial preview
        return TextEditingController(text: initial);
      },
    );

    _focusNodes = List.generate(
      ProviderOtpInputRow.codeLength,
      (index) => FocusNode(),
    );

    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Pasting multi-character code
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < ProviderOtpInputRow.codeLength; i++) {
        if (i < digits.length) {
          _controllers[i].text = digits[i];
        }
      }
      final nextIndex = digits.length.clamp(0, ProviderOtpInputRow.codeLength - 1);
      _focusNodes[nextIndex].requestFocus();
    } else if (value.isNotEmpty) {
      _controllers[index].text = value;
      if (index < ProviderOtpInputRow.codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final code = _currentOtp;
    widget.onChanged?.call(code);
    if (code.length == ProviderOtpInputRow.codeLength) {
      widget.onCompleted?.call(code);
    }
    setState(() {});
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          height: ProviderOtpInputRow.designHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              ProviderOtpInputRow.codeLength,
              (index) => _buildCard(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final String text = _controllers[index].text;
    final bool isFocused = _focusNodes[index].hasFocus;
    final bool isFilled = text.isNotEmpty;
    final bool isActive = isFilled || isFocused;

    return Container(
      width: ProviderOtpInputRow.cardSize,
      height: ProviderOtpInputRow.cardSize,
      decoration: BoxDecoration(
        color: isActive
            ? ProviderColors.otpActiveBackground // #EBFFF4
            : ProviderColors.inputBackground, // #F2F5F4
        borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
        border: isActive
            ? Border.all(
                color: ProviderColors.primaryButton, // border: 1px solid #1D8070
                width: 1.0,
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // If empty and not focused, show the 6x6 ellipse dot (#ADB8B4)
          if (!isFilled && !isFocused)
            Container(
              width: 6.0,
              height: 6.0,
              decoration: const BoxDecoration(
                color: ProviderColors.otpDotPlaceholder, // #ADB8B4
                shape: BoxShape.circle,
              ),
            ),

          // Interactive TextField for digit input
          KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyDown(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: ProviderTextStyles.otpDigit, // Inter 400 Regular 20px #000000
              cursorColor: ProviderColors.primaryButton,
              showCursor: isFocused && !isFilled,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => _onDigitChanged(index, val),
            ),
          ),
        ],
      ),
    );
  }
}
