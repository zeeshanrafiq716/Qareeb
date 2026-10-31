import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../models/provider_model.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/location_service.dart';
import 'provider_detail_screen.dart';
import 'widgets/provider_detail_card_widget.dart';
import 'widgets/top_down_car_widget.dart';

/// Custom scroll behavior enabling smooth mouse dragging, trackpad gestures, and touch on all devices:
class _EasyScrollBehavior extends MaterialScrollBehavior {
  const _EasyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

/// Screen displayed when user clicks 'Find a Provider'.
/// Header strictly matches the branding of PickupDeliveryScreen.
/// Ready for manual layout branding.
class FindProviderScreen extends ConsumerStatefulWidget {
  final String serviceCategory;

  const FindProviderScreen({
    super.key,
    this.serviceCategory = 'Pickup & Delivery',
  });

  @override
  ConsumerState<FindProviderScreen> createState() => _FindProviderScreenState();
}

class _NearbyProviderItem {
  final int id;
  final String name;
  final String nameAr;
  final String vehicle;
  final String vehicleAr;
  final double rating;
  final int reviews;
  final String status;
  final double distanceKm;
  final String eta;
  final String etaAr;
  final String imagePath;
  final String phone;
  final double latOffset;
  final double lngOffset;
  final double heading;
  final Color carColor;

  const _NearbyProviderItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.vehicle,
    required this.vehicleAr,
    required this.rating,
    required this.reviews,
    required this.status,
    required this.distanceKm,
    required this.eta,
    required this.etaAr,
    required this.imagePath,
    required this.phone,
    required this.latOffset,
    required this.lngOffset,
    this.heading = 45.0,
    this.carColor = const Color(0xFFA67AFE),
  });
}

