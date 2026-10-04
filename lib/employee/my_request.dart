import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyRequest extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic> asset;

  const MyRequest({
    super.key,
    this.userData,
    required this.asset,
  });

  @override
  State<MyRequest> createState() => _MyRequestState();
}

class _MyRequestState extends State<MyRequest> {
  static const Color primaryColor = Color(0xFF3157D5);
  static const Color darkColor = Color(0xFF172033);
  static const Color greyColor = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFF6F8FC);

  // ============================================================
  // BACKEND URL
  // ============================================================
  //
  // Android Emulator:
  static const String baseUrl = 'http://10.0.2.2:8000';
  //
  // Real phone:
  // static const String baseUrl = 'http://192.168.1.5:8000';
  //
  // Replace 192.168.1.5 with your PC IPv4 address.
  // ============================================================

  final TextEditingController departmentController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String selectedPriority = 'Normal';

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final department =
        widget.userData?['department']?.toString().trim() ?? '';

    departmentController.text = department;
  }

  @override
  void dispose() {
    departmentController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // EMPLOYEE DATA
  // ============================================================

  String get employeeName {
    final name =
        widget.userData?['name']?.toString().trim() ?? '';

    return name.isNotEmpty ? name : 'Employee';
  }

  String get employeeEmail {
    final email =
        widget.userData?['email']?.toString().trim() ?? '';

    return email;
  }

  // ============================================================
  // ASSET DATA
  // ============================================================

  String get assetName {
    return widget.asset['name']?.toString() ?? '';
  }

  String get assetId {
    return widget.asset['assetId']?.toString() ?? '';
  }

  String get assetCategory {
    return widget.asset['category']?.toString() ?? '';
  }

  String get assetBrand {
    return widget.asset['brand']?.toString() ?? '';
  }

  String get assetModel {
    return widget.asset['model']?.toString() ?? '';
  }

  String get assetImage {
    return widget.asset['image']?.toString() ?? '';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,

        title: const Text(
          'Request Asset',
          style: TextStyle(
            color: darkColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: darkColor,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildPageHeader(),

                  const SizedBox(height: 22),

                  _buildEmployeeSection(),

                  const SizedBox(height: 18),

                  _buildSelectedAssetCard(),

                  const SizedBox(height: 18),

                  _buildRequestForm(),

                  const SizedBox(height: 24),

                  _buildSubmitButton(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submit Asset Request',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: darkColor,
          ),
        ),

        SizedBox(height: 7),

        Text(
          'Your request will be sent to Asset Management for review.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: greyColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPLOYEE SECTION
  // ============================================================

  Widget _buildEmployeeSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Employee Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),

          const SizedBox(height: 16),

          _buildReadOnlyField(
            label: 'Employee Name',
            value: employeeName,
            icon: Icons.person_outline_rounded,
          ),

          if (employeeEmail.isNotEmpty) ...[
            const SizedBox(height: 13),

            _buildReadOnlyField(
              label: 'Email',
              value: employeeEmail,
              icon: Icons.email_outlined,
            ),
          ],

          const SizedBox(height: 13),

          _buildTextField(
            controller: departmentController,
            label: 'Department',
            hint: 'Enter your department',
            icon: Icons.business_outlined,
            mandatory: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED ASSET
  // ============================================================

  Widget _buildSelectedAssetCard() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Requested Asset',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text(
                  'Selected',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE4E7EE),
              ),
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _buildAssetImage(),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        assetName.isNotEmpty
                            ? assetName
                            : 'Asset not selected',

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: darkColor,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        '$assetCategory • $assetId',

                        style: const TextStyle(
                          fontSize: 12,
                          color: greyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (assetBrand.isNotEmpty ||
                          assetModel.isNotEmpty) ...[
                        const SizedBox(height: 5),

                        Text(
                          '$assetBrand $assetModel'.trim(),

                          style: const TextStyle(
                            fontSize: 12,
                            color: greyColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: greyColor,
              ),

              SizedBox(width: 7),

              Expanded(
                child: Text(
                  'This asset was selected from Available Assets and cannot be changed here.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: greyColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),

      child: SizedBox(
        height: 75,
        width: 75,

        child: assetImage.isNotEmpty
            ? Image.network(
                assetImage,
                fit: BoxFit.cover,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _assetPlaceholder();
                },
              )
            : _assetPlaceholder(),
      ),
    );
  }

  Widget _assetPlaceholder() {
    return Container(
      color: const Color(0xFFEDEFF5),

      child: const Icon(
        Icons.devices_rounded,
        color: primaryColor,
        size: 32,
      ),
    );
  }

  // ============================================================
  // REQUEST DETAILS
  // ============================================================

  Widget _buildRequestForm() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Request Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Priority',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: darkColor,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildPriorityOption('Normal'),

              const SizedBox(width: 10),

              _buildPriorityOption('Urgent'),
            ],
          ),

          const SizedBox(height: 18),

          _buildTextField(
            controller: descriptionController,
            label: 'Requirement / Reason',
            hint: 'Why do you need this asset?',
            icon: Icons.description_outlined,
            mandatory: true,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIORITY
  // ============================================================

  Widget _buildPriorityOption(String value) {
    final bool selected =
        selectedPriority == value;

    return Expanded(
      child: InkWell(
        onTap: isSubmitting
            ? null
            : () {
                setState(() {
                  selectedPriority = value;
                });
              },

        borderRadius: BorderRadius.circular(12),

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),

          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEEF2FF)
                : Colors.white,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(
              color: selected
                  ? primaryColor
                  : const Color(0xFFE1E5EC),

              width: selected ? 1.5 : 1,
            ),
          ),

          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,

                size: 19,

                color: selected
                    ? primaryColor
                    : greyColor,
              ),

              const SizedBox(width: 8),

              Text(
                value,

                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,

                  color: selected
                      ? primaryColor
                      : darkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // READ ONLY FIELD
  // ============================================================

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        _buildLabel(label, false),

        const SizedBox(height: 7),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),

          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F8),

            borderRadius:
                BorderRadius.circular(12),

            border: Border.all(
              color: const Color(0xFFE2E5EB),
            ),
          ),

          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: greyColor,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  value.isNotEmpty
                      ? value
                      : '-',

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkColor,
                  ),
                ),
              ),

              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: Color(0xFF9AA0AC),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool mandatory,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        _buildLabel(label, mandatory),

        const SizedBox(height: 7),

        TextField(
          controller: controller,

          enabled: !isSubmitting,

          maxLines: maxLines,

          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              color: Color(0xFF9AA0AC),
              fontSize: 13,
            ),

            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 8,
                top: maxLines > 1 ? 12 : 0,
              ),

              child: Icon(
                icon,
                color: greyColor,
                size: 20,
              ),
            ),

            prefixIconConstraints:
                const BoxConstraints(
              minWidth: 48,
            ),

            filled: true,

            fillColor: Colors.white,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),

              borderSide: const BorderSide(
                color: Color(0xFFE1E5EC),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),

              borderSide: const BorderSide(
                color: Color(0xFFE1E5EC),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),

              borderSide: const BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(
    String label,
    bool mandatory,
  ) {
    return RichText(
      text: TextSpan(
        text: label,

        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: darkColor,
        ),

        children: mandatory
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSectionContainer({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFFE5E8EF),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.025),

            blurRadius: 12,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,

      child: ElevatedButton.icon(
        onPressed:
            isSubmitting ? null : _submitRequest,

        icon: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,

                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.send_rounded,
                size: 20,
              ),

        label: Text(
          isSubmitting
              ? 'Submitting...'
              : 'Submit Request',

          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,

          foregroundColor: Colors.white,

          disabledBackgroundColor:
              primaryColor.withOpacity(.55),

          elevation: 0,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REAL API REQUEST
  // ============================================================

  Future<void> _submitRequest() async {
    final department =
        departmentController.text.trim();

    final description =
        descriptionController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (department.isEmpty) {
      _showMessage(
        'Please enter your department.',
      );
      return;
    }

    if (assetName.isEmpty) {
      _showMessage(
        'No asset has been selected.',
      );
      return;
    }

    if (assetId.isEmpty) {
      _showMessage(
        'Selected asset does not have an asset ID.',
      );
      return;
    }

    if (description.isEmpty) {
      _showMessage(
        'Please explain why you need this asset.',
      );
      return;
    }

    // ----------------------------------------------------------
    // GET JWT TOKEN
    // ----------------------------------------------------------

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString('token');

    if (token == null || token.isEmpty) {
      _showMessage(
        'Your login session has expired. Please login again.',
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // --------------------------------------------------------
      // REAL BACKEND CALL
      // --------------------------------------------------------

      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/requests',
        ),

        headers: {
          'Content-Type':
              'application/json',

          'Authorization':
              'Bearer $token',
        },

        body: jsonEncode({
          'asset_id': assetId,

          'asset_name': assetName,

          'asset_category':
              assetCategory,

          'asset_brand':
              assetBrand,

          'asset_model':
              assetModel,

          'department':
              department,

          'priority':
              selectedPriority,

          'description':
              description,
        }),
      );

      // --------------------------------------------------------
      // RESPONSE
      // --------------------------------------------------------

      Map<String, dynamic> data = {};

      try {
        data = jsonDecode(
          response.body,
        );
      } catch (_) {
        data = {};
      }

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true) {
        if (!mounted) return;

        final request =
            data['request'];

        final requestCode =
            request is Map
                ? request['request_code']
                    ?.toString()
                : null;

        await _showSuccessDialog(
          requestCode,
        );

        return;
      }

      // --------------------------------------------------------
      // SERVER ERROR
      // --------------------------------------------------------

      String message =
          'Unable to submit request.';

      if (data['detail'] != null) {
        message =
            data['detail'].toString();
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      // --------------------------------------------------------
      // NETWORK ERROR
      // --------------------------------------------------------

      if (mounted) {
        _showMessage(
          'Unable to connect to Orgaflow server. '
          'Please check that the backend is running.',
        );
      }

      debugPrint(
        'REQUEST API ERROR: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> _showSuccessDialog(
    String? requestCode,
  ) async {
    if (!mounted) return;

    await showDialog(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 28,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Request Submitted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Your request for "$assetName" has been submitted successfully.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              if (requestCode != null &&
                  requestCode.isNotEmpty) ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(12),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFFEEF2FF),

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),

                  child: Text(
                    'Request ID: $requestCode',

                    style:
                        const TextStyle(
                      color:
                          primaryColor,
                      fontWeight:
                          FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              const Text(
                'Status: Pending\n\n'
                'Asset Management will review your request. '
                'You can track the status from Track Requests.',

                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: greyColor,
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                Navigator.pop(
                  context,
                );
              },

              child: const Text(
                'Done',

                style: TextStyle(
                  color: primaryColor,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),

          behavior:
              SnackBarBehavior.floating,

          duration:
              const Duration(seconds: 3),
        ),
      );
  }
}