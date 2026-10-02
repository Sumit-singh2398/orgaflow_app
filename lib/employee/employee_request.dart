import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================================
// CONTROLLER
// ============================================================

class EmployeeRequestController extends GetxController {
  final isLoading = false.obs;
  final isSubmitted = false.obs;

  Future<void> submitRequest() async {
    try {
      isLoading.value = true;

      // --------------------------------------------------------
      // DEMO SUBMISSION
      // Baad mein yahin FastAPI API call add karenge.
      // --------------------------------------------------------

      await Future.delayed(
        const Duration(seconds: 1),
      );

      isSubmitted.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}

// ============================================================
// REQUESTS LIST PAGE
// ============================================================
// Ye page ExistingEmployeeHome ke Requests tab ke liye hai.
//
// ExistingEmployeeHome se:
//
// EmployeeRequestsPage(
//   userData: widget.userData,
// )
//
// call ho sakta hai.
// ============================================================

class EmployeeRequestsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const EmployeeRequestsPage({
    super.key,
    this.userData,
  });

  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    final String name =
        userData?['name']?.toString().trim().isNotEmpty == true
            ? userData!['name'].toString()
            : 'Employee';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'My Requests',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xFF172033),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          20,
          22,
          20,
          30,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // GREETING
            // --------------------------------------------------

            Text(
              'Hello, $name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Your Requests',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Track your submitted asset requests here.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 25),

            // --------------------------------------------------
            // STATUS SUMMARY
            // --------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    icon: Icons.pending_actions_rounded,
                    title: 'Pending',
                    value: '0',
                    iconColor: const Color(0xFFD97706),
                    backgroundColor: const Color(0xFFFFF7E8),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatusCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Approved',
                    value: '0',
                    iconColor: const Color(0xFF16A34A),
                    backgroundColor: const Color(0xFFEAF8EF),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatusCard(
                    icon: Icons.cancel_outlined,
                    title: 'Rejected',
                    value: '0',
                    iconColor: const Color(0xFFDC2626),
                    backgroundColor: const Color(0xFFFFEEEE),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --------------------------------------------------
            // SECTION TITLE
            // --------------------------------------------------

            const Text(
              'Request History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // EMPTY STATE
            // --------------------------------------------------

            _buildEmptyRequestsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E8EF),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,

            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRequestsCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        22,
        30,
        22,
        30,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E8EF),
        ),
      ),

      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,

            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Icon(
              Icons.assignment_outlined,
              color: Color(0xFF3157D5),
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No Requests Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'You have not submitted any asset requests yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,

            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context!);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3157D5),
                foregroundColor: Colors.white,
                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),

              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SINGLE ASSET REQUEST PAGE
// ============================================================
// Ye page tab open hoga jab employee kisi specific asset ko
// request karega.
//
// Example:
//
// EmployeeRequestPage(
//   asset: asset,
//   userData: userData,
// )
// ============================================================

class EmployeeRequestPage extends StatefulWidget {
  final Map<String, dynamic> asset;
  final Map<String, dynamic>? userData;

  const EmployeeRequestPage({
    super.key,
    required this.asset,
    this.userData,
  });

  @override
  State<EmployeeRequestPage> createState() =>
      _EmployeeRequestPageState();
}

