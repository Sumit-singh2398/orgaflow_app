import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmployeeRequestController extends GetxController {
  // Reactive states
  final RxBool isLoading = false.obs;
  final RxBool isSubmitted = false.obs;
  final RxString descriptionError = ''.obs;
  final Rx<Map<String, dynamic>?> lastSubmittedRequest =
      Rx<Map<String, dynamic>?>(null);

  // Form & Text Controllers
  late final TextEditingController nameController;
  late final TextEditingController departmentController;
  late final TextEditingController descriptionController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Map<String, dynamic>? asset;
  Map<String, dynamic>? userData;

  bool _isInitialized = false;

  /// Initialize controller with asset and user information
  void initData({
    required Map<String, dynamic> assetData,
    Map<String, dynamic>? user,
  }) {
    asset = assetData;
    userData = user;

    final String name = _resolveEmployeeName(user);
    final String department = _resolveDepartment(user);

    nameController = TextEditingController(text: name);
    departmentController = TextEditingController(text: department);
    descriptionController = TextEditingController();

    isLoading.value = false;
    isSubmitted.value = false;
    descriptionError.value = '';
    lastSubmittedRequest.value = null;

    _isInitialized = true;
  }

  static String _resolveEmployeeName(Map<String, dynamic>? user) {
    if (user == null) return 'Employee';
    final dynamic val = user['name'] ??
        user['fullName'] ??
        user['full_name'] ??
        user['username'] ??
        user['employeeName'];
    if (val != null && val.toString().trim().isNotEmpty) {
      return val.toString().trim();
    }
    return 'Employee';
  }

  static String _resolveDepartment(Map<String, dynamic>? user) {
    if (user == null) return 'Information Technology';
    final dynamic val = user['department'] ??
        user['departmentName'] ??
        user['dept'] ??
        user['role'];
    if (val != null && val.toString().trim().isNotEmpty) {
      final deptStr = val.toString().trim();
      if (deptStr.toUpperCase() == 'EMPLOYEE') {
        return 'Engineering';
      }
      return deptStr;
    }
    return 'Information Technology';
  }

  /// Validate form fields
  bool validateForm() {
    descriptionError.value = '';

    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      descriptionError.value = 'Please explain why you need this asset';
      return false;
    }

    if (description.length < 5) {
      descriptionError.value = 'Description must be at least 5 characters long';
      return false;
    }

    return true;
  }

  /// Submit Asset Request
  Future<Map<String, dynamic>?> submitRequest() async {
    if (!validateForm()) {
      return null;
    }

    try {
      isLoading.value = true;

      // Simulate backend submission delay (future FastAPI integration)
      await Future.delayed(const Duration(milliseconds: 900));

      final now = DateTime.now();
      final dateStr = '${now.day} ${_monthName(now.month)} ${now.year}';
      final reqId = 'REQ-${now.millisecondsSinceEpoch.toString().substring(7)}';

      final requestData = <String, dynamic>{
        'requestId': reqId,
        'assetName': asset?['name'] ?? 'Asset',
        'category': asset?['category'] ?? 'Equipment',
        'assetId': asset?['assetId'] ?? '',
        'brand': asset?['brand'] ?? '',
        'model': asset?['model'] ?? '',
        'employeeName': nameController.text.trim(),
        'department': departmentController.text.trim(),
        'reason': descriptionController.text.trim(),
        'requestDate': dateStr,
        'status': 'Pending',
        'image': asset?['image'] ?? '',
      };

      lastSubmittedRequest.value = requestData;
      isSubmitted.value = true;
      return requestData;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear or reset the form
  void resetForm() {
    descriptionController.clear();
    descriptionError.value = '';
    isSubmitted.value = false;
    isLoading.value = false;
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  @override
  void onClose() {
    if (_isInitialized) {
      nameController.dispose();
      departmentController.dispose();
      descriptionController.dispose();
    }
    super.onClose();
  }
}
