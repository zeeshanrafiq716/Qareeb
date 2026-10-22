import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/location/presentation/widgets/top_down_car_widget.dart';

/// Provider Online / Offline Toggle & Live Presence Section
/// Implements exact Figma branding specifications:
///
/// online / offline toggle layout:
///   width: 146;
///   height: 80;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 1000px;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///
/// ellipse layout:
///   width: 68;
///   height: 68;
///   angle: 0 deg;
///   opacity: 1;
///   top: 6px;
///   left: 72px;
///   border-radius: 278.44px;
///   background: linear-gradient(328.11deg, #8347FE 15.78%, #C0A2FD 85.37%);
///   box-shadow: 0px 1.03px 1.03px 0px #C0A2FD inset;
///   box-shadow: 0px -1.03px 2.06px 0px #5D14F5 inset;
///   box-shadow: 0px 0px 8px 0px #00000033;
///
/// inner branding:
///   width: 28;
///   height: 27.999631881713867;
///   angle: 0 deg;
///   opacity: 1;
///   top: 20px;
///   left: 20px;
///   background: #FFFFFF;
///
/// content: ONLINE
///   width: 146;
///   height: 17;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 24px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 24px;
///   letter-spacing: 0px;
///   text-align: center;
///   background: #252527;
///
/// content: 02:14:26
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 100%;
///   letter-spacing: 0px;
///   text-align: center;
///   width: 51;
///   height: 9;
///   angle: 0 deg;
///   opacity: 1;
///   top: 182px;
///   left: 153px;
///   background: #8B53FE;
///
/// dot branding:
///   width: 32;
///   height: 32;
///   angle: 0 deg;
///   opacity: 1;
///   top: 106px;
///   left: 260px;
///   border: 0.6px solid #D5C1FE;
///
/// car layout:
///   width: 15.000003584787077;
///   height: 24.00000573565932;
///   angle: -124 deg;
///   opacity: 1;
///   top: 67px;
///   left: 273px;
class ProviderOnlineToggle extends StatefulWidget {
  final bool isOnline;
  final ValueChanged<bool>? onChanged;

  const ProviderOnlineToggle({
    super.key,
    this.isOnline = true,
    this.onChanged,
  });

  static const double designWidth = 356.0;
  static const double designHeight = 154.0;

  static const double toggleWidth = 146.0;
  static const double toggleHeight = 80.0;
  static const double toggleTop = 0.0;
  static const double toggleLeft = 105.0; // (356 - 146) / 2 = 105.0

  static const double thumbSize = 68.0;
  static const double thumbTop = 6.0;
  static const double thumbLeftOn = 72.0;
  static const double thumbLeftOff = 6.0;
  static const double iconSize = 28.0;

  // Car layout specs (67px - 48px baseline = 19px):
  static const double carWidth = 15.0;
  static const double carHeight = 24.0;
  static const double carAngle = -124.0;
  static const double carTop = 19.0;
  static const double carLeft = 273.0;

  // Dot branding specs (106px - 48px baseline = 58px):
  static const double dotSize = 32.0;
  static const double dotTop = 58.0;
  static const double dotLeft = 260.0;

  // Text specs (146px - 48px baseline = 98px):
  static const double onlineTextTop = 98.0;
  static const double onlineTextWidth = 146.0;
  static const double onlineTextHeight = 17.0;

  // Timer specs (182px - 48px baseline = 134px):
  static const double timerTop = 134.0;
  static const double timerLeft = 153.0;
  static const double timerWidth = 51.0;
  static const double timerHeight = 9.0;

  @override
  State<ProviderOnlineToggle> createState() => _ProviderOnlineToggleState();
}

