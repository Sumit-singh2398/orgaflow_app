import 'package:flutter/material.dart';

// =============================================================================
// DEPARTMENT ASSETS PAGE (READ ONLY)
//
// Ye page sirf dikhata hai ki kaunsa asset kis department ko assign hai.
// Isme koi edit / delete / add / tap-action nahi hai.
// =============================================================================

class DepartmentAssetsPage extends StatefulWidget {
  /// Backend se assets dene ke liye optional list.
  /// Har item mein ye keys ho sakti hain:
  /// name, category, assetId (ya asset_id), department, status, assignedOn
  /// Agar list nahi di gayi to demo data show hoga.
  final List<Map<String, dynamic>>? assetsFromBackend;

  const DepartmentAssetsPage({
    super.key,
    this.assetsFromBackend,
  });

  @override
  State<DepartmentAssetsPage> createState() => _DepartmentAssetsPageState();
}

class _DepartmentAssetsPageState extends State<DepartmentAssetsPage> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedDepartment = 'All';
  String _searchQuery = '';

  static const Color _primary = Color(0xFF3B5BDB);
  static const Color _dark = Color(0xFF20243A);
  static const Color _grey = Color(0xFF85899B);
  static const Color _border = Color(0xFFEBEDF3);

  // ---------------------------------------------------------------------------
  // DEMO DATA
  // ---------------------------------------------------------------------------

  static const List<_DepartmentAsset> _demoAssets = [
    // IT
    _DepartmentAsset(
      name: 'Dell Latitude 5420',
      category: 'Laptop',
      assetId: 'AST-001',
      department: 'IT',
      status: 'Assigned',
      assignedOn: '12 Jan 2026',
    ),
    _DepartmentAsset(
      name: 'Cisco 24-Port Switch',
      category: 'Networking',
      assetId: 'AST-021',
      department: 'IT',
      status: 'Assigned',
      assignedOn: '05 Feb 2026',
    ),
    _DepartmentAsset(
      name: 'TP-Link Archer AX55',
      category: 'Networking',
      assetId: 'AST-007',
      department: 'IT',
      status: 'Assigned',
      assignedOn: '05 Feb 2026',
    ),
    _DepartmentAsset(
      name: 'APC Back-UPS 1100VA',
      category: 'Power',
      assetId: 'AST-006',
      department: 'IT',
      status: 'Maintenance',
      assignedOn: '18 Mar 2026',
    ),

    // HR
    _DepartmentAsset(
      name: 'HP EliteBook 840 G8',
      category: 'Laptop',
      assetId: 'AST-009',
      department: 'HR',
      status: 'Assigned',
      assignedOn: '22 Jan 2026',
    ),
    _DepartmentAsset(
      name: 'HP LaserJet Pro M404',
      category: 'Printer',
      assetId: 'AST-019',
      department: 'HR',
      status: 'Assigned',
      assignedOn: '30 Jan 2026',
    ),
    _DepartmentAsset(
      name: 'Logitech C920 Webcam',
      category: 'Accessories',
      assetId: 'AST-020',
      department: 'HR',
      status: 'Assigned',
      assignedOn: '14 Apr 2026',
    ),

    // Finance
    _DepartmentAsset(
      name: 'Lenovo ThinkPad E14',
      category: 'Laptop',
      assetId: 'AST-010',
      department: 'Finance',
      status: 'Assigned',
      assignedOn: '03 Feb 2026',
    ),
    _DepartmentAsset(
      name: 'Dell 27" Monitor',
      category: 'Display',
      assetId: 'AST-016',
      department: 'Finance',
      status: 'Assigned',
      assignedOn: '03 Feb 2026',
    ),
    _DepartmentAsset(
      name: 'Samsung Galaxy A55',
      category: 'Mobile',
      assetId: 'AST-002',
      department: 'Finance',
      status: 'Assigned',
      assignedOn: '19 May 2026',
    ),

    // Marketing
    _DepartmentAsset(
      name: 'Canon EOS 200D',
      category: 'Camera',
      assetId: 'AST-003',
      department: 'Marketing',
      status: 'Assigned',
      assignedOn: '10 Mar 2026',
    ),
    _DepartmentAsset(
      name: 'GoPro Hero 11',
      category: 'Camera',
      assetId: 'AST-022',
      department: 'Marketing',
      status: 'Assigned',
      assignedOn: '10 Mar 2026',
    ),
    _DepartmentAsset(
      name: 'MacBook Air M2',
      category: 'Laptop',
      assetId: 'AST-008',
      department: 'Marketing',
      status: 'Assigned',
      assignedOn: '27 Mar 2026',
    ),
    _DepartmentAsset(
      name: 'Sony WH-1000XM4',
      category: 'Audio',
      assetId: 'AST-017',
      department: 'Marketing',
      status: 'Maintenance',
      assignedOn: '02 Jun 2026',
    ),

    // Operations
    _DepartmentAsset(
      name: 'Epson EB-X06 Projector',
      category: 'Projector',
      assetId: 'AST-004',
      department: 'Operations',
      status: 'Assigned',
      assignedOn: '15 Feb 2026',
    ),
    _DepartmentAsset(
      name: 'Samsung 65" Smart Display',
      category: 'Display',
      assetId: 'AST-005',
      department: 'Operations',
      status: 'Assigned',
      assignedOn: '15 Feb 2026',
    ),
    _DepartmentAsset(
      name: 'Jabra Speak 510',
      category: 'Audio',
      assetId: 'AST-018',
      department: 'Operations',
      status: 'Assigned',
      assignedOn: '21 Apr 2026',
    ),

    // QA
    _DepartmentAsset(
      name: 'iPhone 13',
      category: 'Mobile',
      assetId: 'AST-011',
      department: 'QA',
      status: 'Assigned',
      assignedOn: '08 Jan 2026',
    ),
    _DepartmentAsset(
      name: 'iPad 10th Gen',
      category: 'Tablet',
      assetId: 'AST-012',
      department: 'QA',
      status: 'Assigned',
      assignedOn: '08 Jan 2026',
    ),
    _DepartmentAsset(
      name: 'Samsung Galaxy Tab S8',
      category: 'Tablet',
      assetId: 'AST-013',
      department: 'QA',
      status: 'Assigned',
      assignedOn: '16 Jul 2026',
    ),
  ];

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  List<_DepartmentAsset> get _assets {
    final backend = widget.assetsFromBackend;

    if (backend == null) {
      return _demoAssets;
    }

    return backend.map(_DepartmentAsset.fromMap).toList();
  }

  List<String> get _departments {
    final names = <String>{};

    for (final asset in _assets) {
      if (asset.department.isNotEmpty) {
        names.add(asset.department);
      }
    }

    final sorted = names.toList()..sort();

    return ['All', ...sorted];
  }

  List<_DepartmentAsset> get _filteredAssets {
    final query = _searchQuery.trim().toLowerCase();

    return _assets.where((asset) {
      final matchesDepartment =
          _selectedDepartment == 'All' || asset.department == _selectedDepartment;

      if (!matchesDepartment) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return asset.name.toLowerCase().contains(query) ||
          asset.category.toLowerCase().contains(query) ||
          asset.assetId.toLowerCase().contains(query) ||
          asset.department.toLowerCase().contains(query);
    }).toList();
  }

  /// Department-wise groups: [header, asset, asset, header, asset ...]
  List<Object> _buildListItems(List<_DepartmentAsset> assets) {
    final grouped = <String, List<_DepartmentAsset>>{};

    for (final asset in assets) {
      grouped.putIfAbsent(asset.department, () => []).add(asset);
    }

    final keys = grouped.keys.toList()..sort();

    final items = <Object>[];

    for (final key in keys) {
      items.add(_DepartmentHeader(key, grouped[key]!.length));
      items.addAll(grouped[key]!);
    }

    return items;
  }

  int _countByStatus(String status) {
    return _assets.where((asset) => asset.status == status).length;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredAssets;
    final items = _buildListItems(filtered);

    return _FixedTextScale(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme),
                      const SizedBox(height: 22),
                      _buildSummary(theme),
                      const SizedBox(height: 16),
                      _buildStats(),
                      const SizedBox(height: 20),
                      _buildSearchField(),
                      const SizedBox(height: 14),
                      _buildFilters(),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Assigned assets',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: _dark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${filtered.length} ${filtered.length == 1 ? 'asset' : 'assets'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _grey,
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
              if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyAssetsState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];

                        if (item is _DepartmentHeader) {
                          return _DepartmentHeaderTile(header: item);
                        }

                        final asset = item as _DepartmentAsset;

                        return Padding(
                          key: ValueKey('${asset.assetId}-${asset.department}'),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AssetCard(asset: asset),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER (read-only: koi options / edit button nahi)
  // ---------------------------------------------------------------------------

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _border),
          ),
          child: const Icon(
            Icons.apartment_rounded,
            color: _primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Department',
                style: theme.textTheme.bodySmall?.copyWith(color: _grey),
              ),
              Text(
                'Assets',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _dark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_outlined, size: 14, color: _grey),
              SizedBox(width: 5),
              Text(
                'View only',
                style: TextStyle(
                  color: _grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

  Widget _buildSummary(ThemeData theme) {
    final departmentCount = _departments.length - 1;

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
            color: _primary.withValues(alpha: 0.20),
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
                  'Who has what',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Department assets',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_assets.length} assets across $departmentCount departments',
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

  // ---------------------------------------------------------------------------
  // STATS
  // ---------------------------------------------------------------------------

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Departments',
            count: _departments.length - 1,
            color: const Color(0xFF7048E8),
            background: const Color(0xFFF1EBFF),
            icon: Icons.apartment_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Assigned',
            count: _countByStatus('Assigned'),
            color: _primary,
            background: const Color(0xFFEEF1FF),
            icon: Icons.person_pin_circle_outlined,
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

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14, color: _dark),
      decoration: InputDecoration(
        hintText: 'Search asset, ID or department',
        hintStyle: const TextStyle(
          color: Color(0xFF9A9EAD),
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _grey,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: _grey,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DEPARTMENT FILTER (sirf dekhne ke liye filter, data change nahi hota)
  // ---------------------------------------------------------------------------

  Widget _buildFilters() {
    final departments = _departments;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: departments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final department = departments[index];
          final isSelected = _selectedDepartment == department;

          return GestureDetector(
            onTap: () => setState(() => _selectedDepartment = department),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? _primary : _border,
                ),
              ),
              child: Text(
                department,
                maxLines: 1,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF686D80),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// SHARED HELPERS
// =============================================================================

/// System font size badhne par bhi layout stable rahe.
class _FixedTextScale extends StatelessWidget {
  final Widget child;

  const _FixedTextScale({required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.1,
        ),
      ),
      child: child,
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase().trim()) {
    case 'laptop':
      return Icons.laptop_mac_rounded;
    case 'mobile':
      return Icons.smartphone_rounded;
    case 'tablet':
      return Icons.tablet_mac_rounded;
    case 'camera':
      return Icons.camera_alt_rounded;
    case 'projector':
      return Icons.videocam_outlined;
    case 'display':
      return Icons.desktop_windows_outlined;
    case 'power':
      return Icons.battery_charging_full_rounded;
    case 'networking':
      return Icons.router_outlined;
    case 'accessories':
      return Icons.mouse_outlined;
    case 'audio':
      return Icons.headphones_rounded;
    case 'printer':
      return Icons.print_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}

Color _departmentColor(String department) {
  const palette = [
    Color(0xFF3B5BDB),
    Color(0xFF159A68),
    Color(0xFF7048E8),
    Color(0xFFE68A22),
    Color(0xFFD6336C),
    Color(0xFF0C8599),
  ];

  var hash = 0;

  for (final unit in department.codeUnits) {
    hash = (hash + unit) % palette.length;
  }

  return palette[hash];
}

// =============================================================================
// DEPARTMENT HEADER TILE
// =============================================================================

class _DepartmentHeaderTile extends StatelessWidget {
  const _DepartmentHeaderTile({required this.header});

  final _DepartmentHeader header;

  @override
  Widget build(BuildContext context) {
    final color = _departmentColor(header.name);

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.apartment_rounded, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              header.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF20243A),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${header.count} ${header.count == 1 ? 'asset' : 'assets'}',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// STAT CARD
// =============================================================================

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

// =============================================================================
// ASSET CARD (read-only: koi tap / edit / delete nahi)
// =============================================================================

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.asset});

  final _DepartmentAsset asset;

  @override
  Widget build(BuildContext context) {
    final isMaintenance = asset.status == 'Maintenance';

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
      'Assigned' => Icons.check_circle_outline_rounded,
      'Available' => Icons.inventory_outlined,
      _ => Icons.build_outlined,
    };

    final deptColor = _departmentColor(asset.department);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEDF3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _categoryIcon(asset.category),
              size: 24,
              color: const Color(0xFF3B5BDB),
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  '${asset.category}  •  ${asset.assetId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF85899B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),

                // Wrap use kiya hai taaki chhoti screen par chips overflow na karein.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      icon: Icons.apartment_rounded,
                      label: asset.department,
                      color: deptColor,
                      background: deptColor.withValues(alpha: 0.10),
                    ),
                    _Pill(
                      icon: statusIcon,
                      label: isMaintenance ? 'In Service' : asset.status,
                      color: statusColor,
                      background: statusBackground,
                    ),
                  ],
                ),

                if (asset.assignedOn.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        size: 13,
                        color: Color(0xFF9A9EAD),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Assigned on ${asset.assignedOn}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF85899B),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PILL
// =============================================================================

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

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
              'Try another search term or department.',
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

// =============================================================================
// MODELS
// =============================================================================

class _DepartmentHeader {
  const _DepartmentHeader(this.name, this.count);

  final String name;
  final int count;
}

class _DepartmentAsset {
  const _DepartmentAsset({
    required this.name,
    required this.category,
    required this.assetId,
    required this.department,
    required this.status,
    this.assignedOn = '',
  });

  final String name;
  final String category;
  final String assetId;
  final String department;
  final String status;
  final String assignedOn;

  factory _DepartmentAsset.fromMap(Map<String, dynamic> map) {
    String read(List<String> keys, String fallback) {
      for (final key in keys) {
        final value = map[key]?.toString().trim();

        if (value != null && value.isNotEmpty && value.toLowerCase() != 'null') {
          return value;
        }
      }

      return fallback;
    }

    return _DepartmentAsset(
      name: read(['name'], 'Unnamed Asset'),
      category: read(['category'], 'Asset'),
      assetId: read(['assetId', 'asset_id'], 'N/A'),
      department: read(['department', 'department_name'], 'Unassigned'),
      status: read(['status'], 'Assigned'),
      assignedOn: read(['assignedOn', 'assigned_on'], ''),
    );
  }
}