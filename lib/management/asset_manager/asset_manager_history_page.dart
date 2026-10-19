
import 'dart:async';
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
  static const Color primary = Color(0xFF3B5BDB);
  static const Color background = Color(0xFFF4F6FB);
  static const Color ink = Color(0xFF172033);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE7EBF3);

  bool loading = false;
  String? error;
  String search = '';
  String selectedFilter = 'All';

  List<Map<String, dynamic>> assets = [];
  List<Map<String, dynamic>> assignments = [];
  List<Map<String, dynamic>> logs = [];

  // Set baseUrl in userData to override this default.
  String get baseUrl {
    final value = widget.userData?['baseUrl'] ??
        widget.userData?['apiBaseUrl'] ??
        widget.userData?['api_base_url'] ??
        'http://127.0.0.1:8000';

    return value.toString().trim().replaceAll(RegExp(r'/+$'), '');
  }

  String get token {
    return (widget.userData?['token'] ??
            widget.userData?['access_token'] ??
            widget.userData?['accessToken'] ??
            '')
        .toString()
        .trim();
  }

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // Supports APIs that return a list directly or inside a named key.
  List<Map<String, dynamic>> extractList(
    dynamic data,
    List<String> keys,
  ) {
    dynamic value = data;

    if (data is Map) {
      for (final key in keys) {
        if (data[key] is List) {
          value = data[key];
          break;
        }
      }
    }

    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getList(
    String path,
    List<String> keys,
  ) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl$path'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpExceptionMessage(
        'GET $path failed (${response.statusCode})',
        response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    return extractList(decoded, keys);
  }

  Future<void> loadDashboard() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    if (token.isEmpty) {
      setState(() {
        loading = false;
        error = 'Login token missing. Please log in again.';
      });
      return;
    }

    // Each endpoint is loaded independently, so one unavailable
    // endpoint does not prevent other dashboard data from appearing.
    final results = await Future.wait([
      _safeLoad('/api/assets', ['assets', 'items', 'data']),
      _safeLoad(
        '/api/assets/assignments',
        ['assignments', 'items', 'data', 'requests'],
      ),
      _safeLoad(
        '/api/audit-logs',
        ['logs', 'items', 'history', 'activities'],
      ),
    ]);

    if (!mounted) return;

    setState(() {
      assets = results[0].data;
      assignments = results[1].data;
      logs = results[2].data;
      loading = false;

      final failures = results.where((r) => r.error != null).toList();
      if (failures.length == results.length) {
        error = failures.first.error;
      } else if (failures.isNotEmpty) {
        error = 'Some data could not be loaded. Check your API routes '
            'and permissions.';
      }
    });
  }

  Future<_LoadResult> _safeLoad(
    String path,
    List<String> keys,
  ) async {
    try {
      return _LoadResult(
        data: await getList(path, keys),
      );
    } catch (e) {
      return _LoadResult(
        data: [],
        error: e.toString(),
      );
    }
  }

  String str(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  String firstValue(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  String statusOf(Map<String, dynamic> item) {
    return firstValue(
      item,
      [
        'status',
        'asset_status',
        'request_status',
        'approval_status',
        'maintenance_status',
        'state',
      ],
      fallback: 'unknown',
    ).toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');
  }

  bool hasStatus(
    Map<String, dynamic> item,
    List<String> words,
  ) {
    final status = statusOf(item);
    return words.any((word) => status.contains(word));
  }

  bool isApproved(Map<String, dynamic> item) =>
      hasStatus(item, ['approved', 'accepted']);

  bool isPending(Map<String, dynamic> item) =>
      hasStatus(item, ['pending', 'awaiting', 'requested', 'in review']);

  bool isRejected(Map<String, dynamic> item) =>
      hasStatus(item, ['rejected', 'declined', 'denied']);

  bool isMaintenance(Map<String, dynamic> item) {
    final status = statusOf(item);
    return status.contains('maintenance') ||
        status.contains('under repair') ||
        status.contains('repairing');
  }

  bool isAssigned(Map<String, dynamic> item) {
    final status = statusOf(item);
    return status.contains('assigned') ||
        status.contains('in use') ||
        status.contains('issued');
  }

  bool isAvailable(Map<String, dynamic> item) {
    final status = statusOf(item);
    return status.contains('available') ||
        status.contains('in stock') ||
        status == 'active';
  }

  bool isCompleted(Map<String, dynamic> item) {
    final status = statusOf(item);
    return status.contains('completed') ||
        status.contains('resolved') ||
        status.contains('finished');
  }

  bool actionMatches(Map<String, dynamic> item, List<String> words) {
    final action = firstValue(
      item,
      ['action', 'event', 'type', 'details', 'description'],
    ).toLowerCase();

    return words.any((word) => action.contains(word));
  }

  int get totalAssets => assets.length;

  int get assignedAssets {
    final ids = <String>{};

    for (final a in assets) {
      if (isAssigned(a)) {
        ids.add(assetIdentity(a));
      }
    }

    for (final a in assignments) {
      if (isAssigned(a)) {
        ids.add(assetIdentity(a));
      }
    }

    ids.remove('');
    return ids.length;
  }

  String assetIdentity(Map<String, dynamic> item) {
    return firstValue(
      item,
      ['asset_id', 'assetId', 'asset_code', 'asset_code_id', 'id'],
    );
  }

  int get approvedCount => assignments.where(isApproved).length;
  int get pendingCount => assignments.where(isPending).length;
  int get rejectedCount => assignments.where(isRejected).length;

  int get maintenanceCount {
    final ids = <String>{};

    for (final item in assets.where(isMaintenance)) {
      ids.add(assetIdentity(item));
    }

    ids.remove('');
    return ids.isNotEmpty
        ? ids.length
        : assets.where(isMaintenance).length;
  }

  int get availableCount => assets.where(isAvailable).length;

  int get completedMaintenanceCount => logs.where((item) {
        return actionMatches(item, ['maintenance']) &&
            (isCompleted(item) ||
                actionMatches(item, [
                  'completed',
                  'resolved',
                  'maintenance_complete',
                ]));
      }).length;

  int get transferCount => logs
      .where((item) => actionMatches(item, ['transfer']))
      .length;

  int get assignmentActivityCount => logs
      .where((item) => actionMatches(item, ['assign']))
      .length;

  int get creationCount => logs
      .where((item) => actionMatches(item, ['create', 'asset added']))
      .length;

  DateTime dateOf(Map<String, dynamic> item) {
    final value = firstValue(
      item,
      ['created_at', 'timestamp', 'date', 'updated_at'],
    );

    return DateTime.tryParse(value)?.toLocal() ??
        DateTime(2000);
  }

  String formatDate(Map<String, dynamic> item) {
    final date = dateOf(item);
    if (date.year == 2000) return 'Date unavailable';

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day.toString().padLeft(2, '0')} '
        '${monthName(date.month)} ${date.year}, $hour:$minute $period';
  }

  String monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  String actorOf(Map<String, dynamic> item) {
    return firstValue(
      item,
      [
        'actor_name',
        'performed_by',
        'reviewed_by',
        'user_name',
        'actor_email',
        'email',
      ],
      fallback: 'System user',
    );
  }

  String titleOf(Map<String, dynamic> item) {
    final raw = firstValue(
      item,
      ['action', 'event', 'type'],
      fallback: 'Activity recorded',
    );

    return raw
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String descriptionOf(Map<String, dynamic> item) {
    final value = item['details'] ??
        item['description'] ??
        item['message'];

    if (value == null) {
      return 'An activity was recorded in the system.';
    }

    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }

    final textValue = value.toString().trim();

    try {
      final decoded = jsonDecode(textValue);
      if (decoded is Map || decoded is List) {
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (_) {}

    return textValue.isEmpty
        ? 'An activity was recorded in the system.'
        : textValue;
  }

  IconData iconFor(String value) {
    final s = value.toLowerCase();
    if (s.contains('approve')) return Icons.check_circle_outline_rounded;
    if (s.contains('reject')) return Icons.cancel_outlined;
    if (s.contains('maintenance') || s.contains('repair')) {
      return Icons.build_circle_outlined;
    }
    if (s.contains('transfer')) return Icons.swap_horiz_rounded;
    if (s.contains('assign')) return Icons.assignment_ind_outlined;
    if (s.contains('delete')) return Icons.delete_outline_rounded;
    if (s.contains('create') || s.contains('add')) {
      return Icons.add_box_outlined;
    }
    if (s.contains('update') || s.contains('edit')) {
      return Icons.edit_note_rounded;
    }
    return Icons.history_rounded;
  }

  Color colorFor(String value) {
    final s = value.toLowerCase();
    if (s.contains('reject') || s.contains('delete')) {
      return const Color(0xFFDC2626);
    }
    if (s.contains('approve') || s.contains('complete')) {
      return const Color(0xFF059669);
    }
    if (s.contains('maintenance') || s.contains('repair')) {
      return const Color(0xFFD97706);
    }
    if (s.contains('transfer') || s.contains('assign')) {
      return const Color(0xFF7C3AED);
    }
    return primary;
  }

  List<Map<String, dynamic>> get visibleLogs {
    final query = search.trim().toLowerCase();

    final sorted = [...logs]
      ..sort((a, b) => dateOf(b).compareTo(dateOf(a)));

    return sorted.where((item) {
      final title = titleOf(item).toLowerCase();
      final details = descriptionOf(item).toLowerCase();
      final actor = actorOf(item).toLowerCase();
      final matchesSearch = query.isEmpty ||
          title.contains(query) ||
          details.contains(query) ||
          actor.contains(query);

      final action = firstValue(
        item,
        ['action', 'event', 'type', 'details'],
      ).toLowerCase();

      final matchesFilter = switch (selectedFilter) {
        'Approvals' => action.contains('approv'),
        'Rejections' => action.contains('reject'),
        'Maintenance' => action.contains('maintenance') ||
            action.contains('repair'),
        'Transfers' => action.contains('transfer'),
        'Assignments' => action.contains('assign'),
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Asset Manager History',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loading ? null : loadDashboard,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            _hero(),
            const SizedBox(height: 20),
            if (error != null) _warning(error!),
            if (loading && assets.isEmpty && logs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(color: primary),
                ),
              )
            else ...[
              _sectionTitle('Asset Overview', 'Live counts from API data'),
              const SizedBox(height: 12),
              _metricGrid([
                _Metric('Total Assets', totalAssets, Icons.inventory_2_outlined,
                    primary),
                _Metric('Assigned Assets', assignedAssets,
                    Icons.assignment_ind_outlined, const Color(0xFF7C3AED)),
                _Metric('Available', availableCount,
                    Icons.check_circle_outline, const Color(0xFF059669)),
                _Metric('Under Maintenance', maintenanceCount,
                    Icons.build_circle_outlined, const Color(0xFFD97706)),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Requests & Approvals', 'Request status summary'),
              const SizedBox(height: 12),
              _metricGrid([
                _Metric('Approved', approvedCount,
                    Icons.verified_outlined, const Color(0xFF059669)),
                _Metric('Pending', pendingCount,
                    Icons.hourglass_top_rounded, const Color(0xFFD97706)),
                _Metric('Rejected', rejectedCount,
                    Icons.cancel_outlined, const Color(0xFFDC2626)),
                _Metric('Assignments', assignmentActivityCount,
                    Icons.assignment_turned_in_outlined,
                    const Color(0xFF7C3AED)),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Maintenance & Transfers', 'Recorded operations'),
              const SizedBox(height: 12),
              _metricGrid([
                _Metric('Maintenance Assets', maintenanceCount,
                    Icons.home_repair_service_outlined,
                    const Color(0xFFD97706)),
                _Metric('Maintenance Completed', completedMaintenanceCount,
                    Icons.task_alt_rounded, const Color(0xFF059669)),
                _Metric('Transfers Recorded', transferCount,
                    Icons.swap_horiz_rounded, const Color(0xFF2563EB)),
                _Metric('Assets Created (Logs)', creationCount,
                    Icons.add_box_outlined, const Color(0xFF0D9488)),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Asset Status Breakdown', 'Current asset records'),
              const SizedBox(height: 12),
              _statusBreakdown(),
              const SizedBox(height: 26),
              _sectionTitle('Complete Activity History',
                  '${visibleLogs.length} recorded activities'),
              const SizedBox(height: 12),
              _searchBox(),
              const SizedBox(height: 12),
              _filterBar(),
              const SizedBox(height: 16),
              if (visibleLogs.isEmpty)
                _emptyState()
              else
                ...visibleLogs.map(_activityCard),
            ],
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Orgaflow • Asset Management System',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    final managerName = firstValue(
      widget.userData ?? {},
      ['name', 'full_name', 'username', 'email'],
      fallback: 'Asset Manager',
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF304CCB), Color(0xFF7087F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asset Control Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Welcome, $managerName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.shield_outlined, color: Colors.white, size: 27),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: muted),
        ),
      ],
    );
  }

  Widget _metricGrid(List<_Metric> metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
                ? 2
                : 2;

        final width =
            (constraints.maxWidth - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics
              .map((metric) => SizedBox(
                    width: width,
                    child: _metricCard(metric),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _metricCard(_Metric metric) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: metric.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, color: metric.color, size: 21),
          ),
          const SizedBox(height: 13),
          Text(
            '${metric.value}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBreakdown() {
    final rows = <(String, int, Color)>[
      ('Available', availableCount, const Color(0xFF059669)),
      ('Assigned / In Use', assignedAssets, const Color(0xFF7C3AED)),
      ('Under Maintenance', maintenanceCount, const Color(0xFFD97706)),
    ];

    final denominator = totalAssets == 0 ? 1 : totalAssets;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: rows.map((row) {
          final ratio = (row.$2 / denominator).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.$1,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${row.$2}',
                      style: TextStyle(
                        color: row.$3,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEF1F6),
                    valueColor: AlwaysStoppedAnimation<Color>(row.$3),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      onChanged: (value) => setState(() => search = value),
      decoration: InputDecoration(
        hintText: 'Search action, details or user...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
      ),
    );
  }

  Widget _filterBar() {
    const filters = [
      'All',
      'Approvals',
      'Rejections',
      'Maintenance',
      'Transfers',
      'Assignments',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final active = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: active,
              onSelected: (_) =>
                  setState(() => selectedFilter = filter),
              selectedColor: primary.withOpacity(0.13),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: active ? primary : border,
              ),
              labelStyle: TextStyle(
                color: active ? primary : muted,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _activityCard(Map<String, dynamic> item) {
    final title = titleOf(item);
    final color = colorFor(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(iconFor(title), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  descriptionOf(item),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _smallMeta(Icons.person_outline, actorOf(item)),
                    _smallMeta(Icons.schedule_rounded, formatDate(item)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallMeta(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: muted),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: muted),
          ),
        ),
      ],
    );
  }

  Widget _warning(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB45309)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: loading ? null : loadDashboard,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, size: 46, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'No matching activities',
            style: TextStyle(
              fontSize: 15,
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Activities will appear here when the backend records them.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Metric {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _Metric(this.label, this.value, this.icon, this.color);
}

class _LoadResult {
  final List<Map<String, dynamic>> data;
  final String? error;

  const _LoadResult({
    required this.data,
    this.error,
  });
}

class HttpExceptionMessage implements Exception {
  final String message;
  final int statusCode;

  const HttpExceptionMessage(this.message, this.statusCode);

  @override
  String toString() => message;
}
