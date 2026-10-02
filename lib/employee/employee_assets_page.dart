import 'package:flutter/material.dart';
import 'my_request.dart';

class EmployeeAssetsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EmployeeAssetsPage({
    super.key,
    this.userData,
  });

  @override
  State<EmployeeAssetsPage> createState() => _EmployeeAssetsPageState();
}

class _EmployeeAssetsPageState extends State<EmployeeAssetsPage> {
  static const Color primaryColor = Color(0xFF3157D5);
  static const Color darkColor = Color(0xFF172033);
  static const Color greyColor = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFF6F8FC);

  final List<Map<String, dynamic>> assets = [
    {
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'assetId': 'AST-001',
      'brand': 'Dell',
      'model': 'Latitude 5420',
      'productCode': 'LAT-5420',
      'processor': 'Intel Core i5',
      'ram': '16 GB',
      'storage': '512 GB SSD',
      'condition': 'Good',
      'location': 'Noida Office',
      'status': 'Available',
      'image':
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800',
    },
    {
      'name': 'Samsung Galaxy A55',
      'category': 'Smartphone',
      'assetId': 'AST-002',
      'brand': 'Samsung',
      'model': 'Galaxy A55',
      'productCode': 'SM-A556E',
      'processor': 'Octa-Core',
      'ram': '8 GB',
      'storage': '128 GB',
      'condition': 'Excellent',
      'location': 'Noida Office',
      'status': 'Available',
      'image':
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800',
    },
    {
      'name': 'Dell OptiPlex 7090',
      'category': 'Desktop',
      'assetId': 'AST-003',
      'brand': 'Dell',
      'model': 'OptiPlex 7090',
      'productCode': 'OPT7090MT',
      'processor': 'Intel Core i7',
      'ram': '16 GB',
      'storage': '512 GB SSD',
      'condition': 'Good',
      'location': 'Noida Office',
      'status': 'Not Available',
      'image':
          'https://images.unsplash.com/photo-1587831990711-23ca6441447b?w=800',
    },
    {
      'name': 'Dell 24 Monitor',
      'category': 'Monitor',
      'assetId': 'AST-004',
      'brand': 'Dell',
      'model': 'P2422H',
      'productCode': 'P2422H',
      'processor': 'N/A',
      'ram': 'N/A',
      'storage': 'N/A',
      'condition': 'Excellent',
      'location': 'Noida Office',
      'status': 'Available',
      'image':
          'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800',
    },
    {
      'name': 'Canon EOS 200D II',
      'category': 'DSLR Camera',
      'assetId': 'AST-005',
      'brand': 'Canon',
      'model': 'EOS 200D II',
      'productCode': 'EOS200D2',
      'processor': 'N/A',
      'ram': 'N/A',
      'storage': '32 GB SD Card',
      'condition': 'Good',
      'location': 'Noida Office',
      'status': 'Not Available',
      'image':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    },
    {
      'name': 'Manfrotto Compact Action',
      'category': 'Tripod',
      'assetId': 'AST-006',
      'brand': 'Manfrotto',
      'model': 'Compact Action',
      'productCode': 'MKA-COMPACT',
      'processor': 'N/A',
      'ram': 'N/A',
      'storage': 'N/A',
      'condition': 'Excellent',
      'location': 'Noida Office',
      'status': 'Available',
      'image':
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Available Assets',
          style: TextStyle(
            color: darkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: darkColor,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 700;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find an Asset',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Browse available company assets and request the asset you need.',
                      style: TextStyle(
                        fontSize: 15,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: assets.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio:
                            isWide ? 1.45 : 1.25,
                      ),
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> asset =
                            assets[index];

                        return _AssetCard(
                          asset: asset,
                          onTap: () {
                            _showAssetDetails(
                              context,
                              asset,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // OPEN REQUEST PAGE
  // ============================================================

  void _openRequestPage(
    BuildContext context,
    Map<String, dynamic> asset,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MyRequest(
            userData: widget.userData,
            asset: asset,
          );
        },
      ),
    );
  }

  // ============================================================
  // ASSET DETAILS
  // ============================================================

  void _showAssetDetails(
    BuildContext context,
    Map<String, dynamic> asset,
  ) {
    final String status =
        asset['status']?.toString() ?? '';

    final bool isAvailable =
        status.toLowerCase() == 'available';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Asset Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // IMAGE
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(16),
                      child: Image.network(
                        asset['image']?.toString() ?? '',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              context,
                              error,
                              stackTrace,
                            ) {
                          return Container(
                            height: 220,
                            width: double.infinity,
                            color:
                                const Color(0xFFEDEFF5),
                            child: const Icon(
                              Icons.devices,
                              size: 80,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ASSET NAME
                    Text(
                      asset['name']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${asset['category'] ?? ''} • ${asset['assetId'] ?? ''}',
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // STATUS
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: (isAvailable
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 9,
                            color: isAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            status,
                            style: TextStyle(
                              color: isAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 10),

                    // DETAILS
                    _DetailRow(
                      label: 'Asset ID',
                      value:
                          asset['assetId']?.toString() ??
                              '',
                    ),

                    _DetailRow(
                      label: 'Category',
                      value:
                          asset['category']?.toString() ??
                              '',
                    ),

                    _DetailRow(
                      label: 'Brand',
                      value:
                          asset['brand']?.toString() ?? '',
                    ),

                    _DetailRow(
                      label: 'Model',
                      value:
                          asset['model']?.toString() ?? '',
                    ),

                    _DetailRow(
                      label: 'Product Code',
                      value:
                          asset['productCode']
                                  ?.toString() ??
                              '',
                    ),

                    _DetailRow(
                      label: 'Processor',
                      value:
                          asset['processor']
                                  ?.toString() ??
                              '',
                    ),

                    _DetailRow(
                      label: 'RAM',
                      value:
                          asset['ram']?.toString() ?? '',
                    ),

                    _DetailRow(
                      label: 'Storage',
                      value:
                          asset['storage']?.toString() ??
                              '',
                    ),

                    _DetailRow(
                      label: 'Condition',
                      value:
                          asset['condition']
                                  ?.toString() ??
                              '',
                    ),

                    _DetailRow(
                      label: 'Location',
                      value:
                          asset['location']
                                  ?.toString() ??
                              '',
                    ),

                    const SizedBox(height: 25),

                    // REQUEST BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isAvailable
                            ? () {
                                Navigator.pop(
                                  dialogContext,
                                );

                                _openRequestPage(
                                  context,
                                  asset,
                                );
                              }
                            : null,
                        icon: const Icon(
                          Icons.send,
                        ),
                        label: Text(
                          isAvailable
                              ? 'Request This Asset'
                              : 'Not Available',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryColor,
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              Colors.grey.shade300,
                          disabledForegroundColor:
                              Colors.grey.shade600,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// ASSET CARD
// ============================================================

class _AssetCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onTap;

  const _AssetCard({
    required this.asset,
    required this.onTap,
  });

  Color? get primaryColor => null;

  Color? get greyColor => null;

  Color? get darkColor => null;

  @override
  Widget build(BuildContext context) {
    final String status =
        asset['status']?.toString() ?? '';

    final bool isAvailable =
        status.toLowerCase() == 'available';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5E8EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // IMAGE
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    asset['image']?.toString() ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          context,
                          error,
                          stackTrace,
                        ) {
                      return Container(
                        width: double.infinity,
                        color:
                            const Color(0xFFEDEFF5),
                        child: Icon(
                          Icons.devices,
                          size: 70,
                          color: primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // CONTENT
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset['name']?.toString() ?? '',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      asset['category']?.toString() ?? '',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // STATUS
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: (isAvailable
                                    ? Colors.green
                                    : Colors.red)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 7,
                                color: isAvailable
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                status,
                                style: TextStyle(
                                  color: isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: onTap,
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight:
                                  FontWeight.w600,
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
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}