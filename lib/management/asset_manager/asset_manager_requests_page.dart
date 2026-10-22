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
  // API CONFIG
  // ============================================================

  // Physical Android phone + USB:
  // adb reverse tcp:8000 tcp:8000
  //
  // Then Flutter can access FastAPI using:
  // http://127.0.0.1:8000
  static const String baseUrl = 'https://orgaflow-app.onrender.com';

  static const Duration requestTimeout = Duration(seconds: 30);

  // ============================================================
  // STATE
  // ============================================================

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
  // TOKEN
  // ============================================================

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    // New/current token key
    final accessToken = prefs.getString('access_token');

    if (accessToken != null && accessToken.trim().isNotEmpty) {
      return accessToken.trim();
    }

    // Backward compatibility
    final token = prefs.getString('token');

    if (token != null && token.trim().isNotEmpty) {
      return token.trim();
    }

    final accessTokenOld = prefs.getString('accessToken');

    if (accessTokenOld != null && accessTokenOld.trim().isNotEmpty) {
      return accessTokenOld.trim();
    }

    final jwt = prefs.getString('jwt');

    if (jwt != null && jwt.trim().isNotEmpty) {
      return jwt.trim();
    }

    return null;
  }

  // ============================================================
  // LOAD REQUESTS
  // ============================================================

  Future<void> _loadRequests({
    bool showRefreshLoader = false,
  }) async {
    if (showRefreshLoader) {
      setState(() {
        isRefreshing = true;
      });
    } else {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login token not found. Please login again.',
        );
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/requests'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> data = [];

        // Backend response:
        // {
        //   "requests": [...]
        // }
        if (decoded is Map<String, dynamic>) {
          if (decoded['requests'] is List) {
            data = decoded['requests'];
          } else if (decoded['data'] is List) {
            data = decoded['data'];
          }
        }

        // If backend directly returns a list
        if (decoded is List) {
          data = decoded;
        }

        final loadedRequests = data
            .whereType<Map>()
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        if (!mounted) return;

        setState(() {
          requests = loadedRequests;
          errorMessage = null;
          isLoading = false;
          isRefreshing = false;
        });
      } else if (response.statusCode == 401) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          isRefreshing = false;
          errorMessage =
              'Session expired. Please login again.';
        });
      } else if (response.statusCode == 403) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          isRefreshing = false;
          errorMessage =
              'You are not authorized to view requests.';
        });
      } else {
        String message = 'Failed to load requests.';

        try {
          final body = jsonDecode(response.body);

          if (body is Map<String, dynamic>) {
            message =
                body['detail']?.toString() ??
                body['message']?.toString() ??
                message;
          }
        } catch (_) {}

        if (!mounted) return;

        setState(() {
          isLoading = false;
          isRefreshing = false;
          errorMessage =
              '$message\nStatus: ${response.statusCode}';
        });
      }
    } on http.ClientException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
        errorMessage =
            'Network error.\n${e.message}';
      });
    } on FormatException {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
        errorMessage =
            'Invalid response received from server.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  // ============================================================
  // STATUS UPDATE
  // ============================================================

  Future<bool> _updateRequestStatus({
    required int requestId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        _showSnackBar(
          'Login session not found. Please login again.',
          isError: true,
        );
        return false;
      }

      final response = await http
          .patch(
            Uri.parse(
              '$baseUrl/api/requests/$requestId/status',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'status': status,
              'rejection_reason': rejectionReason,
            }),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 401) {
        _showSnackBar(
          'Session expired. Please login again.',
          isError: true,
        );
        return false;
      }

      if (response.statusCode == 403) {
        _showSnackBar(
          'You are not authorized to update requests.',
          isError: true,
        );
        return false;
      }

      String message = 'Unable to update request.';

      try {
        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          message =
              body['detail']?.toString() ??
              body['message']?.toString() ??
              message;
        }
      } catch (_) {}

      _showSnackBar(
        '$message\nStatus: ${response.statusCode}',
        isError: true,
      );

      return false;
    } on http.ClientException catch (e) {
      _showSnackBar(
        'Network error: ${e.message}',
        isError: true,
      );
      return false;
    } on FormatException {
      _showSnackBar(
        'Invalid server response.',
        isError: true,
      );
      return false;
    } catch (e) {
      _showSnackBar(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        isError: true,
      );
      return false;
    }
  }

  // ============================================================
  // APPROVE
  // ============================================================

  Future<void> _approveRequest(
    Map<String, dynamic> request,
  ) async {
    final requestId = _getRequestId(request);

    if (requestId == null) {
      _showSnackBar(
        'Request ID not found.',
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve Request'),
          content: Text(
            'Are you sure you want to approve '
            '${_getRequestCode(request)}?',
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
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    _showLoadingDialog('Approving request...');

    final success = await _updateRequestStatus(
      requestId: requestId,
      status: 'Approved',
      rejectionReason: null,
    );

    if (mounted) {
      Navigator.pop(context);
    }

    if (success) {
      _showSnackBar(
        'Request approved successfully.',
      );

      await _loadRequests();
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _rejectRequest(
    Map<String, dynamic> request,
  ) async {
    final requestId = _getRequestId(request);

    if (requestId == null) {
      _showSnackBar(
        'Request ID not found.',
        isError: true,
      );
      return;
    }

    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Not Approve Request'),
          content: TextField(
            controller: reasonController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason',
              border: OutlineInputBorder(),
            ),
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
                final value =
                    reasonController.text.trim();

                if (value.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter rejection reason.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(context, value);
              },
              child: const Text('Not Approve'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    _showLoadingDialog(
      'Updating request...',
    );

    final success = await _updateRequestStatus(
      requestId: requestId,
      status: 'Rejected',
      rejectionReason: reason.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
    }

    if (success) {
      _showSnackBar(
        'Request marked as not approved.',
      );

      await _loadRequests();
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int? _getRequestId(
    Map<String, dynamic> request,
  ) {
    final value = request['id'];

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  String _getRequestCode(
    Map<String, dynamic> request,
  ) {
    return request['request_code']?.toString() ??
        'REQ-${request['id'] ?? '---'}';
  }

  String _getString(
    Map<String, dynamic> request,
    String key, {
    String fallback = 'N/A',
  }) {
    final value = request[key];

    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty) return fallback;

    return text;
  }

  String _getStatus(
    Map<String, dynamic> request,
  ) {
    return _getString(
      request,
      'status',
      fallback: 'Pending',
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;

      case 'rejected':
      case 'not approved':
      case 'not_approved':
        return Colors.red;

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;

      case 'rejected':
      case 'not approved':
      case 'not_approved':
        return Icons.cancel;

      case 'pending':
      default:
        return Icons.pending_actions;
    }
  }

  List<Map<String, dynamic>> get filteredRequests {
    if (selectedFilter == 'All') {
      return requests;
    }

    return requests.where((request) {
      final status =
          _getStatus(request).toLowerCase();

      switch (selectedFilter) {
        case 'Pending':
          return status == 'pending';

        case 'Approved':
          return status == 'approved';

        case 'Not Approved':
          return status == 'rejected' ||
              status == 'not approved' ||
              status == 'not_approved';

        default:
          return true;
      }
    }).toList();
  }

  int get pendingCount {
    return requests.where((request) {
      return _getStatus(request).toLowerCase() ==
          'pending';
    }).length;
  }

  int get approvedCount {
    return requests.where((request) {
      return _getStatus(request).toLowerCase() ==
          'approved';
    }).length;
  }

  int get rejectedCount {
    return requests.where((request) {
      final status =
          _getStatus(request).toLowerCase();

      return status == 'rejected' ||
          status == 'not approved' ||
          status == 'not_approved';
    }).length;
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // REQUEST DETAILS
  // ============================================================

  void _showRequestDetails(
    Map<String, dynamic> request,
  ) {
    final status = _getStatus(request);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Request Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon:
                            const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _detailCard(
                          title: 'Request Information',
                          children: [
                            _detailRow(
                              'Request Code',
                              _getRequestCode(
                                request,
                              ),
                            ),
                            _detailRow(
                              'Status',
                              status,
                              valueWidget:
                                  _statusBadge(
                                status,
                              ),
                            ),
                            _detailRow(
                              'Priority',
                              _getString(
                                request,
                                'priority',
                              ),
                            ),
                            _detailRow(
                              'Created At',
                              _formatDate(
                                request[
                                    'created_at'],
                              ),
                            ),
                            _detailRow(
                              'Reviewed At',
                              _formatDate(
                                request[
                                    'reviewed_at'],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _detailCard(
  title: 'Employee Information',
  children: [
    _detailRow(
      'Name',
      _getString(
        request,
        'employee_name',
      ),
    ),
    _detailRow(
      'Email',
      _getString(
        request,
        'employee_email',
      ),
    ),
    _detailRow(
      'Department',
      _getString(
        request,
        'department',
      ),
    ),
  ],
),

                        const SizedBox(height: 16),

                        _detailCard(
                          title: 'Asset Information',
                          children: [
                            _detailRow(
                              'Asset',
                              _getString(
                                request,
                                'asset_name',
                              ),
                            ),
                            _detailRow(
                              'Asset ID',
                              _getString(
                                request,
                                'asset_id',
                              ),
                            ),
                            _detailRow(
                              'Category',
                              _getString(
                                request,
                                'asset_category',
                              ),
                            ),
                            _detailRow(
                              'Brand',
                              _getString(
                                request,
                                'asset_brand',
                              ),
                            ),
                            _detailRow(
                              'Model',
                              _getString(
                                request,
                                'asset_model',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _detailCard(
                          title: 'Description',
                          children: [
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(
                                14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey.shade50,
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: Text(
                                _getString(
                                  request,
                                  'description',
                                  fallback:
                                      'No description provided.',
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_getString(
                              request,
                              'rejection_reason',
                              fallback: '',
                            ).isNotEmpty) ...[
                          const SizedBox(height: 16),

                          _detailCard(
                            title:
                                'Rejection Reason',
                            children: [
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets
                                        .all(14),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.red.shade50,
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                ),
                                child: Text(
                                  _getString(
                                    request,
                                    'rejection_reason',
                                  ),
                                  style:
                                      const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        if (status.toLowerCase() ==
                            'pending')
                          Row(
                            children: [
                              Expanded(
                                child:
                                    OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                    );
                                    _rejectRequest(
                                      request,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Not Approve',
                                  ),
                                  style:
                                      OutlinedButton
                                          .styleFrom(
                                    foregroundColor:
                                        Colors.red,
                                    side:
                                        const BorderSide(
                                      color: Colors.red,
                                    ),
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child:
                                    ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                    );
                                    _approveRequest(
                                      request,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                  ),
                                  label: const Text(
                                    'Approve',
                                  ),
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        Colors.green,
                                    foregroundColor:
                                        Colors.white,
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
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

  Widget _detailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value, {
    Widget? valueWidget,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: valueWidget ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _statusIcon(status),
              size: 15,
              color: color,
            ),
            const SizedBox(width: 5),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'N/A';
    }

    final text = value.toString();

    if (text.isEmpty) {
      return 'N/A';
    }

    try {
      final date = DateTime.parse(text);

      final day =
          date.day.toString().padLeft(2, '0');
      final month =
          date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour =
          date.hour.toString().padLeft(2, '0');
      final minute =
          date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return text;
    }
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _requestCard(
    Map<String, dynamic> request,
  ) {
    final status = _getStatus(request);
    final statusColor =
        _statusColor(status);

    return Card(
      margin:
          const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: () {
          _showRequestDetails(request);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF3B5BDB,
                      ).withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF3B5BDB),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getString(
                            request,
                            'asset_name',
                            fallback:
                                'Asset Request',
                          ),
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRequestCode(
                            request,
                          ),
                          style: TextStyle(
                            color: Colors
                                .grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _statusBadge(status),
                ],
              ),

              const SizedBox(height: 16),

              _compactInfo(
                Icons.person_outline,
                _getString(
                  request,
                  'employee_name',
                ),
              ),

              const SizedBox(height: 8),

              _compactInfo(
                Icons.business_outlined,
                _getString(
                  request,
                  'department',
                ),
              ),

              const SizedBox(height: 8),

              _compactInfo(
                Icons.priority_high,
                'Priority: ${_getString(
                  request,
                  'priority',
                )}',
              ),

              const SizedBox(height: 8),

              _compactInfo(
                Icons.calendar_today_outlined,
                _formatDate(
                  request['created_at'],
                ),
              ),

              if (status.toLowerCase() ==
                  'pending') ...[
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed: () {
                          _rejectRequest(
                            request,
                          );
                        },
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              Colors.red,
                          side:
                              const BorderSide(
                            color: Colors.red,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 11,
                          ),
                        ),
                        child:
                            const Text(
                          'Not Approve',
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child:
                          ElevatedButton(
                        onPressed: () {
                          _approveRequest(
                            request,
                          );
                        },
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.green,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 11,
                          ),
                        ),
                        child:
                            const Text(
                          'Approve',
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (status.toLowerCase() !=
                  'pending') ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(
                    color: statusColor
                        .withOpacity(0.06),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Text(
                    'Tap to view complete request details',
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactInfo(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ??
                  'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _loadRequests();
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY VIEW
  // ============================================================

  Widget _emptyView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 70,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No requests found',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilter == 'All'
                  ? 'No employee requests have been submitted yet.'
                  : 'No $selectedFilter requests found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
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
    final displayedRequests =
        filteredRequests;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Employee Requests',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isRefreshing
                ? null
                : () {
                    _loadRequests(
                      showRefreshLoader: true,
                    );
                  },
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
                    Icons.refresh,
                    color: Colors.black87,
                  ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadRequests(
                      showRefreshLoader: true,
                    );
                  },
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(16),
                    children: [
                      // Summary
                      Row(
                        children: [
                          _summaryCard(
                            title: 'Pending',
                            count: pendingCount,
                            icon:
                                Icons.pending_actions,
                            color:
                                Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          _summaryCard(
                            title: 'Approved',
                            count: approvedCount,
                            icon:
                                Icons.check_circle,
                            color:
                                Colors.green,
                          ),
                          const SizedBox(width: 10),
                          _summaryCard(
                            title: 'Not Approved',
                            count: rejectedCount,
                            icon:
                                Icons.cancel,
                            color:
                                Colors.red,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Filters
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount:
                              filters.length,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                            width: 8,
                          ),
                          itemBuilder:
                              (context, index) {
                            final filter =
                                filters[index];

                            final isSelected =
                                selectedFilter ==
                                    filter;

                            return ChoiceChip(
                              label:
                                  Text(filter),
                              selected:
                                  isSelected,
                              onSelected: (_) {
                                setState(() {
                                  selectedFilter =
                                      filter;
                                });
                              },
                              selectedColor:
                                  const Color(
                                0xFF3B5BDB,
                              ),
                              labelStyle:
                                  TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors
                                        .black87,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                              backgroundColor:
                                  Colors.white,
                              side: BorderSide(
                                color: Colors
                                    .grey.shade200,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Requests',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${displayedRequests.length} found',
                            style: TextStyle(
                              color: Colors
                                  .grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (displayedRequests.isEmpty)
                        SizedBox(
                          height:
                              MediaQuery.of(context)
                                      .size
                                      .height *
                                  0.45,
                          child: _emptyView(),
                        )
                      else
                        ...displayedRequests.map(
                          _requestCard,
                        ),
                    ],
                  ),
                ),
    );
  }
}