import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a service request / task between a customer and a provider
class ServiceTask {
  final String id;
  final String providerName;
  final String providerPhone;
  final String? providerAvatar;
  final String serviceCategory;
  final String vehicleName;
  final String plateNumber;
  final String distance;
  final String eta;
  final String customerName;
  final String customerLocation;
  final String status; // 'new', 'active', 'arrived', 'in_progress', 'completed', 'cancelled'
  final int step; // 0: Accepted, 1: On The Way, 2: Arrived, 3: In Progress, 4: Completed
  final String dateTime;
  final DateTime createdAt;

  const ServiceTask({
    required this.id,
    required this.providerName,
    this.providerPhone = '+966 54 545 6467',
    this.providerAvatar,
    required this.serviceCategory,
    this.vehicleName = 'Service Vehicle',
    this.plateNumber = '1122',
    this.distance = '1.8 km',
    this.eta = '8 min',
    this.customerName = 'Ahmed',
    this.customerLocation = 'Riyadh, Saudi Arabia',
    this.status = 'active',
    this.step = 1,
    required this.dateTime,
    required this.createdAt,
  });

  ServiceTask copyWith({
    String? id,
    String? providerName,
    String? providerPhone,
    String? providerAvatar,
    String? serviceCategory,
    String? vehicleName,
    String? plateNumber,
    String? distance,
    String? eta,
    String? customerName,
    String? customerLocation,
    String? status,
    int? step,
    String? dateTime,
    DateTime? createdAt,
  }) {
    return ServiceTask(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerAvatar: providerAvatar ?? this.providerAvatar,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      vehicleName: vehicleName ?? this.vehicleName,
      plateNumber: plateNumber ?? this.plateNumber,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      customerName: customerName ?? this.customerName,
      customerLocation: customerLocation ?? this.customerLocation,
      status: status ?? this.status,
      step: step ?? this.step,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerName': providerName,
        'providerPhone': providerPhone,
        'providerAvatar': providerAvatar,
        'serviceCategory': serviceCategory,
        'vehicleName': vehicleName,
        'plateNumber': plateNumber,
        'distance': distance,
        'eta': eta,
        'customerName': customerName,
        'customerLocation': customerLocation,
        'status': status,
        'step': step,
        'dateTime': dateTime,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ServiceTask.fromJson(Map<String, dynamic> json) {
    return ServiceTask(
      id: json['id'] as String? ?? 'REQ-1001',
      providerName: json['providerName'] as String? ?? 'Provider',
      providerPhone: json['providerPhone'] as String? ?? '+966 54 545 6467',
      providerAvatar: json['providerAvatar'] as String?,
      serviceCategory: json['serviceCategory'] as String? ?? 'Roadside Assistance',
      vehicleName: json['vehicleName'] as String? ?? 'Service Vehicle',
      plateNumber: json['plateNumber'] as String? ?? '1122',
      distance: json['distance'] as String? ?? '1.8 km',
      eta: json['eta'] as String? ?? '8 min',
      customerName: json['customerName'] as String? ?? 'Customer',
      customerLocation: json['customerLocation'] as String? ?? 'Riyadh',
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

    final task = ServiceTask(
      id: 'REQ-${now.millisecondsSinceEpoch.toString().substring(7)}',
      providerName: providerName.isNotEmpty ? providerName : 'kinza',
      providerPhone: providerPhone ?? '+966 54 545 6467',
      serviceCategory: serviceCategory.isNotEmpty ? serviceCategory : 'Fuel Delivery',
      vehicleName: vehicleName ?? 'Wheel Lift Tow Truck',
      plateNumber: plateNumber ?? '1122',
      distance: distance ?? '1.8 km',
      eta: eta ?? '8 min',
      customerName: customerName ?? 'Ahmed',
      customerLocation: customerLocation ?? 'Riyadh, Saudi Arabia',
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

  /// When provider app receives [send_request_click] from the API, materialize a pending task locally.
  /// Supports multiple incoming customer requests without dropping new requests.
  Future<void> upsertIncomingRequestFromProviderNotification({
    required String notificationId,
    String serviceCategory = 'Roadside Assistance',
    String? customerLocation,
    String? distance,
    String? customerName,
    DateTime? createdAt,
  }) async {
    if (notificationId.isEmpty) return;
    final taskId = 'REQ-$notificationId';

    // Skip if already completed/cancelled in history or already tracked
    if (_historyTasks.any((t) => t.id == taskId)) return;
    if (_activeTask?.id == taskId) return;
    if (_incomingRequests.any((t) => t.id == taskId)) return;

    final ts = (createdAt ?? DateTime.now()).toLocal();
    final formattedTime =
        '${ts.day.toString().padLeft(2, '0')} ${_monthName(ts.month)} ${ts.year}, ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

    final task = ServiceTask(
      id: taskId,
      providerName: 'Zesho',
      serviceCategory: serviceCategory.trim().isNotEmpty ? serviceCategory.trim() : 'Roadside Assistance',
      distance: distance?.trim().isNotEmpty == true ? distance!.trim() : '—',
      eta: '—',
      customerName: customerName?.trim().isNotEmpty == true ? customerName!.trim() : 'Customer',
      customerLocation: customerLocation?.trim().isNotEmpty == true ? customerLocation!.trim() : 'Shared via Zesho',
      status: 'new',
      step: 0,
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

  /// Select a specific incoming request as the active task (when provider taps a request card)
  Future<void> selectIncomingRequest(String taskId) async {
    if (_activeTask?.id == taskId) return;
    final idx = _incomingRequests.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _activeTask = _incomingRequests[idx];
    activeTaskNotifier.value = _activeTask;
    providerRequestsNotifier.value = providerRequests;
    await _saveActiveTask();
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

