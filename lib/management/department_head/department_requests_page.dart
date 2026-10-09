import 'package:flutter/material.dart';

class DepartmentRequestsPage extends StatefulWidget {
  const DepartmentRequestsPage({super.key});

  @override
  State<DepartmentRequestsPage> createState() =>
      _DepartmentRequestsPageState();
}

class _DepartmentRequestsPageState extends State<DepartmentRequestsPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<_AssetRequest> _requests = const [
    _AssetRequest(
      name: 'Rahul Sharma',
      asset: 'Dell Laptop',
      department: 'Engineering',
      date: 'Today, 10:30 AM',
      status: 'Pending',
      icon: Icons.laptop_mac_rounded,
    ),
    _AssetRequest(
      name: 'Priya Singh',
      asset: 'Samsung Mobile',
      department: 'Marketing',
      date: 'Yesterday, 3:15 PM',
      status: 'Approved',
      icon: Icons.smartphone_rounded,
    ),
    _AssetRequest(
      name: 'Aman Kumar',
      asset: 'Canon DSLR',
      department: 'Design',
      date: 'Oct 07, 2026',
      status: 'Pending',
      icon: Icons.camera_alt_rounded,
    ),
  ];

  List<_AssetRequest> get _filteredRequests {
    return _requests.where((request) {
      final matchesFilter =
          _selectedFilter == 'All' || request.status == _selectedFilter;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = request.name.toLowerCase().contains(query) ||
          request.asset.toLowerCase().contains(query) ||
          request.department.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingCount =
        _requests.where((request) => request.status == 'Pending').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme, pendingCount),
                    const SizedBox(height: 24),
                    _buildSummary(theme, pendingCount),
                    const SizedBox(height: 24),
                    _buildSearchField(theme),
                    const SizedBox(height: 18),
                    _buildFilters(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Recent requests',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF20243A),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredRequests.length} requests',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF85899B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (_filteredRequests.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RequestCard(request: _filteredRequests[index]),
                    ),
                    childCount: _filteredRequests.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int pendingCount) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            color: Color(0xFF3B5BDB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Department',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF85899B),
                ),
              ),
              Text(
                'Asset requests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF20243A),
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              tooltip: 'Notifications',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF40445A),
              ),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (pendingCount > 0)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A3D),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme, int pendingCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF657AEC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5BDB).withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your team’s',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'asset requests',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '$pendingCount waiting for review',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: 'Search name, asset or department',
        hintStyle: const TextStyle(
          color: Color(0xFF9A9EAD),
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF85899B),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEBEDF3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B5BDB)),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All', 'Pending', 'Approved'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF686D80),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              selectedColor: const Color(0xFF3B5BDB),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF3B5BDB)
                    : const Color(0xFFEBEDF3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final _AssetRequest request;

  @override
  Widget build(BuildContext context) {
    final isApproved = request.status == 'Approved';
    final statusColor =
        isApproved ? const Color(0xFF159A68) : const Color(0xFFE68A22);
    final statusBackground =
        isApproved ? const Color(0xFFE8F7F0) : const Color(0xFFFFF3E3);

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEBEDF3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF1FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    request.icon,
                    color: const Color(0xFF3B5BDB),
                    size: 23,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF20243A),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        request.department,
                        style: const TextStyle(
                          color: Color(0xFF85899B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isApproved
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        request.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: Color(0xFFF0F1F5)),
            ),
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: Color(0xFF85899B),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    request.asset,
                    style: const TextStyle(
                      color: Color(0xFF40445A),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: Color(0xFF9A9EAD),
                ),
                const SizedBox(width: 5),
                Text(
                  request.date,
                  style: const TextStyle(
                    color: Color(0xFF85899B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF1FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Color(0xFF3B5BDB),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No requests found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF20243A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF85899B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetRequest {
  const _AssetRequest({
    required this.name,
    required this.asset,
    required this.department,
    required this.date,
    required this.status,
    required this.icon,
  });

  final String name;
  final String asset;
  final String department;
  final String date;
  final String status;
  final IconData icon;
}