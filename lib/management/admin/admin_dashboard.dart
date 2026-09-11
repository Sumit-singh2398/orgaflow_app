import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<String> _titles = [
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
      backgroundColor: const Color(0xFFF4F6FA),

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),

        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              _showMessage('Notifications');
            },
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFF3B5BDB),
              child: const Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      // ================= DRAWER =================
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 55, 20, 25),
              decoration: const BoxDecoration(
                color: Color(0xFF3B5BDB),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFF3B5BDB),
                      size: 35,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    index: 0,
                  ),

                  _drawerItem(
                    icon: Icons.people_outline,
                    title: 'Employees',
                    index: 1,
                  ),

                  _drawerItem(
                    icon: Icons.devices_other_outlined,
                    title: 'Assets',
                    index: 2,
                  ),

                  _drawerItem(
                    icon: Icons.assignment_outlined,
                    title: 'Requests',
                    index: 3,
                  ),

                  _drawerItem(
                    icon: Icons.build_outlined,
                    title: 'Maintenance',
                    index: 4,
                  ),

                  _drawerItem(
                    icon: Icons.business_outlined,
                    title: 'Departments',
                    index: 5,
                  ),

                  _drawerItem(
                    icon: Icons.bar_chart_outlined,
                    title: 'Reports',
                    index: 6,
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage('Profile');
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      _logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: _buildBody(),
    );
  }

  // ================= BODY SWITCH =================

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return _employeesPage();

      case 2:
        return _assetsPage();

      case 3:
        return _requestsPage();

      case 4:
        return _maintenancePage();

      case 5:
        return _departmentsPage();

      case 6:
        return _reportsPage();

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
          const Text(
            'Welcome, Admin 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Manage your organization from one place.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 22),

          // ================= STAT CARDS =================

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _statCard(
                title: 'Employees',
                value: '128',
                icon: Icons.people,
              ),

              _statCard(
                title: 'Total Assets',
                value: '356',
                icon: Icons.devices,
              ),

              _statCard(
                title: 'Assigned Assets',
                value: '291',
                icon: Icons.assignment_turned_in,
              ),

              _statCard(
                title: 'Pending Requests',
                value: '18',
                icon: Icons.pending_actions,
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _quickAction(
            icon: Icons.person_add_alt_1,
            title: 'Add Employee',
            subtitle: 'Create a new employee account',
            onTap: () {
              _showMessage('Add Employee');
            },
          ),

          _quickAction(
            icon: Icons.add_box_outlined,
            title: 'Add Asset',
            subtitle: 'Register a new organization asset',
            onTap: () {
              _showMessage('Add Asset');
            },
          ),

          _quickAction(
            icon: Icons.assignment_ind_outlined,
            title: 'Assign Asset',
            subtitle: 'Assign an asset to an employee',
            onTap: () {
              _showMessage('Assign Asset');
            },
          ),

          _quickAction(
            icon: Icons.bar_chart,
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

  // ================= EMPLOYEES =================

  Widget _employeesPage() {
    return _simplePage(
      icon: Icons.people_outline,
      title: 'Employees',
      subtitle: 'Manage all organization employees.',
      buttonText: 'Add Employee',
    );
  }

  // ================= ASSETS =================

  Widget _assetsPage() {
    return _simplePage(
      icon: Icons.devices_other_outlined,
      title: 'Assets',
      subtitle: 'View and manage all organization assets.',
      buttonText: 'Add Asset',
    );
  }

  // ================= REQUESTS =================

  Widget _requestsPage() {
    return _simplePage(
      icon: Icons.assignment_outlined,
      title: 'Requests',
      subtitle: 'Review employee and department requests.',
      buttonText: 'View Requests',
    );
  }

  // ================= MAINTENANCE =================

  Widget _maintenancePage() {
    return _simplePage(
      icon: Icons.build_outlined,
      title: 'Maintenance',
      subtitle: 'Manage asset maintenance requests.',
      buttonText: 'View Maintenance',
    );
  }

  // ================= DEPARTMENTS =================

  Widget _departmentsPage() {
    return _simplePage(
      icon: Icons.business_outlined,
      title: 'Departments',
      subtitle: 'Manage organization departments.',
      buttonText: 'Add Department',
    );
  }

  // ================= REPORTS =================

  Widget _reportsPage() {
    return _simplePage(
      icon: Icons.bar_chart_outlined,
      title: 'Reports',
      subtitle: 'View organization-wide asset and employee reports.',
      buttonText: 'Generate Report',
    );
  }

  // ================= COMMON PAGE =================

  Widget _simplePage({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 70,
              color: const Color(0xFF3B5BDB),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: () {
                _showMessage(buttonText);
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BDB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DRAWER ITEM =================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool selected = _selectedIndex == index;

    return ListTile(
      selected: selected,
      selectedTileColor: const Color(0xFFE8EDFF),
      leading: Icon(
        icon,
        color: selected
            ? const Color(0xFF3B5BDB)
            : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
          color: selected
              ? const Color(0xFF3B5BDB)
              : Colors.black87,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        Navigator.pop(context);
      },
    );
  }

  // ================= STAT CARD =================

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF3B5BDB),
            size: 28,
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ================= QUICK ACTION =================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8EDFF),
          child: Icon(
            icon,
            color: const Color(0xFF3B5BDB),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // ================= MESSAGE =================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message screen will open here.'),
      ),
    );
  }

  // ================= LOGOUT =================

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

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