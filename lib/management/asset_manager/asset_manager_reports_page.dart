
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetManagerReportsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final List<Map<String, dynamic>>? assets;
  final List<Map<String, dynamic>>? activityRecords;

  /// Parent page se actual API refresh function pass kar sakte ho.
  final Future<void> Function()? onRefresh;

  const AssetManagerReportsPage({
    super.key,
    this.userData,
    this.assets,
    this.activityRecords,
    this.onRefresh,
  });

  @override
  State<AssetManagerReportsPage> createState() =>
      _AssetManagerReportsPageState();
}

class _AssetManagerReportsPageState
    extends State<AssetManagerReportsPage> {
  static const Color primary = Color(0xFF3157D5);
  static const Color green = Color(0xFF16834B);
  static const Color orange = Color(0xFFB26A00);
  static const Color red = Color(0xFFC62828);
  static const Color purple = Color(0xFF7C4DFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color pageBackground = Color(0xFFF7F8FC);
  static const Color border = Color(0xFFE9ECF3);

  String selectedPeriod = '6 Months';
  String selectedTab = 'Overview';
  String searchQuery = '';
  bool refreshing = false;

  List<Map<String, dynamic>> get allAssets =>
      widget.assets ?? const [];

  List<Map<String, dynamic>> get allActivities =>
      widget.activityRecords ?? const [];

  String normalize(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  String firstValue(
    Map<String, dynamic> record,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = record[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  String assetStatus(Map<String, dynamic> record) {
    return normalize(firstValue(record, [
      'status',
      'assetStatus',
      'asset_status',
    ]));
  }

  String activityAction(Map<String, dynamic> record) {
    return normalize(firstValue(record, [
      'action',
      'event',
      'type',
      'status',
    ]));
  }

  DateTime? activityDate(Map<String, dynamic> record) {
    final value = record['date'] ??
        record['createdAt'] ??
        record['created_at'] ??
        record['timestamp'] ??
        record['updated_at'];

    if (value is DateTime) return value;
    if (value is int) {
      // Unix timestamps can be in seconds or milliseconds.
      return DateTime.fromMillisecondsSinceEpoch(
        value < 1000000000000 ? value * 1000 : value,
      );
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool isAssignedStatus(String status) => {
        'assigned',
        'in_use',
        'in-use',
        'allocated',
      }.contains(status);

  bool isAvailableStatus(String status) => {
        'available',
        'unassigned',
        'in_stock',
        'in stock',
      }.contains(status);

  bool isMaintenanceStatus(String status) => {
        'maintenance',
        'under_maintenance',
        'in_maintenance',
        'in_repair',
      }.contains(status);

  bool isReturnedStatus(String status) => {
        'returned',
        'retired',
        'disposed',
      }.contains(status);

  bool isAssignedAction(String action) => {
        'assigned',
        'assignment',
        'asset_assigned',
        'assignment_created',
      }.contains(action);

  bool isRemovedAction(String action) => {
        'removed',
        'returned',
        'unassigned',
        'assignment_removed',
        'asset_returned',
      }.contains(action);

  bool isMaintenanceAction(String action) => {
        'maintenance',
        'sent_for_maintenance',
        'maintenance_started',
        'maintenance_completed',
      }.contains(action);

  int get assignedCount =>
      allAssets.where((a) => isAssignedStatus(assetStatus(a))).length;

  int get availableCount =>
      allAssets.where((a) => isAvailableStatus(assetStatus(a))).length;

  int get maintenanceCount =>
      allAssets.where((a) => isMaintenanceStatus(assetStatus(a))).length;

  int get returnedCount =>
      allAssets.where((a) => isReturnedStatus(assetStatus(a))).length;

  List<Map<String, dynamic>> get filteredActivities {
    final now = DateTime.now();

    DateTime? start;
    switch (selectedPeriod) {
      case '7 Days':
        start = now.subtract(const Duration(days: 7));
        break;
      case '30 Days':
        start = now.subtract(const Duration(days: 30));
        break;
      case '6 Months':
        start = DateTime(now.year, now.month - 5, 1);
        break;
      case 'All Time':
        start = null;
        break;
    }

    return allActivities.where((record) {
      final date = activityDate(record);

      // Unknown dates are included only in All Time.
      if (start != null && (date == null || date.isBefore(start!))) {
        return false;
      }

      if (searchQuery.trim().isEmpty) return true;

      final searchable = [
        record['action'],
        record['event'],
        record['type'],
        record['status'],
        record['asset_name'],
        record['assetName'],
        record['asset_code'],
        record['assetCode'],
        record['employee_name'],
        record['employeeName'],
        record['name'],
        record['description'],
      ].where((value) => value != null).join(' ').toLowerCase();

      return searchable.contains(searchQuery.trim().toLowerCase());
    }).toList();
  }

  int countEvents(bool Function(String) predicate) {
    return filteredActivities
        .where((record) => predicate(activityAction(record)))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final hasAssetData = widget.assets != null;
    final hasActivityData = widget.activityRecords != null;

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refreshReports,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildFilterBar(),
                    const SizedBox(height: 20),
                    _buildTabSelector(),
                    const SizedBox(height: 20),

                    if (!hasAssetData && !hasActivityData)
                      _buildEmptyState(
                        'Reports are not connected',
                        'Pass asset and activity records from your API to '
                            'display real reports.',
                        Icons.cloud_off_outlined,
                      )
                    else if (selectedTab == 'Overview') ...[
                      _buildSectionHeading('Asset overview'),
                      const SizedBox(height: 12),
                      if (hasAssetData) ...[
                        _buildTotalCard(),
                        const SizedBox(height: 12),
                        _buildStatusCards(),
                        const SizedBox(height: 22),
                        _buildSectionHeading('Asset status distribution'),
                        const SizedBox(height: 12),
                        _buildStatusChart(),
                      ] else
                        _buildEmptyState(
                          'Asset data unavailable',
                          'Provide asset records to calculate status totals.',
                          Icons.inventory_2_outlined,
                        ),
                      const SizedBox(height: 22),
                      _buildSectionHeading('Recent activity summary'),
                      const SizedBox(height: 12),
                      if (hasActivityData)
                        _buildActivitySummary()
                      else
                        _buildEmptyState(
                          'Activity history unavailable',
                          'Provide activity records from the backend.',
                          Icons.history_rounded,
                        ),
                    ] else if (selectedTab == 'Activity') ...[
                      _buildSectionHeading('Activity report'),
                      const SizedBox(height: 12),
                      if (hasActivityData) ...[
                        _buildActivitySummary(),
                        const SizedBox(height: 16),
                        _buildMonthlyChart(),
                        const SizedBox(height: 20),
                        _buildActivityList(),
                      ] else
                        _buildEmptyState(
                          'No activity data connected',
                          'Connect the activity history endpoint to view '
                              'assignments, returns and maintenance.',
                          Icons.history_rounded,
                        ),
                    ] else ...[
                      _buildSectionHeading('Asset status report'),
                      const SizedBox(height: 12),
                      if (hasAssetData) ...[
                        _buildTotalCard(),
                        const SizedBox(height: 12),
                        _buildStatusCards(),
                        const SizedBox(height: 16),
                        _buildStatusChart(),
                        const SizedBox(height: 20),
                        _buildAssetList(),
                      ] else
                        _buildEmptyState(
                          'No asset data connected',
                          'Connect your asset list endpoint.',
                          Icons.inventory_2_outlined,
                        ),
                    ],

                    const SizedBox(height: 24),
                    _buildExportButton(),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Report totals are based on the records supplied '
                        'to this page.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = firstValue(widget.userData ?? {}, [
      'name',
      'full_name',
      'fullName',
    ]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asset Reports',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name.isEmpty
                    ? 'Monitor assets and operational activity.'
                    : 'Hello, $name. Here is your report overview.',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: refreshing ? null : _refreshReports,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: refreshing
                  ? const SizedBox(
                      height: 21,
                      width: 21,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: primary,
                      size: 22,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    const periods = ['7 Days', '30 Days', '6 Months', 'All Time'];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Row(
        children: periods.map((period) {
          final selected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : textSecondary,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabSelector() {
    const tabs = ['Overview', 'Activity', 'Assets'];

    return Row(
      children: tabs.map((tab) {
        final selected = selectedTab == tab;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 7),
            child: OutlinedButton(
              onPressed: () => setState(() => selectedTab = tab),
              style: OutlinedButton.styleFrom(
                backgroundColor: selected ? primary : Colors.white,
                foregroundColor: selected ? Colors.white : textSecondary,
                side: BorderSide(color: selected ? primary : border),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                tab,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3157D5), Color(0xFF5879E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.17),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total registered assets',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'All asset records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            allAssets.length.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'Assigned',
                assignedCount,
                Icons.person_pin_circle_outlined,
                green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                'Available',
                availableCount,
                Icons.inventory_outlined,
                primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'Maintenance',
                maintenanceCount,
                Icons.build_outlined,
                orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                'Returned / retired',
                returnedCount,
                Icons.assignment_return_outlined,
                red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChart() {
    final values = [
      assignedCount,
      availableCount,
      maintenanceCount,
      returnedCount,
    ];
    final colors = [green, primary, orange, red];
    const labels = ['Assigned', 'Available', 'Maintenance', 'Returned'];

    final total = values.fold<int>(0, (sum, value) => sum + value);

    if (total == 0) {
      return _buildEmptyState(
        'No asset statuses to chart',
        'The supplied asset list is empty or has no matching statuses.',
        Icons.pie_chart_outline_rounded,
      );
    }

    return _chartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current asset distribution',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 42,
                sections: List.generate(values.length, (index) {
                  return PieChartSectionData(
                    value: values[index].toDouble(),
                    color: colors[index],
                    radius: 28,
                    showTitle: values[index] > 0,
                    title: '${(values[index] * 100 / total).round()}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(values.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      labels[index],
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${values[index]}',
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivitySummary() {
    final assigned = countEvents(isAssignedAction);
    final removed = countEvents(isRemovedAction);
    final maintenance = countEvents(isMaintenanceAction);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'Assignments',
                assigned,
                Icons.assignment_turned_in_outlined,
                primary,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _metricCard(
                'Returns / removals',
                removed,
                Icons.assignment_return_outlined,
                red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        _metricCard(
          'Maintenance events',
          maintenance,
          Icons.build_outlined,
          orange,
        ),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final date = DateTime(now.year, now.month - 5 + index, 1);
      return _MonthData(date);
    });

    for (final record in filteredActivities) {
      final date = activityDate(record);
      if (date == null) continue;

      final item = months.where(
        (month) =>
            month.date.year == date.year &&
            month.date.month == date.month,
      );

      if (item.isEmpty) continue;

      final month = item.first;
      final action = activityAction(record);

      if (isAssignedAction(action)) {
        month.assigned++;
      } else if (isRemovedAction(action)) {
        month.removed++;
      } else if (isMaintenanceAction(action)) {
        month.maintenance++;
      }
    }

    final maxCount = months.fold<int>(
      0,
      (maxValue, item) => [
        maxValue,
        item.assigned,
        item.removed,
        item.maintenance,
      ].reduce((a, b) => a > b ? a : b),
    );
    final maxY = (maxCount < 4 ? 4 : maxCount + 1).toDouble();

    return _chartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly activity',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Selected period: $selectedPeriod',
            style: const TextStyle(
              color: textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 210,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFEDF0F5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            _monthLabel(months[index].date),
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  _makeLine(months, (m) => m.assigned, primary),
                  _makeLine(months, (m) => m.removed, red),
                  _makeLine(months, (m) => m.maintenance, orange),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _legend('Assigned', primary),
              _legend('Returned / removed', red),
              _legend('Maintenance', orange),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _makeLine(
    List<_MonthData> months,
    int Function(_MonthData) valueOf,
    Color color,
  ) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < months.length; i++)
          FlSpot(i.toDouble(), valueOf(months[i]).toDouble()),
      ],
      isCurved: true,
      color: color,
      barWidth: 2.8,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildActivityList() {
    final records = [...filteredActivities]
      ..sort((a, b) {
        final da = activityDate(a);
        final db = activityDate(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });

    return _chartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity records',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search asset, employee or action',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() => searchQuery = ''),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    )
                  : null,
              filled: true,
              fillColor: pageBackground,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: Text(
                  'No activity records match this filter.',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ),
            )
          else
            ...records.take(100).map(_activityTile),
          if (records.length > 100)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Showing 100 of ${records.length} records.',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _activityTile(Map<String, dynamic> record) {
    final action = activityAction(record);
    final date = activityDate(record);
    final isAssignment = isAssignedAction(action);
    final isMaintenance = isMaintenanceAction(action);
    final color = isAssignment
        ? green
        : isMaintenance
            ? orange
            : red;

    final assetName = firstValue(record, [
      'asset_name',
      'assetName',
      'asset_code',
      'assetCode',
      'name',
    ], fallback: 'Asset activity');

    final employee = firstValue(record, [
      'employee_name',
      'employeeName',
      'user_name',
      'userName',
    ]);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pageBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isAssignment
                  ? Icons.assignment_turned_in_outlined
                  : isMaintenance
                      ? Icons.build_outlined
                      : Icons.history_rounded,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _humanize(action.isEmpty ? 'activity' : action),
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  employee.isEmpty ? assetName : '$assetName • $employee',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            date == null ? 'No date' : _formatDate(date),
            style: const TextStyle(
              color: textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetList() {
    final records = [...allAssets]
      ..sort((a, b) => assetStatus(a).compareTo(assetStatus(b)));

    return _chartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registered assets',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            const Text(
              'No asset records found.',
              style: TextStyle(color: textSecondary, fontSize: 12),
            )
          else
            ...records.take(100).map(_assetTile),
          if (records.length > 100)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Showing 100 of ${records.length} assets.',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _assetTile(Map<String, dynamic> asset) {
    final status = assetStatus(asset);
    final name = firstValue(asset, [
      'name',
      'asset_name',
      'assetName',
      'title',
    ], fallback: 'Unnamed asset');
    final code = firstValue(asset, [
      'asset_code',
      'assetCode',
      'code',
      'tag',
      'serial_number',
    ], fallback: 'No asset code');

    final color = isAssignedStatus(status)
        ? green
        : isAvailableStatus(status)
            ? primary
            : isMaintenanceStatus(status)
                ? orange
                : isReturnedStatus(status)
                    ? red
                    : textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pageBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.devices_other_rounded, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.isEmpty ? 'Unknown' : _humanize(status),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String message,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, color: textSecondary, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _copyCsvReport,
        icon: const Icon(Icons.file_download_outlined),
        label: const Text('Export report as CSV'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _refreshReports() async {
    if (refreshing) return;

    if (widget.onRefresh == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Connect the parent page refresh callback to reload API data.',
          ),
        ),
      );
      return;
    }

    setState(() => refreshing = true);

    try {
      await widget.onRefresh!();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report refresh requested successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not refresh reports: $error')),
      );
    } finally {
      if (mounted) setState(() => refreshing = false);
    }
  }

  Future<void> _copyCsvReport() async {
    final rows = <List<String>>[
      ['ORGAFLOW ASSET REPORT'],
      ['Generated At', DateTime.now().toIso8601String()],
      ['Selected Activity Period', selectedPeriod],
      [],
      ['ASSETS'],
      ['Asset Name', 'Asset Code', 'Status', 'Assigned Employee'],
    ];

    for (final asset in allAssets) {
      rows.add([
        firstValue(asset, ['name', 'asset_name', 'assetName', 'title']),
        firstValue(asset, [
          'asset_code',
          'assetCode',
          'code',
          'tag',
          'serial_number',
        ]),
        firstValue(asset, ['status', 'assetStatus', 'asset_status']),
        firstValue(asset, [
          'employee_name',
          'employeeName',
          'assigned_to',
          'assignedTo',
          'assigned_employee',
        ]),
      ]);
    }

    rows.addAll([
      [],
      ['ACTIVITY HISTORY'],
      ['Action', 'Asset', 'Employee', 'Date', 'Description'],
    ]);

    for (final record in filteredActivities) {
      final date = activityDate(record);
      rows.add([
        firstValue(record, ['action', 'event', 'type', 'status']),
        firstValue(record, [
          'asset_name',
          'assetName',
          'asset_code',
          'assetCode',
        ]),
        firstValue(record, [
          'employee_name',
          'employeeName',
          'user_name',
          'userName',
        ]),
        date?.toIso8601String() ?? '',
        firstValue(record, ['description', 'remarks', 'notes']),
      ]);
    }

    String escapeCell(String value) {
      final escaped = value.replaceAll('"', '""');
      if (escaped.contains(',') ||
          escaped.contains('"') ||
          escaped.contains('\n') ||
          escaped.contains('\r')) {
        return '"$escaped"';
      }
      return escaped;
    }

    final csv = rows
        .map((row) => row.map(escapeCell).join(','))
        .join('\r\n');

    await Clipboard.setData(ClipboardData(text: csv));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'CSV report copied. Paste it into a text editor and save as orgaflow_report.csv.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[date.month - 1];
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

class _MonthData {
  final DateTime date;
  int assigned = 0;
  int removed = 0;
  int maintenance = 0;

  _MonthData(this.date);
}
