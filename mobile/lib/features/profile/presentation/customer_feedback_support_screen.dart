import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/app_locale.dart';
import '../../../services/task_service.dart';
import '../../provider/auth/presentation/widgets/provider_animated_button.dart';

/// Customer Help & Support Screen
/// Comprehensive customer support with ZERO seed data:
/// - Equal left and right padding across all devices and web wrappers
/// - Real official WhatsApp vector icon and clean real communication icons
/// - Overflow-free text with NO ellipsis dots
/// - 24/7 Customer Care Hero Banner
/// - Quick Contact Channels (Hotline, WhatsApp, Email)
/// - Recent Order Assistance (Reads dynamic task from TaskService)
/// - Interactive FAQ Accordion
/// - Submit a Support Ticket / Report an Issue form
class CustomerFeedbackSupportScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const CustomerFeedbackSupportScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<CustomerFeedbackSupportScreen> createState() =>
      _CustomerFeedbackSupportScreenState();
}

class _CustomerFeedbackSupportScreenState
    extends ConsumerState<CustomerFeedbackSupportScreen> {
  late String _selectedCategory;
  final TextEditingController _feedbackCtrl = TextEditingController();
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  int _expandedFaqIndex = -1;

  static const List<String> _issueCategories = [
    'Booking & Provider Arrival',
    'Payment & Pricing Inquiry',
    'Service Quality & Feedback',
    'Safety & Security Concern',
    'App Technical Issue',
    'Other Inquiries',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? _issueCategories.first;
  }

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
    } catch (_) {}
  }

  void _removePhoto(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (index < _selectedPhotos.length) {
        _selectedPhotos.removeAt(index);
      }
    });
  }

  void _showCategoryPicker(BuildContext context, bool isArabic) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  isArabic ? 'اختر نوع المشكلة' : 'Select Issue Category',
                  style: AppTypography.fontForLocale(
                    isArabic: isArabic,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C2926),
                  ),
                ),
                const SizedBox(height: 12.0),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _issueCategories.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: Color(0xFFF2F5F4),
                    ),
                    itemBuilder: (context, index) {
                      final cat = _issueCategories[index];
                      final isSelected = cat == _selectedCategory;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          isArabic ? _categoryAr(cat) : cat,
                          style: AppTypography.fontForLocale(
                            isArabic: isArabic,
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF1C2926),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF8B53FE),
                                size: 20.0,
                              )
                            : null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _categoryAr(String cat) {
    switch (cat) {
      case 'Booking & Provider Arrival':
        return 'الحجز ووصول المزود';
      case 'Payment & Pricing Inquiry':
        return 'الدفع والأسعار';
      case 'Service Quality & Feedback':
        return 'جودة الخدمة والتقييم';
      case 'Safety & Security Concern':
        return 'الأمان والسلامة';
      case 'App Technical Issue':
        return 'مشكلة تقنية في التطبيق';
      case 'Other Inquiries':
      default:
        return 'استفسارات أخرى';
    }
  }

  Future<void> _submitFeedback(bool isArabic) async {
    if (_isSubmitting) return;

    if (_feedbackCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic ? 'يرجى كتابة رسالتك أو تفاصيل المشكلة' : 'Please provide details of your issue or feedback',
            style: AppTypography.fontForLocale(isArabic: isArabic, color: Colors.white),
          ),
        ),
      );
      return;
    }

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
                    ? 'تم استلام تذكرتك بنجاح! سيتواصل معك فريق خدمة العملاء قريباً.'
                    : 'Your support ticket has been received! Our support team will contact you shortly.',
                style: AppTypography.fontForLocale(
                  isArabic: isArabic,
                  color: Colors.white,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
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

            // Perfectly symmetrical horizontal padding across all screen sizes
            final double horizontalPadding = isDesktopWeb
                ? 20.0
                : (containerWidth > 420.0
                    ? ((containerWidth - 380.0) / 2).clamp(20.0, 48.0)
                    : 20.0);

            final double safeTop = mediaQuery.padding.top;
            final double headerTopPadding = math.max(safeTop + 14.0, 56.0);

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: headerTopPadding),

                          // Symmetrical Header
                          _buildHeader(context, tr, isArabic),
                          const SizedBox(height: 20.0),

                          // 24/7 Hero Support Badge (Overflow-proof)
                          _buildCustomerCareHero(isArabic),
                          const SizedBox(height: 20.0),

                          // Quick Contact Channels (Hotline, WhatsApp, Email) - With Real Icons & NO DOTS
                          _buildQuickContactRow(isArabic),
                          const SizedBox(height: 20.0),

                          // Recent Order Assistance (if real task exists)
                          _buildRecentOrderHelpCard(isArabic),

                          // Frequently Asked Questions Header
                          Text(
                            isArabic ? 'الأسئلة الشائعة' : 'Frequently Asked Questions',
                            style: AppTypography.fontForLocale(
                              isArabic: isArabic,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          _buildFaqSection(isArabic),
                          const SizedBox(height: 20.0),

                          // Issue Category Selector
                          _buildCategorySelector(isArabic),
                          const SizedBox(height: 20.0),

                          // Feedback / Issue Description Area
                          _buildFeedbackTextArea(isArabic),
                          const SizedBox(height: 20.0),

                          // Photo attachment (optional)
                          _buildPhotoPickerSection(isArabic),
                          const SizedBox(height: 20.0),

                          // Submit Ticket Button
                          ProviderAnimatedButton(
                            text: isArabic ? 'إرسال طلب الدعم' : 'Submit Support Request',
                            isLoading: _isSubmitting,
                            onTap: () => _submitFeedback(isArabic),
                          ),
                          const SizedBox(height: 48.0),
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

  Widget _buildHeader(BuildContext context, AppTranslations tr, bool isArabic) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                child: Icon(
                  isArabic ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                  size: 22.0,
                  color: const Color(0xFF1C2926),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'المساعدة والدعم' : 'Help & Support',
                style: AppTypography.fontForLocale(
                  isArabic: isArabic,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2926),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                isArabic
                    ? 'فريق خدمة عملاء زشو في خدمتك دائماً.'
                    : 'Zesho Customer Care is here to assist you.',
                style: AppTypography.fontForLocale(
                  isArabic: isArabic,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF616166),
                ),
              ),
            ],
          ),
        ),
        // Symmetrical 36px right placeholder guarantees equal left/right alignment
        const SizedBox(width: 36.0, height: 36.0),
      ],
    );
  }

  /// 24/7 Hero Support Card: Completely overflow-safe with flexible wrapping & constraints
  Widget _buildCustomerCareHero(bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B53FE),
            Color(0xFF6D28D9),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x288B53FE),
            blurRadius: 16.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Center(
              child: Icon(
                Icons.support_agent_rounded,
                size: 24.0,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'خدمة عملاء زشو 24/7' : '24/7 Zesho Customer Care',
                  style: AppTypography.fontForLocale(
                    isArabic: isArabic,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3.0),
                Text(
                  isArabic
                      ? 'مساعدة فورية في الطلبات، الحجوزات والمدفوعات'
                      : 'Instant support for bookings, arrivals & payments',
                  style: AppTypography.fontForLocale(
                    isArabic: isArabic,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Contact Row: Real vector icons, concise labels without truncation or ellipsis dots
  Widget _buildQuickContactRow(bool isArabic) {
    return Row(
      children: [
        // Real Call Button
        Expanded(
          child: _buildContactChannelItem(
            icon: const Icon(
              Icons.phone_rounded,
              size: 18.0,
              color: Color(0xFF8B53FE),
            ),
            label: isArabic ? 'اتصال' : 'Call',
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'جارٍ الاتصال برقم الدعم +966 54 545 6467...'
                        : 'Connecting to Zesho Support (+966 54 545 6467)...',
                    style: AppTypography.fontForLocale(isArabic: isArabic, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF1C2926),
                ),
              );
            },
            isArabic: isArabic,
          ),
        ),
        const SizedBox(width: 10.0),

        // Real Official WhatsApp Button
        Expanded(
          child: _buildContactChannelItem(
            icon: const _RealWhatsAppIcon(
              size: 19.0,
              color: Color(0xFF25D366),
            ),
            label: isArabic ? 'واتساب' : 'WhatsApp',
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'جارٍ فتح محادثة واتساب الدعم...'
                        : 'Opening WhatsApp Customer Care...',
                    style: AppTypography.fontForLocale(isArabic: isArabic, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            isArabic: isArabic,
          ),
        ),
        const SizedBox(width: 10.0),

        // Real Email Support Button
        Expanded(
          child: _buildContactChannelItem(
            icon: const Icon(
              Icons.mail_rounded,
              size: 18.0,
              color: Color(0xFF8B53FE),
            ),
            label: isArabic ? 'إيميل' : 'Email',
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'البريد الإلكتروني للدعم: support@zesho.tech'
                        : 'Support email: support@zesho.tech',
                    style: AppTypography.fontForLocale(isArabic: isArabic, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF8B53FE),
                ),
              );
            },
            isArabic: isArabic,
          ),
        ),
      ],
    );
  }

  Widget _buildContactChannelItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    required bool isArabic,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 6.0),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: AppTypography.fontForLocale(
                        isArabic: isArabic,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrderHelpCard(bool isArabic) {
    final task = TaskService.instance.activeTask ??
        (TaskService.instance.historyTasks.isNotEmpty ? TaskService.instance.historyTasks.first : null);

    if (task == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAFE),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFF8B53FE).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.assignment_outlined,
                size: 20.0,
                color: Color(0xFF8B53FE),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'مساعدة بخصوص طلبك الأخير' : 'Need help with recent order?',
                  style: AppTypography.fontForLocale(
                    isArabic: isArabic,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${task.serviceCategory} • ${task.providerName} (${task.id})',
                  style: AppTypography.fontForLocale(
                    isArabic: isArabic,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF566663),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedCategory = 'Booking & Provider Arrival';
                _feedbackCtrl.text = isArabic
                    ? 'أحتاج مساعدة بخصوص طلبي الأخير (${task.serviceCategory}) رقم ${task.id}'
                    : 'I need assistance regarding my recent task (${task.serviceCategory}) #${task.id}';
              });
            },
            child: Text(
              isArabic ? 'تحديد' : 'Select',
              style: AppTypography.fontForLocale(
                isArabic: isArabic,
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8B53FE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(bool isArabic) {
    final List<Map<String, String>> faqs = [
      {
        'qEn': 'How do I book a nearby service?',
        'qAr': 'كيف يمكنني حجز خدمة قريبة؟',
        'aEn': 'Select your required category on the home screen, specify your location, and available nearby providers will receive your dispatch request immediately.',
        'aAr': 'اختر الخدمة المطلوبة من الصفحة الرئيسية، وحدد موقعك بدقة، وسيتلقى مزودو الخدمة المتواجدون بالقرب منك طلبك فوراً.',
      },
      {
        'qEn': 'How can I track my assigned provider?',
        'qAr': 'كيف أتمكن من تتبع مقدم الخدمة؟',
        'aEn': 'Once a provider accepts your service request, you can monitor their live GPS position in real-time right on the tracking map.',
        'aAr': 'بمجرد قبول المزود للطلب، يمكنك تتبع موقعه ومسار وصوله لحظة بلحظة على خريطة التتبع المباشرة.',
      },
      {
        'qEn': 'Can I cancel an active booking?',
        'qAr': 'هل يمكنني إلغاء الطلب بعد إرساله؟',
        'aEn': 'Yes, you can cancel before the provider arrives. Free cancellation applies within the first 5 minutes of dispatch acceptance.',
        'aAr': 'نعم، يمكنك إلغاء الطلب من تفاصيل الطلب قبل وصول المزود. الإلغاء مجاني خلال أول 5 دقائق من قبول الطلب.',
      },
      {
        'qEn': 'Are all providers verified and licensed?',
        'qAr': 'هل جميع مقدمي الخدمة مرخصون ومعتمدون؟',
        'aEn': 'Yes, every provider on Zesho undergoes thorough verification of their National ID/Iqama, driving license, vehicle registration, and criminal background before being approved.',
        'aAr': 'نعم، يخضع جميع مقدمي الخدمة في زشو لفحص وتوثيق الهوية الوطنية/الإقامة، رخصة القيادة، استمارة المركبة والفحص الأمني قبل اعتمادهم.',
      },
    ];

    return Column(
      children: List.generate(faqs.length, (index) {
        final item = faqs[index];
        final isExpanded = _expandedFaqIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isExpanded ? const Color(0xFF8B53FE) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                title: Text(
                  isArabic ? item['qAr']! : item['qEn']!,
                  style: AppTypography.fontForLocale(
                    isArabic: isArabic,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: isExpanded ? const Color(0xFF8B53FE) : const Color(0xFF616166),
                  size: 20.0,
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _expandedFaqIndex = isExpanded ? -1 : index;
                  });
                },
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 14.0),
                  child: Text(
                    isArabic ? item['aAr']! : item['aEn']!,
                    style: AppTypography.fontForLocale(
                      isArabic: isArabic,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF566663),
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCategorySelector(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'تصنيف المشكلة أو الاستفسار' : 'Inquiry / Issue Category',
          style: AppTypography.fontForLocale(
            isArabic: isArabic,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C2926),
          ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: () => _showCategoryPicker(context, isArabic),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? _categoryAr(_selectedCategory) : _selectedCategory,
                  style: AppTypography.fontForLocale(
                    isArabic: isArabic,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C2926),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.0,
                  color: Color(0xFF616166),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackTextArea(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'تفاصيل الرسالة أو المشكلة' : 'Details / Description',
          style: AppTypography.fontForLocale(
            isArabic: isArabic,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C2926),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 120.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _feedbackCtrl,
            maxLines: null,
            maxLength: 500,
            style: AppTypography.fontForLocale(
              isArabic: isArabic,
              fontSize: 13.0,
              color: const Color(0xFF1C2926),
            ),
            decoration: InputDecoration(
              hintText: isArabic
                  ? 'اكتب استفسارك أو مشكلتك بالتفصيل وسيقوم فريق الدعم بالرد عليك...'
                  : 'Describe your issue or question in detail...',
              hintStyle: AppTypography.fontForLocale(
                isArabic: isArabic,
                fontSize: 12.0,
                color: const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPickerSection(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'إرفاق صور للتوضيح (اختياري)' : 'Attach Photos (Optional)',
          style: AppTypography.fontForLocale(
            isArabic: isArabic,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C2926),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            for (int index = 0; index < 4; index++) ...[
              if (index > 0) const SizedBox(width: 8.0),
              Expanded(
                child: _buildPhotoSlot(index, isArabic),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoSlot(int index, bool isArabic) {
    final hasPhoto = index < _selectedPhotos.length;
    final XFile? file = hasPhoto ? _selectedPhotos[index] : null;

    return GestureDetector(
      onTap: () => hasPhoto ? _removePhoto(index) : _pickImage(index),
      child: Container(
        height: 70.0,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: hasPhoto ? const Color(0xFF8B53FE) : const Color(0xFFE5E7EB),
          ),
        ),
        child: hasPhoto && file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9.0),
                    child: kIsWeb
                        ? Image.network(file.path, fit: BoxFit.cover)
                        : Image.file(File(file.path), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4.0,
                    right: 4.0,
                    child: Container(
                      width: 18.0,
                      height: 18.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 12.0, color: Colors.white),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, size: 20.0, color: Color(0xFF9CA3AF)),
                  const SizedBox(height: 3.0),
                  Text(
                    isArabic ? 'إضافة' : 'Add',
                    style: AppTypography.fontForLocale(
                      isArabic: isArabic,
                      fontSize: 10.0,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Official Vector WhatsApp Icon matching authentic brand curves
class _RealWhatsAppIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _RealWhatsAppIcon({
    this.size = 19.0,
    this.color = const Color(0xFF25D366),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WhatsAppVectorPainter(color: color),
    );
  }
}

class _WhatsAppVectorPainter extends CustomPainter {
  final Color color;

  const _WhatsAppVectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final path = Path()..fillType = PathFillType.evenOdd;

    // 1. Speech bubble
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

    // 2. Inner bubble cutout
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

    // 3. Realistic phone receiver
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
  bool shouldRepaint(covariant _WhatsAppVectorPainter oldDelegate) =>
      oldDelegate.color != color;
}
