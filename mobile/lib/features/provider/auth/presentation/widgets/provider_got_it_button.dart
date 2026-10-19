import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provider Got It Button Widget
/// Implements exact Figma branding specifications following previous buttons:
///
/// button layout:
///   width: 350 (or double.infinity);
///   height: 52;
///   border-radius: 12px;
///   background: #1D8070;
///
/// content: Got it
///   font-family: Inter;
///   font-weight: 500 (Medium);
///   font-size: 14px;
///   line-height: 22px;
///   color: #FFFFFF;
class ProviderGotItButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;

  const ProviderGotItButton({
    super.key,
    this.onTap,
    this.title = 'Got it',
  });

  static const double designWidth = 350.0;
  static const double designHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: designHeight,
      child: ElevatedButton(
        onPressed: onTap ?? () => _defaultOnTap(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D8070),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w500, // Medium 500
            color: Colors.white,
            height: 22.0 / 14.0,
            letterSpacing: 0.0,
          ),
        ),
      ),
    );
  }

  void _defaultOnTap(BuildContext context) {
    // Navigate back to root or home screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