const List<_NearbyProviderItem> _all30NearbyProviders = [
  _NearbyProviderItem(
    id: 1,
    name: 'Uzair Ahmed',
    nameAr: 'عزير أحمد',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.9,
    reviews: 120,
    status: 'Available',
    distanceKm: 0.3,
    eta: '2 min away',
    etaAr: 'على بعد 2 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 300 1234567',
    latOffset: 0.0018,
    lngOffset: -0.0022,
    heading: 85.0,
    carColor: Color(0xFFA67AFE),
  ),
  _NearbyProviderItem(
    id: 2,
    name: 'Ahmad Raza',
    nameAr: 'أحمد رضا',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.9,
    reviews: 115,
    status: 'Available',
    distanceKm: 0.5,
    eta: '3 min away',
    etaAr: 'على بعد 3 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 301 2345678',
    latOffset: -0.0015,
    lngOffset: 0.0028,
    heading: 210.0,
    carColor: Color(0xFF8B53FE),
  ),
  _NearbyProviderItem(
    id: 3,
    name: 'Muhammad Bilal',
    nameAr: 'محمد بلال',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.8,
    reviews: 95,
    status: 'Available',
    distanceKm: 0.6,
    eta: '4 min away',
    etaAr: 'على بعد 4 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 302 3456789',
    latOffset: 0.0032,
    lngOffset: 0.0015,
    heading: 340.0,
    carColor: Color(0xFF6C3CE9),
  ),
  _NearbyProviderItem(
    id: 4,
    name: 'Usman Ali',
    nameAr: 'عثمان علي',
    vehicle: 'Pickup • AC',
    vehicleAr: 'شاحنة نقل • مكيف',
    rating: 4.9,
    reviews: 142,
    status: 'Available',
    distanceKm: 0.9,
    eta: '5 min away',
    etaAr: 'على بعد 5 د',
    imagePath: 'assets/images/pickup.png',
    phone: '+92 303 4567890',
    latOffset: -0.0028,
    lngOffset: -0.0035,
    heading: 120.0,
    carColor: Color(0xFF9E6CF5),
  ),
  _NearbyProviderItem(
    id: 5,
    name: 'Hamza Sheikh',
    nameAr: 'حمزة شيخ',
    vehicle: 'Sedan • Non-AC',
    vehicleAr: 'سيدان • بدون تكييف',
    rating: 4.7,
    reviews: 80,
    status: 'Available',
    distanceKm: 1.1,
    eta: '6 min away',
    etaAr: 'على بعد 6 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 304 5678901',
    latOffset: 0.0042,
    lngOffset: -0.0018,
    heading: 45.0,
    carColor: Color(0xFF7C4DFF),
  ),
  _NearbyProviderItem(
    id: 6,
    name: 'Tariq Mahmood',
    nameAr: 'طارق محمود',
    vehicle: 'SUV • AC',
    vehicleAr: 'دفع رباعي • مكيف',
    rating: 4.8,
    reviews: 108,
    status: 'Available',
    distanceKm: 1.2,
    eta: '7 min away',
    etaAr: 'على بعد 7 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 305 6789012',
    latOffset: -0.0038,
    lngOffset: 0.0042,
    heading: 175.0,
    carColor: Color(0xFF8B53FE),
  ),
  _NearbyProviderItem(
    id: 7,
    name: 'Zeeshan Khan',
    nameAr: 'ذیشان خان',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.9,
    reviews: 134,
    status: 'Available',
    distanceKm: 1.4,
    eta: '8 min away',
    etaAr: 'على بعد 8 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 306 7890123',
    latOffset: 0.0022,
    lngOffset: 0.0051,
    heading: 290.0,
    carColor: Color(0xFFA67AFE),
  ),
  _NearbyProviderItem(
    id: 8,
    name: 'Fahad Mustafa',
    nameAr: 'فهد مصطفى',
    vehicle: 'Hatchback • AC',
    vehicleAr: 'هاتشباك • مكيف',
    rating: 4.7,
    reviews: 64,
    status: 'Available',
    distanceKm: 1.5,
    eta: '9 min away',
    etaAr: 'على بعد 9 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 307 8901234',
    latOffset: -0.0045,
    lngOffset: -0.0021,
    heading: 60.0,
    carColor: Color(0xFF9E6CF5),
  ),
  _NearbyProviderItem(
    id: 9,
    name: 'Imran Butt',
    nameAr: 'عمران بت',
    vehicle: 'Pickup • AC',
    vehicleAr: 'شاحنة نقل • مكيف',
    rating: 4.8,
    reviews: 112,
    status: 'Available',
    distanceKm: 1.7,
    eta: '10 min away',
    etaAr: 'على بعد 10 د',
    imagePath: 'assets/images/pickup.png',
    phone: '+92 308 9012345',
    latOffset: 0.0055,
    lngOffset: 0.0033,
    heading: 195.0,
    carColor: Color(0xFF6C3CE9),
  ),
  _NearbyProviderItem(
    id: 10,
    name: 'Asad Malik',
    nameAr: 'أسعد مالك',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.9,
    reviews: 88,
    status: 'Available',
    distanceKm: 1.8,
    eta: '11 min away',
    etaAr: 'على بعد 11 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 309 0123456',
    latOffset: -0.0019,
    lngOffset: 0.0062,
    heading: 315.0,
    carColor: Color(0xFF8B53FE),
  ),
  _NearbyProviderItem(
    id: 11,
    name: 'Rashid Minhas',
    nameAr: 'راشد منهاس',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.8,
    reviews: 92,
    status: 'Available',
    distanceKm: 2.0,
    eta: '12 min away',
    etaAr: 'على بعد 12 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 310 1234567',
    latOffset: 0.0062,
    lngOffset: -0.0041,
    heading: 110.0,
    carColor: Color(0xFFA67AFE),
  ),
  _NearbyProviderItem(
    id: 12,
    name: 'Daniyal Siddiqui',
    nameAr: 'دانيال صديقي',
    vehicle: 'SUV • AC',
    vehicleAr: 'دفع رباعي • مكيف',
    rating: 4.9,
    reviews: 150,
    status: 'Available',
    distanceKm: 2.1,
    eta: '12 min away',
    etaAr: 'على بعد 12 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 311 2345678',
    latOffset: -0.0058,
    lngOffset: 0.0054,
    heading: 225.0,
    carColor: Color(0xFF7C4DFF),
  ),
  _NearbyProviderItem(
    id: 13,
    name: 'Waqas Qureshi',
    nameAr: 'وقاص قريشي',
    vehicle: 'Pickup • AC',
    vehicleAr: 'شاحنة نقل • مكيف',
    rating: 4.7,
    reviews: 76,
    status: 'Available',
    distanceKm: 2.3,
    eta: '13 min away',
    etaAr: 'على بعد 13 د',
    imagePath: 'assets/images/pickup.png',
    phone: '+92 312 3456789',
    latOffset: 0.0035,
    lngOffset: -0.0068,
    heading: 15.0,
    carColor: Color(0xFF9E6CF5),
  ),
  _NearbyProviderItem(
    id: 14,
    name: 'Salman Farooq',
    nameAr: 'سلمان فاروق',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.8,
    reviews: 104,
    status: 'Available',
    distanceKm: 2.4,
    eta: '14 min away',
    etaAr: 'على بعد 14 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 313 4567890',
    latOffset: -0.0065,
    lngOffset: -0.0039,
    heading: 140.0,
    carColor: Color(0xFF8B53FE),
  ),
  _NearbyProviderItem(
    id: 15,
    name: 'Haris Rauf',
    nameAr: 'حارث رؤوف',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.9,
    reviews: 128,
    status: 'Available',
    distanceKm: 2.5,
    eta: '14 min away',
    etaAr: 'على بعد 14 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 314 5678901',
    latOffset: 0.0071,
    lngOffset: 0.0025,
    heading: 270.0,
    carColor: Color(0xFF6C3CE9),
  ),
  _NearbyProviderItem(
    id: 16,
    name: 'Babar Azam',
    nameAr: 'بابر أعظم',
    vehicle: 'SUV • AC',
    vehicleAr: 'دفع رباعي • مكيف',
    rating: 5.0,
    reviews: 210,
    status: 'Available',
    distanceKm: 2.7,
    eta: '15 min away',
    etaAr: 'على بعد 15 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 315 6789012',
    latOffset: -0.0041,
    lngOffset: 0.0078,
    heading: 35.0,
    carColor: Color(0xFFA67AFE),
  ),
  _NearbyProviderItem(
    id: 17,
    name: 'Shaheen Afridi',
    nameAr: 'شاهين أفريدي',
    vehicle: 'Pickup • AC',
    vehicleAr: 'شاحنة نقل • مكيف',
    rating: 4.9,
    reviews: 175,
    status: 'Available',
    distanceKm: 2.8,
    eta: '16 min away',
    etaAr: 'على بعد 16 د',
    imagePath: 'assets/images/pickup.png',
    phone: '+92 316 7890123',
    latOffset: 0.0048,
    lngOffset: -0.0075,
    heading: 180.0,
    carColor: Color(0xFF8B53FE),
  ),
  _NearbyProviderItem(
    id: 18,
    name: 'Shadab Khan',
    nameAr: 'شاداب خان',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.8,
    reviews: 98,
    status: 'Available',
    distanceKm: 3.0,
    eta: '17 min away',
    etaAr: 'على بعد 17 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 317 8901234',
    latOffset: -0.0074,
    lngOffset: 0.0048,
    heading: 300.0,
    carColor: Color(0xFF9E6CF5),
  ),
  _NearbyProviderItem(
    id: 19,
    name: 'Naseem Shah',
    nameAr: 'نسيم شاه',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.9,
    reviews: 110,
    status: 'Available',
    distanceKm: 3.1,
    eta: '17 min away',
    etaAr: 'على بعد 17 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 318 9012345',
    latOffset: 0.0082,
    lngOffset: -0.0031,
    heading: 90.0,
    carColor: Color(0xFF7C4DFF),
  ),
  _NearbyProviderItem(
    id: 20,
    name: 'Mohammad Rizwan',
    nameAr: 'محمد رضوان',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.9,
    reviews: 185,
    status: 'Available',
    distanceKm: 3.2,
    eta: '18 min away',
    etaAr: 'على بعد 18 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 319 0123456',
    latOffset: -0.0051,
    lngOffset: -0.0082,
    heading: 240.0,
    carColor: Color(0xFF8B53FE),
  ),
  _NearbyProviderItem(
    id: 21,
    name: 'Fakhar Zaman',
    nameAr: 'فخر زمان',
    vehicle: 'SUV • AC',
    vehicleAr: 'دفع رباعي • مكيف',
    rating: 4.8,
    reviews: 102,
    status: 'Available',
    distanceKm: 3.4,
    eta: '19 min away',
    etaAr: 'على بعد 19 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 320 1234567',
    latOffset: 0.0069,
    lngOffset: 0.0065,
    heading: 135.0,
    carColor: Color(0xFFA67AFE),
  ),
  _NearbyProviderItem(
    id: 22,
    name: 'Iftikhar Ahmed',
    nameAr: 'افتخار أحمد',
    vehicle: 'Pickup • AC',
    vehicleAr: 'شاحنة نقل • مكيف',
    rating: 4.7,
    reviews: 89,
    status: 'Available',
    distanceKm: 3.5,
    eta: '20 min away',
    etaAr: 'على بعد 20 د',
    imagePath: 'assets/images/pickup.png',
    phone: '+92 321 2345678',
    latOffset: -0.0083,
    lngOffset: -0.0055,
    heading: 330.0,
    carColor: Color(0xFF6C3CE9),
  ),
  _NearbyProviderItem(
    id: 23,
    name: 'Imad Wasim',
    nameAr: 'عماد وسيم',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.8,
    reviews: 114,
    status: 'Available',
    distanceKm: 3.6,
    eta: '20 min away',
    etaAr: 'على بعد 20 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 322 3456789',
    latOffset: 0.0058,
    lngOffset: -0.0088,
    heading: 50.0,
    carColor: Color(0xFF8B53FE),
  ),
  _NearbyProviderItem(
    id: 24,
    name: 'Hasan Ali',
    nameAr: 'حسن علي',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.7,
    reviews: 73,
    status: 'Available',
    distanceKm: 3.8,
    eta: '21 min away',
    etaAr: 'على بعد 21 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 323 4567890',
    latOffset: -0.0068,
    lngOffset: 0.0086,
    heading: 215.0,
    carColor: Color(0xFF9E6CF5),
  ),
  _NearbyProviderItem(
    id: 25,
    name: 'Faheem Ashraf',
    nameAr: 'فهيم أشرف',
    vehicle: 'Hatchback • AC',
    vehicleAr: 'هاتشباك • مكيف',
    rating: 4.6,
    reviews: 58,
    status: 'Available',
    distanceKm: 3.9,
    eta: '22 min away',
    etaAr: 'على بعد 22 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 324 5678901',
    latOffset: 0.0091,
    lngOffset: 0.0042,
    heading: 160.0,
    carColor: Color(0xFF7C4DFF),
  ),
  _NearbyProviderItem(
    id: 26,
    name: 'Aamer Jamal',
    nameAr: 'عامر جمال',
    vehicle: 'Pickup • AC',
    vehicleAr: 'شاحنة نقل • مكيف',
    rating: 4.8,
    reviews: 91,
    status: 'Available',
    distanceKm: 4.1,
    eta: '23 min away',
    etaAr: 'على بعد 23 د',
    imagePath: 'assets/images/pickup.png',
    phone: '+92 325 6789012',
    latOffset: -0.0092,
    lngOffset: -0.0046,
    heading: 280.0,
    carColor: Color(0xFF8B53FE),
  ),
  _NearbyProviderItem(
    id: 27,
    name: 'Saim Ayub',
    nameAr: 'صائم أيوب',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.9,
    reviews: 130,
    status: 'Available',
    distanceKm: 4.2,
    eta: '23 min away',
    etaAr: 'على بعد 23 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 326 7890123',
    latOffset: 0.0076,
    lngOffset: -0.0079,
    heading: 20.0,
    carColor: Color(0xFFA67AFE),
  ),
  _NearbyProviderItem(
    id: 28,
    name: 'Abdullah Shafique',
    nameAr: 'عبد الله شفيق',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.8,
    reviews: 84,
    status: 'Available',
    distanceKm: 4.4,
    eta: '24 min away',
    etaAr: 'على بعد 24 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 327 8901234',
    latOffset: -0.0079,
    lngOffset: 0.0094,
    heading: 190.0,
    carColor: Color(0xFF6C3CE9),
  ),
  _NearbyProviderItem(
    id: 29,
    name: 'Usama Mir',
    nameAr: 'أسامة مير',
    vehicle: 'SUV • AC',
    vehicleAr: 'دفع رباعي • مكيف',
    rating: 4.7,
    reviews: 67,
    status: 'Available',
    distanceKm: 4.5,
    eta: '25 min away',
    etaAr: 'على بعد 25 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 328 9012345',
    latOffset: 0.0098,
    lngOffset: -0.0062,
    heading: 320.0,
    carColor: Color(0xFF9E6CF5),
  ),
  _NearbyProviderItem(
    id: 30,
    name: 'Zaman Khan',
    nameAr: 'زمان خان',
    vehicle: 'Sedan • AC',
    vehicleAr: 'سيدان • مكيف',
    rating: 4.8,
    reviews: 95,
    status: 'Available',
    distanceKm: 4.7,
    eta: '26 min away',
    etaAr: 'على بعد 26 د',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 329 0123456',
    latOffset: -0.0095,
    lngOffset: -0.0078,
    heading: 75.0,
    carColor: Color(0xFF8B53FE),
  ),
];

