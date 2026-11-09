import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/services/task_service.dart';
import 'package:mobile/features/home/presentation/widgets/bottom_nav_bar_widget.dart';
import 'package:mobile/features/provider/requests/presentation/provider_active_request_screen.dart';
import 'package:mobile/features/provider/requests/presentation/provider_request_details_screen.dart';
import 'package:mobile/features/provider/requests/presentation/widgets/provider_request_card.dart';
import 'package:mobile/features/provider/requests/presentation/widgets/provider_requests_header.dart';

/// Model representing incoming service requests for the provider side
class _ProviderRequestItem {
  final String id;
  final String serviceTypeEn;
  final String serviceTypeAr;
  final String locationEn;
  final String locationAr;
  final String distanceEn;
  final String distanceAr;
  final String timeEn;
  final String timeAr;
  final String badgeEn;
  final String badgeAr;
  final String imageAsset;
  final String status; // 'new', 'active', 'completed', 'cancelled'
  final String customerNameEn;
  final String customerNameAr;
  final String customerAvatarAsset;

  const _ProviderRequestItem({
    required this.id,
    required this.serviceTypeEn,
    required this.serviceTypeAr,
    required this.locationEn,
    required this.locationAr,
    required this.distanceEn,
    required this.distanceAr,
    required this.timeEn,
    required this.timeAr,
    required this.badgeEn,
    required this.badgeAr,
    required this.imageAsset,
    required this.status,
    this.customerNameEn = 'Ahmed Khan',
    this.customerNameAr = 'أحمد خان',
    this.customerAvatarAsset = 'assets/images/ahmed_khan.jpg',
  });
}

