import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a service request / task between a customer and a provider
class ServiceTask {
  final String id;
  final String? providerPublicId;
  final String providerName;
  final String providerPhone;
  final String? providerAvatar;
  final double providerRating;
  final int providerTripsCount;
  final double? providerLatitude;
  final double? providerLongitude;
  final String serviceCategory;
  final String vehicleName;
  final String plateNumber;
  final String distance;
  final String eta;
  final String customerName;
  final String customerLocation;
  final String? customerPhotoUrl;
  final String customerNote;
  final double? customerLatitude;
  final double? customerLongitude;
  final String status; // 'new', 'active', 'arrived', 'in_progress', 'completed', 'cancelled'
  final int step; // 0: Accepted, 1: On The Way, 2: Arrived, 3: In Progress, 4: Completed
  final String dateTime;
  final DateTime createdAt;

  const ServiceTask({
    required this.id,
    this.providerPublicId,
    required this.providerName,
    this.providerPhone = '',
    this.providerAvatar,
    this.providerRating = 0.0,
    this.providerTripsCount = 0,
    this.providerLatitude,
    this.providerLongitude,
    required this.serviceCategory,
    this.vehicleName = '',
    this.plateNumber = '',
    this.distance = '--',
    this.eta = '--',
    this.customerName = 'Customer',
    this.customerLocation = '',
    this.customerPhotoUrl,
    this.customerNote = '',
    this.customerLatitude,
    this.customerLongitude,
    this.status = 'active',
    this.step = 1,
    required this.dateTime,
    required this.createdAt,
  });