class _FindProviderScreenState extends ConsumerState<FindProviderScreen> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedProviderCount = 10;
  double _zoom = 14.5;
  double? _centerPixelX;
  double? _centerPixelY;
  bool _isDraggingMap = false;
  double _mapScaleBase = 1.0;
  int? _selectedProviderId;

  void _zoomIn() {
    HapticFeedback.selectionClick();
    if (_zoom >= 18.0) return;
    setState(() {
      if (_centerPixelX != null && _centerPixelY != null) {
        final curLng = MercatorProjection.xToLng(_centerPixelX!, _zoom);
        final curLat = MercatorProjection.yToLat(_centerPixelY!, _zoom);
        _zoom = (_zoom + 1.0).clamp(10.0, 18.0);
        _centerPixelX = MercatorProjection.lngToX(curLng, _zoom);
        _centerPixelY = MercatorProjection.latToY(curLat, _zoom);
      } else {
        _zoom = (_zoom + 1.0).clamp(10.0, 18.0);
      }
    });
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    if (_zoom <= 10.0) return;
    setState(() {
      if (_centerPixelX != null && _centerPixelY != null) {
        final curLng = MercatorProjection.xToLng(_centerPixelX!, _zoom);
        final curLat = MercatorProjection.yToLat(_centerPixelY!, _zoom);
        _zoom = (_zoom - 1.0).clamp(10.0, 18.0);
        _centerPixelX = MercatorProjection.lngToX(curLng, _zoom);
        _centerPixelY = MercatorProjection.latToY(curLat, _zoom);
      } else {
        _zoom = (_zoom - 1.0).clamp(10.0, 18.0);
      }
    });
  }

  AppTranslations get tr => ref.read(translationsProvider);

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : constraints.maxWidth;
            final double horizontalPadding = isDesktopWeb
                ? 20.0
                : (containerWidth > 420.0
                    ? ((containerWidth - 380.0) / 2.0).clamp(16.0, 40.0)
                    : 20.0);
            final double cardWidth = containerWidth - (horizontalPadding * 2.0);
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (constraints.maxHeight - 32.0).clamp(520.0, 844.0))
                : constraints.maxHeight;

            final tr = ref.watch(translationsProvider);
            final userLocAsync = ref.watch(userLocationProvider);
            final userLoc = userLocAsync.value ?? UserLocation.defaultLocation;

            final nearbyProvidersAsync = ref.watch(nearbyProvidersProvider);
            final List<ProviderMarkerModel> liveProviders = nearbyProvidersAsync.value ?? [];

            _centerPixelX ??= MercatorProjection.lngToX(userLoc.longitude, _zoom);
            _centerPixelY ??= MercatorProjection.latToY(userLoc.latitude, _zoom) + 15.0;

            final double mapWidth = containerWidth;
            final double mapHeight = 220.0;
            final double leftPx = _centerPixelX! - (mapWidth / 2.0);
            final double topPx = _centerPixelY! - (mapHeight / 2.0);

            final double userScreenX = MercatorProjection.lngToX(userLoc.longitude, _zoom) - leftPx;
            final double userScreenY = MercatorProjection.latToY(userLoc.latitude, _zoom) - topPx;

            final String searchQuery = _searchController.text.trim().toLowerCase();
            final List<_NearbyProviderItem> searchedProviders = searchQuery.isEmpty
                ? _all30NearbyProviders
                : _all30NearbyProviders.where((p) {
                    return p.name.toLowerCase().contains(searchQuery) ||
                        p.nameAr.toLowerCase().contains(searchQuery) ||
                        p.vehicle.toLowerCase().contains(searchQuery) ||
                        p.vehicleAr.toLowerCase().contains(searchQuery) ||
                        '${p.distanceKm} km'.contains(searchQuery);
                  }).toList();

            final List<_NearbyProviderItem> activeProviders = searchedProviders
                .take(_selectedProviderCount)
                .toList();

            final screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // 1. Real Slippy Map Layer at Top behind card ("in bg map hoga"):
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    width: mapWidth,
                    height: mapHeight,
                    child: Listener(
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          if (pointerSignal.scrollDelta.dy < 0) {
                            _zoomIn();
                          } else if (pointerSignal.scrollDelta.dy > 0) {
                            _zoomOut();
                          }
                        }
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onDoubleTap: _zoomIn,
                        onScaleStart: (details) {
                          _mapScaleBase = 1.0;
                          setState(() => _isDraggingMap = true);
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            _centerPixelX = (_centerPixelX ?? 0) - details.focalPointDelta.dx;
                            _centerPixelY = (_centerPixelY ?? 0) - details.focalPointDelta.dy;

                            if (details.scale != 1.0) {
                              final double ratio = details.scale / _mapScaleBase;
                              if (ratio > 1.25 && _zoom < 18.0) {
                                _zoomIn();
                                _mapScaleBase = details.scale;
                              } else if (ratio < 0.8 && _zoom > 10.0) {
                                _zoomOut();
                                _mapScaleBase = details.scale;
                              }
                            }
                          });
                        },
                        onScaleEnd: (details) {
                          setState(() => _isDraggingMap = false);
                        },
                      child: MouseRegion(
                        cursor: _isDraggingMap
                            ? SystemMouseCursors.grabbing
                            : SystemMouseCursors.grab,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // A. Slippy Tile Layer with Google/OSM tiles
                            _DynamicMapTileLayer(
                              centerPixelX: _centerPixelX!,
                              centerPixelY: _centerPixelY!,
                              zoom: _zoom,
                              width: mapWidth,
                              height: mapHeight,
                            ),

                            // B. Customer Location Center Beacon
                            Positioned(
                              left: userScreenX - 14.0,
                              top: userScreenY - 14.0,
                              child: Tooltip(
                                message: tr.isArabic
                                    ? 'موقعك: ${userLoc.cityName}'
                                    : 'Your Location: ${userLoc.cityName}',
                                child: Container(
                                  key: const Key('find_provider_gps_center_marker'),
                                  width: 28.0,
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF8B53FE),
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x408B53FE),
                                        blurRadius: 10.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_pin_circle_rounded,
                                      size: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // C. Providers cars plotted on real map according to filter (10, 20, 30)
                            ...activeProviders.map((p) {
                              final double pLat = userLoc.latitude + p.latOffset;
                              final double pLng = userLoc.longitude + p.lngOffset;
                              final double carScreenX = MercatorProjection.lngToX(pLng, _zoom) - leftPx;
                              final double carScreenY = MercatorProjection.latToY(pLat, _zoom) - topPx;

                              return Positioned(
                                left: carScreenX - 45.0,
                                top: carScreenY - 37.0,
                                width: 90.0,
                                height: 74.0,
                                child: TopDownCarWidget(
                                  key: ValueKey('find_provider_car_${p.id}'),
                                  width: 17.0,
                                  height: 29.0,
                                  angle: p.heading,
                                  driverName: (tr.isArabic ? p.nameAr : p.name).split(' ').first,
                                  distanceKm: p.distanceKm,
                                  bodyColor: p.carColor,
                                  showBadge: true,
                                  isSelected: _selectedProviderId == p.id,
                                  isInsideRadius: true,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _selectedProviderId = p.id;
                                    });
                                    ProviderDetailCardWidget.showAsBottomSheet(
                                      context: context,
                                      providerName: tr.isArabic ? p.nameAr : p.name,
                                      serviceCategory: tr.categoryName(widget.serviceCategory),
                                      vehicleName: tr.isArabic ? p.vehicleAr : p.vehicle,
                                      distance: tr.isArabic ? '${p.distanceKm} كم' : '${p.distanceKm} km',
                                      estimatedTime: tr.isArabic ? p.etaAr : p.eta,
                                      rating: p.rating,
                                      tripsCount: p.reviews,
                                      phoneNumber: p.phone,
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                  // 2. Subtle Gradient Overlay Layer ("after header"):
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    width: containerWidth,
                    height: 96.0,
                    child: const IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.65, 1.0],
                            colors: [
                              Color(0xDDFFFFFF),
                              Color(0x77FFFFFF),
                              Color(0x00FFFFFF),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Floating Map Controls: Zoom In, Zoom Out, Location Button:
                  Positioned(
                    top: 106.0,
                    right: horizontalPadding,
                    width: 36.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zoom In Button (+)
                        GestureDetector(
                          key: const Key('find_provider_zoom_in_button'),
                          onTap: _zoomIn,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_rounded,
                                size: 20.0,
                                color: Color(0xFF1C2926),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // Zoom Out Button (-)
                        GestureDetector(
                          key: const Key('find_provider_zoom_out_button'),
                          onTap: _zoomOut,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.remove_rounded,
                                size: 20.0,
                                color: Color(0xFF1C2926),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // Current Location Button
                        GestureDetector(
                          key: const Key('find_provider_location_button'),
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  tr.gpsDetecting,
                                  style: tr.font(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF8B53FE),
                                duration: const Duration(milliseconds: 1000),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            final freshLoc = await ref.read(locationServiceProvider).getCurrentLocation();
                            ref.refresh(userLocationProvider);
                            ref.refresh(nearbyProvidersProvider);

                            if (!freshLoc.isGpsDetected) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_off_rounded,
                                        size: 16.0,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          tr.isArabic
                                              ? 'خدمة الموقع غير مفعلة في جهازك'
                                              : 'Device location is OFF. Please turn ON location in device settings.',
                                          style: tr.font(
                                            fontSize: 12.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFFE11D48),
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _centerPixelX = MercatorProjection.lngToX(freshLoc.longitude, _zoom);
                              _centerPixelY = MercatorProjection.latToY(freshLoc.latitude, _zoom) + 15.0;
                            });

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  tr.isArabic
                                      ? 'تحديد تلقائي: ${freshLoc.coordinatesDisplay} (${freshLoc.cityName})'
                                      : 'GPS: ${freshLoc.coordinatesDisplay} (${freshLoc.cityName})',
                                  style: tr.font(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF8B53FE),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F000000), // #0000000F
                                  blurRadius: 8.0,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.my_location_rounded,
                                size: 20.0,
                                color: Color(0xFF8B53FE),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Header Branding (Symmetrical margins matching cards exactly):
                  Positioned(
                    top: 56.0,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    height: 36.0,
                    child: SizedBox(
                      width: cardWidth,
                      height: 36.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            key: const Key('find_provider_back_button'),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).maybePop();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFFFFF),
                                border: Border.all(
                                  color: const Color(0xFF566663),
                                  width: 1.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 12.0,
                                    offset: Offset(0, -2),
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Transform.scale(
                                  scaleX: (tr.isArabic || Directionality.of(context) == TextDirection.rtl) ? -1.0 : 1.0,
                                  child: const CustomPaint(
                                    size: Size(6.0, 13.0),
                                    painter: _BackChevronPainter(
                                      color: Color(0xFF566663),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              tr.nearbyProviders,
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                              style: tr.font(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1C2926),
                                height: 1.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          GestureDetector(
                            key: const Key('header_search_button'),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isSearchOpen = !_isSearchOpen;
                              });
                              if (_isSearchOpen) {
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  _searchFocusNode.requestFocus();
                                });
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(8.0),
                                border: _isSearchOpen
                                    ? Border.all(color: const Color(0xFF8B53FE), width: 1.2)
                                    : null,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F000000), // #0000000F
                                    blurRadius: 8.0,
                                    offset: Offset(0, 1),
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(18.0, 18.0),
                                  painter: _SearchVectorPainter(
                                    color: _isSearchOpen
                                        ? const Color(0xFF8B53FE)
                                        : const Color(0xFF1C2926),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Card Styling:
                  Positioned(
                    top: 162.0,
                    left: 0.0,
                    width: containerWidth,
                    height: containerHeight > 162.0 ? (containerHeight - 162.0) : 520.0,
                    child: Container(
                      key: const Key('nearby_providers_card_layout'),
                      width: containerWidth,
                      height: containerHeight > 162.0 ? (containerHeight - 162.0) : 520.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28.0),
                          topRight: Radius.circular(28.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x14000000), // #00000014
                            offset: Offset(0, -2),
                            blurRadius: 12.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28.0),
                          topRight: Radius.circular(28.0),
                        ),
                        child: ScrollConfiguration(
                          behavior: const _EasyScrollBehavior(),
                          child: ListView(
                            padding: EdgeInsets.only(
                              top: 24.0,
                              left: horizontalPadding,
                              right: horizontalPadding,
                              bottom: 80.0,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              // 1. Header controls (Providers to show, buttons):
                              Center(child: _buildProvidersInnerCard(cardWidth)),

                              const SizedBox(height: 16.0),

                              // 2. Services cards:
                              ...activeProviders.asMap().entries.map(
                                (entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final liveItem = (index < liveProviders.length) ? liveProviders[index] : null;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Center(
                                      child: _buildServiceCard(cardWidth, item, liveItem),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 16.0),

                              // 3. Bottom bar indicator after last card:
                              Center(
                                child: Container(
                                  key: const Key('bottom_bar_indicator'),
                                  width: 134.0,
                                  height: 4.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C2926),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 6. Search Bar opening below header on search icon tap:
                  // width: 350; height: 48; top: 104px; left: 20px;
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    top: _isSearchOpen ? 104.0 : 76.0,
                    left: containerWidth >= 390
                        ? 20.0
                        : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0),
                    width: containerWidth >= 390
                        ? 350.0
                        : (containerWidth - 40.0).clamp(280.0, 350.0),
                    height: 48.0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      opacity: _isSearchOpen ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_isSearchOpen,
                        child: Container(
                          key: const Key('header_search_bar_container'),
                          width: containerWidth >= 390
                              ? 350.0
                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0xFFEDF0EF),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000), // #0000000F
                                blurRadius: 10.0,
                                offset: Offset(0, 2),
                                spreadRadius: 0.0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomPaint(
                                size: Size(16.0, 16.0),
                                painter: _SearchVectorPainter(
                                  color: Color(0xFF566663),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  style: tr.font(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF1C2926),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: tr.isArabic ? 'ابحث عن مزودي الخدمة...' : 'Search nearby providers...',
                                    hintStyle: tr.font(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF8F9E9B),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_searchController.text.isNotEmpty) {
                                    _searchController.clear();
                                  } else {
                                    setState(() {
                                      _isSearchOpen = false;
                                    });
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 18.0,
                                    color: Color(0xFF566663),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                color: const Color(0xFFF0F1F5),
                child: Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(42),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.25),
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

  /// Providers to show widget matching Figma branding from pickup screen:
  Widget _buildProvidersInnerCard(double cardWidth) {
    return SizedBox(
      width: cardWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Heading Branding Row (36x36 icon + title + subtitle)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side icon branding: width: 36; height: 36; border-radius: 40px; background: #F0EAFE;
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAFE),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: const Center(
                  // Vector branding: dual user silhouettes matching Figma
                  child: CustomPaint(
                    size: Size(20.0, 19.0),
                    painter: _ProviderGroupVectorPainter(
                      color: Color(0xFF8B53FE),
                      backgroundColor: Color(0xFFF0EAFE),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0), // gap: 12px;

              // Inner content branding: width: 302; gap: 12px;
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Content: Providers to show (16px, weight 500, line-height 22px, #1C2926)
                    Text(
                      tr.isArabic ? 'عدد المزودين المعروضين' : 'Providers to show',
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: tr.font(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1C2926),
                        height: tr.isArabic ? 1.0 : 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tr.isArabic ? 0.0 : 2.0),
                    // Content: Adjust the number of providers on the map. (wrapped without dots)
                    Transform.translate(
                      offset: Offset(0, tr.isArabic ? -3.5 : 0.0),
                      child: Text(
                        tr.isArabic ? 'حدد عدد المزودين الظاهرين على الخريطة.' : 'Adjust the number of providers on the map.',
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: tr.font(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF566663),
                          height: tr.isArabic ? 1.05 : 1.15,
                        ),
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0), // gap: 16px;

          // 2. Buttons layout: width: 350; height: 44.400001525878906; gap: 8px;
          SizedBox(
            width: cardWidth,
            height: 44.4,
            child: Row(
              children: [
                Expanded(child: _buildCountButton(10)),
                const SizedBox(width: 8.0), // gap: 8px;
                Expanded(child: _buildCountButton(20)),
                const SizedBox(width: 8.0), // gap: 8px;
                Expanded(child: _buildCountButton(30)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card branding matching exact Figma specifications:
  Widget _buildServiceCard(double cardWidth, _NearbyProviderItem item, [ProviderMarkerModel? liveItem]) {
    final String providerName = liveItem != null
        ? tr.formatProviderName(liveItem.name)
        : (tr.isArabic ? item.nameAr : item.name);

    final String imagePath = (liveItem?.categorySlug == 'pickup' || item.imagePath.contains('pickup'))
        ? 'assets/images/pickup.png'
        : 'assets/images/car_ride.png';

    final String vehicleType = liveItem != null
        ? (liveItem.categorySlug == 'pickup'
            ? (tr.isArabic ? 'بيك أب • مكيف' : 'Pickup • AC')
            : (tr.isArabic ? 'سيدان • مكيف' : 'Sedan • AC'))
        : (tr.isArabic ? item.vehicleAr : item.vehicle);

    final double distanceKm = liveItem?.distanceKm ?? item.distanceKm;
    final String etaStr = tr.isArabic
        ? item.etaAr
        : (liveItem?.etaDisplay ?? item.eta);
    final String distanceStr = tr.isArabic
        ? '${distanceKm.toStringAsFixed(1)} كم'
        : '${distanceKm.toStringAsFixed(1)} km';

    final double rating = liveItem?.ratingAvg ?? item.rating;
    final int reviews = liveItem?.ratingCount ?? item.reviews;

    final double effectiveWidth = cardWidth;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(
                serviceCategory: tr.categoryName(liveItem?.categoryName ?? widget.serviceCategory),
                providerName: providerName,
              ),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: effectiveWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // 0px 1px 12px 0px #0000001A
                blurRadius: 12.0,
                offset: Offset(0, 1),
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side content: Image + Details
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Provider vehicle image (optimized size for mobile screens)
                    SizedBox(
                      width: 48.0,
                      height: 34.0,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.asset(
                          imagePath,
                          width: 48.0,
                          height: 34.0,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 48.0,
                            height: 34.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EAFE),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: const Icon(
                              Icons.directions_car_filled,
                              size: 18,
                              color: Color(0xFF8B53FE),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0), // gap: 8px;

                    // Content details column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Provider Name
                          Text(
                            providerName,
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                            style: tr.font(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),

                          // Vehicle Type and Available badge row (Maintains exact original branding)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                vehicleType,
                                textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: tr.font(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF566663),
                                  height: 1.15,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(width: 6.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EAFE),
                                  borderRadius: BorderRadius.circular(60.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  tr.isArabic ? 'متاح' : 'Available',
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: tr.font(
                                    fontSize: 8.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8B53FE),
                                    height: 1.15,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0),

                          // Rating and Reviews
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 11.0,
                                color: Color(0xFF8B53FE),
                              ),
                              const SizedBox(width: 3.0),
                              RichText(
                                textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                text: TextSpan(
                                  text: '${rating.toStringAsFixed(1)} ',
                                  style: tr.font(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1C2926),
                                    height: 1.15,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '($reviews)',
                                      style: tr.font(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),

              // Right side content: Distance, Timer & Call Icon
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Distance row with clean navigation arrow icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scaleX: (tr.isArabic || Directionality.of(context) == TextDirection.rtl) ? -1.0 : 1.0,
                            child: const Icon(
                              Icons.near_me_rounded,
                              size: 11.5,
                              color: Color(0xFF8B53FE),
                            ),
                          ),
                          const SizedBox(width: 3.0),
                          Text(
                            distanceStr,
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                            style: tr.font(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                              height: 1.0,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                      SizedBox(height: tr.isArabic ? 0.0 : 1.0),

                      // ETA Timer (gap decreased)
                      Transform.translate(
                        offset: Offset(0, tr.isArabic ? -3.0 : -1.0),
                        child: Text(
                          etaStr,
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: tr.font(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                            height: 1.0,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8.0),

                  // Call icon
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            liveItem != null
                                ? (tr.isArabic
                                    ? 'جارٍ الاتصال بـ $providerName...'
                                    : 'Calling $providerName (GPS: ${liveItem.coordinatesDisplay})...')
                                : (tr.isArabic
                                    ? 'جارٍ الاتصال بـ $providerName...'
                                    : 'Calling $providerName (${item.phone})...'),
                            style: tr.font(fontSize: 12.0, color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF8B53FE),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE2E8E6),
                          width: 0.6,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.phone,
                        size: 13.0,
                        color: Color(0xFF1C2926),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Button branding matching Figma specifications:
  /// Selected (10 default): background: #8B53FE; content: #FFFFFF; font: Inter 500, 15px
  /// Unselected (20, 30): border: 1.2px solid #EDF0EF; content: #1C2926; font: Inter 500, 15px
  Widget _buildCountButton(int count) {
    final bool isSelected = _selectedProviderCount == count;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedProviderCount = count;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44.4,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B53FE) : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFEDF0EF),
                  width: 1.2,
                ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x268B53FE),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$count',
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: tr.font(
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF1C2926),
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// Back chevron vector < matching Figma specifications exactly:
/// width: 6; height: 13; border: 1px solid #566663
class _BackChevronPainter extends CustomPainter {
  final Color color;
  const _BackChevronPainter({this.color = const Color(0xFF566663)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width - 0.5, 0.5);
    path.lineTo(0.5, size.height / 2.0);
    path.lineTo(size.width - 0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Search vector icon matching user design:
/// Geometric circular lens with straight 45-degree angle handle to bottom-right
class _SearchVectorPainter extends CustomPainter {
  final Color color;
  const _SearchVectorPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Center and radius of the magnifying glass ring
    final center = Offset(size.width * 0.42, size.height * 0.42);
    final radius = size.width * 0.32;

    // Draw circular lens
    canvas.drawCircle(center, radius, strokePaint);

    // Draw handle at 45 degree angle
    const angle = math.pi / 4.0;
    final handleStart = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    final handleEnd = Offset(
      size.width - 1.0,
      size.height - 1.0,
    );

    canvas.drawLine(handleStart, handleEnd, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SearchVectorPainter oldDelegate) => color != oldDelegate.color;
}

/// Vector group/providers branding matching Figma specifications:
/// Dual user silhouettes (foreground user + background user with cutout contour)
class _ProviderGroupVectorPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;

  const _ProviderGroupVectorPainter({
    this.color = const Color(0xFF8B53FE),
    this.backgroundColor = const Color(0xFFF0EAFE),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cutoutPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Scale / center within the provided size (normalized around 20.0 x 19.0)
    final double scaleX = size.width / 20.0;
    final double scaleY = size.height / 19.0;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    // --- 1. Background Person (Person 2 - Right side) ---
    // Head 2
    canvas.drawCircle(const Offset(14.5, 4.4), 3.6, fillPaint);

    // Torso 2 (shoulder peeking out on right)
    final body2RRect = RRect.fromRectAndCorners(
      const Rect.fromLTRB(9.5, 10.8, 18.2, 18.2),
      topLeft: const Radius.circular(5.0),
      topRight: const Radius.circular(5.0),
      bottomLeft: const Radius.circular(3.2),
      bottomRight: const Radius.circular(3.2),
    );
    canvas.drawRRect(body2RRect, fillPaint);

    // --- 2. Cutout Contour of Foreground Person (creates transparent gap) ---
    // Head 1 cutout
    canvas.drawCircle(const Offset(7.0, 4.8), 3.8, cutoutPaint);

    // Torso 1 cutout
    final body1RRect = RRect.fromRectAndCorners(
      const Rect.fromLTRB(0.8, 10.8, 13.2, 18.2),
      topLeft: const Radius.circular(5.0),
      topRight: const Radius.circular(5.0),
      bottomLeft: const Radius.circular(3.2),
      bottomRight: const Radius.circular(3.2),
    );
    canvas.drawRRect(body1RRect, cutoutPaint);

    // --- 3. Foreground Person (Person 1 - Left side) ---
    // Head 1 fill
    canvas.drawCircle(const Offset(7.0, 4.8), 3.8, fillPaint);

    // Torso 1 fill
    canvas.drawRRect(body1RRect, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProviderGroupVectorPainter oldDelegate) =>
      color != oldDelegate.color || backgroundColor != oldDelegate.backgroundColor;
}

/// Vector arrow up and down branding matching Figma specifications:
/// width: 12; height: 10; angle: 0 deg; opacity: 1; background: #1C2926;
class _ArrowUpDownVectorPainter extends CustomPainter {
  final Color color;
  const _ArrowUpDownVectorPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Up arrow on left (x = 3.0):
    canvas.drawLine(const Offset(3.0, 9.0), const Offset(3.0, 1.5), strokePaint);
    final upHead = Path()
      ..moveTo(0.8, 3.8)
      ..lineTo(3.0, 1.5)
      ..lineTo(5.2, 3.8);
    canvas.drawPath(upHead, strokePaint);

    // Down arrow on right (x = 9.0):
    canvas.drawLine(const Offset(9.0, 1.0), const Offset(9.0, 8.5), strokePaint);
    final downHead = Path()
      ..moveTo(6.8, 6.2)
      ..lineTo(9.0, 8.5)
      ..lineTo(11.2, 6.2);
    canvas.drawPath(downHead, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ArrowUpDownVectorPainter oldDelegate) => color != oldDelegate.color;
}

/// Vector chevron right matching Figma specifications:
/// width: 4; height: 8; angle: -180 deg; opacity: 1; border-width: 0.6px; border: 0.6px solid #1C2926;
class _ChevronRightVectorPainter extends CustomPainter {
  final Color color;
  const _ChevronRightVectorPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width - 0.5, size.height / 2.0)
      ..lineTo(0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Standard Web Mercator (EPSG:3857) projection matching Google Maps & OpenStreetMap
class MercatorProjection {
  static double latToY(double lat, double zoom) {
    final double latRad = lat * math.pi / 180.0;
    final double sinLat = math.sin(latRad).clamp(-0.9999, 0.9999);
    return (128.0 / math.pi) * (1 << zoom.toInt()) * (math.pi - math.log((1.0 + sinLat) / (1.0 - sinLat)) / 2.0);
  }

  static double lngToX(double lng, double zoom) {
    return (128.0 / math.pi) * (1 << zoom.toInt()) * ((lng * math.pi / 180.0) + math.pi);
  }

  static double xToLng(double x, double zoom) {
    final double n = 256.0 * (1 << zoom.toInt());
    return (x / n) * 360.0 - 180.0;
  }

  static double yToLat(double y, double zoom) {
    final double n = 256.0 * (1 << zoom.toInt());
    final double u = math.pi * (1.0 - 2.0 * y / n);
    final double latRad = 2.0 * math.atan(math.exp(u)) - (math.pi / 2.0);
    return latRad * 180.0 / math.pi;
  }
}

/// Dynamic Slippy Map Layer supporting unlimited viewport dragging & Google/OSM tile rendering
class _DynamicMapTileLayer extends StatelessWidget {
  final double centerPixelX;
  final double centerPixelY;
  final double zoom;
  final double width;
  final double height;

  const _DynamicMapTileLayer({
    required this.centerPixelX,
    required this.centerPixelY,
    required this.zoom,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    const double tileSize = 256.0;
    final int z = zoom.toInt();

    final double leftPx = centerPixelX - (width / 2.0);
    final double topPx = centerPixelY - (height / 2.0);
    final double rightPx = leftPx + width;
    final double bottomPx = topPx + height;

    final int minTileX = (leftPx / tileSize).floor() - 1;
    final int maxTileX = (rightPx / tileSize).ceil() + 1;
    final int minTileY = (topPx / tileSize).floor() - 1;
    final int maxTileY = (bottomPx / tileSize).ceil() + 1;

    final int maxIndex = (1 << z) - 1;
    final List<Widget> tileWidgets = [];

    for (int tx = minTileX; tx <= maxTileX; tx++) {
      for (int ty = minTileY; ty <= maxTileY; ty++) {
        final int wrappedTileX = (tx % (maxIndex + 1) + (maxIndex + 1)) % (maxIndex + 1);
        if (ty < 0 || ty > maxIndex) continue;

        final double tileLeft = (tx * tileSize) - leftPx;
        final double tileTop = (ty * tileSize) - topPx;

        final int serverIdx = (wrappedTileX.abs() + ty.abs()) % 4;
        final String lang = Localizations.localeOf(context).languageCode;
        final String topoSub = ['a', 'b', 'c'][(wrappedTileX.abs() + ty.abs()) % 3];
        final String googleTileUrl =
            'https://mt$serverIdx.google.com/vt/lyrs=p&hl=$lang&x=$wrappedTileX&y=$ty&z=$z';
        final String osmTileUrl =
            'https://$topoSub.tile.opentopomap.org/$z/$wrappedTileX/$ty.png';

        tileWidgets.add(
          Positioned(
            key: ValueKey('find_tile_${wrappedTileX}_${ty}_$z'),
            left: tileLeft,
            top: tileTop,
            width: tileSize,
            height: tileSize,
            child: Image.network(
              googleTileUrl,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  osmTileUrl,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/BG image.png',
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    );
                  },
                );
              },
            ),
          ),
        );
      }
    }

    return ClipRect(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/BG image.png',
                fit: BoxFit.cover,
              ),
            ),
            ...tileWidgets,
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B53FE).withValues(alpha: 0.03),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