/// Provider Requests Screen
/// Dedicated provider-side request tab screen matching exact branding specifications:
///
/// Selected card branding:
///   background: #F4EFFE;
///   border: 1px solid #8B53FE;
///
/// Remaining cards:
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///   border will not purple (border: null)
///
/// Equal gap design 4,5 cards:
///   gap: 12px between cards
///   bottom indicator bar removed
class ProviderRequestsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackTap;
  final ValueChanged<int>? onTabSelected;
  final bool showBottomNav;
  final int initialFilterIndex;
  final bool isHistoryMode;

  const ProviderRequestsScreen({
    super.key,
    this.onBackTap,
    this.onTabSelected,
    this.showBottomNav = true,
    this.initialFilterIndex = 0,
    this.isHistoryMode = false,
  });

  static const double designWidth = 392.0;
  static const double designHeight = 844.0;

  @override
  ConsumerState<ProviderRequestsScreen> createState() =>
      _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends ConsumerState<ProviderRequestsScreen> {
  static const double designWidth = 392.0;
  static const double designHeight = 844.0;

  ScrollController? _scrollControllerInstance;
  ScrollController get _scrollController =>
      _scrollControllerInstance ??= ScrollController();

  int _selectedFilterIndex = 0; // 0: New (10), 1: Active (2), 2: Completed, 3: Cancelled
  int _selectedCardIndex = 0; // Selected card index (default 0)

  void _onTasksChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
    TaskService.instance.activeTaskNotifier.addListener(_onTasksChanged);
    TaskService.instance.historyNotifier.addListener(_onTasksChanged);
  }

  @override
  void dispose() {
    TaskService.instance.activeTaskNotifier.removeListener(_onTasksChanged);
    TaskService.instance.historyNotifier.removeListener(_onTasksChanged);
    _scrollControllerInstance?.dispose();
    super.dispose();
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (widget.onBackTap != null) {
      widget.onBackTap!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.onTabSelected != null) {
      widget.onTabSelected!(0);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  List<_ProviderRequestItem> get _allRequests {
    final List<_ProviderRequestItem> list = [];
    final active = TaskService.instance.activeTask;
    if (active != null) {
      final bool isNew = active.status == 'new' || active.status == 'pending';
      list.add(
        _ProviderRequestItem(
          id: active.id,
          serviceTypeEn: active.serviceCategory,
          serviceTypeAr: active.serviceCategory,
          locationEn: active.customerLocation,
          locationAr: active.customerLocation,
          distanceEn: '${active.distance} away',
          distanceAr: 'على بعد ${active.distance}',
          timeEn: active.dateTime,
          timeAr: active.dateTime,
          badgeEn: isNew ? 'New Request' : (active.status == 'arrived' ? 'Arrived' : 'Active'),
          badgeAr: isNew ? 'طلب جديد' : (active.status == 'arrived' ? 'تم الوصول' : 'نشط'),
          imageAsset: 'assets/images/img.png',
          status: active.status,
          customerNameEn: active.customerName,
          customerNameAr: active.customerName,
          customerAvatarAsset: 'assets/images/ahmed_khan.jpg',
        ),
      );
    }

    for (final h in TaskService.instance.historyTasks) {
      final bool isCancelled = h.status == 'cancelled';
      list.add(
        _ProviderRequestItem(
          id: h.id,
          serviceTypeEn: h.serviceCategory,
          serviceTypeAr: h.serviceCategory,
          locationEn: h.customerLocation,
          locationAr: h.customerLocation,
          distanceEn: h.distance,
          distanceAr: h.distance,
          timeEn: h.dateTime,
          timeAr: h.dateTime,
          badgeEn: isCancelled ? 'Cancelled' : 'Completed',
          badgeAr: isCancelled ? 'ملغي' : 'مكتمل',
          imageAsset: 'assets/images/img.png',
          status: h.status,
          customerNameEn: h.customerName,
          customerNameAr: h.customerName,
          customerAvatarAsset: 'assets/images/ahmed_khan.jpg',
        ),
      );
    }
    return list;
  }

  List<_ProviderRequestItem> get _filteredRequests {
    final all = _allRequests;
    if (widget.isHistoryMode) {
      // History Mode Tabs: 0: Completed, 1: Pending, 2: In Progress, 3: Cancelled
      switch (_selectedFilterIndex) {
        case 0:
          return all.where((r) => r.status == 'completed').toList();
        case 1:
          return all
              .where((r) => r.status == 'new' || r.status == 'pending')
              .toList();
        case 2:
          return all
              .where((r) => r.status == 'active' || r.status == 'in_progress' || r.status == 'arrived')
              .toList();
        case 3:
          return all.where((r) => r.status == 'cancelled').toList();
        default:
          return all;
      }
    } else {
      // Main Requests Tab Screen: 0: New, 1: Active, 2: Completed, 3: Cancelled
      switch (_selectedFilterIndex) {
        case 0:
          return all
              .where((r) => r.status == 'new' || r.status == 'pending')
              .toList();
        case 1:
          return all
              .where((r) => r.status == 'active' || r.status == 'in_progress' || r.status == 'arrived')
              .toList();
        case 2:
          return all.where((r) => r.status == 'completed').toList();
        case 3:
          return all.where((r) => r.status == 'cancelled').toList();
        default:
          return all;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

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
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb
                ? designWidth
                : (constraints.maxWidth > designWidth
                    ? designWidth
                    : constraints.maxWidth);
            final double containerHeight =
                isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double headerTop = isDesktopWeb
                ? ProviderRequestsHeader.designTop
                : (topSafeArea > 0
                    ? (topSafeArea + 12.0)
                    : ProviderRequestsHeader.designTop);

            // Header height: 36px (matching previous screen branding)
            // Tabs row layout specifications:
            final double tabsTop =
                headerTop + ProviderRequestsHeader.designHeight + 16.0;

            // Cards layout specifications (equal 20px padding left & right):
            final double cardsTop = tabsTop + 45.0 + 14.0;

            final Widget screenContent = Opacity(
              opacity: 1.0,
              child: Transform.rotate(
                angle: 0.0,
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      // Top Purple Glow Gradient
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: containerHeight * 0.298,
                        child: const IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.009, -1.0),
                                end: Alignment(-0.009, 1.0),
                                stops: [0.0, 1.0],
                                colors: [
                                  Color(0x5F8B53FE),
                                  Color(0x008B53FE),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 1. Pinned Header with chevron on left, Title + Subtitle, and Toggle on right
                      Positioned(
                        top: headerTop,
                        left: 20.0,
                        right: 20.0,
                        child: ProviderRequestsHeader(
                          onBack: _handleBack,
                        ),
                      ),

                      // 2. Pinned Tabs Row Layout (equal left & right padding: 20px)
                      Positioned(
                        top: tabsTop,
                        left: 20.0,
                        right: 20.0,
                        child: _buildFilterTabsRow(isArabic),
                      ),

                      // 3. Next Widget Layout: Cards Container with equal left and right padding: 20px
                      Positioned(
                        top: cardsTop,
                        left: 20.0,
                        right: 20.0,
                        bottom: isDesktopWeb
                            ? 96.0
                            : (MediaQuery.of(context).padding.bottom + 84.0),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false,
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                              PointerDeviceKind.stylus,
                            },
                          ),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_filteredRequests.isEmpty)
                                  _buildEmptyState(isArabic)
                                else
                                  ...List.generate(_filteredRequests.length, (index) {
                                    final item = _filteredRequests[index];
                                    final bool isSelected = _selectedCardIndex == index;

                                    String badgeTextEn = item.badgeEn;
                                    String badgeTextAr = item.badgeAr;
                                    if (widget.isHistoryMode) {
                                      if (item.status == 'new' || item.status == 'pending') {
                                        badgeTextEn = 'Pending';
                                        badgeTextAr = 'معلق';
                                      } else if (item.status == 'active' || item.status == 'in_progress') {
                                        badgeTextEn = 'In Progress';
                                        badgeTextAr = 'جاري التنفيذ';
                                      }
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0), // equal gap: 12px
                                      child: ProviderRequestCard(
                                        isSelected: isSelected,
                                        title: isArabic
                                            ? item.serviceTypeAr
                                            : item.serviceTypeEn,
                                        customerName: isArabic
                                            ? item.customerNameAr
                                            : item.customerNameEn,
                                        customerAvatarAsset: item.customerAvatarAsset,
                                        location: isArabic
                                            ? item.locationAr
                                            : item.locationEn,
                                        distance: isArabic
                                            ? item.distanceAr
                                            : item.distanceEn,
                                        timeText: isArabic
                                            ? item.timeAr
                                            : item.timeEn,
                                        badgeText: isArabic
                                            ? badgeTextAr
                                            : badgeTextEn,
                                        imageAsset: item.imageAsset,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            _selectedCardIndex = index;
                                          });
                                          if (item.status == 'active') {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ProviderActiveRequestScreen(
                                                  requestId: item.id,
                                                  serviceTypeEn: item.serviceTypeEn,
                                                  serviceTypeAr: item.serviceTypeAr,
                                                  locationEn: item.locationEn,
                                                  locationAr: item.locationAr,
                                                  distanceEn: item.distanceEn,
                                                  distanceAr: item.distanceAr,
                                                  timeEn: item.timeEn,
                                                  timeAr: item.timeAr,
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ProviderRequestDetailsScreen(
                                                  requestId: item.id,
                                                  serviceTypeEn: item.serviceTypeEn,
                                                  serviceTypeAr: item.serviceTypeAr,
                                                  locationEn: item.locationEn,
                                                  locationAr: item.locationAr,
                                                  distanceEn: item.distanceEn,
                                                  distanceAr: item.distanceAr,
                                                  timeEn: item.timeEn,
                                                  timeAr: item.timeAr,
                                                  badgeEn: item.badgeEn,
                                                  badgeAr: item.badgeAr,
                                                  imageAsset: item.imageAsset,
                                                  status: item.status,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 4. Floating Bottom Navigation Bar (Centered, width: 292)
                      if (widget.showBottomNav)
                        Positioned(
                          left: (containerWidth - 292.0) / 2,
                          width: 292.0,
                          bottom: isDesktopWeb
                              ? 20.0
                              : (MediaQuery.of(context).padding.bottom + 12.0),
                          child: BottomNavBarWidget(
                            currentIndex: 1,
                            initialIndex: 1,
                            onTabSelected: (index) {
                              if (widget.onTabSelected != null) {
                                widget.onTabSelected!(index);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: designWidth,
                    height: designHeight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 36,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.10),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(42),
                      child: screenContent,
                    ),
                  ),
                ),
              );
            }

            return Center(
              child: SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: screenContent,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Exact Figma Row Layout & Tabs:
  /// row layout:
  ///   width: 350; height: 45; border-radius: 12px; top: 108px; left: 20px; padding: 4px; background: #F3F2F5;
  /// 1st tab: width: 96; height: 37; border-radius: 10px; background: #8B53FE; New (10) - Inter 500 12px #FFFFFF
  /// 2nd tab: width: 82; height: 37; Active (2) - Inter 400 12px #616166
  /// 3rd tab: width: 82; height: 37; Completed - Inter 400 12px #616166
  /// 4th tab: width: 82; height: 37; Cancelled - Inter 400 12px #616166
  Widget _buildFilterTabsRow(bool isArabic) {
    final all = _allRequests;
    final newCount = all.where((r) => r.status == 'new' || r.status == 'pending').length;
    final activeCount = all.where((r) => r.status == 'active' || r.status == 'in_progress' || r.status == 'arrived').length;
    final completedCount = all.where((r) => r.status == 'completed').length;
    final cancelledCount = all.where((r) => r.status == 'cancelled').length;

    final List<Map<String, dynamic>> tabs = widget.isHistoryMode
        ? [
            {
              'labelEn': completedCount > 0 ? 'Completed ($completedCount)' : 'Completed',
              'labelAr': completedCount > 0 ? 'مكتمل ($completedCount)' : 'مكتمل',
              'flex': 88,
            },
            {
              'labelEn': newCount > 0 ? 'Pending ($newCount)' : 'Pending',
              'labelAr': newCount > 0 ? 'معلق ($newCount)' : 'معلق',
              'flex': 80,
            },
            {
              'labelEn': activeCount > 0 ? 'In Progress ($activeCount)' : 'In Progress',
              'labelAr': activeCount > 0 ? 'جاري التنفيذ ($activeCount)' : 'جاري التنفيذ',
              'flex': 96,
            },
            {
              'labelEn': cancelledCount > 0 ? 'Cancelled ($cancelledCount)' : 'Cancelled',
              'labelAr': cancelledCount > 0 ? 'ملغي ($cancelledCount)' : 'ملغي',
              'flex': 80,
            },
          ]
        : [
            {
              'labelEn': newCount > 0 ? 'New ($newCount)' : 'New',
              'labelAr': newCount > 0 ? 'جديد ($newCount)' : 'جديد',
              'flex': 96,
            },
            {
              'labelEn': activeCount > 0 ? 'Active ($activeCount)' : 'Active',
              'labelAr': activeCount > 0 ? 'نشط ($activeCount)' : 'نشط',
              'flex': 82,
            },
            {
              'labelEn': completedCount > 0 ? 'Completed ($completedCount)' : 'Completed',
              'labelAr': completedCount > 0 ? 'مكتمل ($completedCount)' : 'مكتمل',
              'flex': 82,
            },
            {
              'labelEn': cancelledCount > 0 ? 'Cancelled ($cancelledCount)' : 'Cancelled',
              'labelAr': cancelledCount > 0 ? 'ملغي ($cancelledCount)' : 'ملغي',
              'flex': 82,
            },
          ];

    return Container(
      width: double.infinity,
      height: 45.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2F5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          final item = tabs[index];
          final label = isArabic ? item['labelAr'] as String : item['labelEn'] as String;
          final flex = item['flex'] as int;

          return Expanded(
            flex: flex,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilterIndex = index;
                  _selectedCardIndex = 0; // Reset selected card to 0 on tab change
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                height: 37.0,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B53FE) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        label,
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 12.0,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF616166),
                                height: 1.0,
                              )
                            : GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF616166),
                                height: 1.0,
                                letterSpacing: 0.0,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Empty State Widget
  Widget _buildEmptyState(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 72.0,
            height: 72.0,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F2F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 36.0,
              color: Color(0xFF8B53FE),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            isArabic ? 'لا توجد طلبات في هذا القسم' : 'No requests in this tab',
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C2926),
                  )
                : GoogleFonts.inter(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                  ),
          ),
          const SizedBox(height: 6.0),
          Text(
            isArabic
                ? 'ستظهر هنا طلبات العملاء بمجرد تحديث الحالة'
                : 'Customer service requests will appear here when updated',
            textAlign: TextAlign.center,
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 12.0,
                    color: const Color(0xFF566663),
                  )
                : GoogleFonts.inter(
                    fontSize: 12.0,
                    color: const Color(0xFF566663),
                  ),
          ),
        ],
      ),
    );
  }
}
