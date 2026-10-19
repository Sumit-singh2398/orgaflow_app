import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssetManagerDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerDashboardScreen({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerDashboardScreen> createState() =>
      _AssetManagerDashboardScreenState();
}

// Compatibility alias if another file uses AssetManagerDashboard.
typedef AssetManagerDashboard = AssetManagerDashboardScreen;

class _AssetManagerDashboardScreenState
    extends State<AssetManagerDashboardScreen> {
  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _summary = {};
  List<dynamic> _activities = [];

  String get _baseUrl {
    final configuredUrl = widget.userData?['baseUrl'] ??
        widget.userData?['apiBaseUrl'] ??
        widget.userData?['api_url'];

    final value = configuredUrl?.toString().trim();

    if (value != null && value.isNotEmpty) {
      return value.replaceAll(RegExp(r'/+$'), '');
    }

    // For Flutter Web / Windows on the same computer.
    // Android emulator: use http://10.0.2.2:8000
    // Physical phone: use http://YOUR_COMPUTER_IP:8000
    return 'http://127.0.0.1:8000';
    
  }

  String get _token {
    return (widget.userData?['token'] ??
            widget.userData?['access_token'] ??
            widget.userData?['accessToken'] ??
            '')
        .toString();
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/dashboard/summary'),
            headers: {
              'Accept': 'application/json',
              if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Server returned ${response.statusCode}. '
          'Check your backend API and login token.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('The dashboard API returned an unexpected response.');
      }

      final root = Map<String, dynamic>.from(decoded);
      final nested = root['data'];

      final summary = nested is Map
          ? Map<String, dynamic>.from(nested)
          : root;

      final activityData = summary['recent_activity'] ??
          summary['recentActivity'] ??
          summary['activities'] ??
          summary['recent_logs'] ??
          summary['recentLogs'] ??
          root['recent_activity'] ??
          root['activities'] ??
          [];

      if (!mounted) return;

      setState(() {
        _summary = summary;
        _activities = activityData is List ? activityData : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  num _number(List<String> keys) {
    for (final key in keys) {
      final value = _summary[key];

      if (value is num) return value;
      if (value != null) {
        final parsed = num.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
    }

    return 0;
  }

  String _displayNumber(List<String> keys) {
    return _number(keys).toInt().toString();
  }

  String _activityValue(dynamic item, List<String> keys) {
    if (item is! Map) return '';

    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  String _activityTitle(dynamic item) {
    return _activityValue(item, [
      'description',
      'message',
      'action',
      'event',
      'title',
      'activity_type',
      'activityType',
    ]).replaceAll('_', ' ');
  }

  String _activitySubtitle(dynamic item) {
    final actor = _activityValue(item, [
      'actor_name',
      'actorName',
      'user_name',
      'userName',
      'performed_by',
      'performedBy',
      'username',
    ]);

    final created = _activityValue(item, [
      'created_at',
      'createdAt',
      'timestamp',
      'date',
      'time',
    ]);

    if (actor.isNotEmpty && created.isNotEmpty) {
      return '$actor • $created';
    }
    if (actor.isNotEmpty) return actor;
    if (created.isNotEmpty) return created;

    return 'Activity recorded';
  }

  IconData _activityIcon(String value) {
    final text = value.toLowerCase();

    if (text.contains('assign')) return Icons.assignment_ind_outlined;
    if (text.contains('approv')) return Icons.check_circle_outline;
    if (text.contains('reject')) return Icons.cancel_outlined;
    if (text.contains('transfer')) return Icons.swap_horiz_rounded;
    if (text.contains('mainten')) return Icons.build_outlined;
    if (text.contains('delete') || text.contains('retire')) {
      return Icons.inventory_2_outlined;
    }
    if (text.contains('login')) return Icons.login_rounded;
    if (text.contains('request')) return Icons.pending_actions_rounded;

    return Icons.history_rounded;
  }

  Color _activityColor(String value) {
    final text = value.toLowerCase();

    if (text.contains('reject') || text.contains('delete')) {
      return Colors.red;
    }
    if (text.contains('approv') || text.contains('complete')) {
      return Colors.green;
    }
    if (text.contains('mainten') || text.contains('pending')) {
      return Colors.orange;
    }

    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth < 600 ? 16 : 28,
                    20,
                    screenWidth < 600 ? 16 : 28,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isWide),
                      const SizedBox(height: 24),
                      _buildWelcomeCard(),
                      const SizedBox(height: 26),
                      _buildSectionHeader(
                        'Asset Overview',
                        'Live counts from your backend',
                      ),
                      const SizedBox(height: 14),
                      if (_loading && _summary.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                        )
                      else if (_error != null && _summary.isEmpty)
                        _buildErrorCard()
                      else
                        _buildMetricGrid(screenWidth),
                      const SizedBox(height: 26),
                      _buildSectionHeader(
                        'Request Overview',
                        'Assignment request status',
                      ),
                      const SizedBox(height: 14),
                      _buildRequestOverview(screenWidth),
                      const SizedBox(height: 26),
                      _buildSectionHeader(
                        'Operations',
                        'Transfers and maintenance',
                      ),
                      const SizedBox(height: 14),
                      _buildOperationsGrid(screenWidth),
                      const SizedBox(height: 26),
                      _buildSectionHeader(
                        'Recent Activity',
                        'Latest events recorded by the system',
                      ),
                      const SizedBox(height: 14),
                      _buildRecentActivity(),
                      const SizedBox(height: 20),
                      if (_error != null && _summary.isNotEmpty)
                        _buildSmallError(),
                      Center(
                        child: Text(
                          'Orgaflow Asset Management',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _loadDashboard,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Refresh dashboard',
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    final userName = (widget.userData?['name'] ??
            widget.userData?['full_name'] ??
            widget.userData?['username'] ??
            'Asset Manager')
        .toString();

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asset Manager',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172033),
                ),
              ),
              Text(
                'Welcome, $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadDashboard,
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF667EEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor assets, requests, transfers and maintenance '
                  'from one place.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadDashboard,
                  icon: const Icon(Icons.sync_rounded, size: 17),
                  label: const Text('Refresh data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.query_stats_rounded,
            size: 70,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricGrid(double screenWidth) {
    final columns = screenWidth >= 1200
        ? 4
        : screenWidth >= 650
            ? 2
            : 2;

    final cards = <_MetricData>[
      _MetricData(
        title: 'Total Assets',
        value: _displayNumber([
          'total_assets',
          'totalAssets',
          'assets_total',
          'assets_count',
        ]),
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF3B5BDB),
      ),
      _MetricData(
        title: 'Assigned Assets',
        value: _displayNumber([
          'assigned_assets',
          'assignedAssets',
          'total_assigned',
          'assigned_count',
        ]),
        icon: Icons.assignment_ind_outlined,
        color: const Color(0xFF0D9488),
      ),
      _MetricData(
        title: 'Available Assets',
        value: _displayNumber([
          'available_assets',
          'availableAssets',
          'unassigned_assets',
          'unassignedAssets',
        ]),
        icon: Icons.inventory_outlined,
        color: const Color(0xFF2563EB),
      ),
      _MetricData(
        title: 'Under Maintenance',
        value: _displayNumber([
          'assets_under_maintenance',
          'under_maintenance',
          'underMaintenance',
          'maintenance_assets',
        ]),
        icon: Icons.build_circle_outlined,
        color: const Color(0xFFD97706),
      ),
      _MetricData(
        title: 'Inactive / Retired',
        value: _displayNumber([
          'inactive_assets',
          'inactiveAssets',
          'retired_assets',
          'retiredAssets',
        ]),
        icon: Icons.inventory_rounded,
        color: const Color(0xFF64748B),
      ),
      _MetricData(
        title: 'Total Requests',
        value: _displayNumber([
          'total_requests',
          'totalRequests',
          'requests_total',
        ]),
        icon: Icons.assignment_outlined,
        color: const Color(0xFF7C3AED),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _buildMetricCard(item),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMetricCard(_MetricData item) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestOverview(double screenWidth) {
    final items = <_StatusData>[
      _StatusData(
        'Approved',
        _displayNumber([
          'approved_requests',
          'approvedRequests',
          'requests_approved',
        ]),
        Colors.green,
        Icons.check_circle_outline,
      ),
      _StatusData(
        'Pending',
        _displayNumber([
          'pending_requests',
          'pendingRequests',
          'requests_pending',
        ]),
        Colors.orange,
        Icons.hourglass_top_rounded,
      ),
      _StatusData(
        'Rejected',
        _displayNumber([
          'rejected_requests',
          'rejectedRequests',
          'requests_rejected',
        ]),
        Colors.red,
        Icons.cancel_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {

        return Row(
          children: items.map((item) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8ECF4)),
                ),
                child: Column(
                  children: [
                    Icon(item.icon, color: item.color, size: 23),
                    const SizedBox(height: 10),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 19 : 23,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOperationsGrid(double screenWidth) {
    final items = <_MetricData>[
      _MetricData(
        title: 'Total Transfers',
        value: _displayNumber([
          'total_transfers',
          'totalTransfers',
          'transfers_count',
          'transfer_count',
        ]),
        icon: Icons.swap_horiz_rounded,
        color: const Color(0xFF0D9488),
      ),
      _MetricData(
        title: 'Open Maintenance',
        value: _displayNumber([
          'open_maintenance',
          'openMaintenance',
          'maintenance_open',
          'pending_maintenance',
        ]),
        icon: Icons.build_outlined,
        color: const Color(0xFFD97706),
      ),
      _MetricData(
        title: 'Completed Maintenance',
        value: _displayNumber([
          'completed_maintenance',
          'completedMaintenance',
          'maintenance_completed',
        ]),
        icon: Icons.task_alt_rounded,
        color: const Color(0xFF16A34A),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 3 : 2;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _buildMetricCard(item),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    if (_loading && _activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8ECF4)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 38,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            const Text(
              'No recent activity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Activity will appear here when the backend records events.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final visibleActivities = _activities.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Column(
        children: List.generate(visibleActivities.length, (index) {
          final item = visibleActivities[index];
          final title = _activityTitle(item);
          final displayTitle =
              title.isEmpty ? 'Activity recorded' : title;
          final color = _activityColor(displayTitle);

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _activityIcon(displayTitle),
                    color: color,
                    size: 21,
                  ),
                ),
                title: Text(
                  displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _activitySubtitle(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                ),
              ),
              if (index != visibleActivities.length - 1)
                const Divider(
                  height: 1,
                  indent: 70,
                  endIndent: 14,
                  color: Color(0xFFF0F2F7),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Colors.red.shade400,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Refresh failed: $_error',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.shade800,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadDashboard,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _StatusData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatusData(
    this.title,
    this.value,
    this.color,
    this.icon,
  );
}
