// ignore: unused_element
import 'package:flutter/material.dart';
import 'department_employees_page.dart';
import 'department_assets_page.dart';
import 'department_requests_page.dart';
import 'department_maintenance_page.dart';
import 'department_reports_page.dart';
import 'department_notifications_page.dart';
import 'department_head_profile_page.dart';

class DepartmentHeadDashboard extends StatefulWidget {
  const DepartmentHeadDashboard({super.key});

  @override
  State<DepartmentHeadDashboard> createState() =>
      _DepartmentHeadDashboardState();
}

class _DepartmentHeadDashboardState
    extends State<DepartmentHeadDashboard> {
  int _selectedIndex = 0;

  final Color primaryColor = const Color(0xFF3B5BDB);
  final Color backgroundColor = const Color(0xFFF4F6FA);

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
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1F2937),
      centerTitle: false,

      title: Text(
        _titles[_selectedIndex],
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DepartmentNotificationsPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
          ),
        ),

        const SizedBox(width: 4),

        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DepartmentHeadProfilePage(),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFF3B5BDB),
              child: Text(
                'DH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // DRAWER
  // =========================================================

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              22,
              55,
              20,
              25,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF3B5BDB),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.account_tree_rounded,
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

                SizedBox(height: 5),

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
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              children: [
                _drawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  index: 0,
                ),

                _drawerItem(
                  icon: Icons.people_outline_rounded,
                  title: 'Department Employees',
                  index: 1,
                ),

                _drawerItem(
                  icon: Icons.devices_other_outlined,
                  title: 'Department Assets',
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
                  icon: Icons.bar_chart_outlined,
                  title: 'Department Reports',
                  index: 5,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Divider(),
                ),

                ListTile(
                  leading: const Icon(
                    Icons.notifications_none_rounded,
                  ),
                  title: const Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DepartmentNotificationsPage(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                  ),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DepartmentHeadProfilePage(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DRAWER ITEM
  // =========================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      child: ListTile(
        selected: selected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedTileColor: const Color(0xFFE8EDFF),

        leading: Icon(
          icon,
          color: selected
              ? primaryColor
              : Colors.grey.shade700,
        ),

        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? primaryColor
                : const Color(0xFF374151),
          ),
        ),

        trailing: selected
            ? Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: primaryColor,
              )
            : null,

        onTap: () {
          setState(() {
            _selectedIndex = index;
          });

          Navigator.pop(context);
        },
      ),
    );
  }

  // =========================================================
  // BODY
  // =========================================================

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const DepartmentEmployeesPage();

      case 2:
        return const DepartmentAssetsPage();

      case 3:
        return const DepartmentRequestsPage();

      case 4:
        return const DepartmentMaintenancePage();

      case 5:
        return const DepartmentReportsPage();

      default:
        return _dashboardPage();
    }
  }

  // =========================================================
  // DASHBOARD
  // =========================================================

  Widget _dashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Department Head 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Monitor your department employees, assets and requests.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 22),

          _departmentCard(),

          const SizedBox(height: 22),

          _sectionTitle(
            'Department Overview',
            'Current department statistics',
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.28,
            children: [
              _statCard(
                title: 'Employees',
                value: '42',
                icon: Icons.people_outline_rounded,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),

              _statCard(
                title: 'Department Assets',
                value: '96',
                icon: Icons.devices_other_outlined,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),

              _statCard(
                title: 'Pending Requests',
                value: '8',
                icon: Icons.pending_actions_outlined,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),

              _statCard(
                title: 'Maintenance',
                value: '5',
                icon: Icons.build_outlined,
                onTap: () {
                  setState(() {
                    _selectedIndex = 4;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 25),

          _sectionTitle(
            'Quick Actions',
            'Frequently used department operations',
          ),

          const SizedBox(height: 14),

          _quickAction(
            icon: Icons.people_outline_rounded,
            title: 'View Employees',
            subtitle:
                'Manage employees belonging to your department.',
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),

          _quickAction(
            icon: Icons.devices_other_outlined,
            title: 'Department Assets',
            subtitle:
                'Check assets assigned to your department.',
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
                'Review and process employee requests.',
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
                'Monitor assets currently under maintenance.',
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
                'View department performance and reports.',
            onTap: () {
              setState(() {
                _selectedIndex = 5;
              });
            },
          ),

          const SizedBox(height: 20),

          _recentActivity(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =========================================================
  // DEPARTMENT CARD
  // =========================================================

  Widget _departmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B5BDB),
            Color(0xFF5472E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.business_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Department',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Department Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Department Head Portal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDFF),
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 23,
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
              ],
            ),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // QUICK ACTION
  // =========================================================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 6,
        ),
        leading: CircleAvatar(
          radius: 23,
          backgroundColor:
              const Color(0xFFE8EDFF),
          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
        onTap: onTap,
      ),
    );
  }

  // =========================================================
  // RECENT ACTIVITY
  // =========================================================

  Widget _recentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 14),

          _activityItem(
            icon: Icons.assignment_outlined,
            title: 'New asset request',
            subtitle:
                'Employee requested a laptop',
            time: '10 min ago',
          ),

          _activityItem(
            icon: Icons.build_outlined,
            title: 'Maintenance update',
            subtitle:
                'Dell Latitude marked for repair',
            time: '1 hour ago',
          ),

          _activityItem(
            icon: Icons.devices_other_outlined,
            title: 'Asset assigned',
            subtitle:
                'Samsung Galaxy assigned to employee',
            time: '2 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
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