class _ProviderOnlineToggleState extends State<ProviderOnlineToggle>
    with SingleTickerProviderStateMixin {
  late bool _isOnline;
  late AnimationController _controller;
  late Animation<double> _thumbPositionAnimation;

  // Live timer simulation starting from Figma timestamp: 02:14:26 = 8066 seconds
  int _onlineSeconds = 8066;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.isOnline;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _thumbPositionAnimation = Tween<double>(
      begin: ProviderOnlineToggle.thumbLeftOff,
      end: ProviderOnlineToggle.thumbLeftOn,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    if (_isOnline) {
      _controller.value = 1.0;
      _startTimer();
    } else {
      _controller.value = 0.0;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isOnline) {
        setState(() {
          _onlineSeconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didUpdateWidget(covariant ProviderOnlineToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != _isOnline) {
      _isOnline = widget.isOnline;
      if (_isOnline) {
        _controller.forward();
        _startTimer();
      } else {
        _controller.reverse();
        _stopTimer();
      }
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final nextState = !_isOnline;
    setState(() {
      _isOnline = nextState;
      if (_isOnline) {
        _controller.forward();
        _startTimer();
      } else {
        _controller.reverse();
        _stopTimer();
      }
    });
    widget.onChanged?.call(nextState);
  }

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    final String h = hours.toString().padLeft(2, '0');
    final String m = minutes.toString().padLeft(2, '0');
    final String s = seconds.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String statusLabel = isArabic
        ? (_isOnline ? 'متصل' : 'غير متصل')
        : (_isOnline ? 'ONLINE' : 'OFFLINE');
    final String timerText = _formatDuration(_onlineSeconds);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalW = constraints.maxWidth;
        final double toggleLeft = (totalW - ProviderOnlineToggle.toggleWidth) / 2.0;
        final double timerLeft = (totalW - ProviderOnlineToggle.timerWidth) / 2.0;

        // Compute coordinate positions adapted symmetrically for RTL when Arabic
        final double carLeftPos = isArabic
            ? (toggleLeft - 32.0)
            : (toggleLeft + ProviderOnlineToggle.toggleWidth + 22.0);
        final double dotLeftPos = isArabic
            ? (toggleLeft - 45.0)
            : (toggleLeft + ProviderOnlineToggle.toggleWidth + 9.0);
        final double carAngle = isArabic
            ? -ProviderOnlineToggle.carAngle
            : ProviderOnlineToggle.carAngle;

        return Opacity(
          opacity: 1.0, // opacity: 1
          child: Transform.rotate(
            angle: 0.0, // angle: 0 deg
            child: SizedBox(
              width: totalW,
              height: ProviderOnlineToggle.designHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Car layout: width: 15; height: 24; angle: -124 deg; top: 67px;
                  Positioned(
                    top: ProviderOnlineToggle.carTop,
                    left: carLeftPos,
                child: Opacity(
                  opacity: _isOnline ? 1.0 : 0.45,
                  child: TopDownCarWidget(
                    width: ProviderOnlineToggle.carWidth,
                    height: ProviderOnlineToggle.carHeight,
                    angle: carAngle,
                    showBadge: false,
                    bodyColor: const Color(0xFF8B53FE),
                  ),
                ),
              ),

              // 2. Dot branding: width: 32; height: 32; top: 106px; left: 260px; border: 0.6px solid #D5C1FE;
              Positioned(
                top: ProviderOnlineToggle.dotTop,
                left: dotLeftPos,
                child: Opacity(
                  opacity: _isOnline ? 1.0 : 0.45,
                  child: Container(
                    width: ProviderOnlineToggle.dotSize,
                    height: ProviderOnlineToggle.dotSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F2FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD5C1FE), // border: 0.6px solid #D5C1FE
                        width: 0.6,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B53FE), // #8B53FE center dot
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Online / Offline Toggle Switch Layout:
              // width: 146; height: 80; top: 48px; left: 105px; border-radius: 1000px;
              Positioned(
                top: ProviderOnlineToggle.toggleTop,
                left: toggleLeft,
                child: GestureDetector(
                  onTap: _handleTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: ProviderOnlineToggle.toggleWidth,
                    height: ProviderOnlineToggle.toggleHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), // background: #FFFFFF
                      borderRadius: BorderRadius.circular(1000.0), // border-radius: 1000px
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000), // box-shadow: 0px 1px 12px 0px #0000001A
                          offset: Offset(0, 1),
                          blurRadius: 12.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final double currentLeft = _thumbPositionAnimation.value;
                        final double t = _controller.value;

                        // Linear gradient (328.11deg, #8347FE 15.78%, #C0A2FD 85.37%)
                        final gradient = LinearGradient(
                          begin: const Alignment(0.65, 0.75),
                          end: const Alignment(-0.65, -0.75),
                          stops: const [0.1578, 0.8537],
                          colors: [
                            Color.lerp(const Color(0xFF9E9EA7), const Color(0xFF8347FE), t)!,
                            Color.lerp(const Color(0xFFD1D1D8), const Color(0xFFC0A2FD), t)!,
                          ],
                        );

                        return Stack(
                          children: [
                            // ellipse layout:
                            // width: 68; height: 68; top: 6px; left: 72px (animated);
                            // border-radius: 278.44px;
                            Positioned(
                              top: ProviderOnlineToggle.thumbTop,
                              left: currentLeft,
                              child: Container(
                                width: ProviderOnlineToggle.thumbSize,
                                height: ProviderOnlineToggle.thumbSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: gradient,
                                  boxShadow: const [
                                    // box-shadow: 0px 0px 8px 0px #00000033
                                    BoxShadow(
                                      color: Color(0x33000000),
                                      offset: Offset(0, 2),
                                      blurRadius: 8.0,
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Color.lerp(
                                      const Color(0xFFDCDCE2),
                                      const Color(0xFFC0A2FD),
                                      t,
                                    )!,
                                    width: 1.03, // box-shadow: 0px 1.03px inset simulation
                                  ),
                                ),
                                child: Center(
                                  // inner branding:
                                  // width: 28; height: 28; top: 20px; left: 20px; background: #FFFFFF;
                                  child: Opacity(
                                    opacity: 1.0,
                                    child: Transform.rotate(
                                      angle: 0.0,
                                      child: const Icon(
                                        Icons.power_settings_new_rounded,
                                        size: ProviderOnlineToggle.iconSize,
                                        color: Color(0xFFFFFFFF), // background: #FFFFFF
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 4. Content: ONLINE (or OFFLINE)
              // width: 146; height: 17; font-family: Inter; font-weight: 500; font-size: 24px;
              // leading-trim: CAP_HEIGHT; line-height: 24px; text-align: center; background: #252527;
              Positioned(
                top: ProviderOnlineToggle.onlineTextTop,
                left: toggleLeft,
                child: Opacity(
                  opacity: 1.0, // opacity: 1
                  child: Transform.rotate(
                    angle: 0.0, // angle: 0 deg
                    child: SizedBox(
                      width: ProviderOnlineToggle.onlineTextWidth,
                      child: Text(
                        statusLabel,
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                          color: _isOnline ? const Color(0xFF252527) : const Color(0xFF8E8E93),
                          height: 1.0,
                          letterSpacing: isArabic ? 0.0 : 0.6,
                        ),
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Content: 02:14:26 (live timer)
              // font-family: Inter; font-weight: 500; font-size: 12px; leading-trim: CAP_HEIGHT;
              // line-height: 100%; text-align: center; width: 51; height: 9;
              // top: 182px; background: #8B53FE;
              Positioned(
                top: ProviderOnlineToggle.timerTop,
                left: timerLeft,
                child: Opacity(
                  opacity: _isOnline ? 1.0 : 0.0, // Fade out timer when offline
                  child: Transform.rotate(
                    angle: 0.0, // angle: 0 deg
                    child: SizedBox(
                      width: ProviderOnlineToggle.timerWidth,
                      child: Text(
                        timerText,
                        style: GoogleFonts.inter(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8B53FE), // background: #8B53FE
                          height: 1.0, // line-height: 100%
                          letterSpacing: 0.2,
                        ),
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