class _EmployeeRequestPageState
    extends State<EmployeeRequestPage> {
  late final EmployeeRequestController controller;

  late final TextEditingController nameController;
  late final TextEditingController departmentController;
  late final TextEditingController descriptionController;

  late final String controllerTag;

  @override
  void initState() {
    super.initState();

    final String assetId =
        widget.asset['assetId']?.toString() ?? 'unknown';

    controllerTag =
        'employee_request_${assetId}_${identityHashCode(this)}';

    controller = Get.put(
      EmployeeRequestController(),
      tag: controllerTag,
    );

    final String name =
        widget.userData?['name']?.toString() ?? '';

    final String department =
        widget.userData?['department']?.toString() ?? '';

    nameController = TextEditingController(
      text: name,
    );

    departmentController = TextEditingController(
      text: department,
    );

    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    departmentController.dispose();
    descriptionController.dispose();

    if (Get.isRegistered<EmployeeRequestController>(
      tag: controllerTag,
    )) {
      Get.delete<EmployeeRequestController>(
        tag: controllerTag,
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF172033),
          ),
        ),

        title: const Text(
          'Request Asset',
          style: TextStyle(
            color: Color(0xFF172033),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: Obx(
        () {
          if (controller.isSubmitted.value) {
            return _buildSuccessScreen();
          }

          return _buildRequestForm();
        },
      ),
    );
  }

  // ============================================================
  // REQUEST FORM
  // ============================================================

  Widget _buildRequestForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        30,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Asset Request',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Fill in the details to request this asset.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 25),

          // ----------------------------------------------------
          // EMPLOYEE NAME
          // ----------------------------------------------------

          _buildLabel('Employee Name'),

          const SizedBox(height: 8),

          TextField(
            controller: nameController,
            readOnly: true,
            decoration: _inputDecoration(
              icon: Icons.person_outline,
              hint: 'Employee Name',
            ),
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------
          // DEPARTMENT
          // ----------------------------------------------------

          _buildLabel('Department'),

          const SizedBox(height: 8),

          TextField(
            controller: departmentController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              icon: Icons.business_outlined,
              hint: 'Enter your department',
            ),
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------
          // SELECTED ASSET
          // ----------------------------------------------------

          _buildLabel('Requested Asset'),

          const SizedBox(height: 8),

          _buildSelectedAsset(),

          const SizedBox(height: 18),

          // ----------------------------------------------------
          // DESCRIPTION
          // ----------------------------------------------------

          _buildLabel('Reason / Description'),

          const SizedBox(height: 8),

          TextField(
            controller: descriptionController,
            maxLines: 5,
            textInputAction: TextInputAction.newline,

            decoration: InputDecoration(
              hintText:
                  'Explain why you need this asset...',

              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
              ),

              filled: true,
              fillColor: Colors.white,

              contentPadding: const EdgeInsets.all(16),

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
            ),
          ),

          const SizedBox(height: 25),

          // ----------------------------------------------------
          // SUBMIT BUTTON
          // ----------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 54,

            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : _submitRequest,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF3157D5),

                  disabledBackgroundColor:
                      const Color(0xFF9AA9D8),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 23,
                        width: 23,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------
          // INFORMATION CARD
          // ----------------------------------------------------

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),

            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF3157D5),
                  size: 21,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'After submission, your request will be sent to the Asset Manager for approval.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED ASSET
  // ============================================================

  Widget _buildSelectedAsset() {
    final String assetName =
        widget.asset['name']?.toString() ??
            'Unknown Asset';

    final String assetId =
        widget.asset['assetId']?.toString() ??
            'N/A';

    final String brand =
        widget.asset['brand']?.toString() ?? '';

    final String model =
        widget.asset['model']?.toString() ?? '';

    String brandModel =
        '$brand $model'.trim();

    if (brandModel.isEmpty) {
      brandModel = 'Asset information';
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE1E5EC),
        ),
      ),

      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,

            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.laptop_mac_outlined,
              color: Color(0xFF3157D5),
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  assetName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  brandModel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Asset ID: $assetId',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A919E),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT REQUEST
  // ============================================================

  Future<void> _submitRequest() async {
    final String employeeName =
        nameController.text.trim();

    final String department =
        departmentController.text.trim();

    final String description =
        descriptionController.text.trim();

    if (employeeName.isEmpty) {
      _showError(
        'Employee Name Missing',
        'Employee name could not be found.',
      );
      return;
    }

    if (department.isEmpty) {
      _showError(
        'Department Required',
        'Please enter your department.',
      );
      return;
    }

    if (description.isEmpty) {
      _showError(
        'Description Required',
        'Please explain why you need this asset.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    await controller.submitRequest();
  }

  // ============================================================
  // SUCCESS SCREEN
  // ============================================================

  Widget _buildSuccessScreen() {
    final String assetName =
        widget.asset['name']?.toString() ??
            'Selected Asset';

    final String assetId =
        widget.asset['assetId']?.toString() ??
            'N/A';

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              height: 82,
              width: 82,

              decoration: const BoxDecoration(
                color: Color(0xFFE8F7ED),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.check_rounded,
                color: Colors.green,
                size: 48,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Request Submitted!',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your asset request has been submitted successfully.',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE1E5EC),
                ),
              ),

              child: Column(
                children: [
                  _successRow(
                    'Asset',
                    assetName,
                  ),

                  const SizedBox(height: 12),

                  _successRow(
                    'Asset ID',
                    assetId,
                  ),

                  const SizedBox(height: 12),

                  _successRow(
                    'Status',
                    'Pending',
                    valueColor:
                        const Color(0xFFD97706),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF3157D5),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUCCESS ROW
  // ============================================================

  Widget _successRow(
    String title,
    String value, {
    Color valueColor =
        const Color(0xFF172033),
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            value,

            textAlign: TextAlign.right,

            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,

      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF172033),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF6B7280),
      ),

      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
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

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(
    String title,
    String message,
  ) {
    Get.snackbar(
      title,
      message,

      snackPosition: SnackPosition.BOTTOM,

      margin: const EdgeInsets.all(15),

      backgroundColor: Colors.white,

      colorText: const Color(0xFF172033),

      borderRadius: 14,

      duration: const Duration(
        seconds: 3,
      ),

      icon: const Icon(
        Icons.error_outline,
        color: Colors.red,
      ),
    );
  }
}
