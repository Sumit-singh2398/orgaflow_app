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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      surfaceTintColor: Colors.white,
      titleSpacing: 0,
      title: Text(
        _titles[_selectedIndex],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
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
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _openProfile,
            child: const CircleAvatar(
              radius: 18,
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

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                    radius: 27,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_tree_rounded,
                      size: 29,
                      color: primary,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Orgaflow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
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
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _drawerItem(
                    Icons.space_dashboard_rounded,
                    'Dashboard',
                    0,
                  ),
                  _drawerItem(Icons.groups_rounded, 'Employees', 1),
                  _drawerItem(Icons.devices_rounded, 'Department Assets', 2),
                  _drawerItem(Icons.assignment_rounded, 'Requests', 3),
                  _drawerItem(Icons.handyman_rounded, 'Maintenance', 4),
                  _drawerItem(Icons.analytics_rounded, 'Reports', 5),
                  const Divider(height: 28),
                  ListTile(
                    leading: const Icon(Icons.notifications_none_rounded),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.1,
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
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
            ? const Icon(Icons.chevron_right_rounded, color: primary)
            : null,
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

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

  // RESPONSIVE DASHBOARD

  Widget _dashboardPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width < 360 ? 12.0 : 18.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back! 👋',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                      letterSpacing: -0.5,
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
                  const SizedBox(height: 22),
                  _departmentBanner(),
                  const SizedBox(height: 28),
                  _sectionHeading(
                    'Department Overview',
                    'A quick look at your department',
                    icon: Icons.insights_rounded,
                  ),
                  const SizedBox(height: 15),
                  _buildStatsGrid(width),
                  const SizedBox(height: 28),
                  _sectionHeading(
                    'Quick Actions',
                    'Go directly to what you need',
                    icon: Icons.bolt_rounded,
                  ),
                  const SizedBox(height: 15),
                  _buildQuickActions(width),
                  const SizedBox(height: 28),
                  _sectionHeading(
                    'Recent Activity',
                    'Latest department updates',
                    icon: Icons.history_rounded,
                  ),
                  const SizedBox(height: 15),
                  _recentActivity(),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Orgaflow • Department Portal',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(double width) {
    final columns = width >= 900
        ? 4
        : width >= 540
            ? 2
            : 2;

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      // More vertical room on small phones prevents text overflow.
      childAspectRatio: width < 360
          ? 1.02
          : width < 540
              ? 1.14
              : width < 900
                  ? 1.45
                  : 1.30,
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
  }

  Widget _departmentBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryDark, primary, Color(0xFF7187F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                right: 0,
                top: 5,
                child: IgnorePointer(
                  child: Icon(
                    Icons.account_tree_rounded,
                    size: constraints.maxWidth < 350 ? 64 : 95,
                    color: Colors.white.withValues(alpha: 0.09),
                  ),
                ),
              ),
              Padding(
                // Reserve room for the decorative icon.
                padding: EdgeInsets.only(
                  right: constraints.maxWidth < 350 ? 0 : 42,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          Text(
                            'DEPARTMENT HEAD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
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
                    const SizedBox(height: 6),
                    const Text(
                      'Department Name',
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage people, assets and requests from one place.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          horizontal: 13,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeading(
    String title,
    String subtitle, {
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                softWrap: true,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 21),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 13,
                        color: color,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(double width) {
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

    if (width >= 700) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: actions.map((item) {
          return SizedBox(
            width: (width - 24) / 3,
            child: _quickAction(item),
          );
        }).toList(),
      );
    }

    return Column(
      children: actions.map(_quickAction).toList(),
    );
  }

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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        softWrap: true,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        softWrap: true,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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

  Widget _recentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  softWrap: true,
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

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Logout?',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
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
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
