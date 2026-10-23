import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeTrackRequestsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EmployeeTrackRequestsPage({
    super.key,
    this.userData,
  });

  @override
  State<EmployeeTrackRequestsPage> createState() =>
      _EmployeeTrackRequestsPageState();
}

class _EmployeeTrackRequestsPageState
    extends State<EmployeeTrackRequestsPage> {
  // ============================================================
  // API CONFIG
  // ============================================================

  // Physical Android phone + USB:
  //
  // adb reverse tcp:8000 tcp:8000
  //
  // Then use:
  // http://127.0.0.1:8000

  static const String baseUrl = 'https://orgaflow-app.onrender.com';

  static const Duration requestTimeout =
      Duration(seconds: 30);

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
    final prefs =
        await SharedPreferences.getInstance();

    // Current token
    final accessToken =
        prefs.getString('access_token');

    if (accessToken != null &&
        accessToken.trim().isNotEmpty) {
      return accessToken.trim();
    }

    // Old token key
    final token = prefs.getString('token');

    if (token != null &&
        token.trim().isNotEmpty) {
      return token.trim();
    }

    // Other possible keys
    final accessTokenOld =
        prefs.getString('accessToken');

    if (accessTokenOld != null &&
        accessTokenOld.trim().isNotEmpty) {
      return accessTokenOld.trim();
    }

    final jwt = prefs.getString('jwt');

    if (jwt != null &&
        jwt.trim().isNotEmpty) {
      return jwt.trim();
    }

    return null;
  }

  // ============================================================
  // LOAD EMPLOYEE REQUESTS
  // ============================================================

  Future<void> _loadRequests({
    bool showLoader = true,
  }) async {
    if (!mounted) return;

    if (showLoader) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login session not found. Please login again.',
        );
      }

      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/requests/my',
            ),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(requestTimeout);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decoded =
            jsonDecode(response.body);

        List<dynamic> rawRequests = [];

        if (decoded is Map<String, dynamic>) {
          if (decoded['requests'] is List) {
            rawRequests =
                decoded['requests'];
          } else if (decoded['data'] is List) {
            rawRequests =
                decoded['data'];
          }
        } else if (decoded is List) {
          rawRequests = decoded;
        }

        final loadedRequests = rawRequests
            .whereType<Map>()
            .map(
              (request) =>
                  Map<String, dynamic>.from(
                request,
              ),
            )
            .toList();

        setState(() {
          requests = loadedRequests;
          isLoading = false;
          errorMessage = null;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage =
              'Session expired. Please login again.';
        });
      } else if (response.statusCode == 403) {
        setState(() {
          isLoading = false;
          errorMessage =
              'You are not authorized to view your requests.';
        });
      } else {
        String message =
            'Unable to load requests.';

        try {
          final body =
              jsonDecode(response.body);

          if (body is Map<String, dynamic>) {
            message =
                body['detail']?.toString() ??
                body['message']?.toString() ??
                message;
          }
        } catch (_) {}

        setState(() {
          isLoading = false;
          errorMessage =
              '$message\nStatus: ${response.statusCode}';
        });
      }
    } on http.ClientException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Network error.\n${e.message}';
      });
    } on FormatException {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Invalid response received from server.';
      });
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
      await _loadRequests(
        showLoader: false,
      );
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

  List<Map<String, dynamic>>
      get filteredRequests {
    if (selectedFilter == 'All') {
      return requests;
    }

    return requests.where((request) {
      final status =
          _statusForDisplay(request);

      return status.toLowerCase() ==
          selectedFilter.toLowerCase();
    }).toList();
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _rawStatus(
    Map<String, dynamic> request,
  ) {
    return (request['status'] ?? 'Pending')
        .toString()
        .trim();
  }

  String _statusForDisplay(
    Map<String, dynamic> request,
  ) {
    final status =
        _rawStatus(request).toLowerCase();

    switch (status) {
      case 'pending':
        return 'Pending';

      case 'approved':
        return 'Approved';

      case 'rejected':
      case 'not approved':
      case 'not_approved':
        return 'Not Approved';

      default:
        return _rawStatus(request);
    }
  }

  // ============================================================
  // COUNTS
  // ============================================================

  int get pendingCount {
    return requests.where((request) {
      return _rawStatus(request)
              .toLowerCase() ==
          'pending';
    }).length;
  }

  int get approvedCount {
    return requests.where((request) {
      return _rawStatus(request)
              .toLowerCase() ==
          'approved';
    }).length;
  }

  int get rejectedCount {
    return requests.where((request) {
      final status =
          _rawStatus(request).toLowerCase();

      return status == 'rejected' ||
          status == 'not approved' ||
          status == 'not_approved';
    }).length;
  }

  // ============================================================
  // STRING HELPER
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

  // ============================================================
  // ERROR HELPER
  // ============================================================

  String _cleanError(Object error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message =
          message.substring('Exception: '.length);
    }

    return message;
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Not available';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return 'Not available';
    }

    try {
      final date =
          DateTime.parse(text).toLocal();

      final day =
          date.day.toString().padLeft(2, '0');

      final month =
          date.month.toString().padLeft(2, '0');

      final year =
          date.year.toString();

      final hour12 = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final hour =
          hour12.toString().padLeft(2, '0');

      final minute =
          date.minute.toString().padLeft(2, '0');

      final period =
          date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year â€¢ '
          '$hour:$minute $period';
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

  // ============================================================
  // PRIORITY
  // ============================================================

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
  // REQUEST DETAILS
  // ============================================================

  void _showRequestDetails(
    Map<String, dynamic> request,
  ) {
    final requestCode = _stringValue(
      request,
      'request_code',
      fallback: _stringValue(
        request,
        'requestCode',
        fallback: 'Request',
      ),
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
      fallback: _stringValue(
        request,
        'category',
        fallback: 'N/A',
      ),
    );

    final brand = _stringValue(
      request,
      'asset_brand',
      fallback: _stringValue(
        request,
        'brand',
        fallback: 'N/A',
      ),
    );

    final model = _stringValue(
      request,
      'asset_model',
      fallback: _stringValue(
        request,
        'model',
        fallback: 'N/A',
      ),
    );

    final priority = _stringValue(
      request,
      'priority',
      fallback: 'Normal',
    );

    final description = _stringValue(
      request,
      'description',
      fallback:
          'No description provided.',
    );

    final rejectionReason =
        _stringValue(
      request,
      'rejection_reason',
      fallback: _stringValue(
        request,
        'rejectionReason',
      ),
    );

    final status =
        _statusForDisplay(request);

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
                MediaQuery.of(context)
                        .size
                        .height *
                    0.88,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
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
                    decoration:
                        BoxDecoration(
                      color: const Color(
                        0xFFD7DBE5,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        requestCode,
                        style:
                            const TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.w800,
                          color: Color(
                            0xFF172033,
                          ),
                        ),
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),

                const SizedBox(height: 24),

                _sectionTitle(
                  'Asset Details',
                ),

                const SizedBox(height: 12),

                _detailRow(
                  Icons.inventory_2_outlined,
                  'Asset',
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
                  Icons.business_outlined,
                  'Brand',
                  brand,
                ),

                _detailRow(
                  Icons.devices_other_outlined,
                  'Model',
                  model,
                ),

                const SizedBox(height: 22),

                _sectionTitle(
                  'Request Details',
                ),

                const SizedBox(height: 12),

                _detailRow(
                  Icons.flag_outlined,
                  'Priority',
                  priority,
                  valueColor:
                      _priorityColor(
                    priority,
                  ),
                ),

                _detailRow(
                  Icons.calendar_today_outlined,
                  'Submitted',
                  _formatDate(
                    createdAt,
                  ),
                ),

                if (reviewedAt != null)
                  _detailRow(
                    Icons.fact_check_outlined,
                    'Reviewed',
                    _formatDate(
                      reviewedAt,
                    ),
                  ),

                const SizedBox(height: 18),

                const Text(
                  'Employee Requirement / Reason',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFF6F8FC,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    border: Border.all(
                      color: const Color(
                        0xFFE4E7EF,
                      ),
                    ),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color:
                          Color(0xFF4D5566),
                    ),
                  ),
                ),

                if (status ==
                        'Not Approved' &&
                    rejectionReason
                        .isNotEmpty) ...[
                  const SizedBox(height: 22),

                  const Text(
                    'Reason from Asset Management',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFFD93025),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    decoration:
                        BoxDecoration(
                      color: const Color(
                        0xFFFFF1F0,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      border: Border.all(
                        color: const Color(
                          0xFFFFD2CE,
                        ),
                      ),
                    ),
                    child: Text(
                      rejectionReason,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color:
                            Color(0xFF8B2A22),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
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
                          14,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 15,
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

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF172033),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
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
              color:
                  const Color(0xFFF0F3FA),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              size: 19,
              color:
                  const Color(0xFF3157D5),
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
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color:
                        Color(0xFF7A8190),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ??
                        const Color(
                          0xFF252B38,
                        ),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color =
        _statusColor(status);

    final background =
        _statusBackground(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
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
              fontWeight:
                  FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _requestCard(
    Map<String, dynamic> request,
  ) {
    final requestCode =
        _stringValue(
      request,
      'request_code',
      fallback: _stringValue(
        request,
        'requestCode',
        fallback: 'Request',
      ),
    );

    final assetName =
        _stringValue(
      request,
      'asset_name',
      fallback: _stringValue(
        request,
        'assetName',
        fallback: 'Unknown Asset',
      ),
    );

    final assetId =
        _stringValue(
      request,
      'asset_id',
      fallback: _stringValue(
        request,
        'assetId',
        fallback: 'N/A',
      ),
    );

    final priority =
        _stringValue(
      request,
      'priority',
      fallback: 'Normal',
    );

    final description =
        _stringValue(
      request,
      'description',
      fallback:
          'No description provided.',
    );

    final status =
        _statusForDisplay(request);

    final createdAt =
        request['created_at'] ??
            request['createdAt'];

    final rejectionReason =
        _stringValue(
      request,
      'rejection_reason',
      fallback: _stringValue(
        request,
        'rejectionReason',
      ),
    );

    return GestureDetector(
      onTap: () {
        _showRequestDetails(
          request,
        );
      },
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: const Color(
              0xFFE5E8F0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.035),
              blurRadius: 12,
              offset:
                  const Offset(0, 5),
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
                    style:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w800,
                      color: Color(
                        0xFF3157D5,
                      ),
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
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFF0F3FA,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .inventory_2_outlined,
                    color: Color(
                      0xFF3157D5,
                    ),
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        assetName,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w800,
                          color: Color(
                            0xFF172033,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Asset ID: $assetId',
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color: Color(
                            0xFF7A8190,
                          ),
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

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
                    Icons
                        .calendar_today_outlined,
                    'Submitted',
                    _formatDate(
                      createdAt,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              description,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(
                  0xFF606878,
                ),
              ),
            ),

            if (status ==
                    'Not Approved' &&
                rejectionReason
                    .isNotEmpty) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  11,
                ),
                decoration:
                    BoxDecoration(
                  color: const Color(
                    0xFFFFF1F0,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(
                        0xFFD93025,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Not Approved: '
                        '$rejectionReason',
                        style:
                            const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(
                            0xFF8B2A22,
                          ),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color: Color(
                      0xFF3157D5,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 12,
                  color: Color(
                    0xFF3157D5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SMALL INFO
  // ============================================================

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
          color:
              const Color(0xFF7A8190),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 10,
                  color:
                      Color(0xFF8B919D),
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
                  color: valueColor ??
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
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFF3157D5),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'My Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '${requests.length} total request'
            '${requests.length == 1 ? '' : 's'}',
            style:
                const TextStyle(
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
                  Icons
                      .access_time_rounded,
                ),
              ),

              Expanded(
                child: _summaryItem(
                  'Approved',
                  approvedCount,
                  Icons
                      .check_circle_outline,
                ),
              ),

              Expanded(
                child: _summaryItem(
                  'Not Approved',
                  rejectedCount,
                  Icons
                      .cancel_outlined,
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
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          title,
          textAlign: TextAlign.center,
          style:
              const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight:
                FontWeight.w600,
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
        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 8,
        ),
        itemBuilder:
            (context, index) {
          final filter =
              filters[index];

          final selected =
              selectedFilter ==
                  filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter =
                    filter;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF3157D5,
                      )
                    : Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
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
      title = 'No requests yet';
      subtitle =
          'Your asset requests will appear here after you submit them.';
    } else {
      title =
          'No $selectedFilter requests';
      subtitle =
          'There are no requests with this status.';
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
              decoration:
                  BoxDecoration(
                color: const Color(
                  0xFFEFF2FA,
                ),
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 40,
                color: Color(
                  0xFF3157D5,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color: Color(
                  0xFF172033,
                ),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(
                  0xFF7A8190,
                ),
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
              decoration:
                  BoxDecoration(
                color: const Color(
                  0xFFFFEEEE,
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 38,
                color: Color(
                  0xFFD93025,
                ),
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
                color: Color(
                  0xFF172033,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(
                  0xFF737A88,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed:
                  _loadRequests,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
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
          'Track Requests',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color: Color(0xFF172033),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isRefreshing
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
                    Icons
                        .refresh_rounded,
                  ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refreshRequests,
        color:
            const Color(0xFF3157D5),

        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color: Color(
                    0xFF3157D5,
                  ),
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
                                    context)
                                .size
                                .height *
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
                        ...filteredRequests
                            .map(
                          _requestCard,
                        ),
                    ],
                  ),
      ),
    );
  }
}