import 'package:flutter/material.dart';

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
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> history = [
    {
      'id': 'HIS-1001',
      'action': 'Asset Assigned',
      'asset': 'Dell Latitude 5420',
      'assetId': 'AST-001',
      'employee': 'Rahul Sharma',
      'performedBy': 'Asset Manager',
      'date': '04 Oct 2026',
      'time': '10:30 AM',
      'type': 'Assignment',
      'description':
          'Dell Latitude 5420 was assigned to Rahul Sharma.',
    },
    {
      'id': 'HIS-1002',
      'action': 'Asset Returned',
      'asset': 'Samsung Galaxy A55',
      'assetId': 'AST-002',
      'employee': 'Priya Verma',
      'performedBy': 'Asset Manager',
      'date': '03 Oct 2026',
      'time': '04:15 PM',
      'type': 'Return',
      'description':
          'Samsung Galaxy A55 was returned by Priya Verma.',
    },
    {
      'id': 'HIS-1003',
      'action': 'Maintenance Started',
      'asset': 'Epson Projector',
      'assetId': 'AST-004',
      'employee': '-',
      'performedBy': 'IT Support',
      'date': '03 Oct 2026',
      'time': '01:20 PM',
      'type': 'Maintenance',
      'description':
          'Maintenance was started for Epson Projector due to display issue.',
    },
    {
      'id': 'HIS-1004',
      'action': 'Asset Created',
      'asset': 'Canon DSLR Camera',
      'assetId': 'AST-027',
      'employee': '-',
      'performedBy': 'Asset Manager',
      'date': '02 Oct 2026',
      'time': '11:10 AM',
      'type': 'Created',
      'description':
          'A new Canon DSLR Camera asset was added to the inventory.',
    },
    {
      'id': 'HIS-1005',
      'action': 'Request Approved',
      'asset': 'Wi-Fi Router',
      'assetId': 'AST-021',
      'employee': 'Arjun Mehta',
      'performedBy': 'Asset Manager',
      'date': '01 Oct 2026',
      'time': '03:45 PM',
      'type': 'Request',
      'description':
          'Asset request for Wi-Fi Router was approved.',
    },
    {
      'id': 'HIS-1006',
      'action': 'Asset Transferred',
      'asset': 'Dell Latitude 5420',
      'assetId': 'AST-010',
      'employee': 'Neha Singh',
      'performedBy': 'Asset Manager',
      'date': '30 Sep 2026',
      'time': '12:30 PM',
      'type': 'Transfer',
      'description':
          'Dell Latitude 5420 was transferred to the Finance department.',
    },
  ];

  List<Map<String, dynamic>> get filteredHistory {
    if (selectedFilter == 'All') {
      return history;
    }

    return history
        .where(
          (item) => item['type'] == selectedFilter,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSummary(),
            _buildFilters(),
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        16,
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.history,
              color: Color(0xFF3157D5),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'View all asset management activities',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _refreshHistory,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF3157D5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18,
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              title: 'Activities',
              value: history.length.toString(),
              icon: Icons.timeline,
              iconColor: const Color(0xFF3157D5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              title: 'Assignments',
              value: history
                  .where(
                    (item) =>
                        item['type'] == 'Assignment',
                  )
                  .length
                  .toString(),
              icon: Icons.person_add_alt_1_outlined,
              iconColor: Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              title: 'Maintenance',
              value: history
                  .where(
                    (item) =>
                        item['type'] == 'Maintenance',
                  )
                  .length
                  .toString(),
              icon: Icons.build_outlined,
              iconColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE7EAF2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = [
      'All',
      'Assignment',
      'Return',
      'Maintenance',
      'Request',
      'Transfer',
      'Created',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        15,
        18,
        12,
      ),
      color: const Color(0xFFF6F8FC),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map(_filterButton).toList(),
        ),
      ),
    );
  }

  Widget _filterButton(String filter) {
    final bool selected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(filter),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
        selectedColor: const Color(0xFF3157D5),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : const Color(0xFF4B5563),
          fontWeight: selected
              ? FontWeight.bold
              : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected
              ? const Color(0xFF3157D5)
              : const Color(0xFFE1E5EE),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final items = filteredHistory;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        18,
        4,
        18,
        25,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _historyCard(items[index]);
      },
    );
  }

  Widget _historyCard(
    Map<String, dynamic> item,
  ) {
    final String type =
        item['type']?.toString() ?? '';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE8EAF0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showHistoryDetails(item);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _activityIcon(type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['action']?.toString() ??
                                'Activity',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),
                        ),
                        Text(
                          item['time']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['asset']?.toString() ??
                          'Asset',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3157D5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['assetId']} • ${item['employee']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['date']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3157D5),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right,
                          size: 17,
                          color: Color(0xFF3157D5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityIcon(String type) {
    IconData icon;
    Color color;
    Color background;

    switch (type) {
      case 'Assignment':
        icon = Icons.person_add_alt_1_outlined;
        color = Colors.green;
        background = const Color(0xFFE8F7EE);
        break;

      case 'Return':
        icon = Icons.assignment_return_outlined;
        color = Colors.orange;
        background = const Color(0xFFFFF4E5);
        break;

      case 'Maintenance':
        icon = Icons.build_outlined;
        color = Colors.deepOrange;
        background = const Color(0xFFFFEDE3);
        break;

      case 'Request':
        icon = Icons.pending_actions_outlined;
        color = const Color(0xFF3157D5);
        background = const Color(0xFFE8EDFF);
        break;

      case 'Transfer':
        icon = Icons.swap_horiz;
        color = Colors.purple;
        background = const Color(0xFFF1E8FF);
        break;

      case 'Created':
        icon = Icons.add_box_outlined;
        color = Colors.teal;
        background = const Color(0xFFE5F7F5);
        break;

      default:
        icon = Icons.history;
        color = const Color(0xFF3157D5);
        background = const Color(0xFFE8EDFF);
    }

    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: color,
        size: 23,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history_toggle_off,
                size: 40,
                color: Color(0xFF3157D5),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No History Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              selectedFilter == 'All'
                  ? 'There are no asset activities yet.'
                  : 'There are no $selectedFilter activities.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDetails(
    Map<String, dynamic> item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              25,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Activity Details',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _detailRow(
                    'Activity ID',
                    item['id'],
                  ),
                  _detailRow(
                    'Action',
                    item['action'],
                  ),
                  _detailRow(
                    'Asset',
                    item['asset'],
                  ),
                  _detailRow(
                    'Asset ID',
                    item['assetId'],
                  ),
                  _detailRow(
                    'Employee',
                    item['employee'],
                  ),
                  _detailRow(
                    'Performed By',
                    item['performedBy'],
                  ),
                  _detailRow(
                    'Date',
                    item['date'],
                  ),
                  _detailRow(
                    'Time',
                    item['time'],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['description']?.toString() ??
                          'No description available.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
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

  Widget _detailRow(
    String title,
    dynamic value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshHistory() {
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'History refreshed.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
