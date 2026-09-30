import 'package:flutter/material.dart';

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

  // Requested Assets Tracker List
  final List<Map<String, dynamic>> myRequests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'My Requests',
              icon: Stack(
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    color: Color(0xFF3B5BDB),
                    size: 26,
                  ),
                  if (myRequests.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyRequestPage(
                      requests: myRequests,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
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
                      'Company assets currently available for request.',
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
    final String statusText = (asset['status'] ?? '').toString().trim();
    final bool isAvailable = statusText.toLowerCase() == 'available';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Asset Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
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
                            child: const Icon(
                              Icons.devices,
                              size: 80,
                              color: Color(0xFF3B5BDB),
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
                    const SizedBox(height: 16),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: (isAvailable ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 9,
                            color: isAvailable ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    _DetailRow(label: 'Brand', value: asset['brand']),
                    _DetailRow(label: 'Model', value: asset['model']),
                    _DetailRow(label: 'Processor', value: asset['processor']),
                    _DetailRow(label: 'RAM', value: asset['ram']),
                    _DetailRow(label: 'Storage', value: asset['storage']),
                    _DetailRow(label: 'Condition', value: asset['condition']),
                    _DetailRow(label: 'Location', value: asset['location']),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isAvailable
                            ? () {
                                Navigator.pop(context);
                                _showRequestDialog(context, asset);
                              }
                            : null,
                        icon: const Icon(Icons.send),
                        label: Text(
                          isAvailable ? 'Request Asset' : 'Not Available',
                          style: const TextStyle(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Request Asset',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for request',
                  hintText: 'e.g. Required for mobile app development',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reasonText = reasonController.text.trim();

                setState(() {
                  myRequests.add({
                    'requestId':
                        'REQ-${1000 + myRequests.length + 1}',
                    'assetName': asset['name'],
                    'category': asset['category'],
                    'requestDate': '30 Sep 2026',
                    'status': 'Pending',
                    'reason': reasonText.isEmpty
                        ? 'No reason specified'
                        : reasonText,
                    'image': asset['image'],
                  });
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Asset request submitted successfully!',
                    ),
                    action: SnackBarAction(
                      label: 'VIEW',
                      textColor: Colors.amber,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyRequestPage(
                              requests: myRequests,
                            ),
                          ),
                        );
                      },
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

// Asset Card Component
class _AssetCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onTap;

  const _AssetCard({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String statusText = (asset['status'] ?? '').toString().trim();
    final bool isAvailable = statusText.toLowerCase() == 'available';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    color: const Color(0xFFEDEFF5),
                    child: const Icon(
                      Icons.devices,
                      size: 70,
                      color: Color(0xFF3B5BDB),
                    ),
                  ),
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
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                          color: (isAvailable ? Colors.green : Colors.red)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: isAvailable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
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

// Detail Row Component
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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
              style: const TextStyle(color: Colors.grey, fontSize: 14),
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

// My Request Tracker Screen
class MyRequestPage extends StatelessWidget {
  final List<Map<String, dynamic>> requests;

  const MyRequestPage({super.key, required this.requests});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'pending':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF202020)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Requests',
          style: TextStyle(
            color: Color(0xFF202020),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.assignment_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Requests Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202020),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You haven\'t requested any assets yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Track Requested Assets',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202020),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'View status of your submitted asset requests.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = requests[index];
                          final status = item['status'] ?? 'Pending';
                          final statusColor = _getStatusColor(status);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      child: Image.network(
                                        item['image'],
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Container(
                                          width: 70,
                                          height: 70,
                                          color: const Color(0xFFEDEFF5),
                                          child: const Icon(
                                            Icons.devices,
                                            color: Color(0xFF3B5BDB),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['assetName'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF202020),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item['category']} • ${item['requestId']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Requested: ${item['requestDate']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getStatusIcon(status),
                                            size: 14,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            status,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (item['reason'] != null) ...[
                                  const Divider(height: 24),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Reason: ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item['reason'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}