import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_locale.dart';
import '../send_location_screen.dart';
import '../send_request_screen.dart';

/// Reusable Provider Details Card matching Figma & user screenshot specifications:
/// - Top drag handle indicator
/// - Prominent circular CLOSE ICON ('X') in card to dismiss
/// - Driver avatar, name ("Usman Ali"), "Available" pill badge, rating "★ 4.9 (120 trips)"
/// - WhatsApp and Call quick action buttons
/// - Vehicle ("Toyota Hilux") and Category ("Fire Brigade") row
/// - Stat boxes: "1.8 km Distance Away" and "6 min Estimated time"
/// - Verification banner: Verified Providers | 500+ Deliveries | 98% On time
/// - "Send My Location" secondary button
/// - "Send Request ->" primary brand purple button
class ProviderDetailCardWidget extends ConsumerWidget {
  final String providerName;
  final String serviceCategory;
  final String vehicleName;
  final String distance;
  final String estimatedTime;
  final double rating;
  final int tripsCount;
  final String? avatarUrl;
  final String? phoneNumber;
  final bool showCloseIcon;
  final VoidCallback? onClose;
  final VoidCallback? onSendMyLocation;
  final VoidCallback? onSendRequest;

  const ProviderDetailCardWidget({
    super.key,
    this.providerName = 'Usman Ali',
    this.serviceCategory = 'Fire Brigade',
    this.vehicleName = 'Toyota Hilux',
    this.distance = '1.8 km',
    this.estimatedTime = '6 min',
    this.rating = 4.9,
    this.tripsCount = 120,
    this.avatarUrl,
    this.phoneNumber,
    this.showCloseIcon = true,
    this.onClose,
    this.onSendMyLocation,
    this.onSendRequest,
  });

