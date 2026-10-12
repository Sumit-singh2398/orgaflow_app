import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AssetManagerReportsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  /// Backend se aaye asset records.
  ///
  /// Har record mein kam se kam `status` hona chahiye.
  /// Example: [{'status': 'Assigned'}, {'status': 'Maintenance'}]
  final List<Map<String, dynamic>>? assets;

  /// Backend se aaye asset history records.
  ///
  /// Example: [{'action': 'assigned', 'date': '2026-10-12'}]
  /// `action`: assigned / removed / maintenance
  final List<Map<String, dynamic>>? activityRecords;

  const AssetManagerReportsPage({
    super.key,
    this.userData,
    this.assets,
    this.activityRecords,
  });

  static const Color _primary = Color(0xFF3157D5);
  static const Color _green = Color(0xFF16834B);
  static const Color _orange = Color(0xFFB26A00);
  static const Color _red = Color(0xFFC62828);
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _pageBackground = Color(0xFFF7F8FC);
  static const Color _border = Color(0xFFE9ECF3);

  @override
  Widget build(BuildContext context) {
    final hasAssetData = assets != null;
    final hasActivityData = activityRecords != null;

    final assignedCount = _countAssets(
      assets,
      const {'assigned', 'in use', 'in-use'},
    );

    final maintenanceCount = _countAssets(
      assets,
      const {'maintenance', 'under maintenance', 'in maintenance'},
    );

    final removedCount = _countEvents(
      activityRecords,
      const {'removed', 'returned', 'unassigned', 'assignment_removed'},
    );

    final assignedEvents = _countEvents(
      activityRecords,
      const {'assigned', 'assignment', 'asset_assigned'},
    );

    final maintenanceEvents = _countEvents(
      activityRecords,
      const {'maintenance', 'sent_for_maintenance', 'maintenance_started'},
    );

    final monthlyData = _buildMonthlyData(activityRecords);

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildHeader(),
                    const SizedBox(height: 22),

                    if (!hasAssetData && !hasActivityData)
                      _buildNoDataCard(
                        title: 'Report data not connected',
                        message:
                            'Pass asset and activity records from your backend '
                            'to see live counts and charts here.',
                        icon: Icons.cloud_off_outlined,
                      )
                    else ...[
                      _buildSectionTitle('Current asset status'),
                      const SizedBox(height: 12),
                      if (hasAssetData)
                        _buildSummaryCards(
                          totalAssets: assets!.length,
                          assigned: assignedCount,
                          maintenance: maintenanceCount,
                        )
                      else
                        _buildNoDataCard(
                          title: 'Asset status unavailable',
                          message:
                              'Provide asset records to calculate current '
                              'assigned and maintenance counts.',
                          icon: Icons.inventory_2_outlined,
                        ),
                      const SizedBox(height: 22),
                      _buildSectionTitle('Assignment activity'),
                      const SizedBox(height: 12),
                      if (hasActivityData)
                        _buildActivityChart(
                          assigned: assignedEvents,
                          removed: removedCount,
                        )
                      else
                        _buildNoDataCard(
                          title: 'Assignment history unavailable',
                          message:
                              'Provide assignment and removal history from '
                              'your backend to show this chart.',
                          icon: Icons.bar_chart_rounded,
                        ),
                      const SizedBox(height: 22),
                      _buildSectionTitle('Monthly activity'),
                      const SizedBox(height: 12),
                      if (hasActivityData && monthlyData.isNotEmpty)
                        _buildMonthlyChart(monthlyData)
                      else
                        _buildNoDataCard(
                          title: 'Monthly history unavailable',
                          message:
                              'Monthly chart needs dated activity records '
                              'from your backend.',
                          icon: Icons.show_chart_rounded,
                        ),
                      const SizedBox(height: 22),
                      _buildSectionTitle('Maintenance activity'),
                      const SizedBox(height: 12),
                      if (hasActivityData)
                        _buildMaintenanceCard(maintenanceEvents)
                      else
                        _buildNoDataCard(
                          title: 'Maintenance history unavailable',
                          message:
                              'Provide maintenance activity records from '
                              'your backend to show this report.',
                          icon: Icons.build_outlined,
                        ),
                    ],
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Reports',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Live overview of asset status and activity.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSummaryCards({
    required int totalAssets,
    required int assigned,
    required int maintenance,
  }) {
    return Column(
      children: [
        _SummaryCard(
          title: 'Total assets',
          count: totalAssets,
          icon: Icons.inventory_2_outlined,
          color: _primary,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Assigned',
                count: assigned,
                icon: Icons.assignment_ind_outlined,
                color: _green,
                compact: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: 'Maintenance',
                count: maintenance,
                icon: Icons.build_outlined,
                color: _orange,
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityChart({
    required int assigned,
    required int removed,
  }) {
    final maxValue = _safeMaxValue([assigned, removed]);

    return _ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned vs removed',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Based on recorded asset activity',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                maxY: maxValue.toDouble(),
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _safeInterval(maxValue),
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFEDF0F5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: _safeInterval(maxValue),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final label = value.toInt() == 0
                            ? 'Assigned'
                            : value.toInt() == 1
                                ? 'Removed'
                                : '';

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _barGroup(0, assigned, _primary),
                  _barGroup(1, removed, _red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _chartLegend([
            _LegendItem(label: 'Assigned', color: _primary),
            _LegendItem(label: 'Removed', color: _red),
          ]),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, int count, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: count.toDouble(),
          color: color,
          width: 28,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(7),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(List<_MonthActivity> data) {
    final maxValue = _safeMaxValue(
      data.map((item) => item.total).toList(),
    );

    return _ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity over time',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Assignments, removals and maintenance',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxValue.toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _safeInterval(maxValue),
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFEDF0F5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _safeInterval(maxValue),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[index].label,
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  _line(data, (item) => item.assigned, _primary),
                  _line(data, (item) => item.removed, _red),
                  _line(data, (item) => item.maintenance, _orange),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _chartLegend([
            _LegendItem(label: 'Assigned', color: _primary),
            _LegendItem(label: 'Removed', color: _red),
            _LegendItem(label: 'Maintenance', color: _orange),
          ]),
        ],
      ),
    );
  }

  LineChartBarData _line(
    List<_MonthActivity> data,
    int Function(_MonthActivity) valueOf,
    Color color,
  ) {
    return LineChartBarData(
      spots: [
        for (var index = 0; index < data.length; index++)
          FlSpot(index.toDouble(), valueOf(data[index]).toDouble()),
      ],
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildMaintenanceCard(int count) {
    return _ChartCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.build_outlined,
              color: _orange,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Assets sent for maintenance',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              color: _orange,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _textSecondary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(List<_LegendItem> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  int _countAssets(
    List<Map<String, dynamic>>? records,
    Set<String> acceptedStatuses,
  ) {
    if (records == null) return 0;

    return records.where((record) {
      final status = _normalize(record['status'] ?? record['assetStatus']);
      return acceptedStatuses.contains(status);
    }).length;
  }

  int _countEvents(
    List<Map<String, dynamic>>? records,
    Set<String> acceptedActions,
  ) {
    if (records == null) return 0;

    return records.where((record) {
      final action = _normalize(
        record['action'] ??
            record['event'] ??
            record['type'] ??
            record['status'],
      );
      return acceptedActions.contains(action);
    }).length;
  }

  List<_MonthActivity> _buildMonthlyData(
    List<Map<String, dynamic>>? records,
  ) {
    if (records == null || records.isEmpty) return [];

    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final date = DateTime(now.year, now.month - 5 + index);
      return _MonthActivity(
        year: date.year,
        month: date.month,
        label: _monthLabel(date.month),
      );
    });

    for (final record in records) {
      final action = _normalize(
        record['action'] ??
            record['event'] ??
            record['type'] ??
            record['status'],
      );
      final date = _parseDate(
        record['date'] ??
            record['createdAt'] ??
            record['created_at'] ??
            record['timestamp'],
      );

      if (date == null) continue;

      final monthData = months.where(
        (item) => item.year == date.year && item.month == date.month,
      );

      if (monthData.isEmpty) continue;

      final item = monthData.first;

      if ({
        'assigned',
        'assignment',
        'asset_assigned',
      }.contains(action)) {
        item.assigned++;
      } else if ({
        'removed',
        'returned',
        'unassigned',
        'assignment_removed',
      }.contains(action)) {
        item.removed++;
      } else if ({
        'maintenance',
        'sent_for_maintenance',
        'maintenance_started',
      }.contains(action)) {
        item.maintenance++;
      }
    }

    return months;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _normalize(dynamic value) {
    return value
            ?.toString()
            .trim()
            .toLowerCase()
            .replaceAll('-', '_') ??
        '';
  }

  String _monthLabel(int month) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return labels[month - 1];
  }

  int _safeMaxValue(List<int> values) {
    final maxValue = values.fold<int>(
      0,
      (current, value) => value > current ? value : current,
    );
    return maxValue == 0 ? 1 : maxValue;
  }

  double _safeInterval(int maxValue) {
    if (maxValue <= 5) return 1;
    return (maxValue / 4).ceilToDouble();
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool compact;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 13 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF3)),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 36 : 42,
            height: compact ? 36 : 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: compact ? 19 : 22,
            ),
          ),
          SizedBox(width: compact ? 9 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: compact ? 19 : 23,
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
}

class _ChartCard extends StatelessWidget {
  final Widget child;

  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECF3)),
      ),
      child: child,
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });
}

class _MonthActivity {
  final int year;
  final int month;
  final String label;
  int assigned = 0;
  int removed = 0;
  int maintenance = 0;

  _MonthActivity({
    required this.year,
    required this.month,
    required this.label,
  });

  int get total => assigned + removed + maintenance;
}