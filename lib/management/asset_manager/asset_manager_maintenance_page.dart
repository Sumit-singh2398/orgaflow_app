import 'package:flutter/material.dart';

class AssetManagerMaintenancePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerMaintenancePage({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final maintenance = [
      {
        'asset': 'Epson Projector',
        'id': 'AST-004',
        'issue': 'Display not working',
        'status': 'In Progress',
      },
      {
        'asset': 'Dell Latitude 5420',
        'id': 'AST-010',
        'issue': 'Battery replacement',
        'status': 'Pending',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Maintenance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Track assets currently under maintenance.',
          style: TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 20),

        ...maintenance.map(
          (item) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor:
                    Colors.orange.withOpacity(.12),
                child: const Icon(
                  Icons.build_outlined,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                item['asset']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${item['id']}\n${item['issue']}',
              ),
              isThreeLine: true,
              trailing: Text(
                item['status']!,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}