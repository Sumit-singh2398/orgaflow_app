import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'More',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Color(0xFF1A1A1A), size: 26),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE8EEFF),
                    child: const Text(
                      'SS',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Sumit Singh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                        Text('Employee · IT Department', style: TextStyle(fontSize: 14, color: Color(0xFF777777))),
                        Text('sumit@assetflow.com', style: TextStyle(fontSize: 14, color: Color(0xFF777777))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

        
              _buildMenuItem(Icons.inventory_2_outlined, 'My Assets', () {}),
              _buildMenuItem(Icons.swap_horiz, 'Transfer Requests', () {}),
              _buildMenuItem(Icons.assignment_turned_in_outlined, 'Audit', () {}),
              _buildMenuItem(Icons.analytics_outlined, 'Reports', () {}),
              _buildMenuItem(Icons.notifications_none_outlined, 'Notifications', () {}),
              const SizedBox(height: 20),
              _buildMenuItem(Icons.help_outline, 'Help', () {}),
              const SizedBox(height: 10),
              _buildLogoutItem(Icons.logout, 'Logout', () {}),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for standard menu items
  static Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF3B5BDB), size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF888888)),
      onTap: onTap,
    );
  }

  // Helper widget for Logout (Red colored)
  static Widget _buildLogoutItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.red.shade400, size: 24),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red.shade400)),
      onTap: onTap,
    );
  }
}