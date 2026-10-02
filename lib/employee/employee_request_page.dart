import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'employee_request_controller.dart';

class EmployeeRequestPage extends StatefulWidget {
  final Map<String, dynamic> asset;
  final Map<String, dynamic>? userData;

  const EmployeeRequestPage({
    super.key,
    required this.asset,
    this.userData,
  });

  @override
  State<EmployeeRequestPage> createState() => _EmployeeRequestPageState();
}

class _EmployeeRequestPageState extends State<EmployeeRequestPage> {
  late final EmployeeRequestController controller;
  late final String controllerTag;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    final assetId = widget.asset['assetId']?.toString() ?? 'asset';
    controllerTag =
        'employee_request_${assetId}_${DateTime.now().millisecondsSinceEpoch}';

    controller = Get.put(
      EmployeeRequestController(),
      tag: controllerTag,
    );

    controller.initData(
      assetData: widget.asset,
      user: widget.userData,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<EmployeeRequestController>(tag: controllerTag)) {
      Get.delete<EmployeeRequestController>(tag: controllerTag);
    }
    super.dispose();
  }

  void _popWithResult(dynamic result) {
    if (!_hasPopped && mounted) {
      _hasPopped = true;
      Navigator.of(context).pop(result);
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '✓ Request submitted successfully',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!controller.validateForm()) {
      final errorMsg = controller.descriptionError.value.isNotEmpty
          ? controller.descriptionError.value
          : 'Please enter a description for your request.';
      _showErrorSnackbar(errorMsg);
      return;
    }

    final result = await controller.submitRequest();

    if (result != null && mounted) {
      _showSuccessSnackbar();

      // Give user time to see bottom success message, then return cleanly
      await Future.delayed(const Duration(milliseconds: 1800));
      _popWithResult(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetName = widget.asset['name']?.toString() ?? 'Asset';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF172033),
          ),
          onPressed: () => _popWithResult(null),
        ),
        title: const Text(
          'Asset Request',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Text(
                  'Request an Asset',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Submit requisition details for $assetName.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Employee Name (Auto-populated, Read-only)
                _buildFieldLabel(
                  label: 'Name',
                  isAutoFilled: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.nameController,
                  readOnly: true,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172033),
                  ),
                  decoration: _inputDecoration(
                    icon: Icons.person_outline_rounded,
                    hint: 'Employee Name',
                    isReadOnly: true,
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Department (Auto-populated, Read-only)
                _buildFieldLabel(
                  label: 'Department',
                  isAutoFilled: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.departmentController,
                  readOnly: true,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172033),
                  ),
                  decoration: _inputDecoration(
                    icon: Icons.business_outlined,
                    hint: 'Department',
                    isReadOnly: true,
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Selected Asset (Auto-populated from Employee Assets page)
                _buildFieldLabel(
                  label: 'Asset',
                  isAutoFilled: true,
                ),
                const SizedBox(height: 8),
                _buildAssetCard(),
                const SizedBox(height: 18),

                // 4. Description (Required)
                _buildFieldLabel(
                  label: 'Description',
                  isRequired: true,
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextField(
                    controller: controller.descriptionController,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      if (controller.descriptionError.value.isNotEmpty) {
                        controller.descriptionError.value = '';
                      }
                    },
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF172033),
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Explain why you need this asset (e.g., required for mobile app development and testing)...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13.5,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: controller.descriptionError.value.isNotEmpty
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFE1E5EC),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: controller.descriptionError.value.isNotEmpty
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFE1E5EC),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: controller.descriptionError.value.isNotEmpty
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF3157D5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  if (controller.descriptionError.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          controller.descriptionError.value,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 28),

                // 5. Submit Request Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Obx(
                    () {
                      final isLoading = controller.isLoading.value;
                      final isSubmitted = controller.isSubmitted.value;

                      return ElevatedButton(
                        onPressed:
                            (isLoading || isSubmitted) ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubmitted
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF3157D5),
                          disabledBackgroundColor: isSubmitted
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF9AA9D8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isSubmitted
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.send_rounded,
                                    size: 19,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSubmitted
                                        ? 'Request Submitted'
                                        : 'Submit Request',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Notice Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFDDE3FB),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF3157D5),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your asset request will be reviewed and processed by the Asset Manager. You can track status under "My Requests".',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({
    required String label,
    bool isRequired = false,
    bool isAutoFilled = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172033),
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        const Spacer(),
        if (isAutoFilled)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 11,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 4),
                Text(
                  'Auto-filled',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
    bool isReadOnly = false,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF3157D5),
        size: 21,
      ),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
      ),
      filled: true,
      fillColor: isReadOnly ? const Color(0xFFF9FAFB) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE1E5EC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE1E5EC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF3157D5),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildAssetCard() {
    final assetName = widget.asset['name']?.toString() ?? 'Asset';
    final assetId = widget.asset['assetId']?.toString() ?? 'AST-000';
    final category = widget.asset['category']?.toString() ?? 'General';
    final brand = widget.asset['brand']?.toString() ?? '';
    final model = widget.asset['model']?.toString() ?? '';
    final image = widget.asset['image']?.toString() ?? '';

    final subtitle = [brand, model]
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE1E5EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildAssetIconPlaceholder(),
                  )
                : _buildAssetIconPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assetName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$category • $assetId',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF8A919E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Selected',
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetIconPlaceholder() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.devices_rounded,
        color: Color(0xFF3157D5),
        size: 30,
      ),
    );
  }
}
