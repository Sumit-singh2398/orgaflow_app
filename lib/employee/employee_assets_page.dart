import 'package:flutter/material.dart';

class EmployeeAssetsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const EmployeeAssetsPage({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final assets = [
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
    'status': 'Available',
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
    'status': 'Available',
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
  {
    'name': 'Epson EB-E01',
    'category': 'Projector',
    'assetId': 'AST-007',
    'brand': 'Epson',
    'model': 'EB-E01',
    'productCode': 'V11H975050',
    'processor': 'N/A',
    'ram': 'N/A',
    'storage': 'N/A',
    'condition': 'Good',
    'location': 'Noida Office',
    'status': 'Available',
    'image':
        'https://images.unsplash.com/photo-1626379953822-baec19c3accd?w=800',
  },
  {
    'name': 'Samsung 65" Conference Display',
    'category': 'Conference Display',
    'assetId': 'AST-008',
    'brand': 'Samsung',
    'model': '65" Crystal UHD',
    'productCode': 'UA65CU7700',
    'processor': 'Crystal Processor 4K',
    'ram': 'N/A',
    'storage': 'N/A',
    'condition': 'Excellent',
    'location': 'Conference Room',
    'status': 'Available',
    'image':
        'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800',
  },
  {
    'name': 'APC Back-UPS 1100VA',
    'category': 'UPS',
    'assetId': 'AST-009',
    'brand': 'APC',
    'model': 'Back-UPS 1100VA',
    'productCode': 'BX1100C-IN',
    'processor': 'N/A',
    'ram': 'N/A',
    'storage': 'N/A',
    'condition': 'Good',
    'location': 'IT Storage Room',
    'status': 'Available',
    'image':
        'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=800',
  },
  {
    'name': 'TP-Link Archer AX55',
    'category': 'Wi-Fi Router',
    'assetId': 'AST-010',
    'brand': 'TP-Link',
    'model': 'Archer AX55',
    'productCode': 'ARCHER-AX55',
    'processor': 'Quad-Core CPU',
    'ram': 'N/A',
    'storage': 'N/A',
    'condition': 'Excellent',
    'location': 'IT Department',
    'status': 'Available',
    'image':
        'https://images.unsplash.com/photo-1646900074939-4f6b7f8e0a7e?w=800',
  },
];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Available Assets',
          style: TextStyle(
            color: Color(0xFF202124),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF202124),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

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
                        color: Color(0xFF202124),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Browse company assets currently available for request.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 28),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: assets.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: isWide ? 1.45 : 1.25,
                      ),
                      itemBuilder: (context, index) {
                        final asset = assets[index];

                        return _AssetCard(
                          asset: asset,
                          onTap: () {
                            _showAssetDetails(context, asset);
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

  void _showAssetDetails(
    BuildContext context,
    Map<String, dynamic> asset,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 550,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Asset Details',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
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

                    const SizedBox(height: 15),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        asset['image'],
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            color: const Color(0xFFEDEFF5),
                            child: Icon(
                              asset['category'] == 'Laptop'
                                  ? Icons.laptop_mac
                                  : Icons.smartphone,
                              size: 80,
                              color: const Color(0xFF3B5BDB),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      asset['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF202124),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${asset['category']} • ${asset['assetId']}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 9,
                            color: Colors.green,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Available',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 10),

                    _DetailRow(
                      label: 'Brand',
                      value: asset['brand'],
                    ),

                    _DetailRow(
                      label: 'Model',
                      value: asset['model'],
                    ),

                    _DetailRow(
                      label: 'Processor',
                      value: asset['processor'],
                    ),

                    _DetailRow(
                      label: 'RAM',
                      value: asset['ram'],
                    ),

                    _DetailRow(
                      label: 'Storage',
                      value: asset['storage'],
                    ),

                    _DetailRow(
                      label: 'Condition',
                      value: asset['condition'],
                    ),

                    _DetailRow(
                      label: 'Location',
                      value: asset['location'],
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRequestDialog(
                            context,
                            asset,
                          );
                        },
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Request Asset',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B5BDB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  void _showRequestDialog(
    BuildContext context,
    Map<String, dynamic> asset,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Request Asset',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for request',
                  hintText: 'e.g. Required for development work',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Asset request submitted successfully.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BDB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }
}

class _AssetCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onTap;

  const _AssetCard({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.network(
                  asset['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      color: const Color(0xFFEDEFF5),
                      child: Icon(
                        asset['category'] == 'Laptop'
                            ? Icons.laptop_mac
                            : Icons.smartphone,
                        size: 70,
                        color: const Color(0xFF3B5BDB),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202124),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    asset['category'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: Colors.green,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Available',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      TextButton(
                        onPressed: onTap,
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            color: Color(0xFF3B5BDB),
                            fontWeight: FontWeight.w600,
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
    );
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF202124),
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