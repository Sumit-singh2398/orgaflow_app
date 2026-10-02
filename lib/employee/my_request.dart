import 'package:flutter/material.dart';

class MyRequest extends StatefulWidget {
  final Map<String, dynamic>? userData;

  // Selected asset comes from EmployeeAssetsPage.
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

  final TextEditingController departmentController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String selectedPriority = 'Normal';

  @override
  void initState() {
    super.initState();

    final String department =
        widget.userData?['department']
                ?.toString()
                .trim() ??
            '';

    departmentController.text = department;
  }

  @override
  void dispose() {
    departmentController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // GET EMPLOYEE NAME
  // ============================================================

  String get employeeName {
    final String name =
        widget.userData?['name']
                ?.toString()
                .trim() ??
            '';

    return name.isNotEmpty ? name : 'Employee';
  }

  // ============================================================
  // GET ASSET DETAILS
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Submit Asset Request',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
  // SELECTED ASSET CARD
  // ============================================================

  Widget _buildSelectedAssetCard() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius:
                      BorderRadius.circular(20),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                        overflow:
                            TextOverflow.ellipsis,
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

                      const SizedBox(height: 5),

                      if (assetBrand.isNotEmpty ||
                          assetModel.isNotEmpty)
                        Text(
                          '$assetBrand $assetModel'
                              .trim(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: greyColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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

  // ============================================================
  // ASSET IMAGE
  // ============================================================

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
                errorBuilder:
                    (context, error, stackTrace) {
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
  // REQUEST FORM
  // ============================================================

  Widget _buildRequestForm() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
            hint:
                'Why do you need this asset?',
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
        onTap: () {
          setState(() {
            selectedPriority = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEEF2FF)
                : Colors.white,
            borderRadius:
                BorderRadius.circular(12),
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
          padding:
              const EdgeInsets.symmetric(
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
                  value,
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
  // SECTION CONTAINER
  // ============================================================

  Widget _buildSectionContainer({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E8EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
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
        onPressed: _submitRequest,
        icon: const Icon(
          Icons.send_rounded,
          size: 20,
        ),
        label: const Text(
          'Submit Request',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT REQUEST
  // ============================================================

  void _submitRequest() {
    final String department =
        departmentController.text.trim();

    final String description =
        descriptionController.text.trim();

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

    if (description.isEmpty) {
      _showMessage(
        'Please explain why you need this asset.',
      );
      return;
    }

    // Temporary frontend request data.
    // Later this same data will be sent to FastAPI.
    final Map<String, dynamic> requestData = {
      'employeeName': employeeName,
      'department': department,
      'assetName': assetName,
      'assetId': assetId,
      'assetCategory': assetCategory,
      'assetBrand': assetBrand,
      'assetModel': assetModel,
      'description': description,
      'priority': selectedPriority,
      'status': 'Pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    debugPrint(
      'ORGAFLOW REQUEST: $requestData',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
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
          content: Text(
            'Your request for "$assetName" has been submitted to Asset Management.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}