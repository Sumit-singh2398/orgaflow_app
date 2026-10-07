import 'package:flutter/material.dart';

class DepartmentAssetsPage extends StatelessWidget {
  const DepartmentAssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = [
      ['Dell Latitude 5420', 'Assigned'],
      ['Samsung Galaxy A55', 'Assigned'],
      ['Canon DSLR', 'Available'],
      ['Epson Projector', 'Maintenance'],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Department Assets',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Assets of your department'),
        const SizedBox(height: 18),

        ...assets.map(
          (asset) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.devices_other,
                color: Color(0xFF3B5BDB),
              ),
              title: Text(
                asset[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(asset[1]),
              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          ),
        ),
      ],
    );
  }
}