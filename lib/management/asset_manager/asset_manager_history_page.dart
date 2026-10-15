import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssetManagerHistoryPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerHistoryPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerHistoryPage> createState() =>
      _AssetManagerHistoryPageState();
}

class _AssetManagerHistoryPageState
    extends State<AssetManagerHistoryPage> {
  static const Color primary = Color(0xFF3157D5);
  static const Color background = Color(0xFFF5F7FC);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF758096);
  static const Color borderColor = Color(0xFFE7EBF3);

  String selectedFilter = 'All';

  List<Map<String, dynamic>> history = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  String get _baseUrl {
    // Use the same base URL configuration as your other API screens.
    return (widget.userData?['http://127.0.0.1:8000'] ??
            widget.userData?['http://127.0.0.1:8000'] ??
            '')
        .toString()
        .replaceAll(RegExp(r'/+$'), '');
  }

  String get _token {
    return (widget.userData?['token'] ??
            widget.userData?['access_token'] ??
            widget.userData?['accessToken'] ??
            '')
        .toString();
  }

  String get _managerName {
    return (widget.userData?['name'] ??
            widget.userData?['full_name'] ??
            'Asset Manager')
        .toString();
  }

  Future<void> _refreshHistory() async {
    if (_baseUrl.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage =
            'API base URL missing. Configure baseUrl in userData.';
      });
      return;
    }

    if (_token.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Authentication token missing. Please log in again.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/asset-manager/history'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 401 ||
          response.statusCode == 403) {
        throw Exception(
          'Access denied. Please log in again or check your manager permissions.',
        );
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned ${response.statusCode}. '
          'Check whether the history API endpoint exists.',
        );
      }

      final decoded = jsonDecode(response.body);

      // Supported responses:
      // {"items": [...]}
      // {"history": [...]}
      // {"activities": [...]}
      // [...]
      final dynamic rawItems = decoded is List
          ? decoded
          : decoded is Map
              ? decoded['items'] ??
                  decoded['history'] ??
                  decoded['activities']
              : null;

      if (rawItems is! List) {
        throw const FormatException(
          'Unexpected history API response format.',
        );
      }

      final records = rawItems
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .where(_belongsToCurrentManager)
          .toList();

      if (!mounted) return;

      setState(() {
        history = records;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  // The backend should return manager-scoped audit records.
  // Never count activities performed by another manager.
  bool _belongsToCurrentManager(
    Map<String, dynamic> item,
  ) {
    final managerId =
        widget.userData?['id']?.toString() ??
        widget.userData?['user_id']?.toString();

    final recordedManagerId =
        item['performed_by_id']?.toString() ??
        item['reviewed_by_id']?.toString() ??
        item['actor_id']?.toString();

    if (managerId != null && recordedManagerId != null) {
      return managerId == recordedManagerId;
    }

    final recordedName =
        item['performed_by']?.toString() ??
        item['reviewed_by']?.toString() ??
        item['actor_name']?.toString();

    // Name matching is only a fallback for APIs without actor IDs.
    // Prefer immutable manager IDs in production.
    return recordedName != null &&
        recordedName.trim().toLowerCase() ==
            _managerName.trim().toLowerCase();
  }

  String _value(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '-',
  }) {
    for (final key in keys) {
      final value = item[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String _status(Map<String, dynamic> item) {
    final raw = _value(
      item,
      ['status', 'decision', 'action_type', 'action'],
      fallback: '',
    ).toLowerCase();

    if (raw.contains('reject') ||
        raw == 'denied' ||
        raw == 'declined') {
      return 'Rejected';
    }

    if (raw.contains('approv') ||
        raw == 'accepted') {
      return 'Approved';
    }

    return 'Other';
  }

  String _activityType(Map<String, dynamic> item) {
    final raw = _value(
      item,
      ['type', 'activity_type', 'action_type', 'action'],
      fallback: '',
    ).toLowerCase();

    if (raw.contains('approv') ||
        raw.contains('reject') ||
        raw.contains('request')) {
      return 'Request';
    }
    if (raw.contains('assign')) return 'Assignment';
    if (raw.contains('return')) return 'Return';
    if (raw.contains('mainten')) return 'Maintenance';
    if (raw.contains('transfer')) return 'Transfer';
    if (raw.contains('creat') || raw.contains('add')) {
      return 'Created';
    }

    return 'Other';
  }

  int get totalActivities => history.length;

  int get approvedCount => history
      .where((item) => _status(item) == 'Approved')
      .length;

  int get rejectedCount => history
      .where((item) => _status(item) == 'Rejected')
      .length;

  List<Map<String, dynamic>> get filteredHistory {
    if (selectedFilter == 'All') return history;

    if (selectedFilter == 'Approved' ||
        selectedFilter == 'Rejected') {
      return history
          .where(
            (item) => _status(item) == selectedFilter,
          )
          .toList();
    }

    return history
        .where(
          (item) => _activityType(item) == selectedFilter,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: primary,
                onRefresh: _refreshHistory,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 28,
                  ),
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 18),
                    _buildSummary(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(),
                    const SizedBox(height: 12),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    if (isLoading)
                      _buildLoading()
                    else if (errorMessage != null)
                      _buildError()
                    else if (filteredHistory.isEmpty)
                      _buildEmptyState()
                    else
                      ...filteredHistory.map(_historyCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 15, 12, 15),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEFF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity History',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your asset management records',
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh records',
            onPressed: isLoading ? null : _refreshHistory,
            icon: const Icon(
              Icons.refresh_rounded,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3157D5),
            Color(0xFF5577EA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Manager Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Welcome, $_managerName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Track the requests you reviewed and your recorded asset activities.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Counts are based on records returned by the server.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Request decisions',
          style: TextStyle(
            color: textDark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Total Activities',
                value: totalActivities,
                icon: Icons.timeline_rounded,
                color: primary,
                background: const Color(0xFFE9EEFF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                title: 'Approved',
                value: approvedCount,
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF15803D),
                background: const Color(0xFFE8F7EE),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                title: 'Rejected',
                value: rejectedCount,
                icon: Icons.cancel_outlined,
                color: const Color(0xFFDC4545),
                background: const Color(0xFFFFEEEE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 125),
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            isLoading ? '—' : '$value',
            style: const TextStyle(
              color: textDark,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Recent Activities',
            style: TextStyle(
              color: textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          isLoading ? 'Loading...' : '${filteredHistory.length} records',
          style: const TextStyle(
            color: textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    const filters = [
      'All',
      'Approved',
      'Rejected',
      'Assignment',
      'Return',
      'Maintenance',
      'Transfer',
      'Created',
      'Request',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() => selectedFilter = filter);
              },
              selectedColor: primary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? primary : borderColor,
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : textDark,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    final status = _status(item);
    final type = _activityType(item);

    final action = _value(
      item,
      ['action', 'activity', 'action_type', 'type'],
      fallback: status == 'Other' ? type : '$status Request',
    );

    final asset = _value(
      item,
      ['asset_name', 'asset', 'item_name'],
      fallback: 'Asset not specified',
    );

    final assetId = _value(
      item,
      ['asset_id', 'asset_code', 'asset_tag'],
    );

    final employee = _value(
      item,
      ['employee_name', 'employee', 'requester_name', 'user_name'],
    );

    final date = _value(
      item,
      ['created_at', 'reviewed_at', 'timestamp', 'date'],
    );

    final description = _value(
      item,
      ['description', 'remarks', 'reason', 'comments'],
      fallback: 'No description available.',
    );

    final decision = status == 'Approved'
        ? const Color(0xFF15803D)
        : status == 'Rejected'
            ? const Color(0xFFDC4545)
            : primary;

    final decisionBackground = status == 'Approved'
        ? const Color(0xFFE8F7EE)
        : status == 'Rejected'
            ? const Color(0xFFFFEEEE)
            : const Color(0xFFE9EEFF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDetails(
          item: item,
          action: action,
          asset: asset,
          assetId: assetId,
          employee: employee,
          date: date,
          description: description,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _activityIcon(type, status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          asset,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (status != 'Other')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: decisionBackground,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: decision,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 13),
              const Divider(height: 1, color: borderColor),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 15,
                    color: textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      employee,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      assetId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Text(
                    'View details',
                    style: TextStyle(
                      color: primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityIcon(String type, String status) {
    IconData icon;
    Color color;
    Color bg;

    if (status == 'Approved') {
      icon = Icons.check_circle_outline_rounded;
      color = const Color(0xFF15803D);
      bg = const Color(0xFFE8F7EE);
    } else if (status == 'Rejected') {
      icon = Icons.cancel_outlined;
      color = const Color(0xFFDC4545);
      bg = const Color(0xFFFFEEEE);
    } else {
      switch (type) {
        case 'Assignment':
          icon = Icons.person_add_alt_1_rounded;
          color = const Color(0xFF15803D);
          bg = const Color(0xFFE8F7EE);
          break;
        case 'Return':
          icon = Icons.assignment_return_outlined;
          color = Colors.orange;
          bg = const Color(0xFFFFF4E5);
          break;
        case 'Maintenance':
          icon = Icons.build_outlined;
          color = Colors.deepOrange;
          bg = const Color(0xFFFFEDE3);
          break;
        case 'Transfer':
          icon = Icons.swap_horiz_rounded;
          color = Colors.purple;
          bg = const Color(0xFFF1E8FF);
          break;
        case 'Created':
          icon = Icons.add_box_outlined;
          color = Colors.teal;
          bg = const Color(0xFFE5F7F5);
          break;
        default:
          icon = Icons.history_rounded;
          color = primary;
          bg = const Color(0xFFE9EEFF);
      }
    }

    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: primary),
            SizedBox(height: 15),
            Text(
              'Fetching real activity records...',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: Color(0xFFDC4545),
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load history',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshHistory,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEFF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              size: 35,
              color: primary,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'No activities found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            selectedFilter == 'All'
                ? 'Your recorded activities will appear here when available.'
                : 'No records match the "$selectedFilter" filter.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails({
    required Map<String, dynamic> item,
    required String action,
    required String asset,
    required String assetId,
    required String employee,
    required String date,
    required String description,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 42,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Activity Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _detailRow(
                    'Activity ID',
                    _value(item, ['id', 'activity_id', 'request_id']),
                  ),
                  _detailRow('Action', action),
                  _detailRow('Asset', asset),
                  _detailRow('Asset ID', assetId),
                  _detailRow('Employee', employee),
                  _detailRow(
                    'Performed by',
                    _value(
                      item,
                      ['performed_by', 'reviewed_by', 'actor_name'],
                    ),
                  ),
                  _detailRow('Date / Time', date),
                  _detailRow('Status', _status(item)),
                  _detailRow(
                    'Decision reason',
                    _value(
                      item,
                      ['rejection_reason', 'remarks', 'reason'],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
