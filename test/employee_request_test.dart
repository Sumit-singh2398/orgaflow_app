import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:orgaflow_app/employee/employee_request_controller.dart';
import 'package:orgaflow_app/employee/employee_request_page.dart';

void main() {
  group('EmployeeRequestController Tests', () {
    late EmployeeRequestController controller;
    final testAsset = {
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'assetId': 'AST-001',
      'brand': 'Dell',
      'model': 'Latitude 5420',
      'status': 'Available',
      'image': '',
    };
    final testUserData = {
      'name': 'Rahul Sharma',
      'department': 'Mobile Development',
      'role': 'EMPLOYEE',
    };

    setUp(() {
      Get.testMode = true;
      controller = EmployeeRequestController();
      controller.initData(
        assetData: testAsset,
        user: testUserData,
      );
    });

    tearDown(() {
      controller.onClose();
    });

    test('Initial state auto-populates employee info and asset', () {
      expect(controller.nameController.text, 'Rahul Sharma');
      expect(controller.departmentController.text, 'Mobile Development');
      expect(controller.descriptionController.text, isEmpty);
      expect(controller.isLoading.value, false);
      expect(controller.isSubmitted.value, false);
      expect(controller.descriptionError.value, isEmpty);
    });

    test('Validation fails when description is empty', () {
      final isValid = controller.validateForm();
      expect(isValid, false);
      expect(controller.descriptionError.value, isNotEmpty);
    });

    test('Validation succeeds when description is provided', () {
      controller.descriptionController.text =
          'Need this laptop for Flutter app development.';
      final isValid = controller.validateForm();
      expect(isValid, true);
      expect(controller.descriptionError.value, isEmpty);
    });

    test('Submit request flow succeeds and returns request map', () async {
      controller.descriptionController.text =
          'Required for new client project delivery.';
      final result = await controller.submitRequest();

      expect(result, isNotNull);
      expect(result!['assetName'], 'Dell Latitude 5420');
      expect(result['employeeName'], 'Rahul Sharma');
      expect(result['department'], 'Mobile Development');
      expect(result['reason'], 'Required for new client project delivery.');
      expect(result['status'], 'Pending');
      expect(controller.isSubmitted.value, true);
      expect(controller.isLoading.value, false);
    });

    test('resetForm clears inputs and submission state', () async {
      controller.descriptionController.text = 'Some reason';
      await controller.submitRequest();
      expect(controller.isSubmitted.value, true);

      controller.resetForm();
      expect(controller.descriptionController.text, isEmpty);
      expect(controller.isSubmitted.value, false);
      expect(controller.descriptionError.value, isEmpty);
    });
  });

  group('EmployeeRequestPage Widget Tests', () {
    final testAsset = {
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'assetId': 'AST-001',
      'brand': 'Dell',
      'model': 'Latitude 5420',
      'status': 'Available',
      'image': '',
    };
    final testUserData = {
      'name': 'Adarsh Singh',
      'department': 'IT Infrastructure',
      'role': 'EMPLOYEE',
    };

    testWidgets('Renders all fields, validates and submits request',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        GetMaterialApp(
          home: EmployeeRequestPage(
            asset: testAsset,
            userData: testUserData,
          ),
        ),
      );

      // Verify header and auto-populated fields
      expect(find.text('Asset Request'), findsOneWidget);
      expect(find.text('Dell Latitude 5420'), findsWidgets);
      expect(find.text('Adarsh Singh'), findsOneWidget);
      expect(find.text('IT Infrastructure'), findsOneWidget);
      expect(find.text('Submit Request'), findsOneWidget);

      // Try submitting without description -> shows validation error
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Please explain why you need this asset'),
          findsWidgets);

      // Enter description
      await tester.enterText(
        find.byType(TextField).last,
        'Needed for high-performance software builds.',
      );
      await tester.pump();

      // Submit valid request
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pump();

      // Wait for async submission to complete (900ms in controller)
      await tester.pump(const Duration(milliseconds: 1000));
      // Pump to trigger SnackBar entrance animation
      await tester.pump(const Duration(milliseconds: 400));

      // Verify bottom success message appears
      expect(find.text('✓ Request submitted successfully'), findsOneWidget);

      // Pump remaining delay for auto-pop timer
      await tester.pump(const Duration(milliseconds: 2000));
    });
  });
}
