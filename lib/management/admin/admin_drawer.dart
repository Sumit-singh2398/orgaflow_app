import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  static const Color primary = Color(0xFF3157D5);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3157D5),
                  Color(0xFF5B7FE8),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: primary,
                    size: 34,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Organization Administrator',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _drawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  index: 0,
                ),
                _drawerItem(
                  context,
                  icon: Icons.people_outline,
                  title: 'Employees',
                  index: 1,
                ),
                _drawerItem(
                  context,
                  icon: Icons.devices_other_outlined,
                  title: 'Assets',
                  index: 2,
                ),
                _drawerItem(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Requests',
                  index: 3,
                ),
                _drawerItem(
                  context,
                  icon: Icons.build_outlined,
                  title: 'Maintenance',
                  index: 4,
                ),
                _drawerItem(
                  context,
                  icon: Icons.business_outlined,
                  title: 'Departments',
                  index: 5,
                ),
                _drawerItem(
                  context,
                  icon: Icons.bar_chart_outlined,
                  title: 'Reports',
                  index: 6,
                ),
                const Divider(height: 28),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    onProfileTap();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onLogoutTap();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        selected: selected,
        selectedTileColor: primary.withValues(alpha: 0.10),
        leading: Icon(
          icon,
          color: selected ? primary : Colors.grey.shade700,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : Colors.black87,
          ),
        ),
        onTap: () {
          onItemSelected(index);
          Navigator.pop(context);
        },
      ),
    );
  }
}