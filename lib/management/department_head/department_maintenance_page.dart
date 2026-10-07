import 'package:flutter/material.dart';

class DepartmentMaintenancePage extends StatelessWidget {
  const DepartmentMaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ['Dell Latitude 5420', 'Battery issue'],
      ['Epson Projector', 'Display issue'],
      ['Wi-Fi Router', 'Network issue'],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Maintenance',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Department maintenance'),
        const SizedBox(height: 18),

        ...items.map(
          (item) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.build_outlined,
                color: Colors.orange,
              ),
              title: Text(
                item[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(item[1]),
              trailing: const Text(
                'In Progress',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}