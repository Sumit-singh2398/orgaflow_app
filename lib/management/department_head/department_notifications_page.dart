import 'package:flutter/material.dart';

class DepartmentNotificationsPage extends StatelessWidget {
  const DepartmentNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      'New laptop request received',
      'Dell Latitude is under maintenance',
      'Asset assigned successfully',
      'Monthly report is ready',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: notifications
            .map(
              (text) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF3B5BDB),
                  ),
                  title: Text(text),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}