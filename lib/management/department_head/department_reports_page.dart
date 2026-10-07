import 'package:flutter/material.dart';

class DepartmentReportsPage extends StatelessWidget {
  const DepartmentReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      ['Employee Report', Icons.people_outline],
      ['Asset Report', Icons.devices_other_outlined],
      ['Request Report', Icons.assignment_outlined],
      ['Maintenance Report', Icons.build_outlined],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Department Reports',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Department reports'),
        const SizedBox(height: 18),

        ...reports.map(
          (report) => Card(
            child: ListTile(
              leading: Icon(
                report[1] as IconData,
                color: const Color(0xFF3B5BDB),
              ),
              title: Text(
                report[0] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}