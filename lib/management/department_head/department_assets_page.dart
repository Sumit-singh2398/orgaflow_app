import 'package:flutter/material.dart';

class DepartmentAssetsPage extends StatefulWidget {
  const DepartmentAssetsPage({super.key});

  @override
  State<DepartmentAssetsPage> createState() => _DepartmentAssetsPageState();
}

class _DepartmentAssetsPageState extends State<DepartmentAssetsPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<_DepartmentAsset> _assets = const [
    _DepartmentAsset(
      name: 'Dell Latitude 5420',
      category: 'Laptop',
      assetId: 'AST-001',
      status: 'Assigned',
      icon: Icons.laptop_mac_rounded,
    ),
    _DepartmentAsset(
      name: 'Samsung Galaxy A55',
      category: 'Mobile',
      assetId: 'AST-002',
      status: 'Assigned',
      icon: Icons.smartphone_rounded,
    ),
    _DepartmentAsset(
      name: 'Canon DSLR',
      category: 'Camera',
      assetId: 'AST-003',
      status: 'Available',
      icon: Icons.camera_alt_rounded,
    ),
    _DepartmentAsset(
      name: 'Epson Projector',
      category: 'Projector',
      assetId: 'AST-004',
      status: 'Maintenance',
      icon: Icons.videocam_outlined,
    ),
  ];

  List<_DepartmentAsset> get _filteredAssets {
    return _assets.where((asset) {
      final matchesFilter =
          _selectedFilter == 'All' || asset.status == _selectedFilter;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = asset.name.toLowerCase().contains(query) ||
          asset.category.toLowerCase().contains(query) ||
          asset.assetId.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countByStatus(String status) {
    return _assets.where((asset) => asset.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    _buildHeader(theme),
                    const SizedBox(height: 24),
                    _buildSummary(theme),
                    const SizedBox(height: 18),
                    _buildStats(),
                    const SizedBox(height: 22),
                    _buildSearchField(),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Department inventory',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF20243A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredAssets.length} assets',
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
            if (_filteredAssets.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyAssetsState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AssetCard(asset: _filteredAssets[index]),
                    ),
                    childCount: _filteredAssets.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFEBEDF3)),
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
                'Assets',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF20243A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'More options',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF40445A),
            side: const BorderSide(color: Color(0xFFEBEDF3)),
          ),
          icon: const Icon(Icons.more_horiz_rounded),
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme) {
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
            color: const Color(0xFF3B5BDB).withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 9),
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
                  'Everything in one place',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Department assets',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_assets.length} assets registered in your department',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
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
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Assigned',
            count: _countByStatus('Assigned'),
            color: const Color(0xFF3B5BDB),
            background: const Color(0xFFEEF1FF),
            icon: Icons.person_pin_circle_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Available',
            count: _countByStatus('Available'),
            color: const Color(0xFF159A68),
            background: const Color(0xFFE8F7F0),
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Service',
            count: _countByStatus('Maintenance'),
            color: const Color(0xFFE68A22),
            background: const Color(0xFFFFF3E3),
            icon: Icons.build_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: 'Search assets or asset ID',
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
    const filters = ['All', 'Assigned', 'Available', 'Maintenance'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF686D80),
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF20243A),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF85899B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.asset});

  final _DepartmentAsset asset;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (asset.status) {
      'Assigned' => const Color(0xFF3B5BDB),
      'Available' => const Color(0xFF159A68),
      _ => const Color(0xFFE68A22),
    };

    final statusBackground = switch (asset.status) {
      'Assigned' => const Color(0xFFEEF1FF),
      'Available' => const Color(0xFFE8F7F0),
      _ => const Color(0xFFFFF3E3),
    };

    final statusIcon = switch (asset.status) {
      'Assigned' => Icons.person_outline_rounded,
      'Available' => Icons.check_circle_outline_rounded,
      _ => Icons.build_outlined,
    };

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEBEDF3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  asset.icon,
                  size: 24,
                  color: const Color(0xFF3B5BDB),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF20243A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${asset.category}  •  ${asset.assetId}',
                      style: const TextStyle(
                        color: Color(0xFF85899B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 13, color: statusColor),
                          const SizedBox(width: 5),
                          Text(
                            asset.status,
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
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9A9EAD),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAssetsState extends StatelessWidget {
  const _EmptyAssetsState();

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
                Icons.inventory_2_outlined,
                color: Color(0xFF3B5BDB),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No assets found',
              style: TextStyle(
                color: Color(0xFF20243A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try another search term or status filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF85899B),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentAsset {
  const _DepartmentAsset({
    required this.name,
    required this.category,
    required this.assetId,
    required this.status,
    required this.icon,
  });

  final String name;
  final String category;
  final String assetId;
  final String status;
  final IconData icon;
}
