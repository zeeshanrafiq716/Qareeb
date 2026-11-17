import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';
import '../../../services/task_service.dart';

/// Branded service summary — thank-you flow and request history.
class CompletedServiceDetailsScreen extends ConsumerWidget {
  final ServiceTask? task;
  final String providerName;
  final String serviceCategory;

  const CompletedServiceDetailsScreen({
    super.key,
    this.task,
    this.providerName = '',
    this.serviceCategory = '',
  });

  ServiceTask? _resolveTask() {
    return task ?? TaskService.instance.activeTask;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final data = _resolveTask();

    final provider = data?.providerName ?? providerName;
    final category = data?.serviceCategory ?? serviceCategory;
    final location = data?.customerLocation ?? '—';
    final vehicle = data?.vehicleName ?? '—';
    final plate = data?.plateNumber ?? '—';
    final distance = data?.distance ?? '—';
    final eta = data?.eta ?? '—';
    final when = data?.dateTime ?? tr.sampleCompletedDateTime;
    final requestId = data?.id ?? '—';
    final customer = data?.customerName ?? '—';
    final status = data?.status ?? 'completed';

    final bool isCancelled = status == 'cancelled';
    final String outcomeEn =
        isCancelled ? 'Cancelled' : (status == 'completed' ? 'Completed successfully' : status);
    final String outcomeAr = isCancelled
        ? 'تم الإلغاء'
        : (status == 'completed' ? 'تمت الخدمة بنجاح' : status);
    final Color outcomeColor =
        isCancelled ? const Color(0xFFDC2626) : const Color(0xFF8B53FE);
    final Color outcomeBg =
        isCancelled ? const Color(0xFFFFF0F0) : const Color(0xFFF0EAFE);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isDesktopWeb = screenWidth > 600;
          final containerWidth = isDesktopWeb ? 390.0 : screenWidth;
          final cardWidth = containerWidth >= 390
              ? 350.0
              : (containerWidth - 32.0).clamp(280.0, 350.0);
          final horizontalPadding = math.max(16.0, (containerWidth - cardWidth) / 2.0);

          final content = SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 56, horizontalPadding, 32),
            child: Center(
              child: SizedBox(
                width: cardWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(context, tr, cardWidth),
                    const SizedBox(height: 20),
                    Container(
                      width: cardWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: outcomeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCancelled
                                ? Icons.cancel_outlined
                                : Icons.check_circle_outline_rounded,
                            size: 20,
                            color: outcomeColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr.isArabic ? 'النتيجة' : 'Outcome',
                                  style: tr.font(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                  ),
                                ),
                                Text(
                                  tr.isArabic ? outcomeAr : outcomeEn,
                                  style: tr.font(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: outcomeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      tr,
                      cardWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow(tr, tr.isArabic ? 'رقم الطلب' : 'Request ID', requestId),
                          _detailRow(tr, tr.isArabic ? 'المزود' : 'Provider', tr.formatProviderName(provider)),
                          _detailRow(tr, tr.isArabic ? 'نوع الخدمة' : 'Service type', tr.categoryName(category)),
                          _detailRow(tr, tr.isArabic ? 'العميل' : 'Customer', customer),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      tr,
                      cardWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car_filled_outlined,
                                  size: 16, color: Color(0xFF8B53FE)),
                              const SizedBox(width: 8),
                              Text(
                                tr.isArabic ? 'تفاصيل المركبة' : 'Vehicle',
                                style: tr.font(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1C2926),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _detailRow(tr, tr.isArabic ? 'الطراز' : 'Model', tr.formatVehicleName(vehicle)),
                          _detailRow(tr, tr.isArabic ? 'اللوحة' : 'Plate', plate),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      tr,
                      cardWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: Color(0xFF8B53FE)),
                              const SizedBox(width: 8),
                              Text(
                                tr.isArabic ? 'تفاصيل الرحلة' : 'Trip details',
                                style: tr.font(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1C2926),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _detailRow(tr, tr.isArabic ? 'الموقع' : 'Location', location),
                          _detailRow(tr, tr.isArabic ? 'المسافة' : 'Distance', distance),
                          _detailRow(tr, tr.isArabic ? 'الوصول' : 'ETA', eta),
                          _detailRow(tr, tr.completedOn, tr.formatDateTimeString(when)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: cardWidth,
                      height: 4,
                      child: Center(
                        child: Container(
                          width: 134,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2926),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          if (isDesktopWeb) {
            return Center(
              child: Container(
                width: containerWidth,
                constraints: const BoxConstraints(maxHeight: 844),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: content,
              ),
            );
          }
          return content;
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppTranslations tr, double cardWidth) {
    return SizedBox(
      width: cardWidth,
      height: 36,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).maybePop();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFF566663)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  tr.isArabic
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  size: 22,
                  color: const Color(0xFF566663),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tr.isArabic ? 'تفاصيل الخدمة' : 'Service details',
              style: tr.font(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C2926),
                height: 22 / 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(AppTranslations tr, double width, {required Widget child}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _detailRow(AppTranslations tr, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: tr.font(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF566663),
                height: 1.3,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: tr.font(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C2926),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}