  ServiceTask copyWith({
    String? id,
    String? providerPublicId,
    String? providerName,
    String? providerPhone,
    String? providerAvatar,
    double? providerRating,
    int? providerTripsCount,
    double? providerLatitude,
    double? providerLongitude,
    String? serviceCategory,
    String? vehicleName,
    String? plateNumber,
    String? distance,
    String? eta,
    String? customerName,
    String? customerLocation,
    String? customerPhotoUrl,
    String? customerNote,
    double? customerLatitude,
    double? customerLongitude,
    String? status,
    int? step,
    String? dateTime,
    DateTime? createdAt,
  }) {
    return ServiceTask(
      id: id ?? this.id,
      providerPublicId: providerPublicId ?? this.providerPublicId,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerAvatar: providerAvatar ?? this.providerAvatar,
      providerRating: providerRating ?? this.providerRating,
      providerTripsCount: providerTripsCount ?? this.providerTripsCount,
      providerLatitude: providerLatitude ?? this.providerLatitude,
      providerLongitude: providerLongitude ?? this.providerLongitude,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      vehicleName: vehicleName ?? this.vehicleName,
      plateNumber: plateNumber ?? this.plateNumber,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      customerName: customerName ?? this.customerName,
      customerLocation: customerLocation ?? this.customerLocation,
      customerPhotoUrl: customerPhotoUrl ?? this.customerPhotoUrl,
      customerNote: customerNote ?? this.customerNote,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      status: status ?? this.status,
      step: step ?? this.step,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerPublicId': providerPublicId,
        'providerName': providerName,
        'providerPhone': providerPhone,
        'providerAvatar': providerAvatar,
        'providerRating': providerRating,
        'providerTripsCount': providerTripsCount,
        'providerLatitude': providerLatitude,
        'providerLongitude': providerLongitude,
        'serviceCategory': serviceCategory,
        'vehicleName': vehicleName,
        'plateNumber': plateNumber,
        'distance': distance,
        'eta': eta,
        'customerName': customerName,
        'customerLocation': customerLocation,
        'customerPhotoUrl': customerPhotoUrl,
        'customerNote': customerNote,
        'customerLatitude': customerLatitude,
        'customerLongitude': customerLongitude,
        'status': status,
        'step': step,
        'dateTime': dateTime,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ServiceTask.fromJson(Map<String, dynamic> json) {
    return ServiceTask(
      id: json['id'] as String? ?? 'REQ-1001',
      providerPublicId: json['providerPublicId'] as String?,
      providerName: json['providerName'] as String? ?? 'Provider',
      providerPhone: json['providerPhone'] as String? ?? '',
      providerAvatar: json['providerAvatar'] as String?,
      providerRating: (json['providerRating'] as num?)?.toDouble() ?? 0.0,
      providerTripsCount: (json['providerTripsCount'] as num?)?.toInt() ?? 0,
      providerLatitude: (json['providerLatitude'] as num?)?.toDouble(),
      providerLongitude: (json['providerLongitude'] as num?)?.toDouble(),
      serviceCategory: json['serviceCategory'] as String? ?? 'Service',
      vehicleName: json['vehicleName'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
      distance: json['distance'] as String? ?? '--',
      eta: json['eta'] as String? ?? '--',
      customerName: json['customerName'] as String? ?? 'Customer',
      customerLocation: json['customerLocation'] as String? ?? '',
      customerPhotoUrl: json['customerPhotoUrl'] as String?,
      customerNote: json['customerNote'] as String? ?? '',
      customerLatitude: (json['customerLatitude'] as num?)?.toDouble(),
      customerLongitude: (json['customerLongitude'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'active',
      step: json['step'] as int? ?? 1,
      dateTime: json['dateTime'] as String? ?? 'Today',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Persistent service managing real active requests and history for both customer and provider
class TaskService {
  TaskService._();
  static final TaskService instance = TaskService._();

  static const String _keyActiveTask = 'qareeb_real_active_task';
  static const String _keyHistoryTasks = 'qareeb_real_history_tasks';

  ServiceTask? _activeTask;
  final List<ServiceTask> _incomingRequests = [];
  List<ServiceTask> _historyTasks = [];
  bool _isInitialized = false;

  final ValueNotifier<ServiceTask?> activeTaskNotifier = ValueNotifier<ServiceTask?>(null);
  final ValueNotifier<List<ServiceTask>> historyNotifier = ValueNotifier<List<ServiceTask>>([]);
  final ValueNotifier<List<ServiceTask>> providerRequestsNotifier = ValueNotifier<List<ServiceTask>>([]);

  ServiceTask? get activeTask => _activeTask;
  List<ServiceTask> get historyTasks => List.unmodifiable(_historyTasks);
  List<ServiceTask> get providerRequests {
    final List<ServiceTask> combined = [];
    final Set<String> seenIds = {};
    if (_activeTask != null) {
      combined.add(_activeTask!);
      seenIds.add(_activeTask!.id);
    }
    for (final req in _incomingRequests) {
      if (seenIds.add(req.id)) {
        combined.add(req);
      }
    }
    return List.unmodifiable(combined);
  }

  /// Initialize and load persisted real tasks (zero seed data)
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load real active task
      final activeJsonStr = prefs.getString(_keyActiveTask);
      if (activeJsonStr != null && activeJsonStr.isNotEmpty) {
        final decoded = jsonDecode(activeJsonStr) as Map<String, dynamic>;
        _activeTask = ServiceTask.fromJson(decoded);
      } else {
        _activeTask = null;
      }
      activeTaskNotifier.value = _activeTask;

      // 2. Load real history
      final historyListStr = prefs.getStringList(_keyHistoryTasks) ?? [];
      _historyTasks = historyListStr
          .map((itemStr) {
            try {
              return ServiceTask.fromJson(jsonDecode(itemStr) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<ServiceTask>()
          .toList();
      historyNotifier.value = List.unmodifiable(_historyTasks);
      providerRequestsNotifier.value = providerRequests;
    } catch (_) {
      _activeTask = null;
      _historyTasks = [];
    }
  }

  /// Create a new real task when customer sends a service request
  Future<ServiceTask> createCustomerRequest({
    required String providerName,
    required String serviceCategory,
    String? requestId,
    String? providerPublicId,
    String? providerAvatar,
    double? providerRating,
    int? providerTripsCount,
    double? providerLatitude,
    double? providerLongitude,
    String? distance,
    String? eta,
    String? vehicleName,
    String? plateNumber,
    String? providerPhone,
    String? customerName,
    String? customerLocation,
  }) async {
    final now = DateTime.now();
    final formattedTime =
        '${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final String taskId = (requestId != null && requestId.trim().isNotEmpty)
        ? (requestId.startsWith('REQ-') ? requestId.trim() : 'REQ-${requestId.trim()}')
        : 'REQ-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final task = ServiceTask(
      id: taskId,
      providerPublicId: providerPublicId,
      providerName: providerName.isNotEmpty ? providerName : 'Provider',
      providerPhone: providerPhone ?? '',
      providerAvatar: providerAvatar,
      providerRating: providerRating ?? 0.0,
      providerTripsCount: providerTripsCount ?? 0,
      providerLatitude: providerLatitude,
      providerLongitude: providerLongitude,
      serviceCategory: serviceCategory.isNotEmpty ? serviceCategory : 'Service Request',
      vehicleName: vehicleName ?? '',
      plateNumber: plateNumber ?? '',
      distance: distance ?? '--',
      eta: eta ?? '--',
      customerName: customerName ?? 'Customer',
      customerLocation: customerLocation ?? 'Shared via Zesho',
      status: 'new',
      step: 0,
      dateTime: formattedTime,
      createdAt: now,
    );

    _activeTask = task;
    activeTaskNotifier.value = _activeTask;
    providerRequestsNotifier.value = providerRequests;

    await _saveActiveTask();
    return task;
  }

  /// Hydrates real provider details (photo, rating, trips, vehicle, plate, GPS) on the active task.
  Future<void> updateActiveTaskProviderDetails({
    String? providerPublicId,
    String? providerName,
    String? providerPhone,
    String? providerAvatar,
    double? providerRating,
    int? providerTripsCount,
    double? providerLatitude,
    double? providerLongitude,
    String? serviceCategory,
    String? vehicleName,
    String? plateNumber,
    String? distance,
    String? eta,
  }) async {
    if (_activeTask == null) return;
    final current = _activeTask!;
    final next = current.copyWith(
      providerPublicId: (providerPublicId != null && providerPublicId.trim().isNotEmpty)
          ? providerPublicId.trim()
          : current.providerPublicId,
      providerName: (providerName != null && providerName.trim().isNotEmpty)
          ? providerName.trim()
          : current.providerName,
      providerPhone: (providerPhone != null && providerPhone.trim().isNotEmpty)
          ? providerPhone.trim()
          : current.providerPhone,
      providerAvatar: (providerAvatar != null && providerAvatar.trim().isNotEmpty)
          ? providerAvatar.trim()
          : current.providerAvatar,
      providerRating: providerRating ?? current.providerRating,
      providerTripsCount: providerTripsCount ?? current.providerTripsCount,
      providerLatitude: providerLatitude ?? current.providerLatitude,
      providerLongitude: providerLongitude ?? current.providerLongitude,
      serviceCategory: (serviceCategory != null && serviceCategory.trim().isNotEmpty)
          ? serviceCategory.trim()
          : current.serviceCategory,
      vehicleName: (vehicleName != null && vehicleName.trim().isNotEmpty)
          ? vehicleName.trim()
          : current.vehicleName,
      plateNumber: (plateNumber != null && plateNumber.trim().isNotEmpty)
          ? plateNumber.trim()
          : current.plateNumber,
      distance: (distance != null && distance.trim().isNotEmpty)
          ? distance.trim()
          : current.distance,
      eta: (eta != null && eta.trim().isNotEmpty)
          ? eta.trim()
          : current.eta,
    );
    _activeTask = next;
    activeTaskNotifier.value = _activeTask;
    providerRequestsNotifier.value = providerRequests;
    await _saveActiveTask();
  }

  /// Attaches the real backend UUID returned from POST /api/v1/discovery/events to the active customer task.
  Future<void> attachBackendRequestId(String backendRequestId) async {
    final clean = backendRequestId.trim();
    if (clean.isEmpty || _activeTask == null) return;
    final nextId = clean.startsWith('REQ-') ? clean : 'REQ-$clean';
    if (_activeTask!.id == nextId) return;
    _activeTask = _activeTask!.copyWith(id: nextId);
    activeTaskNotifier.value = _activeTask;
    providerRequestsNotifier.value = providerRequests;
    await _saveActiveTask();
  }

  /// Extracts a real backend UUID from a task ID (`REQ-<uuid>`) if present.
  static String? extractBackendUuid(String? taskId) {
    if (taskId == null || taskId.isEmpty) return null;
    final clean = taskId.replaceFirst(RegExp(r'^REQ-', caseSensitive: false), '').trim();
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(clean) ? clean : null;
  }

  /// When provider app receives [send_request_click] from the API, materialize or sync its real status.
  /// Supports multiple incoming customer requests without dropping new requests.
  Future<void> upsertIncomingRequestFromProviderNotification({
    required String notificationId,
    String serviceCategory = 'Roadside Assistance',
    String? customerLocation,
    String? distance,
    String? customerName,
    String? eta,
    String? customerPhotoUrl,
    String? customerNote,
    double? customerLatitude,
    double? customerLongitude,
    String status = 'new',
    int step = 0,
    DateTime? createdAt,
  }) async {
    if (notificationId.isEmpty) return;
    final taskId = 'REQ-$notificationId';
    final normalizedStatus = status.trim().toLowerCase().isNotEmpty
        ? status.trim().toLowerCase()
        : 'new';

    final ts = (createdAt ?? DateTime.now()).toLocal();
    final formattedTime =
        '${ts.day.toString().padLeft(2, '0')} ${_monthName(ts.month)} ${ts.year}, ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

    // If backend says completed or cancelled, ensure it's in history and not pending/active
    if (normalizedStatus == 'completed' || normalizedStatus == 'cancelled') {
      _incomingRequests.removeWhere((t) => t.id == taskId);
      if (_activeTask?.id == taskId) {
        _activeTask = _incomingRequests.isNotEmpty ? _incomingRequests.first : null;
        activeTaskNotifier.value = _activeTask;
        await _saveActiveTask();
      }
      if (!_historyTasks.any((t) => t.id == taskId)) {
        _historyTasks.insert(
          0,
          ServiceTask(
            id: taskId,
            providerName: 'Zesho',
            serviceCategory: serviceCategory.trim().isNotEmpty ? serviceCategory.trim() : 'Roadside Assistance',
            distance: distance?.trim().isNotEmpty == true ? distance!.trim() : '--',
            eta: eta?.trim().isNotEmpty == true ? eta!.trim() : '--',
            customerName: customerName?.trim().isNotEmpty == true ? customerName!.trim() : 'Customer',
            customerLocation: customerLocation?.trim().isNotEmpty == true ? customerLocation!.trim() : 'Shared via Zesho',
            customerPhotoUrl: customerPhotoUrl?.trim().isNotEmpty == true ? customerPhotoUrl!.trim() : null,
            customerNote: customerNote?.trim().isNotEmpty == true ? customerNote!.trim() : '',
            customerLatitude: customerLatitude,
            customerLongitude: customerLongitude,
            status: normalizedStatus,
            step: normalizedStatus == 'completed' ? 4 : step,
            dateTime: formattedTime,
            createdAt: ts,
          ),
        );
        historyNotifier.value = List.unmodifiable(_historyTasks);
        await _saveHistory();
      }
      providerRequestsNotifier.value = providerRequests;
      return;
    }

    // Already completed/cancelled locally -> skip re-adding
    if (_historyTasks.any((t) => t.id == taskId)) return;

    // Update existing tracked request if backend status progressed (e.g. 'new' -> 'active')
    final existingIdx = _incomingRequests.indexWhere((t) => t.id == taskId);
    if (existingIdx != -1) {
      final existing = _incomingRequests[existingIdx];
      final updated = existing.copyWith(
        status: normalizedStatus,
        step: step,
        distance: distance?.trim().isNotEmpty == true ? distance!.trim() : existing.distance,
        eta: eta?.trim().isNotEmpty == true ? eta!.trim() : existing.eta,
        customerName: customerName?.trim().isNotEmpty == true ? customerName!.trim() : existing.customerName,
        customerLocation:
            customerLocation?.trim().isNotEmpty == true ? customerLocation!.trim() : existing.customerLocation,
        customerPhotoUrl:
            customerPhotoUrl?.trim().isNotEmpty == true ? customerPhotoUrl!.trim() : existing.customerPhotoUrl,
        customerNote: customerNote?.trim().isNotEmpty == true ? customerNote!.trim() : existing.customerNote,
        customerLatitude: customerLatitude ?? existing.customerLatitude,
        customerLongitude: customerLongitude ?? existing.customerLongitude,
      );
      _incomingRequests[existingIdx] = updated;
      if (_activeTask?.id == taskId) {
        _activeTask = updated;
        activeTaskNotifier.value = _activeTask;
        await _saveActiveTask();
      }
      providerRequestsNotifier.value = providerRequests;
      return;
    }

    if (_activeTask?.id == taskId) {
      _activeTask = _activeTask!.copyWith(
        status: normalizedStatus,
        step: step,
        distance: distance?.trim().isNotEmpty == true ? distance!.trim() : _activeTask!.distance,
        eta: eta?.trim().isNotEmpty == true ? eta!.trim() : _activeTask!.eta,
        customerName:
            customerName?.trim().isNotEmpty == true ? customerName!.trim() : _activeTask!.customerName,
        customerLocation: customerLocation?.trim().isNotEmpty == true
            ? customerLocation!.trim()
            : _activeTask!.customerLocation,
        customerPhotoUrl: customerPhotoUrl?.trim().isNotEmpty == true
            ? customerPhotoUrl!.trim()
            : _activeTask!.customerPhotoUrl,
        customerNote:
            customerNote?.trim().isNotEmpty == true ? customerNote!.trim() : _activeTask!.customerNote,
        customerLatitude: customerLatitude ?? _activeTask!.customerLatitude,
        customerLongitude: customerLongitude ?? _activeTask!.customerLongitude,
      );
      activeTaskNotifier.value = _activeTask;
      providerRequestsNotifier.value = providerRequests;
      await _saveActiveTask();
      return;
    }

    final task = ServiceTask(
      id: taskId,
      providerName: 'Zesho',
      serviceCategory: serviceCategory.trim().isNotEmpty ? serviceCategory.trim() : 'Roadside Assistance',
      distance: distance?.trim().isNotEmpty == true ? distance!.trim() : '--',
      eta: eta?.trim().isNotEmpty == true ? eta!.trim() : '--',
      customerName: customerName?.trim().isNotEmpty == true ? customerName!.trim() : 'Customer',
      customerLocation: customerLocation?.trim().isNotEmpty == true ? customerLocation!.trim() : 'Shared via Zesho',
      customerPhotoUrl: customerPhotoUrl?.trim().isNotEmpty == true ? customerPhotoUrl!.trim() : null,
      customerNote: customerNote?.trim().isNotEmpty == true ? customerNote!.trim() : '',
      customerLatitude: customerLatitude,
      customerLongitude: customerLongitude,
      status: normalizedStatus,
      step: step,
      dateTime: formattedTime,
      createdAt: ts,
    );

    _incomingRequests.insert(0, task);
    if (_activeTask == null ||
        _activeTask!.status == 'cancelled' ||
        _activeTask!.status == 'completed') {
      _activeTask = task;
      activeTaskNotifier.value = _activeTask;
      await _saveActiveTask();
    }
    providerRequestsNotifier.value = providerRequests;
  }

  /// Select a specific incoming request as the active task (when provider taps a request card).
  /// Returns `true` ONLY if [taskId] actually exists as active or incoming.
  Future<bool> selectIncomingRequest(String taskId) async {
    if (taskId.trim().isEmpty) return false;
    if (_activeTask?.id == taskId) return true;
    final idx = _incomingRequests.indexWhere((t) => t.id == taskId);
    if (idx == -1) return false;
    _activeTask = _incomingRequests[idx];
    activeTaskNotifier.value = _activeTask;
    providerRequestsNotifier.value = providerRequests;
    await _saveActiveTask();
    return true;
  }

  /// Provider accepts a specific pending request -> moves from New tab to Active tab!
  Future<void> acceptRequestById(String taskId) async {
    final found = await selectIncomingRequest(taskId);
    if (!found) return;
    await updateTaskStatus(status: 'active', step: 1);
  }

  /// Provider declines/cancels a specific request -> moves to Cancelled tab!
  /// Strictly matches [taskId] so older cancellation events NEVER cancel a brand-new incoming request.
  Future<void> cancelRequestById(String taskId) async {
    final found = await selectIncomingRequest(taskId);
    if (!found) return;
    await cancelTask();
  }

  /// Provider updates a specific request status & step (e.g. 'arrived', 'in_progress')
  Future<void> updateRequestStatusById({
    required String taskId,
    required String status,
    required int step,
  }) async {
    final found = await selectIncomingRequest(taskId);
    if (!found) return;
    await updateTaskStatus(status: status, step: step);
  }

  /// Provider completes a specific request -> moves to Completed tab!
  Future<void> completeRequestById(String taskId) async {
    final found = await selectIncomingRequest(taskId);
    if (!found) return;
    await completeTask();
  }

  /// Provider accepts a pending customer request — customer listeners can move to live tracking.
  Future<void> acceptActiveRequest() async {
    await updateTaskStatus(status: 'active', step: 1);
  }

  /// Update active task status and progress stepper
  Future<void> updateTaskStatus({
    required String status,
    int? step,
    String? distance,
    String? eta,
  }) async {
    if (_activeTask == null) return;
    _activeTask = _activeTask!.copyWith(
      status: status,
      step: step ?? _activeTask!.step,
      distance: distance ?? _activeTask!.distance,
      eta: eta ?? _activeTask!.eta,
    );
    final idx = _incomingRequests.indexWhere((t) => t.id == _activeTask!.id);
    if (idx != -1) {
      _incomingRequests[idx] = _activeTask!;
    }
    activeTaskNotifier.value = _activeTask;
    providerRequestsNotifier.value = providerRequests;
    await _saveActiveTask();
  }

  /// Complete task: moves active task to history
  Future<void> completeTask() async {
    if (_activeTask == null) return;
    final completed = _activeTask!.copyWith(
      status: 'completed',
      step: 4,
    );
    _incomingRequests.removeWhere((t) => t.id == completed.id);
    _historyTasks.removeWhere((t) => t.id == completed.id);
    _historyTasks.insert(0, completed);
    _activeTask = _incomingRequests.isNotEmpty ? _incomingRequests.first : null;

    activeTaskNotifier.value = _activeTask;
    historyNotifier.value = List.unmodifiable(_historyTasks);
    providerRequestsNotifier.value = providerRequests;

    await _saveActiveTask();
    await _saveHistory();
  }

  /// Cancel task: marks as cancelled, moves to history
  Future<void> cancelTask() async {
    if (_activeTask == null) return;
    final cancelled = _activeTask!.copyWith(
      status: 'cancelled',
    );
    _incomingRequests.removeWhere((t) => t.id == cancelled.id);
    _historyTasks.removeWhere((t) => t.id == cancelled.id);
    _historyTasks.insert(0, cancelled);
    _activeTask = _incomingRequests.isNotEmpty ? _incomingRequests.first : null;

    activeTaskNotifier.value = _activeTask;
    historyNotifier.value = List.unmodifiable(_historyTasks);
    providerRequestsNotifier.value = providerRequests;

    await _saveActiveTask();
    await _saveHistory();
  }

  /// Clear all tasks
  Future<void> clearAll() async {
    _activeTask = null;
    _incomingRequests.clear();
    _historyTasks = [];
    activeTaskNotifier.value = null;
    historyNotifier.value = [];
    providerRequestsNotifier.value = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveTask);
    await prefs.remove(_keyHistoryTasks);
  }

  Future<void> _saveActiveTask() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_activeTask != null) {
        await prefs.setString(_keyActiveTask, jsonEncode(_activeTask!.toJson()));
      } else {
        await prefs.remove(_keyActiveTask);
      }
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _historyTasks.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList(_keyHistoryTasks, stringList);
    } catch (_) {}
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}

