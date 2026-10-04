import 'package:flutter/material.dart';

class AssetManagerReportsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerReportsPage({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Asset Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'View organization asset usage and status reports.',
          style: TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 22),

        _reportCard(
          context,
          Icons.inventory_2_outlined,
          'Asset Inventory Report',
          'Overview of all organization assets.',
        ),

        _reportCard(
          context,
          Icons.assignment_turned_in_outlined,
          'Assignment Report',
          'View assets assigned to employees.',
        ),

        _reportCard(
          context,
          Icons.build_outlined,
          'Maintenance Report',
          'View maintenance activity and pending work.',
        ),

        _reportCard(
          context,
          Icons.swap_horiz,
          'Transfer Report',
          'View asset transfer history.',
        ),
      ],
    );
  }

  Widget _reportCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8EDFF),
          child: Icon(
            icon,
            color: const Color(0xFF3157D5),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.download_outlined),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title will be generated.'),
            ),
          );
        },
      ),
    );
  }
}