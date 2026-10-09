import 'package:flutter/material.dart';

class DepartmentMaintenancePage extends StatefulWidget {
  const DepartmentMaintenancePage({super.key});

  @override
  State<DepartmentMaintenancePage> createState() =>
      _DepartmentMaintenancePageState();
}

class _DepartmentMaintenancePageState extends State<DepartmentMaintenancePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<MaintenanceItem> _items = [
    MaintenanceItem(
      name: 'Dell Latitude 5420',
      issue: 'Battery issue',
      category: 'Laptop',
      status: 'In Progress',
      icon: Icons.laptop_mac_rounded,
      updated: 'Updated today',
    ),
    MaintenanceItem(
      name: 'Epson Projector',
      issue: 'Display issue',
      category: 'Projector',
      status: 'Pending',
      icon: Icons.videocam_outlined,
      updated: 'Updated yesterday',
    ),
    MaintenanceItem(
      name: 'Wi-Fi Router',
      issue: 'Network issue',
      category: 'Networking',
      status: 'Completed',
      icon: Icons.router_outlined,
      updated: 'Updated 2 days ago',
    ),
  ];

  String _searchQuery = '';

  List<MaintenanceItem> get _filteredItems {
    if (_searchQuery.trim().isEmpty) return _items;

    final query = _searchQuery.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.issue.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.status.toLowerCase().contains(query);
    }).toList();
  }

  int get _inProgressCount =>
      _items.where((item) => item.status == 'In Progress').length;

  int get _pendingCount =>
      _items.where((item) => item.status == 'Pending').length;

  int get _completedCount =>
      _items.where((item) => item.status == 'Completed').length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredItems = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 28),
            _buildSectionTitle(),
            const SizedBox(height: 14),
            _buildSearchField(),
            const SizedBox(height: 14),
            if (filteredItems.isEmpty)
              _buildEmptyState()
            else
              ...filteredItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MaintenanceCard(item: item),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Department',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7B8190),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Maintenance',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1D2433),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track and manage your equipment repairs.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7B8190),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE9EBF1)),
          ),
          child: const Icon(
            Icons.build_outlined,
            color: Color(0xFF5367E8),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'In progress',
            count: _inProgressCount,
            color: const Color(0xFFF3A43B),
            icon: Icons.autorenew_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Pending',
            count: _pendingCount,
            color: const Color(0xFF8B6CE8),
            icon: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Completed',
            count: _completedCount,
            color: const Color(0xFF25A879),
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Maintenance requests',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D2433),
            ),
          ),
        ),
        Text(
          '${_filteredItems.length} items',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF858B99),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search equipment or issue',
        hintStyle: const TextStyle(color: Color(0xFF9AA0AC)),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF858B99),
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE9EBF1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE9EBF1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF5367E8), width: 1.4),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EBF1)),
      ),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF5367E8),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No requests found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D2433),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try searching with a different name or issue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF858B99),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE9EBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D2433),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF858B99),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({required this.item});

  final MaintenanceItem item;

  Color get _statusColor {
    switch (item.status) {
      case 'Completed':
        return const Color(0xFF25A879);
      case 'Pending':
        return const Color(0xFF8B6CE8);
      default:
        return const Color(0xFFF3A43B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EBF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080E1938),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: _statusColor, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D2433),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(
                      label: item.status,
                      color: _statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.issue,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF626A79),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: item.category,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.updated,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF969CAA),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF969CAA)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF858B99),
          ),
        ),
      ],
    );
  }
}

class MaintenanceItem {
  const MaintenanceItem({
    required this.name,
    required this.issue,
    required this.category,
    required this.status,
    required this.icon,
    required this.updated,
  });

  final String name;
  final String issue;
  final String category;
  final String status;
  final IconData icon;
  final String updated;
}