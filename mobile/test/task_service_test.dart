import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/task_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TaskService.instance.clearAll();
    await TaskService.instance.init();
  });

  test('TaskService starts with zero seed data', () {
    expect(TaskService.instance.activeTask, isNull);
    expect(TaskService.instance.historyTasks, isEmpty);
    expect(TaskService.instance.providerRequests, isEmpty);
  });

  test('TaskService creates real customer request with proper details', () async {
    final task = await TaskService.instance.createCustomerRequest(
      providerName: 'kinza',
      serviceCategory: 'Fuel Delivery',
      vehicleName: 'Wheel Lift Tow Truck',
      plateNumber: '1122',
      distance: '2.5 km',
      eta: '10 min',
      customerName: 'Ahmed',
      customerLocation: 'Riyadh, Saudi Arabia',
    );

    expect(task.providerName, 'kinza');
    expect(task.serviceCategory, 'Fuel Delivery');
    expect(task.vehicleName, 'Wheel Lift Tow Truck');
    expect(task.plateNumber, '1122');
    expect(task.status, 'active');
    expect(task.step, 1);

    expect(TaskService.instance.activeTask, isNotNull);
    expect(TaskService.instance.activeTask?.id, task.id);
    expect(TaskService.instance.providerRequests.length, 1);
  });

  test('TaskService status progression and completion moves task to history', () async {
    await TaskService.instance.createCustomerRequest(
      providerName: 'kinza',
      serviceCategory: 'Fuel Delivery',
    );

    // Provider arrives
    await TaskService.instance.updateTaskStatus(
      status: 'arrived',
      step: 2,
      distance: '0 km',
      eta: 'Arrived',
    );
    expect(TaskService.instance.activeTask?.step, 2);
    expect(TaskService.instance.activeTask?.status, 'arrived');

    // Complete task
    await TaskService.instance.completeTask();
    expect(TaskService.instance.activeTask, isNull);
    expect(TaskService.instance.historyTasks.length, 1);
    expect(TaskService.instance.historyTasks.first.status, 'completed');
    expect(TaskService.instance.historyTasks.first.providerName, 'kinza');
  });

  test('TaskService cancellation moves task to cancelled history', () async {
    await TaskService.instance.createCustomerRequest(
      providerName: 'kinza',
      serviceCategory: 'Fuel Delivery',
    );

    await TaskService.instance.cancelTask();
    expect(TaskService.instance.activeTask, isNull);
    expect(TaskService.instance.historyTasks.length, 1);
    expect(TaskService.instance.historyTasks.first.status, 'cancelled');
  });
}

