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
import '../../provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import '../../provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';

/// Provider Help & Support Screen
/// Tailored for service providers with equal branding:
/// - Header with circular white back button, title "Help & Support", and language toggle
/// - 24/7 Partner Support hero badge
/// - Quick contact channels (Phone Hotline, WhatsApp Helpdesk)
/// - Issue Category selector (Earnings, Cancellations, Vehicle updates, etc.)
/// - Issue description text area with character counter
/// - 4-slot screenshot/photo attachment picker
/// - Submit Support Request button (#8B53FE)
class ProviderHelpSupportScreen extends ConsumerStatefulWidget {
  const ProviderHelpSupportScreen({super.key});

  @override
  ConsumerState<ProviderHelpSupportScreen> createState() =>
      _ProviderHelpSupportScreenState();
}

class _ProviderHelpSupportScreenState
    extends ConsumerState<ProviderHelpSupportScreen> {
  String _selectedCategory = 'Earnings & Payouts';
  final TextEditingController _issueDescCtrl = TextEditingController();
  final List<XFile> _attachedScreenshots = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  int _expandedFaqIndex = -1;

  static const List<String> _issueCategories = [
    'Earnings & Payouts',
    'Customer Cancellation & Tolls',
    'Vehicle & Document Approval',
    'GPS & Trip Navigation Issue',
    'Account & Login Support',
    'General Partner Inquiry',
  ];

  @override
  void dispose() {
    _issueDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment(int slotIndex) async {
    try {
      HapticFeedback.lightImpact();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image != null) {
        setState(() {
          if (slotIndex < _attachedScreenshots.length) {
            _attachedScreenshots[slotIndex] = image;
          } else {
            _attachedScreenshots.add(image);
          }
        });
      }
    } catch (_) {
      // Graceful fallback
    }
  }

  void _removeAttachment(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (index < _attachedScreenshots.length) {
        _attachedScreenshots.removeAt(index);
      }
    });
  }

  void _showCategoryPicker(BuildContext context, bool isArabic) {
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
                  isArabic ? 'اختر تصنيف المشكلة' : 'Select Issue Category',
                  style: GoogleFonts.inter(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
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
                          cat,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

  Future<void> _submitTicket(bool isArabic) async {
    if (_isSubmitting) return;

    if (_issueDescCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic ? 'يرجى كتابة تفاصيل المشكلة' : 'Please provide details of your issue',
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
                    ? 'تم استلام تذكرتك بنجاح! سيتواصل معك فريق الدعم قريباً'
                    : 'Ticket submitted successfully! Partner support will contact you shortly.',
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
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: headerTopPadding),

                          // Header: Circular Back Button + Title + Subtitle + Language Toggle
                          _buildHeader(context, isArabic),

                          const SizedBox(height: 22.0),

                          // 24/7 Hero Illustration & Badge
                          _buildSupportHero(isArabic),

                          const SizedBox(height: 20.0),

                          // Quick Contact Action Cards (Call + WhatsApp + Email)
                          _buildQuickContactRow(isArabic),

                          const SizedBox(height: 24.0),

                          // Partner FAQs
                          Text(
                            isArabic ? 'الأسئلة الشائعة للشركاء' : 'Partner Frequently Asked Questions',
                            style: GoogleFonts.inter(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          _buildFaqSection(isArabic),
                          const SizedBox(height: 24.0),

                          // Issue Category Dropdown
                          _buildCategorySelector(isArabic),

                          const SizedBox(height: 18.0),

                          // Issue Details Text Area with 0/500 counter
                          _buildIssueDetailsSection(isArabic),

                          const SizedBox(height: 20.0),

                          // Add Screenshots / Documents
                          _buildAttachmentSection(isArabic),

                          const SizedBox(height: 26.0),

                          // Submit Ticket Button (#8B53FE)
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

  /// Header with Back Button + Title + Language Toggle
  Widget _buildHeader(BuildContext context, bool isArabic) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'المساعدة والدعم' : 'Help & Support',
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
              const SizedBox(height: 2.0),
              Text(
                isArabic
                    ? 'فريق دعم الشركاء متاح على مدار الساعة للمساعدة.'
                    : 'Partner support is available 24/7 to assist you.',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF616166),
                      )
                    : GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF616166),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8.0),

        // Language Toggle
        const ProviderAnimatedLanguageToggle.compact(),
      ],
    );
  }

  /// 24/7 Hero Support Illustration Badge
  Widget _buildSupportHero(bool isArabic) {
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
                Icons.headset_mic_rounded,
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
                  isArabic ? 'دعم شركاء قريب على مدار 24/7' : '24/7 Dedicated Partner Care',
                  style: GoogleFonts.inter(
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
                    ? 'استجابة سريعة لجميع مشاكل الرحلات والأرباح'
                    : 'Instant response for trip issues, earnings & safety',
                  style: GoogleFonts.inter(
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

  /// Quick Contact Row (Call Support, WhatsApp & Email)
  Widget _buildQuickContactRow(bool isArabic) {
    return Row(
      children: [
        // Call Hotline
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
                        ? 'جارٍ الاتصال برقم دعم الشركاء +966 54 545 6467...'
                        : 'Connecting to Partner Hotline (+966 54 545 6467)...',
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
                        ? 'جارٍ فتح محادثة واتساب شركاء قريب...'
                        : 'Opening WhatsApp Partner Desk...',
                  ),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            isArabic: isArabic,
          ),
        ),

        const SizedBox(width: 10.0),

        // Email Support
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
                        ? 'البريد الإلكتروني للشركاء: partners@zesho.tech'
                        : 'Email: partners@zesho.tech',
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
                      style: GoogleFonts.inter(
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

  /// Partner FAQ Section
  Widget _buildFaqSection(bool isArabic) {
    final faqs = [
      {
        'qEn': 'How do I receive instant trip earnings?',
        'qAr': 'كيف أستلم أرباح الرحلات والخدمات؟',
        'aEn': 'Earnings from completed orders are credited immediately to your in-app partner balance and can be transferred daily to your registered IBAN.',
        'aAr': 'تضاف أرباح الطلبات المكتملة فوراً إلى رصيد حسابك في التطبيق، ويمكنك تحويلها يومياً إلى حسابك البنكي (الآيبان) المسجل.',
      },
      {
        'qEn': 'What should I do if a customer cancels after arrival?',
        'qAr': 'ماذا أفعل إذا قام العميل بالإلغاء بعد وصولي؟',
        'aEn': 'If the customer cancels after your status is marked as "Arrived", a standard cancellation compensation fee is automatically credited to your balance.',
        'aAr': 'إذا ألغى العميل الطلب بعد تسجيل حالتك كـ "وصلت"، سيتم احتساب رسوم تعويض الإلغاء تلقائياً وإضافتها إلى رصيدك.',
      },
      {
        'qEn': 'How do I update my vehicle or renew documents?',
        'qAr': 'كيف أقوم بتحديث بيانات المركبة وتجديد الوثائق؟',
        'aEn': 'Navigate to your Profile tab > Vehicle & Service Details or Upload Documents to submit renewed licenses or change vehicle info for review.',
        'aAr': 'انتقل إلى تبويب الملف الشخصي > تفاصيل المركبة والخدمة أو رفع الوثائق لتحديث المستندات المجددة أو تعديل بيانات المركبة للمراجعة.',
      },
      {
        'qEn': 'How does GPS tracking and request dispatch work?',
        'qAr': 'كيف يعمل نظام تحديد الموقع وتوجيه الطلبات؟',
        'aEn': 'When your status is set to "Online", Zesho matches you with nearby customers within your service radius. Make sure location permissions are set to "Always Allow".',
        'aAr': 'عند تفعيل حالتك كـ "متصل"، يقوم نظام زشو بمطابقتك مع العملاء الأقرب ضمن نطاق تغطيتك. تأكد من تفعيل إذن الموقع على "السماح دائماً".',
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
                title: Text(
                  isArabic ? item['qAr']! : item['qEn']!,
                  style: GoogleFonts.inter(
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
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 14.0),
                  child: Text(
                    isArabic ? item['aAr']! : item['aEn']!,
                    style: GoogleFonts.inter(
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

  /// Category Selector
  Widget _buildCategorySelector(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'نوع المشكلة' : 'Issue Category',
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C2926),
          ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: () => _showCategoryPicker(context, isArabic),
          child: Container(
            height: 52.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 20.0,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    _selectedCategory,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1C2926),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.0,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Issue Details Section
  Widget _buildIssueDetailsSection(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'تفاصيل المشكلة' : 'Describe your issue',
          style: GoogleFonts.inter(
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
                controller: _issueDescCtrl,
                maxLines: 4,
                maxLength: 500,
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
                      ? 'يرجى كتابة تفاصيل الطلب أو المشكلة بدقة...'
                      : 'Provide details about your trip, booking ID, or inquiry...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13.0,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Align(
                alignment: isArabic ? Alignment.bottomLeft : Alignment.bottomRight,
                child: Text(
                  '${_issueDescCtrl.text.length}/500',
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

  /// 4-Slot Photo / Attachment Section
  Widget _buildAttachmentSection(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isArabic ? 'إرفاق لقطات شاشة ' : 'Attach Screenshots ',
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C2926),
              ),
            ),
            Text(
              isArabic ? '(اختياري)' : '(Optional)',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final hasPhoto = index < _attachedScreenshots.length;

            if (hasPhoto) {
              final photo = _attachedScreenshots[index];
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
                      onTap: () => _removeAttachment(index),
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

            if (index == _attachedScreenshots.length) {
              return GestureDetector(
                onTap: () => _pickAttachment(index),
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
                        isArabic ? 'إرفاق' : 'Attach',
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

            return GestureDetector(
              onTap: () => _pickAttachment(index),
              child: Container(
                width: 74.0,
                height: 74.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFFEFEFF3),
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

  /// Full-width Submit Ticket Button (#8B53FE) - Animated & non-hiding
  Widget _buildSubmitButton(bool isArabic) {
    return ProviderAnimatedButton(
      onTap: () => _submitTicket(isArabic),
      isLoading: _isSubmitting,
      text: isArabic ? 'إرسال طلب الدعم' : 'Submit Support Request',
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

