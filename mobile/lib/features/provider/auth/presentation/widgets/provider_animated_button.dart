import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provider Animated Interactive Button Widget
/// Implements:
/// - Smooth tactile scale bounce animation on press/click (scales to 0.96 and springs back)
/// - Button NEVER hides or collapses when clicked or loading
/// - Displays text + icon consistently, with smooth inline spinner alongside text during async tasks
/// - Haptic feedback on tap
class ProviderAnimatedButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String? text;
  final Widget? icon;
  final Widget? child;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final bool isPrimary;
  final BoxBorder? border;
  final TextStyle? textStyle;
  final List<BoxShadow>? boxShadow;

  const ProviderAnimatedButton({
    super.key,
    this.onTap,
    this.text,
    this.icon,
    this.child,
    this.backgroundColor = const Color(0xFF2D2A3D),
    this.foregroundColor = Colors.white,
    this.height = 52.0,
    this.width = double.infinity,
    this.borderRadius,
    this.isLoading = false,
    this.isPrimary = true,
    this.border,
    this.textStyle,
    this.boxShadow,
  });

  @override
  State<ProviderAnimatedButton> createState() => _ProviderAnimatedButtonState();
}

class _ProviderAnimatedButtonState extends State<ProviderAnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading || widget.onTap == null) return;
    HapticFeedback.lightImpact();
    _animController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animController.reverse();
  }

  void _onTapCancel() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(12.0);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: effectiveBorderRadius,
          border: widget.border,
          boxShadow: widget.boxShadow ??
              (widget.isPrimary && !widget.isLoading
                  ? [
                      BoxShadow(
                        color: widget.backgroundColor.withValues(alpha: 0.28),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            borderRadius: effectiveBorderRadius,
            splashColor: widget.foregroundColor.withValues(alpha: 0.12),
            highlightColor: widget.foregroundColor.withValues(alpha: 0.08),
            child: Center(
              child: widget.child ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Smooth inline loading indicator without hiding text
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: widget.foregroundColor,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                      ],

                      // Button title text (always stays visible)
                      if (widget.text != null && widget.text!.isNotEmpty)
                        Text(
                          widget.text!,
                          style: widget.textStyle ??
                              GoogleFonts.inter(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                color: widget.foregroundColor,
                              ),
                        ),

                      // Optional arrow or vector icon
                      if (!widget.isLoading && widget.icon != null) ...[
                        const SizedBox(width: 8.0),
                        widget.icon!,
                      ],
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
