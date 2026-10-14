import 'package:flutter/material.dart';

class AssetManagerMaintenancePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerMaintenancePage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerMaintenancePage> createState() =>
      _AssetManagerMaintenancePageState();
}

class _AssetManagerMaintenancePageState
    extends State<AssetManagerMaintenancePage> {
  static const Color primary = Color(0xFF3B5BDB);
  static const Color background = Color(0xFFF4F6FB);
  static const Color textDark = Color(0xFF182230);
  static const Color textMuted = Color(0xFF737D90);

  String selectedFilter = 'All';
  String searchQuery = '';

  final List<Map<String, dynamic>> maintenance = [
    {
      'asset': 'Epson Projector',
      'id': 'AST-004',
      'category': 'Projector',
      'brand': 'Epson',
      'location': 'Conference Room',
      'issue': 'Display not working properly',
      'description':
          'Projector powers on but no image appears on the screen. '
              'HDMI input and internal display system need inspection.',
      'status': 'In Progress',
      'priority': 'High',
      'technician': 'Vikas Sharma',
      'cost': 2500,
      'startDate': '12 Oct 2026',
      'expectedDate': '17 Oct 2026',
      'type': 'Repair',
      'actual': true,
    },
    {
      'asset': 'Dell Latitude 5420',
      'id': 'AST-010',
      'category': 'Laptop',
      'brand': 'Dell',
      'location': 'IT Department',
      'issue': 'Battery replacement',
      'description':
          'Battery backup has dropped significantly. Battery health '
              'check and replacement are required.',
      'status': 'Pending',
      'priority': 'Medium',
      'technician': 'Amit Verma',
      'cost': 4200,
      'startDate': '14 Oct 2026',
      'expectedDate': '19 Oct 2026',
      'type': 'Replacement',
      'actual': true,
    },
    {
      'asset': 'Canon DSLR Camera',
      'id': 'AST-003',
      'category': 'Camera',
      'brand': 'Canon',
      'location': 'Media Department',
      'issue': 'Lens autofocus problem',
      'description':
          'Autofocus is not responding consistently. Lens and camera '
              'connection need technical inspection.',
      'status': 'In Progress',
      'priority': 'High',
      'technician': 'Rohit Kumar',
      'cost': 1800,
      'startDate': '11 Oct 2026',
      'expectedDate': '16 Oct 2026',
      'type': 'Repair',
      'actual': true,
    },
    {
      'asset': 'Dell 24-inch Monitor',
      'id': 'AST-005',
      'category': 'Monitor',
      'brand': 'Dell',
      'location': 'Noida Office',
      'issue': 'Screen flickering',
      'description':
          'Monitor screen flickers after extended use. Power cable, '
              'display port and panel need to be checked.',
      'status': 'Pending',
      'priority': 'Medium',
      'technician': 'Not Assigned',
      'cost': 1200,
      'startDate': '14 Oct 2026',
      'expectedDate': '20 Oct 2026',
      'type': 'Inspection',
      'actual': true,
    },
    {
      'asset': 'Samsung Galaxy A55',
      'id': 'AST-002',
      'category': 'Smartphone',
      'brand': 'Samsung',
      'location': 'HR Department',
      'issue': 'Charging port inspection',
      'description':
          'Charging connection is loose. Port cleaning and charging '
              'circuit inspection are required.',
      'status': 'Completed',
      'priority': 'Low',
      'technician': 'Neeraj Singh',
      'cost': 650,
      'startDate': '08 Oct 2026',
      'expectedDate': '10 Oct 2026',
      'type': 'Inspection',
      'actual': true,
    },
  ];

  List<Map<String, dynamic>> get filteredMaintenance {
    return maintenance.where((item) {
      final matchesFilter = selectedFilter == 'All' ||
          item['status'] == selectedFilter;

      final query = searchQuery.toLowerCase();
      final matchesSearch = item['asset']
              .toString()
              .toLowerCase()
              .contains(query) ||
          item['id'].toString().toLowerCase().contains(query) ||
          item['issue'].toString().toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int get activeCount => maintenance
      .where((item) =>
          item['status'] == 'Pending' ||
          item['status'] == 'In Progress')
      .length;

  int get completedCount =>
      maintenance.where((item) => item['status'] == 'Completed').length;

  int get highPriorityCount => maintenance
      .where((item) =>
          item['priority'] == 'High' &&
          item['status'] != 'Completed')
      .length;

  int get totalCost => maintenance
      .where((item) => item['status'] != 'Completed')
      .fold<int>(0, (sum, item) => sum + (item['cost'] as int));

  @override
  Widget build(BuildContext context) {
    final items = filteredMaintenance;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatistics(),
            const SizedBox(height: 24),
            _buildSectionHeader(),
            const SizedBox(height: 14),
            _buildSearch(),
            const SizedBox(height: 14),
            _buildFilters(),
            const SizedBox(height: 18),
            if (items.isEmpty)
              _buildEmptyState()
            else
              ...items.map(_buildMaintenanceCard),
            const SizedBox(height: 24),
            _buildDemoNotice(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF657CF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.home_repair_service_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maintenance Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Track repairs, inspections and servicing',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Active Jobs',
                value: '$activeCount',
                icon: Icons.build_circle_outlined,
                color: const Color(0xFFE58A16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'Completed',
                value: '$completedCount',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF15966C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'High Priority',
                value: '$highPriorityCount',
                icon: Icons.priority_high_rounded,
                color: const Color(0xFFD94848),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'Active Cost',
                value: '₹$totalCost',
                icon: Icons.currency_rupee,
                color: primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: textMuted,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maintenance Records',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'View and update maintenance status',
                style: TextStyle(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDFF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            '${filteredMaintenance.length} records',
            style: const TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) {
        setState(() => searchQuery = value);
      },
      decoration: InputDecoration(
        hintText: 'Search asset, ID or issue...',
        hintStyle: const TextStyle(
          fontSize: 13,
          color: textMuted,
        ),
        prefixIcon: const Icon(Icons.search, color: textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E9F1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E9F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All', 'Pending', 'In Progress', 'Completed'];

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
              showCheckmark: false,
              onSelected: (_) {
                setState(() => selectedFilter = filter);
              },
              backgroundColor: Colors.white,
              selectedColor: primary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : textMuted,
              ),
              side: BorderSide(
                color: selected ? primary : const Color(0xFFE5E9F1),
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

  Widget _buildMaintenanceCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final statusColor = _statusColor(status);
    final priorityColor = _priorityColor(item['priority'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 49,
                      width: 49,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _assetIcon(item['category'] as String),
                        color: statusColor,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['asset'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${item['id']} • ${item['category']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _tag(status, statusColor),
                              _tag(
                                '${item['priority']} Priority',
                                priorityColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'View details',
                      onPressed: () => _showDetails(item),
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        size: 20,
                        color: primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFE58A16),
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reported Issue',
                              style: TextStyle(
                                fontSize: 11,
                                color: textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['issue'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: textDark,
                                fontWeight: FontWeight.w600,
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
                    const Icon(
                      Icons.person_outline,
                      size: 17,
                      color: textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['technician'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.currency_rupee,
                      size: 15,
                      color: textMuted,
                    ),
                    Text(
                      '${item['cost']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Due: ${item['expectedDate']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showDetails(item),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Full Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFBFD),
              border: Border(
                top: BorderSide(color: Color(0xFFE8ECF4)),
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Update progress',
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Change status',
                  onSelected: (value) => _updateStatus(item, value),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'Pending',
                      child: Text('Pending'),
                    ),
                    PopupMenuItem(
                      value: 'In Progress',
                      child: Text('In Progress'),
                    ),
                    PopupMenuItem(
                      value: 'Completed',
                      child: Text('Completed'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFDCE2ED)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Change Status',
                          style: TextStyle(
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: primary,
                          size: 17,
                        ),
                      ],
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

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFE58A16);
      case 'In Progress':
        return const Color(0xFF3B5BDB);
      case 'Completed':
        return const Color(0xFF15966C);
      default:
        return textMuted;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFD94848);
      case 'Medium':
        return const Color(0xFFE58A16);
      default:
        return const Color(0xFF15966C);
    }
  }

  IconData _assetIcon(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return Icons.laptop_mac_outlined;
      case 'projector':
        return Icons.present_to_all_outlined;
      case 'camera':
        return Icons.camera_alt_outlined;
      case 'monitor':
        return Icons.desktop_windows_outlined;
      case 'smartphone':
        return Icons.smartphone_outlined;
      default:
        return Icons.devices_other_outlined;
    }
  }

  void _updateStatus(Map<String, dynamic> item, String newStatus) {
    setState(() {
      item['status'] = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item['asset']} status changed to $newStatus.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDetails(Map<String, dynamic> item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DEEA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    height: 49,
                    width: 49,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _assetIcon(item['category'] as String),
                      color: primary,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['asset'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['id']} • ${item['brand']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Maintenance Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow('Status', '${item['status']}'),
              _detailRow('Priority', '${item['priority']}'),
              _detailRow('Issue', '${item['issue']}'),
              _detailRow('Description', '${item['description']}'),
              _detailRow('Type', '${item['type']}'),
              _detailRow('Technician', '${item['technician']}'),
              _detailRow('Location', '${item['location']}'),
              _detailRow('Start Date', '${item['startDate']}'),
              _detailRow('Expected Date', '${item['expectedDate']}'),
              _detailRow('Estimated Cost', '₹${item['cost']}'),
              const SizedBox(height: 18),
              SizedBox(
                height: 49,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Close Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 44,
            color: textMuted,
          ),
          SizedBox(height: 12),
          Text(
            'No maintenance records found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try another search or status filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5D9A5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFAD6A00),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo data: These records are examples, not verified real '
              'maintenance jobs. Status changes remain in this screen only. '
              'Connect a FastAPI endpoint and PostgreSQL to save real records.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: Color(0xFF79520B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
