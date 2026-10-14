import 'package:flutter/material.dart';
import 'my_request.dart';

// ============================================================
// ORGAFLOW EMPLOYEE ASSETS PAGE
// ============================================================

const Color _primary = Color(0xFF3157D5);
const Color _background = Color(0xFFF6F8FC);
const Color _dark = Color(0xFF171A22);
const Color _grey = Color(0xFF6B7280);
const Color _border = Color(0xFFE5E7EB);

IconData _categoryIcon(String category) {
  switch (category.toLowerCase().trim()) {
    case 'laptop':
      return Icons.laptop_mac_rounded;
    case 'mobile':
      return Icons.smartphone_rounded;
    case 'camera':
      return Icons.photo_camera_outlined;
    case 'projector':
      return Icons.videocam_outlined;
    case 'display':
      return Icons.desktop_windows_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}

// ============================================================
// EMPLOYEE ASSETS PAGE
// ============================================================

class EmployeeAssetsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final List<Map<String, dynamic>>? assetsFromBackend;

  const EmployeeAssetsPage({
    super.key,
    this.userData,
    this.assetsFromBackend,
  });

  @override
  State<EmployeeAssetsPage> createState() =>
      _EmployeeAssetsPageState();
}

class _EmployeeAssetsPageState extends State<EmployeeAssetsPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Five demo assets with individual image URLs.
  final List<Map<String, dynamic>> _demoAssets = [
    {
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'assetId': 'AST-001',
      'brand': 'Dell',
      'model': 'Latitude 5420',
      'productCode': 'DL5420-001',
      'processor': 'Intel Core i5 11th Gen',
      'ram': '16 GB',
      'storage': '512 GB SSD',
      'condition': 'Good',
      'location': 'Noida Office',
      'status': 'Available',
      'visibleToEmployees': true,
      'employee': null,
      'image':
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=85',
    },
    {
      'name': 'Samsung Galaxy A55',
      'category': 'Mobile',
      'assetId': 'AST-002',
      'brand': 'Samsung',
      'model': 'Galaxy A55',
      'productCode': 'SMA55-002',
      'processor': 'Exynos 1480',
      'ram': '8 GB',
      'storage': '128 GB',
      'condition': 'Excellent',
      'location': 'Noida Office',
      'status': 'Available',
      'visibleToEmployees': true,
      'employee': null,
      'image':
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=85',
    },
    {
      'name': 'Canon DSLR Camera',
      'category': 'Camera',
      'assetId': 'AST-003',
      'brand': 'Canon',
      'model': 'EOS Series',
      'productCode': 'CAN-003',
      'processor': 'DIGIC Image Processor',
      'ram': 'N/A',
      'storage': 'SD Card',
      'condition': 'Good',
      'location': 'Media Room',
      'status': 'Available',
      'visibleToEmployees': true,
      'employee': null,
      'image':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=85',
    },
    {
      'name': 'Epson Office Projector',
      'category': 'Projector',
      'assetId': 'AST-004',
      'brand': 'Epson',
      'model': 'Office Projector',
      'productCode': 'EPS-004',
      'processor': 'N/A',
      'ram': 'N/A',
      'storage': 'N/A',
      'condition': 'Good',
      'location': 'Conference Room',
      'status': 'Available',
      'visibleToEmployees': true,
      'employee': null,
      'image':
          'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=800&q=85',
    },
    {
      'name': 'Dell 27-inch Monitor',
      'category': 'Display',
      'assetId': 'AST-005',
      'brand': 'Dell',
      'model': '27-inch Monitor',
      'productCode': 'DLM-005',
      'processor': 'N/A',
      'ram': 'N/A',
      'storage': 'N/A',
      'condition': 'Excellent',
      'location': 'Development Floor',
      'status': 'Available',
      'visibleToEmployees': true,
      'employee': null,
      'image':
          'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=800&q=85',
    },
  ];

  List<Map<String, dynamic>> get _allAssets =>
      widget.assetsFromBackend ?? _demoAssets;

  List<String> get _categories {
    final values = _allAssets
        .map((asset) => asset['category']?.toString() ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['All', ...values];
  }

  bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      return ['true', '1', 'yes', 'visible', 'active']
          .contains(value.toLowerCase().trim());
    }

    return false;
  }

  List<Map<String, dynamic>> get _filteredAssets {
    final query = _searchQuery.trim().toLowerCase();

    return _allAssets.where((asset) {
      final visible = _readBool(
        asset['visibleToEmployees'] ??
            asset['visible_to_employees'] ??
            true,
      );

      final status =
          (asset['status'] ?? '').toString().toLowerCase().trim();

      if (!visible || (status.isNotEmpty && status != 'available')) {
        return false;
      }

      final category = (asset['category'] ?? '').toString();

      if (_selectedCategory != 'All' &&
          category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      if (query.isEmpty) return true;

      final searchable = [
        asset['name'],
        asset['assetId'],
        asset['asset_id'],
        asset['category'],
        asset['brand'],
        asset['model'],
        asset['productCode'],
        asset['product_code'],
        asset['location'],
      ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');

      return searchable.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAssets() async {
    // Refreshes the currently available list.
    // Connect your backend fetch method here when required.
    await Future.delayed(const Duration(milliseconds: 350));

    if (mounted) setState(() {});
  }

  void _openRequest(Map<String, dynamic> asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyRequest(
          userData: widget.userData,
          asset: asset,
        ),
      ),
    );
  }

  void _openDetails(Map<String, dynamic> asset) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
            ),
            child: _AssetDetails(
              asset: asset,
              onRequest: () {
                Navigator.pop(dialogContext);
                _openRequest(asset);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assets = _filteredAssets;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text(
          'Available Assets',
          style: TextStyle(
            color: _dark,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: _primary,
              size: 21,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _refreshAssets,
          child: CustomScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find the right equipment for your work.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _grey,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Summary card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3157D5),
                              Color(0xFF5878EA),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
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
                                    'ASSET INVENTORY',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      letterSpacing: 1.3,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${assets.length} Assets Available',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Browse equipment and submit requests',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 58,
                              width: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: const Icon(
                                Icons.devices_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Search
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search name, brand or asset ID',
                            hintStyle: const TextStyle(
                              color: _grey,
                              fontSize: 12,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: _primary,
                            ),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Categories',
                        style: TextStyle(
                          color: _dark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final selected =
                                category == _selectedCategory;

                            return ChoiceChip(
                              label: Text(category),
                              selected: selected,
                              showCheckmark: false,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              selectedColor: _primary,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: selected ? _primary : _border,
                              ),
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : _dark,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Equipment',
                              style: TextStyle(
                                color: _dark,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${assets.length} found',
                            style: const TextStyle(
                              color: _grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (assets.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: _primary.withOpacity(0.65),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No assets found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _dark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try another search or category.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final asset = assets[index];

                        return Padding(
                          key: ValueKey(
                            asset['assetId'] ?? asset['asset_id'] ?? index,
                          ),
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _AssetCard(
                            asset: asset,
                            onDetails: () => _openDetails(asset),
                            onRequest: () => _openRequest(asset),
                          ),
                        );
                      },
                      childCount: assets.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ASSET CARD
// ============================================================

class _AssetCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onDetails;
  final VoidCallback onRequest;

  const _AssetCard({
    required this.asset,
    required this.onDetails,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final name = asset['name']?.toString() ?? 'Unnamed Asset';
    final id = (asset['assetId'] ?? asset['asset_id'] ?? 'N/A').toString();
    final category = asset['category']?.toString() ?? 'Asset';
    final brand = asset['brand']?.toString() ?? '';
    final model = asset['model']?.toString() ?? '';
    final location = asset['location']?.toString() ?? 'Office';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NetworkAssetImage(
                url: asset['image'] ?? asset['image_url'],
                category: category,
                width: 105,
                height: 112,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: SizedBox(
                  height: 112,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusChip(
                        status: asset['status']?.toString() ?? 'Available',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _dark,
                          fontSize: 15,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        id,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$brand $model',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: _primary,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _dark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    color: _grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetails,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    foregroundColor: _dark,
                    side: const BorderSide(color: _border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const FittedBox(
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRequest,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    minimumSize: const Size(0, 44),
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const FittedBox(
                    child: Text(
                      'Request Asset',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NETWORK IMAGE WITH FIXED SIZE AND FALLBACK
// ============================================================

class _NetworkAssetImage extends StatelessWidget {
  final dynamic url;
  final String category;
  final double width;
  final double height;

  const _NetworkAssetImage({
    required this.url,
    required this.category,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.toString().trim() ?? '';

    Widget fallback() {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFEFF3FC),
        alignment: Alignment.center,
        child: Icon(
          _categoryIcon(category),
          color: _primary,
          size: 38,
        ),
      );
    }

    if (imageUrl.isEmpty || imageUrl.toLowerCase() == 'null') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: fallback(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: width,
          height: height,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => fallback(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return Container(
              width: width,
              height: height,
              color: const Color(0xFFEFF3FC),
              alignment: Alignment.center,
              child: const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// STATUS CHIP
// ============================================================

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final available = status.toLowerCase().trim() == 'available';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: available
            ? const Color(0xFFE7F8EE)
            : const Color(0xFFFFF2DB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: available
                  ? const Color(0xFF16834B)
                  : const Color(0xFFB26A00),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: available
                  ? const Color(0xFF16834B)
                  : const Color(0xFFB26A00),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ASSET DETAILS DIALOG
// ============================================================

class _AssetDetails extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onRequest;

  const _AssetDetails({
    required this.asset,
    required this.onRequest,
  });

  String _value(String key, {String fallback = 'Not available'}) {
    final value = asset[key];

    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final name = _value('name', fallback: 'Unnamed Asset');
    final category = _value('category', fallback: 'Asset');
    final status = _value('status', fallback: 'Available');
    final available = status.toLowerCase() == 'available';

    final details = <MapEntry<String, String>>[
      MapEntry('Asset ID', _value('assetId', fallback: _value('asset_id'))),
      MapEntry('Brand', _value('brand')),
      MapEntry('Model', _value('model')),
      MapEntry(
        'Product Code',
        _value('productCode', fallback: _value('product_code')),
      ),
      MapEntry('Processor', _value('processor')),
      MapEntry('RAM', _value('ram')),
      MapEntry('Storage', _value('storage')),
      MapEntry('Condition', _value('condition')),
      MapEntry('Location', _value('location')),
      MapEntry('Assigned To', _value('employee', fallback: 'Not assigned')),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: _NetworkAssetImage(
                    url: asset['image'] ?? asset['image_url'],
                    category: category,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _DetailBadge(
                      label: 'CATEGORY',
                      value: category,
                      icon: _categoryIcon(category),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DetailBadge(
                      label: 'STATUS',
                      value: status,
                      icon: Icons.verified_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Asset Information',
                style: TextStyle(
                  color: _dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: details.map((entry) {
                    final isLast = entry == details.last;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom: BorderSide(color: _border),
                              ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 105,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: _grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: _dark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 49,
                child: ElevatedButton.icon(
                  onPressed: available ? onRequest : null,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Request This Asset'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DETAILS BADGE
// ============================================================

class _DetailBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 23),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _grey,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _dark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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