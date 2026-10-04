import 'package:flutter/material.dart';

class AssetManagerAssetsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerAssetsPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerAssetsPage> createState() =>
      _AssetManagerAssetsPageState();
}

class _AssetManagerAssetsPageState
    extends State<AssetManagerAssetsPage> {
  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> assets = [
    {
      'id': 'AST-001',
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'employee': 'Rahul Sharma',
      'status': 'Assigned',
    },
    {
      'id': 'AST-002',
      'name': 'Samsung Galaxy A55',
      'category': 'Mobile',
      'employee': 'Neha Singh',
      'status': 'Assigned',
    },
    {
      'id': 'AST-003',
      'name': 'Canon DSLR',
      'category': 'Camera',
      'employee': '',
      'status': 'Available',
    },
    {
      'id': 'AST-004',
      'name': 'Epson Projector',
      'category': 'Projector',
      'employee': '',
      'status': 'Maintenance',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search assets...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredAssets.length,
            itemBuilder: (context, index) {
              final asset = _filteredAssets[index];

              return _assetCard(asset);
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> get _filteredAssets {
    final query =
        searchController.text.trim().toLowerCase();

    if (query.isEmpty) return assets;

    return assets.where((asset) {
      return asset['name']
              .toString()
              .toLowerCase()
              .contains(query) ||
          asset['id']
              .toString()
              .toLowerCase()
              .contains(query) ||
          asset['category']
              .toString()
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  Widget _assetCard(Map<String, dynamic> asset) {
    final status = asset['status'].toString();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EDFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.devices_other_outlined,
            color: Color(0xFF3157D5),
          ),
        ),
        title: Text(
          asset['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${asset['id']} • ${asset['category']}',
          ),
        ),
        trailing: _statusChip(status),
        onTap: () => _showDetails(asset),
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: status == 'Available'
            ? Colors.green.withOpacity(.1)
            : status == 'Maintenance'
                ? Colors.orange.withOpacity(.1)
                : Colors.blue.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: status == 'Available'
              ? Colors.green
              : status == 'Maintenance'
                  ? Colors.orange
                  : Colors.blue,
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> asset) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text('Asset ID: ${asset['id']}'),
              Text('Category: ${asset['category']}'),
              Text(
                'Assigned To: ${asset['employee'].toString().isEmpty ? 'Not Assigned' : asset['employee']}',
              ),
              Text('Status: ${asset['status']}'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Edit Asset'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}