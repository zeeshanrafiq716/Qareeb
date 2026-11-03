import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/app_locale.dart';
import '../../provider/auth/presentation/widgets/provider_animated_button.dart';
import '../../provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';

/// Customer Help & Support / Rate Provider Screen
/// Implements exact design & branding from Figma screenshots:
/// - Circular white back button
/// - Title: "Feedback / Rate Provider"
/// - Subtitle: "Share your experience to help us improve QAREEB services."
/// - 3D purple glowing chat bubble badge with stars
/// - Provider info card (Ahmad Transport, Pickup & Delivery, 4.9 rating)
/// - Interactive 5-star rating (Rate your experience)
/// - Feedback text area with 0/300 character counter
/// - Add Photos (Optional) 4-slot photo picker
/// - Submit Feedback button (#8B53FE)
class CustomerFeedbackSupportScreen extends ConsumerStatefulWidget {
  final String providerName;
  final String serviceType;
  final double rating;
  final int reviewsCount;
  final String? avatarPath;

  const CustomerFeedbackSupportScreen({
    super.key,
    this.providerName = 'Ahmad Transport',
    this.serviceType = 'Pickup & Delivery',
    this.rating = 4.9,
    this.reviewsCount = 120,
    this.avatarPath,
  });

  @override
  ConsumerState<CustomerFeedbackSupportScreen> createState() =>
      _CustomerFeedbackSupportScreenState();
}

