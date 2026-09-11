import 'package:flutter/material.dart';

class DepartmentHeadDashboard extends StatefulWidget {
  const DepartmentHeadDashboard({super.key});

  @override
  State<DepartmentHeadDashboard> createState() =>
      _DepartmentHeadDashboardState();
}

class _DepartmentHeadDashboardState
    extends State<DepartmentHeadDashboard> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Department Head Dashboard',
    'Department Employees',
    'Department Assets',
    'Requests',
    'Maintenance',
    'Department Reports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),

        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              _showMessage('Notifications');
            },
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFF3B5BDB),
              child: const Text(
                'DH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      // =====================================================
      // DRAWER
      // =====================================================

      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                55,
                20,
                25,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF3B5BDB),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_tree_outlined,
                      color: Color(0xFF3B5BDB),
                      size: 34,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Department Head',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Department Management',
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
                  // Dashboard

                  _drawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    index: 0,
                  ),

                  // Employees

                  _drawerItem(
                    icon: Icons.people_outline,
                    title: 'Department Employees',
                    index: 1,
                  ),

                  // Assets

                  _drawerItem(
                    icon: Icons.devices_other_outlined,
                    title: 'Department Assets',
                    index: 2,
                  ),

                  // Requests

                  _drawerItem(
                    icon: Icons.assignment_outlined,
                    title: 'Requests',
                    index: 3,
                  ),

                  // Maintenance

                  _drawerItem(
                    icon: Icons.build_outlined,
                    title: 'Maintenance',
                    index: 4,
                  ),

                  // Reports

                  _drawerItem(
                    icon: Icons.bar_chart_outlined,
                    title: 'Department Reports',
                    index: 5,
                  ),

                  const Divider(),

                  // Notifications

                  ListTile(
                    leading: const Icon(
                      Icons.notifications_none,
                    ),
                    title: const Text(
                      'Notifications',
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      _showMessage(
                        'Notifications',
                      );
                    },
                  ),

                  // Profile

                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                    ),
                    title: const Text(
                      'Profile',
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      _showMessage(
                        'Profile',
                      );
                    },
                  ),

                  // Logout

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

      // =====================================================
      // BODY
      // =====================================================

      body: _buildBody(),
    );
  }

  // =====================================================
  // BODY SWITCH
  // =====================================================

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
        return _reportsPage();

      default:
        return _dashboardPage();
    }
  }

  // =====================================================
  // DASHBOARD
  // =====================================================

  Widget _dashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Welcome, Department Head 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Monitor your department employees, assets and requests.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 22),

          // =================================================
          // DEPARTMENT INFO
          // =================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(15),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset:
                      const Offset(0, 3),
                ),
              ],
            ),

            child: const Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor:
                      Color(0xFFE8EDFF),
                  child: Icon(
                    Icons.business_outlined,
                    color:
                        Color(0xFF3B5BDB),
                    size: 28,
                  ),
                ),

                SizedBox(width: 15),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Department',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Department Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // =================================================
          // STAT CARDS
          // =================================================

          GridView.count(
            crossAxisCount: 2,

            shrinkWrap: true,

            physics:
                const NeverScrollableScrollPhysics(),

            crossAxisSpacing: 12,

            mainAxisSpacing: 12,

            childAspectRatio: 1.35,

            children: [
              _statCard(
                title: 'Employees',
                value: '42',
                icon: Icons.people_outline,
              ),

              _statCard(
                title: 'Department Assets',
                value: '96',
                icon: Icons.devices_other_outlined,
              ),

              _statCard(
                title: 'Pending Requests',
                value: '8',
                icon: Icons.pending_actions,
              ),

              _statCard(
                title: 'Maintenance',
                value: '5',
                icon: Icons.build_outlined,
              ),
            ],
          ),

          const SizedBox(height: 25),

          // =================================================
          // QUICK ACTIONS
          // =================================================

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _quickAction(
            icon: Icons.people_outline,
            title: 'View Employees',
            subtitle:
                'View employees in your department',
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),

          _quickAction(
            icon: Icons.devices_other_outlined,
            title: 'View Department Assets',
            subtitle:
                'Check assets assigned to your department',
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),

          _quickAction(
            icon: Icons.assignment_outlined,
            title: 'Review Requests',
            subtitle:
                'Review employee requests',
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),

          _quickAction(
            icon: Icons.build_outlined,
            title: 'Maintenance',
            subtitle:
                'Check department maintenance requests',
            onTap: () {
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),

          _quickAction(
            icon: Icons.bar_chart_outlined,
            title: 'Department Reports',
            subtitle:
                'View department reports',
            onTap: () {
              setState(() {
                _selectedIndex = 5;
              });
            },
          ),
        ],
      ),
    );
  }

  // =====================================================
  // EMPLOYEES
  // =====================================================

  Widget _employeesPage() {
    return _simplePage(
      icon: Icons.people_outline,
      title: 'Department Employees',
      subtitle:
          'View employees belonging to your department.',
      buttonText: 'View Employees',
    );
  }

  // =====================================================
  // ASSETS
  // =====================================================

  Widget _assetsPage() {
    return _simplePage(
      icon: Icons.devices_other_outlined,
      title: 'Department Assets',
      subtitle:
          'View assets assigned to your department.',
      buttonText: 'View Assets',
    );
  }

  // =====================================================
  // REQUESTS
  // =====================================================

  Widget _requestsPage() {
    return _simplePage(
      icon: Icons.assignment_outlined,
      title: 'Requests',
      subtitle:
          'Review requests submitted by department employees.',
      buttonText: 'View Requests',
    );
  }

  // =====================================================
  // MAINTENANCE
  // =====================================================

  Widget _maintenancePage() {
    return _simplePage(
      icon: Icons.build_outlined,
      title: 'Maintenance',
      subtitle:
          'Monitor maintenance requests from your department.',
      buttonText: 'View Maintenance',
    );
  }

  // =====================================================
  // REPORTS
  // =====================================================

  Widget _reportsPage() {
    return _simplePage(
      icon: Icons.bar_chart_outlined,
      title: 'Department Reports',
      subtitle:
          'View employee, asset and request reports for your department.',
      buttonText: 'Generate Report',
    );
  }

  // =====================================================
  // SIMPLE PAGE
  // =====================================================

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
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 70,
              color:
                  const Color(0xFF3B5BDB),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
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

              icon: const Icon(
                Icons.arrow_forward,
              ),

              label: Text(buttonText),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF3B5BDB),
                foregroundColor:
                    Colors.white,

                padding:
                    const EdgeInsets.symmetric(
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

  // =====================================================
  // DRAWER ITEM
  // =====================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool selected =
        _selectedIndex == index;

    return ListTile(
      selected: selected,

      selectedTileColor:
          const Color(0xFFE8EDFF),

      leading: Icon(
        icon,
        color: selected
            ? const Color(0xFF3B5BDB)
            : Colors.grey.shade700,
      ),

      title: Text(
        title,

        style: TextStyle(
          fontWeight: selected
              ? FontWeight.bold
              : FontWeight.normal,

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

  // =====================================================
  // STAT CARD
  // =====================================================

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color:
                const Color(0xFF3B5BDB),
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

  // =====================================================
  // QUICK ACTION
  // =====================================================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,

      margin:
          const EdgeInsets.only(bottom: 10),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),

        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFFE8EDFF),

          child: Icon(
            icon,
            color:
                const Color(0xFF3B5BDB),
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle),

        trailing:
            const Icon(Icons.chevron_right),

        onTap: onTap,
      ),
    );
  }

  // =====================================================
  // MESSAGE
  // =====================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$message screen will open here.',
        ),
      ),
    );
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  void _logout() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),

          content: const Text(
            'Are you sure you want to logout?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cancel',
              ),
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

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),

              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }
}