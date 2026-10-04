import 'package:flutter/material.dart';

class AssetManagerProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerProfilePage({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        userData?['name']?.toString() ?? 'Asset Manager';

    final email =
        userData?['email']?.toString() ?? 'manager@orgaflow.com';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 15),

        const Center(
          child: CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFF3157D5),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 45,
            ),
          ),
        ),

        const SizedBox(height: 15),

        Center(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Center(
          child: Text(
            email,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ),

        const SizedBox(height: 30),

        _infoTile(
          Icons.badge_outlined,
          'Role',
          'Asset Manager',
        ),

        _infoTile(
          Icons.business_outlined,
          'Portal',
          'Management Portal',
        ),

        _infoTile(
          Icons.verified_user_outlined,
          'Account Status',
          'Active',
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF3157D5),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF172033),
          ),
        ),
      ),
    );
  }
}