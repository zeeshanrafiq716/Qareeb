import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/utils/geo_distance.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/task_service.dart';
import 'package:mobile/providers/backend_provider.dart';

/// Ingests provider notification feed into [TaskService] (requests list + active job).
Future<void> syncProviderRequestsFromBackend(WidgetRef ref) async {
  try {
    final items = await ref.read(backendServiceProvider).fetchProviderNotifications(limit: 50);
    final nowUtc = DateTime.now().toUtc();
    for (final item in items.reversed) {
      final ev = item['eventType']?.toString() ?? '';
      if (ev == 'request_cancelled') {
        final meta = item['metadata'] is Map ? item['metadata'] as Map : const {};
        final cancelledReqId = meta['requestId']?.toString().trim() ?? '';
        if (cancelledReqId.isNotEmpty) {
          await TaskService.instance.cancelRequestById('REQ-$cancelledReqId');
        }
        continue;
      }
      if (ev != 'send_request_click') continue;
      final rawTs = item['createdAt']?.toString();
      final ts = rawTs != null ? DateTime.tryParse(rawTs) : null;
      if (ts != null && nowUtc.difference(ts.toUtc()).abs() > const Duration(hours: 24)) {
        continue;
      }
      final itemId = item['id']?.toString() ?? '';
      if (itemId.isEmpty) continue;
      final meta = item['metadata'] is Map ? item['metadata'] as Map : const {};
      final cat = meta['serviceCategory']?.toString().trim() ?? '';
      final custName = meta['customerName']?.toString().trim() ?? '';
      final custPhone = meta['customerPhone']?.toString().trim() ??
          meta['customerMobile']?.toString().trim() ??
          '';
      final custAddr = meta['customerAddress']?.toString().trim() ?? '';
      final providerLoc =
          ref.read(userLocationProvider).value ?? LocationService.lastKnownValidLocation;
      double? lat = (item['customerLatitude'] as num?)?.toDouble();
      double? lng = (item['customerLongitude'] as num?)?.toDouble();
      if (!GeoDistance.coordsValid(lat, lng)) {
        lat = (meta['customerLatitude'] as num?)?.toDouble();
        lng = (meta['customerLongitude'] as num?)?.toDouble();
      }
      final validProvider = providerLoc != null && providerLoc.hasValidDeviceGps;
      final dist = GeoDistance.labelForProviderNotification(
        providerLat: validProvider ? providerLoc.latitude : null,
        providerLng: validProvider ? providerLoc.longitude : null,
        providerGpsValid: validProvider,
        customerLat: lat,
        customerLng: lng,
        meta: Map<String, dynamic>.from(meta),
      );
      final syncMeters = GeoDistance.metersBetween(
        providerLoc != null && providerLoc.hasValidDeviceGps ? providerLoc.latitude : null,
        providerLoc != null && providerLoc.hasValidDeviceGps ? providerLoc.longitude : null,
        lat,
        lng,
      );
      final eta = (syncMeters != null
              ? GeoDistance.formatEta(syncMeters, isArabic: false)
              : meta['eta']?.toString().trim())
          ?.trim() ??
          '';
      final note = meta['customerNote']?.toString().trim() ??
          meta['note']?.toString().trim() ??
          '';
      final photo = meta['customerPhotoUrl']?.toString().trim() ?? '';
      final reqStatus = meta['requestStatus']?.toString().trim() ?? 'new';
      final reqStep = (meta['step'] is num)
          ? (meta['step'] as num).toInt()
          : int.tryParse(meta['step']?.toString() ?? '') ?? 0;
      final fallbackLoc = GeoDistance.coordsValid(lat, lng)
          ? 'https://maps.google.com/?q=$lat,$lng'
          : 'Shared via Zesho';
      if (!GeoDistance.coordsValid(lat, lng)) {
        final parsed = GeoDistance.parseLatLngFromSharedLocation(
          custAddr.isNotEmpty ? custAddr : fallbackLoc,
        );
        lat = parsed.$1;
        lng = parsed.$2;
      }
      final atCustomer = GeoDistance.isAtCustomerSite(step: reqStep, status: reqStatus);
      final distForUpsert =
          atCustomer ? GeoDistance.zeroDistanceLabel(isArabic: false) : dist;
      final etaForUpsert = atCustomer ? 'Arrived' : eta;

      await TaskService.instance.upsertIncomingRequestFromProviderNotification(
        notificationId: itemId,
        serviceCategory: cat.isNotEmpty ? cat : 'Service request',
        customerLocation: custAddr.isNotEmpty ? custAddr : fallbackLoc,
        distance: distForUpsert,
        eta: etaForUpsert,
        customerName: custName.isNotEmpty ? custName : 'Customer',
        customerPhone: custPhone.isNotEmpty ? custPhone : null,
        customerPhotoUrl: photo.isNotEmpty ? photo : null,
        customerNote: note,
        customerLatitude: lat,
        customerLongitude: lng,
        status: reqStatus,
        step: reqStep,
        createdAt: ts,
      );
    }
  } catch (_) {}
}