import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssetManagerRequestsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerRequestsPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerRequestsPage> createState() =>
      _AssetManagerRequestsPageState();
}

class _AssetManagerRequestsPageState
    extends State<AssetManagerRequestsPage> {
  // ============================================================
  // BACKEND URL
  // ============================================================
  //
  // Android Emulator:
  // http://10.0.2.2:8000
  //
  // Real Phone:
  // http://YOUR_PC_IP:8000
  //
  // Example:
  // http://192.168.1.5:8000
  //
  static const String baseUrl = 'http://10.0.2.2:8000';

  List<Map<String, dynamic>> requests = [];

  bool isLoading = true;
  bool isRefreshing = false;

  String? errorMessage;

  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'Pending',
    'Approved',
    'Not Approved',
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  // ============================================================
  // LOAD ALL REQUESTS
  // ============================================================

  Future<void> _loadRequests() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login session not found. Please login again.',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> rawRequests = [];

        if (decoded is Map<String, dynamic>) {
          if (decoded['requests'] is List) {
            rawRequests = decoded['requests'];
          } else if (decoded['data'] is List) {
            rawRequests = decoded['data'];
          }
        } else if (decoded is List) {
          rawRequests = decoded;
        }

        final loadedRequests = rawRequests
            .whereType<Map>()
            .map(
              (request) => Map<String, dynamic>.from(request),
            )
            .toList();

        setState(() {
          requests = loadedRequests;
          isLoading = false;
        });
      } else if (response.statusCode == 401 ||
          response.statusCode == 403) {
        String message =
            'You are not authorized to manage requests.';

        try {
          final body = jsonDecode(response.body);

          if (body is Map && body['detail'] != null) {
            message = body['detail'].toString();
          }
        } catch (_) {}

        setState(() {
          isLoading = false;
          errorMessage = message;
        });
      } else {
        String message = 'Unable to load requests.';

        try {
          final body = jsonDecode(response.body);

          if (body is Map && body['detail'] != null) {
            message = body['detail'].toString();
          } else if (body is Map && body['message'] != null) {
            message = body['message'].toString();
          }
        } catch (_) {}

        setState(() {
          isLoading = false;
          errorMessage = message;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = _cleanError(e);
      });
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshRequests() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
    });

    try {
      await _loadRequests();
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<Map<String, dynamic>> get filteredRequests {
    if (selectedFilter == 'All') {
      return requests;
    }

    return requests.where((request) {
      return _statusForDisplay(request).toLowerCase() ==
          selectedFilter.toLowerCase();
    }).toList();
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _rawStatus(Map<String, dynamic> request) {
    return (request['status'] ?? 'Pending')
        .toString()
        .trim();
  }

  String _statusForDisplay(Map<String, dynamic> request) {
    final status = _rawStatus(request).toLowerCase();

    if (status == 'pending') {
      return 'Pending';
    }

    if (status == 'approved') {
      return 'Approved';
    }

    if (status == 'rejected' ||
        status == 'not approved' ||
        status == 'not_approved') {
      return 'Not Approved';
    }

    return _rawStatus(request);
  }

  // ============================================================
  // COUNTS
  // ============================================================

  int get pendingCount {
    return requests.where((request) {
      return _rawStatus(request).toLowerCase() == 'pending';
    }).length;
  }

  int get approvedCount {
    return requests.where((request) {
      return _rawStatus(request).toLowerCase() == 'approved';
    }).length;
  }

  int get rejectedCount {
    return requests.where((request) {
      final status = _rawStatus(request).toLowerCase();

      return status == 'rejected' ||
          status == 'not approved' ||
          status == 'not_approved';
    }).length;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _stringValue(
    Map<String, dynamic> request,
    String key, {
    String fallback = '',
  }) {
    final value = request[key];

    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  String _cleanError(Object error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }

    return message;
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Not available';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return 'Not available';
    }

    try {
      final date = DateTime.parse(text).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour12 = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final hour = hour12.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year • $hour:$minute $period';
    } catch (_) {
      return text;
    }
  }

  // ============================================================
  // STATUS COLORS
  // ============================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF168A55);

      case 'not approved':
      case 'rejected':
        return const Color(0xFFD93025);

      case 'pending':
      default:
        return const Color(0xFFD98200);
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFFE8F7EF);

      case 'not approved':
      case 'rejected':
        return const Color(0xFFFFECEB);

      case 'pending':
      default:
        return const Color(0xFFFFF4DF);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline;

      case 'not approved':
      case 'rejected':
        return Icons.cancel_outlined;

      case 'pending':
      default:
        return Icons.access_time_rounded;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'high':
        return const Color(0xFFD93025);

      case 'medium':
        return const Color(0xFFD98200);

      case 'normal':
      case 'low':
      default:
        return const Color(0xFF3157D5);
    }
  }

  // ============================================================
  // APPROVE REQUEST
  // ============================================================

  Future<void> _approveRequest(
    Map<String, dynamic> request,
  ) async {
    final requestId = request['id'];

    if (requestId == null) {
      _showMessage(
        'Request ID is missing.',
        isError: true,
      );
      return;
    }

    final confirmed = await _showApproveConfirmation(
      request,
    );

    if (!confirmed) return;

    await _updateRequestStatus(
      requestId: requestId,
      status: 'Approved',
    );
  }

  // ============================================================
  // REJECT / NOT APPROVE REQUEST
  // ============================================================

  Future<void> _rejectRequest(
    Map<String, dynamic> request,
  ) async {
    final requestId = request['id'];

    if (requestId == null) {
      _showMessage(
        'Request ID is missing.',
        isError: true,
      );
      return;
    }

    final reason = await _showRejectDialog();

    if (reason == null) {
      return;
    }

    final trimmedReason = reason.trim();

    if (trimmedReason.isEmpty) {
      return;
    }

    await _updateRequestStatus(
      requestId: requestId,
      status: 'Rejected',
      rejectionReason: trimmedReason,
    );
  }

  // ============================================================
  // UPDATE STATUS API
  // ============================================================

  Future<void> _updateRequestStatus({
    required dynamic requestId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        _showMessage(
          'Login session expired. Please login again.',
          isError: true,
        );
        return;
      }

      final response = await http.patch(
        Uri.parse(
          '$baseUrl/api/requests/$requestId/status',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
          'rejection_reason': rejectionReason,
        }),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        String successMessage;

        if (status == 'Approved') {
          successMessage =
              'Request approved successfully.';
        } else {
          successMessage =
              'Request marked as Not Approved.';
        }

        _showMessage(successMessage);

        // IMPORTANT:
        // Reload from backend.
        // We don't just modify local list.
        await _loadRequests();
      } else {
        String message =
            'Unable to update request status.';

        try {
          final body = jsonDecode(response.body);

          if (body is Map && body['detail'] != null) {
            message = body['detail'].toString();
          } else if (body is Map && body['message'] != null) {
            message = body['message'].toString();
          }
        } catch (_) {}

        _showMessage(
          message,
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _cleanError(e),
        isError: true,
      );
    }
  }

  // ============================================================
  // APPROVE CONFIRMATION
  // ============================================================

  Future<bool> _showApproveConfirmation(
    Map<String, dynamic> request,
  ) async {
    final requestCode = _stringValue(
      request,
      'request_code',
      fallback: 'this request',
    );

    final assetName = _stringValue(
      request,
      'asset_name',
      fallback: 'selected asset',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Approve Request?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF172033),
            ),
          ),

          content: Text(
            'Are you sure you want to approve $requestCode for $assetName?',
            style: const TextStyle(
              height: 1.5,
              color: Color(0xFF5E6675),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF168A55),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // REJECTION DIALOG
  // ============================================================

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();

    String? errorText;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Not Approve Request',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172033),
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please enter the reason why this request is not approved.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF697181),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: controller,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText:
                          'Enter rejection reason...',
                      errorText: errorText,
                      filled: true,
                      fillColor:
                          const Color(0xFFF6F8FC),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: Color(0xFFE1E5EE),
                        ),
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: Color(0xFFE1E5EE),
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: Color(0xFF3157D5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    final reason =
                        controller.text.trim();

                    if (reason.isEmpty) {
                      setDialogState(() {
                        errorText =
                            'Rejection reason is required.';
                      });
                      return;
                    }

                    Navigator.pop(
                      context,
                      reason,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFD93025),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text(
                    'Not Approve',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    return result;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? const Color(0xFFD93025)
              : const Color(0xFF168A55),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    final background =
        _statusBackground(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(status),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FA),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF3157D5),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A8190),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        valueColor ??
                        const Color(0xFF252B38),
                    fontWeight: FontWeight.w600,
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
  // SHOW FULL DETAILS
  // ============================================================

  void _showRequestDetails(
    Map<String, dynamic> request,
  ) {
    final requestCode = _stringValue(
      request,
      'request_code',
      fallback: 'Request',
    );

    final employeeName = _stringValue(
      request,
      'employee_name',
      fallback: _stringValue(
        request,
        'employeeName',
        fallback: 'Employee',
      ),
    );

    final employeeEmail = _stringValue(
      request,
      'employee_email',
      fallback: _stringValue(
        request,
        'employeeEmail',
        fallback: 'N/A',
      ),
    );

    final department = _stringValue(
      request,
      'department',
      fallback: 'N/A',
    );

    final assetName = _stringValue(
      request,
      'asset_name',
      fallback: _stringValue(
        request,
        'assetName',
        fallback: 'Asset',
      ),
    );

    final assetId = _stringValue(
      request,
      'asset_id',
      fallback: _stringValue(
        request,
        'assetId',
        fallback: 'N/A',
      ),
    );

    final category = _stringValue(
      request,
      'asset_category',
      fallback: 'N/A',
    );

    final brand = _stringValue(
      request,
      'asset_brand',
      fallback: 'N/A',
    );

    final model = _stringValue(
      request,
      'asset_model',
      fallback: 'N/A',
    );

    final priority = _stringValue(
      request,
      'priority',
      fallback: 'Normal',
    );

    final description = _stringValue(
      request,
      'description',
      fallback: 'No description provided.',
    );

    final status = _statusForDisplay(request);

    final rejectionReason = _stringValue(
      request,
      'rejection_reason',
    );

    final createdAt =
        request['created_at'] ??
        request['createdAt'];

    final reviewedAt =
        request['reviewed_at'] ??
        request['reviewedAt'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                0.90,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              28,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFD7DBE5),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        requestCode,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172033),
                        ),
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),

                const SizedBox(height: 24),

                _detailSectionTitle(
                  'Employee Information',
                ),

                const SizedBox(height: 12),

                _detailRow(
                  Icons.person_outline,
                  'Employee Name',
                  employeeName,
                ),

                _detailRow(
                  Icons.email_outlined,
                  'Email',
                  employeeEmail,
                ),

                _detailRow(
                  Icons.business_outlined,
                  'Department',
                  department,
                ),

                const SizedBox(height: 10),

                _detailSectionTitle(
                  'Asset Information',
                ),

                const SizedBox(height: 12),

                _detailRow(
                  Icons.inventory_2_outlined,
                  'Asset Name',
                  assetName,
                ),

                _detailRow(
                  Icons.qr_code_2_rounded,
                  'Asset ID',
                  assetId,
                ),

                _detailRow(
                  Icons.category_outlined,
                  'Category',
                  category,
                ),

                _detailRow(
                  Icons.business_center_outlined,
                  'Brand',
                  brand,
                ),

                _detailRow(
                  Icons.devices_other_outlined,
                  'Model',
                  model,
                ),

                const SizedBox(height: 10),

                _detailSectionTitle(
                  'Request Information',
                ),

                const SizedBox(height: 12),

                _detailRow(
                  Icons.flag_outlined,
                  'Priority',
                  priority,
                  valueColor:
                      _priorityColor(priority),
                ),

                _detailRow(
                  Icons.calendar_today_outlined,
                  'Submitted',
                  _formatDate(createdAt),
                ),

                if (reviewedAt != null)
                  _detailRow(
                    Icons.fact_check_outlined,
                    'Reviewed',
                    _formatDate(reviewedAt),
                  ),

                const SizedBox(height: 10),

                const Text(
                  'Employee Requirement / Reason',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FC),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          const Color(0xFFE4E7EF),
                    ),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF4D5566),
                    ),
                  ),
                ),

                if (status == 'Not Approved' &&
                    rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 20),

                  const Text(
                    'Rejection Reason',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD93025),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFFFF1F0),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            const Color(0xFFFFD2CE),
                      ),
                    ),
                    child: Text(
                      rejectionReason,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF8B2A22),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // =================================================
                // ACTION BUTTONS
                // =================================================

                if (status == 'Pending')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);

                            _rejectRequest(
                              request,
                            );
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                          label: const Text(
                            'Not Approve',
                          ),
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color(
                              0xFFD93025,
                            ),
                            side:
                                const BorderSide(
                              color:
                                  Color(0xFFD93025),
                            ),
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(13),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);

                            _approveRequest(
                              request,
                            );
                          },
                          icon: const Icon(
                            Icons.check_rounded,
                          ),
                          label: const Text(
                            'Approve',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF168A55,
                            ),
                            foregroundColor:
                                Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF3157D5,
                        ),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            13,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF172033),
      ),
    );
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _requestCard(
    Map<String, dynamic> request,
  ) {
    final requestCode = _stringValue(
      request,
      'request_code',
      fallback: 'Request',
    );

    final employeeName = _stringValue(
      request,
      'employee_name',
      fallback: 'Employee',
    );

    final department = _stringValue(
      request,
      'department',
      fallback: 'N/A',
    );

    final assetName = _stringValue(
      request,
      'asset_name',
      fallback: 'Unknown Asset',
    );

    final assetId = _stringValue(
      request,
      'asset_id',
      fallback: 'N/A',
    );

    final priority = _stringValue(
      request,
      'priority',
      fallback: 'Normal',
    );

    final description = _stringValue(
      request,
      'description',
      fallback: 'No description provided.',
    );

    final status = _statusForDisplay(request);

    final createdAt =
        request['created_at'] ??
        request['createdAt'];

    return GestureDetector(
      onTap: () {
        _showRequestDetails(request);
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    requestCode,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3157D5),
                    ),
                  ),
                ),
                _statusBadge(status),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF0F3FA),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF3157D5),
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(0xFF172033),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        department,
                        style: const TextStyle(
                          fontSize: 12,
                          color:
                              Color(0xFF7A8190),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FC),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 19,
                    color: Color(0xFF3157D5),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          assetName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF252B38),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'ID: $assetId',
                          style:
                              const TextStyle(
                            fontSize: 11,
                            color:
                                Color(0xFF7A8190),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                Expanded(
                  child: _smallInfo(
                    Icons.flag_outlined,
                    'Priority',
                    priority,
                    valueColor:
                        _priorityColor(
                      priority,
                    ),
                  ),
                ),

                Expanded(
                  child: _smallInfo(
                    Icons.calendar_today_outlined,
                    'Submitted',
                    _formatDate(createdAt),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            Text(
              description,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF606878),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showRequestDetails(
                        request,
                      );
                    },
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(
                        0xFF3157D5,
                      ),
                      side:
                          const BorderSide(
                        color:
                            Color(0xFF3157D5),
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 11,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          11,
                        ),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                if (status == 'Pending') ...[
                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _approveRequest(
                          request,
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF168A55,
                        ),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 11,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(11),
                        ),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (status == 'Pending') ...[
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _rejectRequest(
                      request,
                    );
                  },
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(
                      0xFFD93025,
                    ),
                    side:
                        const BorderSide(
                      color:
                          Color(0xFFFFB8B2),
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 10,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        11,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Not Approve',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _smallInfo(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF7A8190),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8B919D),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      valueColor ??
                      const Color(
                        0xFF353B48,
                      ),
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3157D5),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Asset Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '${requests.length} total request${requests.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Pending',
                  pendingCount,
                  Icons.access_time_rounded,
                ),
              ),

              Expanded(
                child: _summaryItem(
                  'Approved',
                  approvedCount,
                  Icons.check_circle_outline,
                ),
              ),

              Expanded(
                child: _summaryItem(
                  'Not Approved',
                  rejectedCount,
                  Icons.cancel_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String title,
    int count,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 21,
        ),

        const SizedBox(height: 6),

        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _filterBar() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder:
            (context, index) {
          final filter =
              filters[index];

          final selected =
              selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF3157D5,
                      )
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: selected
                      ? const Color(
                          0xFF3157D5,
                        )
                      : const Color(
                          0xFFE2E5ED,
                        ),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : const Color(
                          0xFF626A79,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    String title;
    String subtitle;

    if (selectedFilter == 'All') {
      title = 'No requests found';
      subtitle =
          'Employee asset requests will appear here when they are submitted.';
    } else {
      title =
          'No $selectedFilter requests';
      subtitle =
          'There are currently no requests with this status.';
    }

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 55,
        ),
        child: Column(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFEFF2FA),
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 40,
                color:
                    Color(0xFF3157D5),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color:
                    Color(0xFF7A8190),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFFFEEEE),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 38,
                color:
                    Color(0xFFD93025),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load requests',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color:
                    Color(0xFF737A88),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed:
                  _loadRequests,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text(
                'Try Again',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF3157D5,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    13,
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FC),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF6F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          'Asset Requests',
          style: TextStyle(
            color:
                Color(0xFF172033),
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color:
              Color(0xFF172033),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                isRefreshing
                    ? null
                    : _refreshRequests,
            icon: isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                  ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh:
            _refreshRequests,
        color:
            const Color(0xFF3157D5),

        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      Color(0xFF3157D5),
                ),
              )
            : errorMessage != null
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.65,
                        child:
                            _errorState(),
                      ),
                    ],
                  )
                : ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      16,
                      4,
                      16,
                      30,
                    ),
                    children: [
                      _summaryCard(),

                      const SizedBox(
                        height: 20,
                      ),

                      _filterBar(),

                      const SizedBox(
                        height: 18,
                      ),

                      if (filteredRequests
                          .isEmpty)
                        _emptyState()
                      else
                        ...filteredRequests.map(
                          _requestCard,
                        ),
                    ],
                  ),
      ),
    );
  }
}