import 'package:flutter/material.dart';

import 'admin_drawer.dart';
import 'admin_quick_action.dart';
import 'admin_section_page.dart';
import 'admin_stat_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const Color primary = Color(0xFF3157D5);
  static const Color textPrimary = Color(0xFF1F2937);

  int _selectedIndex = 0;

  final List<String> _titles = const [
    'Admin Dashboard',
    'Employees',
    'Assets',
    'Requests',
    'Maintenance',
    'Departments',
    'Reports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _buildAppBar(),
      drawer: AdminDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onProfileTap: () => _showMessage('Profile'),
        onLogoutTap: () => _logout(),
      ),
      body: _buildBody(),
    );
  }

  // ================= APP BAR =================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      title: Text(
        _titles[_selectedIndex],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showMessage('Notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 14),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: primary,
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= BODY =================

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const AdminSectionPage(
          icon: Icons.people_outline_rounded,
          title: 'Employees',
          subtitle: 'Manage employee accounts, roles and details.',
          buttonText: 'Add Employee',
        );

      case 2:
        return const AdminSectionPage(
          icon: Icons.devices_other_rounded,
          title: 'Assets',
          subtitle: 'Register, assign and track organization assets.',
          buttonText: 'Add Asset',
        );

      case 3:
        return const AdminSectionPage(
          icon: Icons.assignment_outlined,
          title: 'Requests',
          subtitle: 'Review employee and department requests.',
          buttonText: 'View Requests',
        );

      case 4:
        return const AdminSectionPage(
          icon: Icons.build_circle_outlined,
          title: 'Maintenance',
          subtitle: 'Track repair and maintenance activities.',
          buttonText: 'View Maintenance',
        );

      case 5:
        return const AdminSectionPage(
          icon: Icons.business_outlined,
          title: 'Departments',
          subtitle: 'Create and manage organization departments.',
          buttonText: 'Add Department',
        );

      case 6:
        return const AdminSectionPage(
          icon: Icons.bar_chart_rounded,
          title: 'Reports',
          subtitle: 'View organization-wide asset and employee reports.',
          buttonText: 'Generate Report',
        );

      default:
        return _dashboardPage();
    }
  }

  // ================= DASHBOARD =================

  Widget _dashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildStatCards(),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          AdminQuickAction(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Add Employee',
            subtitle: 'Create a new employee account',
            onTap: () => _showMessage('Add Employee'),
          ),
          AdminQuickAction(
            icon: Icons.add_box_outlined,
            title: 'Add Asset',
            subtitle: 'Register a new organization asset',
            onTap: () => _showMessage('Add Asset'),
          ),
          AdminQuickAction(
            icon: Icons.assignment_ind_outlined,
            title: 'Assign Asset',
            subtitle: 'Assign an asset to an employee',
            onTap: () => _showMessage('Assign Asset'),
          ),
          AdminQuickAction(
            icon: Icons.bar_chart_rounded,
            title: 'View Reports',
            subtitle: 'Check organization asset reports',
            onTap: () {
              setState(() {
                _selectedIndex = 6;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3157D5),
            Color(0xFF5B7FE8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Admin 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Manage your organization from one place.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: const [
        AdminStatCard(
          title: 'Employees',
          value: '128',
          icon: Icons.people_rounded,
        ),
        AdminStatCard(
          title: 'Total Assets',
          value: '356',
          icon: Icons.devices_rounded,
        ),
        AdminStatCard(
          title: 'Assigned Assets',
          value: '291',
          icon: Icons.assignment_turned_in_rounded,
        ),
        AdminStatCard(
          title: 'Pending Requests',
          value: '18',
          icon: Icons.pending_actions_rounded,
        ),
      ],
    );
  }

  // ================= MESSAGE =================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('$message screen will open here.'),
      ),
    );
  }

  // ================= LOGOUT =================

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}