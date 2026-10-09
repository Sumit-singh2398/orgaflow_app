
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

  static const Color primary = Color(0xFF3B5BDB);
  static const Color primaryDark = Color(0xFF2946B8);
  static const Color background = Color(0xFFF5F7FC);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF788197);
  static const Color borderColor = Color(0xFFE8ECF4);

  final List<String> _titles = [
    'Dashboard',
    'Employees',
    'Department Assets',
    'Requests',
    'Maintenance',
    'Reports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: SafeArea(child: _buildBody()),
    );
  }

  // APP BAR

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      surfaceTintColor: Colors.white,
      titleSpacing: 0,
      title: Text(
        _titles[_selectedIndex],
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: _openNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _openProfile,
            child: const CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFFE8EDFF),
              child: Text(
                'DH',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // DRAWER

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 55, 22, 27),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryDark, primary, Color(0xFF7187F2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.account_tree_rounded,
                    size: 31,
                    color: primary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Orgaflow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Department Head Portal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _drawerItem(
                  Icons.space_dashboard_rounded,
                  'Dashboard',
                  0,
                ),
                _drawerItem(
                  Icons.groups_rounded,
                  'Employees',
                  1,
                ),
                _drawerItem(
                  Icons.devices_rounded,
                  'Department Assets',
                  2,
                ),
                _drawerItem(
                  Icons.assignment_rounded,
                  'Requests',
                  3,
                ),
                _drawerItem(
                  Icons.handyman_rounded,
                  'Maintenance',
                  4,
                ),
                _drawerItem(
                  Icons.analytics_rounded,
                  'Reports',
                  5,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: borderColor),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_none_rounded,
                  ),
                  title: const Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                    _openNotifications();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('My Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    _openProfile();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'ORGANIZATION ASSET PORTAL',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.2,
                color: textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    final selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        selected: selected,
        selectedTileColor: const Color(0xFFEFF2FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        leading: Icon(
          icon,
          color: selected ? primary : textMuted,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? primary : textDark,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: selected
            ? const Icon(
                Icons.chevron_right_rounded,
                color: primary,
              )
            : null,
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  // NAVIGATION

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

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DepartmentNotificationsPage(),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DepartmentHeadProfilePage(),
      ),
    );
  }

  void _navigateTo(int index) {
    setState(() => _selectedIndex = index);
  }

  // MAIN DASHBOARD

  Widget _dashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back! 👋',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: textDark,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Here is what is happening in your department.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 23),

          _departmentBanner(),

          const SizedBox(height: 27),

          _sectionHeading(
            'Department Overview',
            'A quick look at your department',
            icon: Icons.insights_rounded,
          ),

          const SizedBox(height: 15),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 4 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 4 ? 1.05 : 1.23,
                children: [
                  _statCard(
                    title: 'Employees',
                    value: '42',
                    icon: Icons.groups_rounded,
                    color: const Color(0xFF3B5BDB),
                    backgroundColor: const Color(0xFFEDF0FF),
                    onTap: () => _navigateTo(1),
                  ),
                  _statCard(
                    title: 'Total Assets',
                    value: '96',
                    icon: Icons.devices_rounded,
                    color: const Color(0xFF078A71),
                    backgroundColor: const Color(0xFFE4F7F1),
                    onTap: () => _navigateTo(2),
                  ),
                  _statCard(
                    title: 'Pending Requests',
                    value: '08',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFD88716),
                    backgroundColor: const Color(0xFFFFF3DE),
                    onTap: () => _navigateTo(3),
                  ),
                  _statCard(
                    title: 'Maintenance',
                    value: '05',
                    icon: Icons.build_circle_outlined,
                    color: const Color(0xFF8A52CF),
                    backgroundColor: const Color(0xFFF2EAFE),
                    onTap: () => _navigateTo(4),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          _sectionHeading(
            'Quick Actions',
            'Go directly to what you need',
            icon: Icons.bolt_rounded,
          ),

          const SizedBox(height: 15),

          LayoutBuilder(
            builder: (context, constraints) {
              final actions = [
                _actionData(
                  Icons.groups_rounded,
                  'Employees',
                  'View your team',
                  const Color(0xFF3B5BDB),
                  1,
                ),
                _actionData(
                  Icons.devices_rounded,
                  'Assets',
                  'Explore department assets',
                  const Color(0xFF078A71),
                  2,
                ),
                _actionData(
                  Icons.assignment_rounded,
                  'Requests',
                  'Review employee requests',
                  const Color(0xFFD88716),
                  3,
                ),
                _actionData(
                  Icons.handyman_rounded,
                  'Maintenance',
                  'Check repair status',
                  const Color(0xFF8A52CF),
                  4,
                ),
                _actionData(
                  Icons.bar_chart_rounded,
                  'Reports',
                  'View department reports',
                  const Color(0xFFDB5875),
                  5,
                ),
              ];

              if (constraints.maxWidth >= 650) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: actions.map((item) {
                    return SizedBox(
                      width: (constraints.maxWidth - 24) / 3,
                      child: _quickAction(item),
                    );
                  }).toList(),
                );
              }

              return Column(
                children: actions.map(_quickAction).toList(),
              );
            },
          ),

          const SizedBox(height: 28),

          _sectionHeading(
            'Recent Activity',
            'Latest department updates',
            icon: Icons.history_rounded,
          ),

          const SizedBox(height: 15),

          _recentActivity(),

          const SizedBox(height: 12),

          Center(
            child: Text(
              'Orgaflow • Department Portal',
              style: TextStyle(
                color: Colors.blueGrey.shade300,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DEPARTMENT BANNER

  Widget _departmentBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryDark, primary, Color(0xFF7187F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -22,
            child: Icon(
              Icons.account_tree_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'DEPARTMENT HEAD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Your Department',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Department Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage people, assets and requests\nfrom one place.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _navigateTo(1),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                ),
                label: const Text('Explore Department'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SECTION HEADING

  Widget _sectionHeading(
    String title,
    String subtitle, {
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, color: primary, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STATISTICS CARD

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 14,
                    color: color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // QUICK ACTION DATA

  Map<String, dynamic> _actionData(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    int index,
  ) {
    return {
      'icon': icon,
      'title': title,
      'subtitle': subtitle,
      'color': color,
      'index': index,
    };
  }

  Widget _quickAction(Map<String, dynamic> item) {
    final icon = item['icon'] as IconData;
    final title = item['title'] as String;
    final subtitle = item['subtitle'] as String;
    final color = item['color'] as Color;
    final index = item['index'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => _navigateTo(index),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 23),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // RECENT ACTIVITY

  Widget _recentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _activityItem(
            icon: Icons.assignment_rounded,
            color: const Color(0xFFD88716),
            title: 'New asset request',
            subtitle: 'An employee requested a laptop',
            time: '10 min ago',
            isLast: false,
          ),
          _activityItem(
            icon: Icons.build_rounded,
            color: const Color(0xFF8A52CF),
            title: 'Maintenance update',
            subtitle: 'Dell Latitude marked for repair',
            time: '1 hour ago',
            isLast: false,
          ),
          _activityItem(
            icon: Icons.devices_rounded,
            color: const Color(0xFF078A71),
            title: 'Asset assigned',
            subtitle: 'Samsung Galaxy assigned to employee',
            time: '2 hours ago',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LOGOUT

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'Logout?',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from Orgaflow?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}