class _CustomerFeedbackSupportScreenState
    extends ConsumerState<CustomerFeedbackSupportScreen> {
  int _selectedRating = 4;
  final TextEditingController _feedbackCtrl = TextEditingController();
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int slotIndex) async {
    try {
      HapticFeedback.lightImpact();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image != null) {
        setState(() {
          if (slotIndex < _selectedPhotos.length) {
            _selectedPhotos[slotIndex] = image;
          } else {
            _selectedPhotos.add(image);
          }
        });
      }
    } catch (_) {
      // Graceful fallback
    }
  }

  void _removePhoto(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (index < _selectedPhotos.length) {
        _selectedPhotos.removeAt(index);
      }
    });
  }

  Future<void> _submitFeedback(bool isArabic) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        backgroundColor: const Color(0xFF1C2926),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                isArabic
                    ? 'شكراً لك! تم إرسال تقييمك وملاحظاتك بنجاح'
                    : 'Thank you! Your feedback has been submitted successfully',
                style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isArabic = tr.isArabic;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : mediaQuery.size.width;
            final screenHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : mediaQuery.size.height;

            final bool isDesktopWeb = screenWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : screenWidth;
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (screenHeight - 32.0).clamp(520.0, 844.0))
                : screenHeight;

            final double safeTop = mediaQuery.padding.top;
            final double headerTopPadding = math.max(safeTop + 14.0, 56.0);

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // Main Scrollable Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: headerTopPadding),

                          // Header: Circular back button + Title + Subtitle
                          _buildHeader(context, isArabic),

                          const SizedBox(height: 24.0),

                          // Top Illustration: 3D purple glowing chat bubble with stars
                          _buildIllustrationBadge(),

                          const SizedBox(height: 22.0),

                          // Provider Info Card
                          _buildProviderCard(isArabic),

                          const SizedBox(height: 22.0),

                          // Rating Section
                          _buildRatingSection(isArabic),

                          const SizedBox(height: 22.0),

                          // Your Feedback Textarea Section
                          _buildFeedbackInputSection(isArabic),

                          const SizedBox(height: 22.0),

                          // Add Photos (Optional) Section
                          _buildAddPhotosSection(isArabic),

                          const SizedBox(height: 26.0),

                          // Submit Feedback Button
                          _buildSubmitButton(isArabic),

                          const SizedBox(height: 20.0),
                          const Center(child: ProviderCardBottomIndicator()),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF141C1A),
                child: Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(42),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: screenContent,
                  ),
                ),
              );
            }

            return screenContent;
          },
        ),
      ),
    );
  }

  /// Header with Back Button + Title + Subtitle matching Figma spec
  Widget _buildHeader(BuildContext context, bool isArabic) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circular White Back Button
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).maybePop();
            },
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: _ChevronWidget(
                  width: 7.0,
                  height: 13.0,
                  color: const Color(0xFF1C2926),
                  isLeft: !isArabic,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14.0),

        // Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'التقييم وملاحظات المزود' : 'Feedback / Rate Provider',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                        height: 1.2,
                      )
                    : GoogleFonts.inter(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                        height: 1.2,
                      ),
              ),
              const SizedBox(height: 4.0),
              Text(
                isArabic
                    ? 'شارك تجربتك لمساعدتنا في تحسين خدمات تطبيق قريب.'
                    : 'Share your experience to help us improve QAREEB services.',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF616166),
                        height: 1.3,
                      )
                    : GoogleFonts.inter(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF616166),
                        height: 1.3,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Top Illustration: Purple glowing layered chat bubble with 3 hovering stars
  Widget _buildIllustrationBadge() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hovering purple stars: small, large, small
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Icon(Icons.star_rounded, size: 14.0, color: Color(0xFF9D65FE)),
              SizedBox(width: 4.0),
              Icon(Icons.star_rounded, size: 22.0, color: Color(0xFF8B53FE)),
              SizedBox(width: 4.0),
              Icon(Icons.star_rounded, size: 14.0, color: Color(0xFF9D65FE)),
            ],
          ),
          const SizedBox(height: 6.0),

          // Layered 3D-effect Chat Bubble
          Container(
            width: 96.0,
            height: 78.0,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFA573FE),
                  Color(0xFF8B53FE),
                ],
              ),
              borderRadius: BorderRadius.circular(22.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x458B53FE),
                  blurRadius: 28.0,
                  spreadRadius: 4.0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Inner content: 3 rounded horizontal lines
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46.0,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        width: 46.0,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        width: 32.0,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtle chat bubble tail
                Positioned(
                  bottom: -6.0,
                  right: 18.0,
                  child: Transform.rotate(
                    angle: 0.6,
                    child: Container(
                      width: 14.0,
                      height: 14.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B53FE),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Provider Info Card (matching uploaded screenshot)
  Widget _buildProviderCard(bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFF1F2EF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 12.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Provider circular Avatar
          Container(
            width: 52.0,
            height: 52.0,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC1CC),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/driver_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.person_rounded,
                  size: 28.0,
                  color: Color(0xFF1C2926),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14.0),

          // Provider details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.providerName,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                        )
                      : GoogleFonts.inter(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  widget.serviceType,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF616166),
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15.0,
                      color: Color(0xFF8B53FE),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${widget.rating} (${widget.reviewsCount} reviews)',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF616166),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Rating Section (1 to 5 stars)
  Widget _buildRatingSection(bool isArabic) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isArabic ? 'قيم تجربتك ' : 'Rate your experience ',
              style: isArabic
                  ? GoogleFonts.cairo(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1C2926),
                    )
                  : GoogleFonts.inter(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1C2926),
                    ),
            ),
            Text(
              isArabic ? '(اختياري)' : '(optional)',
              style: isArabic
                  ? GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    )
                  : GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // 5 Stars Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isFilled = starNumber <= _selectedRating;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedRating = starNumber);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 36.0,
                  color: isFilled
                      ? const Color(0xFFF59E0B) // Gold star matching screenshot
                      : const Color(0xFFD1D5DB),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Feedback Input Field Section with 0/300 Counter
  Widget _buildFeedbackInputSection(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'ملاحظاتك' : 'Your Feedback',
          style: isArabic
              ? GoogleFonts.cairo(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C2926),
                )
              : GoogleFonts.inter(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C2926),
                ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _feedbackCtrl,
                maxLines: 4,
                maxLength: 300,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1C2926),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: isArabic
                      ? 'شارك ملاحظاتك هنا...'
                      : 'Share your feedback here...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13.0,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Align(
                alignment: isArabic ? Alignment.bottomLeft : Alignment.bottomRight,
                child: Text(
                  '${_feedbackCtrl.text.length}/300',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Add Photos (Optional) 4-Slot Photo Picker
  Widget _buildAddPhotosSection(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isArabic ? 'إضافة صور ' : 'Add Photos ',
              style: isArabic
                  ? GoogleFonts.cairo(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C2926),
                    )
                  : GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C2926),
                    ),
            ),
            Text(
              isArabic ? '(اختياري)' : '(Optional)',
              style: isArabic
                  ? GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    )
                  : GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        // 4 slots row matching screenshot
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final hasPhoto = index < _selectedPhotos.length;

            if (hasPhoto) {
              final photo = _selectedPhotos[index];
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 74.0,
                    height: 74.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: kIsWeb
                        ? Image.network(photo.path, fit: BoxFit.cover)
                        : Image.file(File(photo.path), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: -6.0,
                    right: -6.0,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1C2926),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 13.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Slot 0 when empty: Camera icon + "Add Photo"
            if (index == _selectedPhotos.length) {
              return GestureDetector(
                onTap: () => _pickImage(index),
                child: Container(
                  width: 74.0,
                  height: 74.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 24.0,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        isArabic ? 'إضافة صورة' : 'Add Photo',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Inactive `+` slots
            return GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                width: 74.0,
                height: 74.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFFEFEFF3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 24.0,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Full-width Submit Feedback Button (#8B53FE) - Animated & non-hiding
  Widget _buildSubmitButton(bool isArabic) {
    return ProviderAnimatedButton(
      onTap: () => _submitFeedback(isArabic),
      isLoading: _isSubmitting,
      text: isArabic ? 'إرسال التقييم' : 'Submit Feedback',
      borderRadius: BorderRadius.circular(14.0),
      textStyle: isArabic
          ? GoogleFonts.cairo(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            )
          : GoogleFonts.inter(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
      icon: Icon(
        isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
        size: 18.0,
        color: Colors.white,
      ),
    );
  }
}

class _ChevronWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final bool isLeft;

  const _ChevronWidget({
    required this.width,
    required this.height,
    required this.color,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: isLeft ? 1.0 : -1.0,
      child: CustomPaint(
        size: Size(width, height),
        painter: _ChevronPainter(color: color),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  final Color color;
  const _ChevronPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(0.0, size.height / 2.0);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) => oldDelegate.color != color;
}

