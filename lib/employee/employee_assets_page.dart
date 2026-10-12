import 'package:flutter/material.dart';
import 'my_request.dart';

// =============================================================================
// SHARED HELPERS
// =============================================================================

/// Category ke hisab se fallback icon (image load na ho to ye dikhega).
IconData _categoryIcon(String category) {
  switch (category.toLowerCase().trim()) {
    case 'laptop':
      return Icons.laptop_mac_rounded;
    case 'mobile':
      return Icons.smartphone_rounded;
    case 'tablet':
      return Icons.tablet_mac_rounded;
    case 'camera':
      return Icons.photo_camera_outlined;
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

/// Text scale ko limit karta hai taaki phone ki system font size badhne par
/// bhi layout / fonts idhar-udhar ya overflow na hon.
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

// =============================================================================
// EMPLOYEE ASSETS PAGE
// =============================================================================

class EmployeeAssetsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  /// Backend se assets bhejne ke liye optional list.
  /// Agar backend list nahi di gayi to demo assets show honge.
  final List<Map<String, dynamic>>? assetsFromBackend;

  const EmployeeAssetsPage({
    super.key,
    this.userData,
    this.assetsFromBackend,
  });

  @override
  State<EmployeeAssetsPage> createState() => _EmployeeAssetsPageState();
}

class _EmployeeAssetsPageState extends State<EmployeeAssetsPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const Color primaryColor = Color(0xFF3157D5);
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color darkColor = Color(0xFF171A22);
  static const Color greyColor = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  // ---------------------------------------------------------------------------
  // DEMO ASSETS (24 items)
  // Backend connect hone tak ye fallback data use hoga.
  //
  // Images: loremflickr se keyword-based stable images (lock = fixed image).
  // Apni real image URL dalni ho to 'image' field replace kar do.
  // Image fail ho jaye to category icon wala placeholder automatically dikhega.
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _asset({
    required int n,
    required String name,
    required String category,
    required String brand,
    required String model,
    required String productCode,
    required String processor,
    required String ram,
    required String storage,
    required String condition,
    required String location,
    required String imageKeyword,
    String status = 'Available',
    bool visible = true,
  }) {
    return {
      'name': name,
      'category': category,
      'assetId': 'AST-${n.toString().padLeft(3, '0')}',
      'brand': brand,
      'model': model,
      'productCode': productCode,
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'condition': condition,
      'location': location,
      'status': status,
      'employee': null,
      'visibleToEmployees': visible,
      'image': 'https://loremflickr.com/640/480/$imageKeyword?lock=$n',
    };
  }

  final List<Map<String, dynamic>> demoAssets = [
    _asset(
      n: 1,
      name: 'Dell Latitude 5420',
      category: 'Laptop',
      brand: 'Dell',
      model: 'Latitude 5420',
      productCode: 'DL5420-001',
      processor: 'Intel Core i5 11th Gen',
      ram: '16 GB',
      storage: '512 GB SSD',
      condition: 'Good',
      location: 'Noida Office',
      imageKeyword: 'laptop',
    ),
    _asset(
      n: 2,
      name: 'Samsung Galaxy A55',
      category: 'Mobile',
      brand: 'Samsung',
      model: 'Galaxy A55',
      productCode: 'SMA55-002',
      processor: 'Exynos 1480',
      ram: '8 GB',
      storage: '128 GB',
      condition: 'Excellent',
      location: 'Noida Office',
      imageKeyword: 'smartphone',
    ),
    _asset(
      n: 3,
      name: 'DSLR Camera',
      category: 'Camera',
      brand: 'Canon',
      model: 'EOS 200D',
      productCode: 'CAN200D-003',
      processor: 'DIGIC 7',
      ram: 'N/A',
      storage: '128 GB SD Card',
      condition: 'Good',
      location: 'Media Room',
      imageKeyword: 'camera',
    ),
    _asset(
      n: 4,
      name: 'Tripod Projector',
      category: 'Projector',
      brand: 'Epson',
      model: 'EB-X06',
      productCode: 'EPS-X06-004',
      processor: 'N/A',
      ram: 'N/A',
      storage: 'N/A',
      condition: 'Good',
      location: 'Conference Room',
      imageKeyword: 'projector',
    ),
    _asset(
      n: 5,
      name: 'Conference Room Display',
      category: 'Display',
      brand: 'Samsung',
      model: '65 inch Smart Display',
      productCode: 'SAM65-005',
      processor: 'Smart TV Processor',
      ram: '4 GB',
      storage: '32 GB',
      condition: 'Excellent',
      location: 'Conference Room',
      imageKeyword: 'television',
    ),
    _asset(
      n: 6,
      name: 'UPS Power Backup',
      category: 'Power',
      brand: 'APC',
      model: 'Back-UPS 1100VA',
      productCode: 'APC1100-006',
      processor: 'N/A',
      ram: 'N/A',
      storage: 'N/A',
      condition: 'Good',
      location: 'IT Room',
      imageKeyword: 'battery',
    ),
    _asset(
      n: 7,
      name: 'Wi-Fi Router',
      category: 'Networking',
      brand: 'TP-Link',
      model: 'Archer AX55',
      productCode: 'TPLAX55-007',
      processor: 'Quad Core',
      ram: '512 MB',
      storage: 'N/A',
      condition: 'Excellent',
      location: 'IT Room',
      imageKeyword: 'router',
    ),
    _asset(
      n: 8,
      name: 'MacBook Air M2',
      category: 'Laptop',
      brand: 'Apple',
      model: 'MacBook Air M2',
      productCode: 'MBA-M2-008',
      processor: 'Apple M2',
      ram: '8 GB',
      storage: '256 GB SSD',
      condition: 'Excellent',
      location: 'Noida Office',
      imageKeyword: 'macbook',
    ),
    _asset(
      n: 9,
      name: 'HP EliteBook 840 G8',
      category: 'Laptop',
      brand: 'HP',
      model: 'EliteBook 840 G8',
      productCode: 'HP840G8-009',
      processor: 'Intel Core i7 11th Gen',
      ram: '16 GB',
      storage: '512 GB SSD',
      condition: 'Good',
      location: 'Noida Office',
      imageKeyword: 'notebook',
    ),
    _asset(
      n: 10,
      name: 'Lenovo ThinkPad E14',
      category: 'Laptop',
      brand: 'Lenovo',
      model: 'ThinkPad E14 Gen 4',
      productCode: 'LNVE14-010',
      processor: 'AMD Ryzen 5 5625U',
      ram: '16 GB',
      storage: '512 GB SSD',
      condition: 'Good',
      location: 'Dev Floor',
      imageKeyword: 'computer',
    ),
    _asset(
      n: 11,
      name: 'iPhone 13',
      category: 'Mobile',
      brand: 'Apple',
      model: 'iPhone 13',
      productCode: 'IP13-011',
      processor: 'Apple A15 Bionic',
      ram: '4 GB',
      storage: '128 GB',
      condition: 'Excellent',
      location: 'QA Lab',
      imageKeyword: 'iphone',
    ),
    _asset(
      n: 12,
      name: 'iPad 10th Gen',
      category: 'Tablet',
      brand: 'Apple',
      model: 'iPad 10th Generation',
      productCode: 'IPAD10-012',
      processor: 'Apple A14 Bionic',
      ram: '4 GB',
      storage: '64 GB',
      condition: 'Excellent',
      location: 'QA Lab',
      imageKeyword: 'ipad',
    ),
    _asset(
      n: 13,
      name: 'Samsung Galaxy Tab S8',
      category: 'Tablet',
      brand: 'Samsung',
      model: 'Galaxy Tab S8',
      productCode: 'SMTS8-013',
      processor: 'Snapdragon 8 Gen 1',
      ram: '8 GB',
      storage: '128 GB',
      condition: 'Good',
      location: 'Noida Office',
      imageKeyword: 'tablet',
    ),
    _asset(
      n: 14,
      name: 'Logitech MX Master 3',
      category: 'Accessories',
      brand: 'Logitech',
      model: 'MX Master 3',
      productCode: 'LGMX3-014',
      processor: 'N/A',
      ram: 'N/A',
      storage: 'N/A',
      condition: 'Excellent',
      location: 'IT Room',
      imageKeyword: 'mouse',
    ),
    _asset(
      n: 15,
      name: 'Keychron K8 Keyboard',
      category: 'Accessories',
      brand: 'Keychron',
      model: 'K8 Wireless',
      productCode: 'KCK8-015',
      processor: 'N/A',
      ram: 'N/A',
      storage: 'N/A',
      condition: 'Good',
      location: 'IT Room',
      imageKeyword: 'keyboard',
    ),
    _asset(
      n: 16,
      name: 'Dell 27" Monitor',
      category: 'Display',
      brand: 'Dell',
      model: 'P2722H',
      productCode: 'DLP2722-016',
      processor: 'N/A',
      ram: 'N/A',
      storage: 'N/A',
      condition: 'Excellent',
      location: 'Dev Floor',
      imageKeyword: 'monitor',
    ),
    _asset(
      n: 17,
      name: 'Sony WH-1000XM4',
      category: 'Audio',
      brand: 'Sony',
      model: 'WH-1000XM4',
      productCode: 'SNXM4-017',
      processor: 'QN1 Chip',
      ram: 'N/A',
      storage: 'N/A',
      condition: 'Good',
      location: 'Media Room',
      imageKeyword: 'headphones',
    ),
    _asset(
      n: 18,
      name: 'Jabra Speak 510',
      category: 'Audio',
      brand: 'Jabra',
      model: 'Speak 510',
      productCode: 'JBS510-018',
      processor: 'N/A',
      ram: 'N/A',
      storage: 'N/A',
      condition: 'Good',
      location: 'Conference Room',
      imageKeyword: 'speaker',
    ),
    _asset(
      n: 19,
      name: 'HP LaserJet Pro M404',
      category: 'Printer',
      brand: 'HP',
      model: 'LaserJet Pro M404dn',
      productCode: 'HPM404-019',
      processor: '1.2 GHz',
      ram: '256 MB',
      storage: 'N/A',
      condition: 'Good',
      location: 'Admin Area',
      imageKeyword: 'printer',
    ),
    _asset(
      n: 20,
      name: 'Logitech C920 Webcam',
      category: 'Accessories',
      brand: 'Logitech',
      model: 'C920 HD Pro',
      productCode: 'LGC920-020',
      processor: 'N/A',
      ram: 'N/A',
      storage: 'N/A',
      condition: 'Excellent',
      location: 'Conference Room',
      imageKeyword: 'webcam',
    ),
    _asset(
      n: 21,
      name: 'Cisco 24-Port Switch',
      category: 'Networking',
      brand: 'Cisco',
      model: 'CBS350-24T',
      productCode: 'CSCO24-021',
      processor: 'Dual Core',
      ram: '512 MB',
      storage: 'N/A',
      condition: 'Excellent',
      location: 'Server Room',
      imageKeyword: 'server',
    ),
    _asset(
      n: 22,
      name: 'GoPro Hero 11',
      category: 'Camera',
      brand: 'GoPro',
      model: 'Hero 11 Black',
      productCode: 'GPH11-022',
      processor: 'GP2',
      ram: 'N/A',
      storage: '256 GB SD Card',
      condition: 'Excellent',
      location: 'Media Room',
      imageKeyword: 'gopro',
    ),

    // Ye 2 assets employee page par nahi dikhenge (filter test ke liye):
    _asset(
      n: 23,
      name: 'Lenovo ThinkPad T14',
      category: 'Laptop',
      brand: 'Lenovo',
      model: 'ThinkPad T14 Gen 3',
      productCode: 'LNVT14-023',
      processor: 'Intel Core i7 12th Gen',
      ram: '32 GB',
      storage: '1 TB SSD',
      condition: 'Fair',
      location: 'Service Center',
      imageKeyword: 'laptop',
      status: 'Maintenance',
    ),
    _asset(
      n: 24,
      name: 'Dell Precision 5570',
      category: 'Laptop',
      brand: 'Dell',
      model: 'Precision 5570',
      productCode: 'DLP5570-024',
      processor: 'Intel Core i9 12th Gen',
      ram: '64 GB',
      storage: '2 TB SSD',
      condition: 'Excellent',
      location: 'Admin Area',
      imageKeyword: 'workstation',
      visible: false,
    ),
  ];

  // ---------------------------------------------------------------------------
  // ASSET SOURCE
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> get allAssets {
    if (widget.assetsFromBackend != null) {
      return widget.assetsFromBackend!;
    }

    return demoAssets;
  }

  // ---------------------------------------------------------------------------
  // CATEGORIES
  // ---------------------------------------------------------------------------

  List<String> get categories {
    final Set<String> categorySet = {'All'};

    for (final asset in allAssets) {
      final category = asset['category']?.toString().trim();

      if (category != null && category.isNotEmpty) {
        categorySet.add(category);
      }
    }

    return categorySet.toList();
  }

  // ---------------------------------------------------------------------------
  // FILTERED ASSETS
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> get employeeAssets {
    final query = _searchQuery.trim().toLowerCase();

    return allAssets.where((asset) {
      final visible = _readBool(
        asset['visibleToEmployees'] ??
            asset['visible_to_employees'] ??
            true,
      );

      final status = (asset['status'] ?? '').toString().toLowerCase();

      // Employee page par sirf visible + available assets.
      if (!visible) {
        return false;
      }

      if (status.isNotEmpty && status != 'available') {
        return false;
      }

      final category = (asset['category'] ?? '').toString();

      if (_selectedCategory != 'All' &&
          category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchableText = [
        asset['name'],
        asset['assetId'],
        asset['asset_id'],
        asset['category'],
        asset['brand'],
        asset['model'],
        asset['productCode'],
        asset['product_code'],
        asset['location'],
        asset['condition'],
      ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');

      return searchableText.contains(query);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // BOOLEAN HELPER
  // ---------------------------------------------------------------------------

  bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final text = value.toLowerCase().trim();

      return text == 'true' ||
          text == '1' ||
          text == 'yes' ||
          text == 'visible' ||
          text == 'active';
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // REFRESH
  // ---------------------------------------------------------------------------

  Future<void> _refreshAssets() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // OPEN ASSET DETAILS
  // ---------------------------------------------------------------------------

  void _openAssetDetails(Map<String, dynamic> asset) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;

        return _FixedTextScale(
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 24,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                maxHeight: size.height * 0.86,
              ),
              child: _AssetDetailsDialog(
                asset: asset,
                userData: widget.userData,
                onRequest: () {
                  Navigator.pop(dialogContext);

                  _openRequestPage(asset);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // REQUEST
  // ---------------------------------------------------------------------------

  void _openRequestPage(Map<String, dynamic> asset) {
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

  // ---------------------------------------------------------------------------
  // ASSET CARD
  // ---------------------------------------------------------------------------

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    return _AssetCard(
      asset: asset,
      onDetails: () {
        _openAssetDetails(asset);
      },
      onRequest: () {
        _openRequestPage(asset);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY CHIPS
  // ---------------------------------------------------------------------------

  Widget _buildCategorySelector() {
    final cats = categories;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = cats[index];
          final selected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: selected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? primaryColor : borderColor,
                ),
              ),
              child: Text(
                category,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : darkColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH FIELD
  // ---------------------------------------------------------------------------

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14,
          color: darkColor,
        ),
        decoration: InputDecoration(
          hintText: 'Search assets...',
          hintStyle: const TextStyle(
            color: greyColor,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: greyColor,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: greyColor,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 60,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No assets found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All'
                  ? 'Try a different search or category.'
                  : 'There are no available assets for you right now.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final assets = employeeAssets;

    return _FixedTextScale(
      child: Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: lightBackground,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: const Text(
            'Available Assets',
            style: TextStyle(
              color: darkColor,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: primaryColor,
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
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      4,
                      20,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${assets.length} ${assets.length == 1 ? 'asset' : 'assets'} available',
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSearchField(),
                        const SizedBox(height: 14),
                        _buildCategorySelector(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (assets.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final asset = assets[index];

                          return Padding(
                            key: ValueKey(
                              '${asset['assetId'] ?? asset['asset_id'] ?? index}',
                            ),
                            padding: const EdgeInsets.only(
                              bottom: 14,
                            ),
                            child: _buildAssetCard(asset),
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
      ),
    );
  }
}

// =============================================================================
// ASSET CARD
// =============================================================================

class _AssetCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onDetails;
  final VoidCallback onRequest;

  const _AssetCard({
    required this.asset,
    required this.onDetails,
    required this.onRequest,
  });

  static const Color primaryColor = Color(0xFF3157D5);
  static const Color darkColor = Color(0xFF171A22);
  static const Color greyColor = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final name = asset['name']?.toString() ?? 'Unnamed Asset';

    final assetId = (asset['assetId'] ?? asset['asset_id'] ?? 'N/A').toString();

    final category = asset['category']?.toString() ?? 'Asset';

    final brand = asset['brand']?.toString() ?? '';

    final model = asset['model']?.toString() ?? '';

    final location = asset['location']?.toString() ?? 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed size image -> scroll / load ke time layout shift nahi.
                _AssetImage(
                  imageUrl: asset['image'] ?? asset['image_url'],
                  category: category,
                  width: 84,
                  height: 84,
                  borderRadius: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    // Image ki height ke barabar, taaki card height stable rahe.
                    height: 84,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.25,
                                  fontWeight: FontWeight.w700,
                                  color: darkColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _StatusChip(
                              status:
                                  asset['status']?.toString() ?? 'Available',
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assetId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              [brand, model]
                                  .where((e) => e.isNotEmpty)
                                  .join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: greyColor,
                              ),
                            ),
                          ],
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
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: greyColor,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: darkColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: greyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetails,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      side: const BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'View Details',
                        maxLines: 1,
                        style: TextStyle(
                          color: darkColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Request',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
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
      ),
    );
  }
}

// =============================================================================
// ASSET DETAILS DIALOG
// =============================================================================

class _AssetDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> asset;
  final Map<String, dynamic>? userData;
  final VoidCallback onRequest;

  const _AssetDetailsDialog({
    required this.asset,
    required this.userData,
    required this.onRequest,
  });

  static const Color primaryColor = Color(0xFF3157D5);
  static const Color darkColor = Color(0xFF171A22);
  static const Color borderColor = Color(0xFFE5E7EB);

  String _value(
    String key, {
    String fallback = 'Not available',
  }) {
    final value = asset[key];

    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = asset['image'] ?? asset['image_url'];

    final name = _value(
      'name',
      fallback: 'Unnamed Asset',
    );

    final assetId = _value(
      'assetId',
      fallback: _value(
        'asset_id',
        fallback: 'N/A',
      ),
    );

    final status = _value(
      'status',
      fallback: 'Available',
    );

    final category = _value(
      'category',
      fallback: 'Asset',
    );

    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // -------------------------------------------------------------------
          // HEADER
          // -------------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: darkColor,
                            fontSize: 19,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assetId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // SCROLLABLE CONTENT
          // -------------------------------------------------------------------
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed 16:10 ratio -> image load hone par layout nahi hilega.
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: _AssetImage(
                      imageUrl: imageUrl,
                      category: category,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          title: 'Category',
                          value: category,
                          icon: _categoryIcon(category),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoBox(
                          title: 'Status',
                          value: status,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Asset Information',
                    style: TextStyle(
                      color: darkColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Asset ID',
                          value: assetId,
                          icon: Icons.tag_rounded,
                        ),
                        _DetailRow(
                          label: 'Brand',
                          value: _value('brand'),
                          icon: Icons.business_outlined,
                        ),
                        _DetailRow(
                          label: 'Model',
                          value: _value('model'),
                          icon: Icons.devices_outlined,
                        ),
                        _DetailRow(
                          label: 'Product Code',
                          value: _value(
                            'productCode',
                            fallback: _value('product_code'),
                          ),
                          icon: Icons.qr_code_rounded,
                        ),
                        _DetailRow(
                          label: 'Processor',
                          value: _value('processor'),
                          icon: Icons.memory_rounded,
                        ),
                        _DetailRow(
                          label: 'RAM',
                          value: _value('ram'),
                          icon: Icons.developer_board_outlined,
                        ),
                        _DetailRow(
                          label: 'Storage',
                          value: _value('storage'),
                          icon: Icons.storage_outlined,
                        ),
                        _DetailRow(
                          label: 'Condition',
                          value: _value('condition'),
                          icon: Icons.verified_outlined,
                        ),
                        _DetailRow(
                          label: 'Location',
                          value: _value('location'),
                          icon: Icons.location_on_outlined,
                        ),
                        _DetailRow(
                          label: 'Assigned To',
                          value: _value(
                            'employee',
                            fallback: 'Not assigned',
                          ),
                          icon: Icons.person_outline_rounded,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ------------------------------------------------------------
                  // REQUEST BUTTON
                  // ------------------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          status.toLowerCase() == 'available' ? onRequest : null,
                      icon: const Icon(
                        Icons.send_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Request This Asset',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DETAIL ROW (overflow-safe)
// =============================================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool showDivider;

  const _DetailRow({
    required this.label,
    required this.value,
    this.icon,
    this.showDivider = true,
  });

  static const Color primaryColor = Color(0xFF3157D5);
  static const Color darkColor = Color(0xFF171A22);
  static const Color greyColor = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: borderColor, width: 0.8),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label ki width fixed, value Expanded -> small phones par overflow nahi.
          SizedBox(
            width: 108,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: greyColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not available' : value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: darkColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INFO BOX
// =============================================================================

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  static const Color primaryColor = Color(0xFF3157D5);
  static const Color darkColor = Color(0xFF171A22);
  static const Color greyColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: greyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: darkColor,
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

// =============================================================================
// STATUS CHIP
// =============================================================================

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase().trim();

    Color background;
    Color foreground;

    if (normalized == 'available') {
      background = const Color(0xFFE9F8EF);
      foreground = const Color(0xFF16834B);
    } else if (normalized == 'maintenance') {
      background = const Color(0xFFFFF4DD);
      foreground = const Color(0xFFB26A00);
    } else if (normalized == 'assigned') {
      background = const Color(0xFFE9EEFF);
      foreground = const Color(0xFF3157D5);
    } else if (normalized == 'retired') {
      background = const Color(0xFFFDECEC);
      foreground = const Color(0xFFC62828);
    } else {
      background = const Color(0xFFF0F1F3);
      foreground = const Color(0xFF555B66);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 82),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// ASSET IMAGE
// Fixed size + placeholder + fade-in => image load hone par UI jump nahi karta.
// =============================================================================

class _AssetImage extends StatelessWidget {
  final dynamic imageUrl;
  final String category;
  final double width;
  final double height;
  final double borderRadius;

  const _AssetImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.category = 'Asset',
    this.borderRadius = 16,
  });

  static const Color primaryColor = Color(0xFF3157D5);

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.toString().trim() ?? '';

    final hasImage = url.isNotEmpty && url.toLowerCase() != 'null';

    final radius = BorderRadius.circular(borderRadius);

    Widget placeholder({bool loading = false}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FA),
          borderRadius: radius,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                )
              : Icon(
                  _categoryIcon(category),
                  size: 32,
                  color: primaryColor,
                ),
        ),
      );
    }

    if (!hasImage) {
      return placeholder();
    }

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: radius,
        child: Image.network(
          url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }

            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: child,
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }

            return placeholder(loading: true);
          },
          errorBuilder: (context, error, stackTrace) {
            return placeholder();
          },
        ),
      ),
    );
  }
}