  /// Opens the provider details card directly as a modal bottom sheet
  static Future<T?> showAsBottomSheet<T>({
    required BuildContext context,
    String providerName = 'Usman Ali',
    String serviceCategory = 'Fire Brigade',
    String vehicleName = 'Toyota Hilux',
    String distance = '1.8 km',
    String estimatedTime = '6 min',
    double rating = 4.9,
    int tripsCount = 120,
    String? avatarUrl,
    String? phoneNumber,
    VoidCallback? onSendMyLocation,
    VoidCallback? onSendRequest,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (ctx) => ProviderDetailCardWidget(
        providerName: providerName,
        serviceCategory: serviceCategory,
        vehicleName: vehicleName,
        distance: distance,
        estimatedTime: estimatedTime,
        rating: rating,
        tripsCount: tripsCount,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
        showCloseIcon: true,
        onClose: () => Navigator.of(ctx).pop(),
        onSendMyLocation: onSendMyLocation ??
            () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SendLocationScreen(
                    serviceCategory: serviceCategory,
                    providerName: providerName,
                  ),
                ),
              );
            },
        onSendRequest: onSendRequest ??
            () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SendRequestScreen(
                    serviceCategory: serviceCategory,
                    providerName: providerName,
                    distance: distance,
                  ),
                ),
              );
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = math.min(screenWidth, 440.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: cardWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1F000000), // 0px -2px 14px #0000001F
              offset: Offset(0, -3),
              blurRadius: 14.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Top Center Drag Indicator Handle
            Positioned(
              top: 12.0,
              left: (cardWidth - 40.0) / 2.0,
              width: 40.0,
              height: 4.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),

            // Scrollable Content
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 48.0, 20.0, math.max(16.0, bottomInset + 12.0)),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. DRIVER HEADER ROW: Avatar, Name, "Available" Badge, Rating, WhatsApp, Call
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Driver Avatar
                        Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFAAA6),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            avatarUrl ??
                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80',
                            width: 42.0,
                            height: 42.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF8B53FE),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 24.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),

                        // Name, Available Pill, Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      tr.formatProviderName(providerName),
                                      style: tr.font(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1C2926),
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0EAFE),
                                      borderRadius: BorderRadius.circular(60.0),
                                    ),
                                    child: Text(
                                      tr.isArabic ? 'متاح' : 'Available',
                                      style: tr.font(
                                        fontSize: 9.0,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8B53FE),
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 13.0,
                                    color: Color(0xFF8B53FE),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    tr.isArabic
                                        ? '${rating.toStringAsFixed(1)} ($tripsCount رحلة)'
                                        : '${rating.toStringAsFixed(1)} ($tripsCount trips)',
                                    style: tr.font(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF566663),
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons: WhatsApp & Call
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // WhatsApp
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                key: const Key('provider_detail_card_whatsapp_btn'),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tr.openingWhatsApp,
                                        style: tr.font(color: Colors.white),
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF25D366),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CustomPaint(
                                      size: Size(18.0, 18.0),
                                      painter: _CardWhatsAppIconPainter(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0),

                            // Call
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                key: const Key('provider_detail_card_call_btn'),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tr.callingProvider(tr.formatProviderName(providerName)),
                                        style: tr.font(color: Colors.white),
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1C2926),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.phone,
                                      size: 17.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),

                    // 2. VEHICLE & CATEGORY ROW: Car Icon, "Toyota Hilux", "Fire Brigade"
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 13.0,
                          color: Color(0xFF1C2926),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          tr.formatVehicleName(vehicleName),
                          style: tr.font(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          tr.categoryName(serviceCategory),
                          style: tr.font(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),

                    // 3. STAT CARDS ROW: Distance Away (1.8 km) & Estimated Time (6 min)
                    Row(
                      children: [
                        // Left Stat Box: Distance
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EAFE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CustomPaint(
                                      size: Size(15.0, 17.0),
                                      painter: _CardLocationPinPainter(
                                        color: Color(0xFF8B53FE),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        distance,
                                        style: tr.font(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C2926),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        tr.distanceAway,
                                        style: tr.font(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF566663),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),

                        // Right Stat Box: Estimated Time
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EAFE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CustomPaint(
                                      size: Size(18.0, 18.0),
                                      painter: _CardClockIconPainter(
                                        backgroundColor: Color(0xFF8B53FE),
                                        handColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        estimatedTime,
                                        style: tr.font(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C2926),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        tr.estimatedTime,
                                        style: tr.font(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF566663),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    // 4. VERIFICATION BANNER: Verified Providers | 500+ Deliveries | 98% On time
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5F4),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          // 1: Verified Providers
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 26.0,
                                  height: 26.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EAFE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CustomPaint(
                                      size: Size(13.0, 15.0),
                                      painter: _CardVerifiedShieldPainter(
                                        shieldColor: Color(0xFF8B53FE),
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tr.verified,
                                        style: tr.font(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C2926),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        tr.providersLabel,
                                        style: tr.font(
                                          fontSize: 9.0,
                                          color: const Color(0xFF566663),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 0.8,
                            height: 22.0,
                            color: const Color(0xFFE5E7EB),
                          ),

                          // 2: 500+ Deliveries
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 26.0,
                                  height: 26.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EAFE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.group_rounded,
                                      size: 15.0,
                                      color: Color(0xFF8B53FE),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '500+',
                                        style: tr.font(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C2926),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        tr.deliveriesLabel,
                                        style: tr.font(
                                          fontSize: 9.0,
                                          color: const Color(0xFF566663),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 0.8,
                            height: 22.0,
                            color: const Color(0xFFE5E7EB),
                          ),

                          // 3: 98% On time
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 26.0,
                                  height: 26.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EAFE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.thumb_up_rounded,
                                      size: 14.0,
                                      color: Color(0xFF8B53FE),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '98%',
                                        style: tr.font(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C2926),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        tr.onTime,
                                        style: tr.font(
                                          fontSize: 9.0,
                                          color: const Color(0xFF566663),
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // 5. ACTION BUTTONS: "Send My Location" & "Send Request ->"
                    // Send My Location Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        key: const Key('provider_detail_card_send_loc_btn'),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (onSendMyLocation != null) {
                            onSendMyLocation!();
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SendLocationScreen(
                                  serviceCategory: serviceCategory,
                                  providerName: providerName,
                                ),
                              ),
                            );
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F5F4),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomPaint(
                                size: Size(14.0, 16.0),
                                painter: _CardLocationPinPainter(
                                  color: Color(0xFF1C2926),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                tr.sendMyLocation,
                                style: tr.font(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1C2926),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    // Send Request Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        key: const Key('provider_detail_card_send_req_btn'),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          if (onSendRequest != null) {
                            onSendRequest!();
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SendRequestScreen(
                                  serviceCategory: serviceCategory,
                                  providerName: providerName,
                                  distance: distance,
                                ),
                              ),
                            );
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B53FE),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x338B53FE),
                                blurRadius: 10.0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                tr.isArabic ? 'إرسال الطلب' : 'Send Request',
                                style: tr.font(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Icon(
                                tr.isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                size: 18.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Corner Close Button ('X') - Painted on TOP of content
            if (showCloseIcon)
              PositionedDirectional(
                top: 10.0,
                end: 16.0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    key: const Key('provider_detail_card_close_button'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (onClose != null) {
                        onClose!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34.0,
                      height: 34.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFDDE2E0),
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.0,
                          color: Color(0xFF1C2926),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Vector WhatsApp Icon Painter
class _CardWhatsAppIconPainter extends CustomPainter {
  const _CardWhatsAppIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path bubble = Path();
    bubble.addOval(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.76));
    bubble.moveTo(w * 0.22, h * 0.72);
    bubble.lineTo(w * 0.12, h * 0.90);
    bubble.lineTo(w * 0.36, h * 0.82);
    bubble.close();

    final Paint outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawPath(bubble, outline);

    // Inner Phone Receiver
    final Paint phonePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Path phone = Path();
    phone.moveTo(w * 0.38, h * 0.34);
    phone.quadraticBezierTo(w * 0.44, h * 0.44, w * 0.54, h * 0.54);
    phone.quadraticBezierTo(w * 0.64, h * 0.62, w * 0.68, h * 0.58);
    phone.lineTo(w * 0.62, h * 0.70);
    phone.quadraticBezierTo(w * 0.48, h * 0.68, w * 0.34, h * 0.54);
    phone.quadraticBezierTo(w * 0.26, h * 0.42, w * 0.28, h * 0.32);
    phone.close();
    canvas.drawPath(phone, phonePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Location Pin Painter
class _CardLocationPinPainter extends CustomPainter {
  final Color color;

  const _CardLocationPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(w / 2.0, h);
    path.cubicTo(w * 0.1, h * 0.65, 0.0, h * 0.45, 0.0, h * 0.34);
    path.cubicTo(0.0, h * 0.15, w * 0.22, 0.0, w / 2.0, 0.0);
    path.cubicTo(w * 0.78, 0.0, w, h * 0.15, w, h * 0.34);
    path.cubicTo(w, h * 0.45, w * 0.9, h * 0.65, w / 2.0, h);
    path.close();

    canvas.drawPath(path, paint);

    // Inner Cutout Circle
    final Paint hole = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2.0, h * 0.34), w * 0.22, hole);
  }

  @override
  bool shouldRepaint(covariant _CardLocationPinPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Vector Clock Icon Painter
class _CardClockIconPainter extends CustomPainter {
  final Color backgroundColor;
  final Color handColor;

  const _CardClockIconPainter({
    required this.backgroundColor,
    required this.handColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;
    final double r = size.width / 2.0;

    final Paint circlePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), r, circlePaint);

    final Paint handPaint = Paint()
      ..color = handColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Minute Hand (pointing up)
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - (r * 0.52)), handPaint);
    // Hour Hand (pointing right)
    canvas.drawLine(Offset(cx, cy), Offset(cx + (r * 0.40), cy), handPaint);
  }

  @override
  bool shouldRepaint(covariant _CardClockIconPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.handColor != handColor;
}

/// Vector Verified Shield Painter
class _CardVerifiedShieldPainter extends CustomPainter {
  final Color shieldColor;
  final Color checkColor;

  const _CardVerifiedShieldPainter({
    required this.shieldColor,
    required this.checkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint shield = Paint()
      ..color = shieldColor
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(w / 2.0, 0.0);
    path.lineTo(w, h * 0.18);
    path.lineTo(w, h * 0.52);
    path.quadraticBezierTo(w * 0.85, h * 0.85, w / 2.0, h);
    path.quadraticBezierTo(w * 0.15, h * 0.85, 0.0, h * 0.52);
    path.lineTo(0.0, h * 0.18);
    path.close();

    canvas.drawPath(path, shield);

    // Inner White Checkmark
    final Paint check = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path checkPath = Path();
    checkPath.moveTo(w * 0.28, h * 0.50);
    checkPath.lineTo(w * 0.44, h * 0.66);
    checkPath.lineTo(w * 0.74, h * 0.34);

    canvas.drawPath(checkPath, check);
  }

  @override
  bool shouldRepaint(covariant _CardVerifiedShieldPainter oldDelegate) =>
      oldDelegate.shieldColor != shieldColor ||
      oldDelegate.checkColor != checkColor;
}
