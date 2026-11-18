import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/utils/geo_distance.dart';
import '../../../features/customer/auth/data/customer_auth_store.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/task_service.dart';

/// Branded service summary — thank-you flow and request history.
class CompletedServiceDetailsScreen extends ConsumerStatefulWidget {
  final ServiceTask? task;
  final String providerName;
  final String serviceCategory;

  const CompletedServiceDetailsScreen({
    super.key,
    this.task,
    this.providerName = '',
    this.serviceCategory = '',
  });

  @override
  ConsumerState<CompletedServiceDetailsScreen> createState() =>
      _CompletedServiceDetailsScreenState();
}

class _CompletedServiceDetailsScreenState
    extends ConsumerState<CompletedServiceDetailsScreen> {
  ServiceTask? _displayTask;
  bool _hydrating = false;

  @override
  void initState() {
    super.initState();
    _displayTask = _resolveInitialTask();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateFromBackend());
  }

  ServiceTask? _resolveInitialTask() {
    if (widget.task != null) return widget.task;
    final active = TaskService.instance.activeTask;
    if (active != null) return active;
    final history = TaskService.instance.customerHistoryTasks;
    if (history.isNotEmpty) return history.first;
    return null;
  }

  Future<void> _hydrateFromBackend() async {
    final t = _displayTask;
    final reqId = TaskService.extractBackendUuid(t?.id);
    if (reqId == null || _hydrating) return;
    setState(() => _hydrating = true);
    final data =
        await ref.read(backendServiceProvider).getCustomerRequestStatus(reqId);
    if (!mounted) return;
    if (data != null && t != null) {
      final addr = data['customerAddress']?.toString().trim() ?? '';
      final dist = data['distance']?.toString().trim() ?? '';
      final provider = data['providerName']?.toString().trim() ?? '';
      final category = data['serviceCategory']?.toString().trim() ?? '';
      final vehicleType = data['providerVehicleType']?.toString().trim() ?? '';
      final vehicleModel = data['providerVehicleModel']?.toString().trim() ?? '';
      final plate = data['providerPlateNumber']?.toString().trim() ?? '';
      final resolvedVehicle =
          vehicleType.isNotEmpty ? vehicleType : vehicleModel;

      setState(() {
        _displayTask = t.copyWith(
          providerName: provider.isNotEmpty ? provider : t.providerName,
          serviceCategory: category.isNotEmpty ? category : t.serviceCategory,
          customerLocation: addr.isNotEmpty ? addr : t.customerLocation,
          distance: dist.isNotEmpty && dist != '--' ? dist : t.distance,
          vehicleName: resolvedVehicle.isNotEmpty ? resolvedVehicle : t.vehicleName,
          plateNumber: plate.isNotEmpty ? plate : t.plateNumber,
        );
      });
    }
    if (mounted) setState(() => _hydrating = false);
  }

  static String _dashIfEmpty(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || v == '--' || v == '—') return '—';
    return v;
  }

  static String _requestIdLabel(ServiceTask? data) {
    if (data == null) return '—';
    final id = data.id.trim();
    if (id.isEmpty) return '—';
    return id.startsWith('REQ-') ? id : 'REQ-$id';
  }

  static String _customerName(ServiceTask? data, AppTranslations tr, CustomerAuthData auth) {
    final fromTask = data?.customerName.trim() ?? '';
    if (fromTask.isNotEmpty && fromTask.toLowerCase() != 'customer') {
      return fromTask;
    }
    final signedIn = auth.fullName.trim();
    if (signedIn.isNotEmpty) return signedIn;
    return fromTask.isNotEmpty ? fromTask : '—';
  }

  static String _locationLabel(ServiceTask? data, bool isArabic) {
    final raw = data?.customerLocation.trim() ?? '';
    if (raw.isEmpty) return '—';
    final label = GeoDistance.customerLocationLabel(raw, isArabic: isArabic);
    if (label.isEmpty || label == raw && GeoDistance.isGpsCoordinateLabel(raw)) {
      return '—';
    }
    return label;
  }

  static String _completedWhen(ServiceTask? data, AppTranslations tr) {
    final fromTask = data?.dateTime.trim() ?? '';
    if (fromTask.isNotEmpty && !fromTask.toLowerCase().contains('sample')) {
      return tr.formatDateTimeString(fromTask);
    }
    final ts = data?.createdAt;
    if (ts == null) return '—';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = ts.month >= 1 && ts.month <= 12 ? months[ts.month - 1] : '';
    final line =
        '${ts.day.toString().padLeft(2, '0')} $m ${ts.year}, ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    return tr.formatDateTimeString(line);
  }

  static String _etaLabel(ServiceTask? data, AppTranslations tr) {
    final eta = data?.eta.trim() ?? '';
    if (eta.isNotEmpty && eta != '--' && eta != '—') return eta;
    if (data?.status == 'completed') {
      return tr.isArabic ? 'اكتمل' : 'Completed';
    }
    return '—';
  }

  static bool _isSeedVehicle(String name) {
    final low = name.trim().toLowerCase();
    if (low.isEmpty) return true;
    return low == 'toyota hilux' ||
        low == 'toyota corolla' ||
        low == 'service vehicle' ||
        low == 'pickup';
  }

  static bool _isSeedPlate(String plate) {
    final p = plate.trim().toUpperCase();
    if (p.isEmpty) return true;
    return p == 'ABC-123' || p == '1122' || p == 'KSA 1234' || p == 'KSA1234';
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final auth = ref.watch(customerAuthProvider);
    final data = _displayTask;

    final provider = _dashIfEmpty(
      (data?.providerName.trim().isNotEmpty == true)
          ? data!.providerName.trim()
          : widget.providerName.trim(),
    );
    final category = _dashIfEmpty(
      (data?.serviceCategory.trim().isNotEmpty == true)
          ? data!.serviceCategory.trim()
          : widget.serviceCategory.trim(),
    );
    final location = _locationLabel(data, tr.isArabic);
    final distance = _dashIfEmpty(data?.distance);
    final eta = _etaLabel(data, tr);
    final when = _completedWhen(data, tr);
    final requestId = _requestIdLabel(data);
    final customer = _customerName(data, tr, auth);
    final rawVehicle = (data?.vehicleName ?? '').trim();
    final hasRealVehicle = !_isSeedVehicle(rawVehicle);
    final rawPlate = (data?.plateNumber ?? '').trim();
    final hasRealPlate = !_isSeedPlate(rawPlate);
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
                          _detailRow(
                            tr,
                            tr.isArabic ? 'المزود' : 'Provider',
                            provider == '—' ? provider : tr.formatProviderName(provider),
                          ),
                          _detailRow(
                            tr,
                            tr.isArabic ? 'نوع الخدمة' : 'Service type',
                            category == '—' ? category : tr.categoryName(category),
                          ),
                          _detailRow(tr, tr.isArabic ? 'العميل' : 'Customer', customer),
                        ],
                      ),
                    ),
                    if (hasRealVehicle || hasRealPlate) ...[
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
                            if (hasRealVehicle)
                              _detailRow(
                                tr,
                                tr.isArabic ? 'الطراز' : 'Model',
                                tr.formatVehicleName(rawVehicle),
                              ),
                            if (hasRealPlate)
                              _detailRow(tr, tr.isArabic ? 'اللوحة' : 'Plate', rawPlate),
                          ],
                        ),
                      ),
                    ],
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
                          _detailRow(tr, tr.completedOn, when),
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